part of ripplelib.client;

class Response extends RippleJsonObject {

  final Request request;

  Response(Request this.request, JsonObject message) : super.fromMap(message, false);

  bool get successful => this.status == "success";

  JsonObject get result => this["result"];

  String get error => this["error"];
}