part of ripplelib.remote;

class Request extends RippleJsonObject with Events {

  static final EventType OnResponse = new EventType<Response>();
  static final EventType OnSuccess  = new EventType<Response>();
  static final EventType OnError    = new EventType<Response>();

  Stream<Response> get onResponse => on(OnResponse);
  Stream<Response> get onSuccess  => on(OnSuccess);
  Stream<Response> get onError    => on(OnError);

  static const Duration REQUEST_TIMEOUT = const Duration(minutes: 1);

  final Remote remote;
  final Command command;
  final int id;
  Response response;

  Request(Remote this.remote, Command this.command, int this.id) {
    this["command"] = command.jsonValue;
    this["id"] = id;
  }

  void updateJson(JsonObject json) {
    json.forEach((k, v) {
      this[k] = v;
    });
  }

  Future<Response> request() => remote.request(this);

  void handleResponse(JsonObject message) {
    response = new Response(this, message);
    emit(OnResponse, response);
    emit(response.successful ? OnSuccess : OnError, response);
  }

}