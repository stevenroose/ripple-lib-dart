library ripplelib.remote.io;

import "dart:async";
import "dart:io";

import "package:logging/logging.dart";

import "json.dart";
import "remote.dart";
export "remote.dart";

class ServerRemote extends Remote {

  static void _log(String message, [Level level = Level.INFO]) => Remote.log.log(level, message);

  final String url;
  WebSocket _ws;

  ServerRemote(String this.url) : super();

  @override
  Future<Remote> connect() {
    WebSocket.connect(url).then((socket) {
      _log("Connected to websocket at $url");
      socket.listen((message) {
        _log("Message received: $message", Level.FINER);
        handleMessage(message);
      });
      _ws = socket;
      emit(Remote.OnConnected, this);
    });
    return once(Remote.OnConnected);
  }

  @override
  void disconnect() {
    _log("Disconnecting from websocket at $url");
    emit(Remote.OnDisconnected, null);
    _ws.close();
  }

  @override
  bool get isConnected => _ws.readyState == WebSocket.OPEN;

  @override
  void sendMessage(dynamic/*String|RippleJsonMessage|RippleSerializable*/ message) {
    String messageString;
    if(message is String) {
      messageString = message;
      message = const RippleJsonCodec().decode(messageString);
    } else {
      messageString = const RippleJsonCodec().encode(message);
    }
    this.emit(Remote.OnSendMessage, message);
    _ws.add(messageString);
    _log("Message sent: $messageString", Level.FINER);
  }

}