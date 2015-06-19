library ripplelib.browser_remote;


import "dart:async";

import "package:websockets/browser_websockets.dart";

import "remote.dart";


class BrowserRemote extends Remote {


  static Future<Remote> connect(dynamic url,  {bool isTrusted: false}) async {
    WebSocket ws = await BrowserWebSocket.connect(url);
    Remote.logger.info("Connected to websocket at $url");
    return new BrowserRemote.withExistingWebSocket(ws, isTrusted: isTrusted);
  }

}