part of ripplelib.remote;


class Request extends RippleJsonObject with Events {

  static final EventType OnResponse = new EventType<Response>();
  static final EventType OnSuccess  = new EventType<Response>();
  static final EventType OnError    = new EventType<Response>();

  Stream<Response> get onResponse => on(OnResponse);
  Stream<Response> get onSuccess  => on(OnSuccess);
  Stream<Response> get onError    => on(OnError);

  final Remote remote;
  final Command command;
  final int id;
  Response response;

  Request(Remote this.remote, Command this.command, int this.id) {
    this["command"] = command.jsonValue;
    this["id"] = id;
  }

  /**
   * Copies this request with a new request ID from the remote.
   */
  Request copy() => remote.newRequest(command)..updateJson(this);

  /**
   * Update all fields from the given JSON object, except the "id" and "command" fields.
   */
  void updateJson(JsonObject json) {
    json.forEach((k, v) {
      if(k != "id" && k != "command") {
        this[k] = v;
      }
    });
  }

  Future<Response> request() => remote.request(this);

  void _handleResponse(JsonObject message) {
    response = new Response(this, message);
    emit(OnResponse, response);
    emit(response.successful ? OnSuccess : OnError, response);
  }

}