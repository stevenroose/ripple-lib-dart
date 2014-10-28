part of ripplelib.remote;

class Response extends JsonObject {

  final Request request;

  Response(Request this.request, JsonObject message) : super.fromMap(message, false);

  bool get succeeded => this.status == "success";

  EngineResult get engineResult => this.result.engine_result;
}