library ripplelib.client.html;

import "dart:async";
import "dart:html";

import "package:logging/logging.dart";

import "json.dart";
import 'client.dart';
export 'client.dart';

class RemoteImpl extends Remote {

  static void _log(String message, [Level level = Level.INFO]) => Remote.log.log(level, message);

  final String _uri;
  WebSocket _ws;

  RemoteImpl(String this._uri, [bool trusted = false]) : super(trusted);

  Uri get uri => Uri.parse(_uri);

  @override
  Future<Remote> connect() {
    _ws = new WebSocket(_uri);
    _log("Connected to websocket at $_uri");
    _ws.onMessage.listen((MessageEvent message) {
      _log("Message received: $message", Level.FINER);
      handleMessage(message.toString());
    });
    emit(Remote.OnConnected, this);
    return new Future.value(this);
  }

  @override
  void disconnect() {
    _log("Disconnecting from websocket at $_uri");
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
    _ws.send(messageString);
    _log("Message sent: $messageString", Level.FINER);
  }

}