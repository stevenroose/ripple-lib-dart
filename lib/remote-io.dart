library ripplelib.io.remote;

import "dart:async";
import "dart:io";

import "remote.dart";

class ServerRemote extends Remote {

  final String url;
  WebSocket _ws;

  ServerRemote(String this.url) : super();

  @override
  Future<Remote> connect() {
    WebSocket.connect(url).then((socket) {
      socket.listen((message) {
        print(message);
        handleMessage(const RippleJsonCodec().decode(message));
      });
      _ws = socket;
      emit(Remote.OnConnected, this);
    });
    return once(Remote.OnConnected);
  }

  @override
  void disconnect() {
    this.emit(Remote.OnDisconnected, null);
    _ws.close();
  }

  @override
  bool get isConnected => _ws.readyState == WebSocket.OPEN;

  @override
  void sendMessage(dynamic message) {
    if(message is String) {
      this.emit(Remote.OnSendMessage, const RippleJsonCodec().decode(message));
      _ws.add(message);
    } else {
      this.emit(Remote.OnSendMessage, message);
      _ws.add(const RippleJsonCodec().encode(message));
    }
  }

}