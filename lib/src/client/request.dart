part of ripplelib.client;


class Request extends RippleJsonObject {

  final Remote remote;
  final Command command;
  final int id;
  Response response;

  Completer _completer;
  Future<Response> get onResponse => _completer.future;

  Request(Remote this.remote, Command this.command, int this.id) {
    this["command"] = command.jsonValue;
    this["id"] = id;
    _completer = new Completer();
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
    if(response.successful)
      _completer.complete(response);
    else
      _completer.completeError(response);
  }

}