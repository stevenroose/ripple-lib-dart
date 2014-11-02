part of ripplelib.remote;

@proxy
class PathFindStream implements Stream<Alternative> {

  final Remote _remote;
  final StreamController<Alternative> _streamController = new StreamController.broadcast();

  PathFindStream._withRequest(Request pathFindRequest) : _remote = pathFindRequest.remote {
    _remote.on(Remote.OnPathFindStatus).where((r) => r.id == pathFindRequest.id).listen(_handleFollowUp);
    pathFindRequest.request().then(_handleResponse);
  }

  /**
   * Request a status on the pathfinding process.
   *
   * The status will be visible in the stream.
   */
  void askStatus() {
    Request req = _remote.newRequest(Command.PATH_FIND);
    req.subcommand = "status";
    req.request().then(_handleResponse);
  }

  /**
   * Close the path find stream.
   */
  void close() {
    Request req = _remote.newRequest(Command.PATH_FIND);
    req.subcommand = "close";
    req.request().then(_handleResponse);;
  }

  void _handleResponse(Response response) {
    if(!response.successful)
      _streamController.addError(response);
    _streamAll(response.result.alternatives);
  }

  void _handleFollowUp(JsonObject message) =>
      _streamAll(message.alternatives);

  void _streamAll(Iterable<Alternative> alts) => alts.forEach((alt) => _streamController.add(alt));

  @override
  noSuchMethod(Invocation inv) => reflect(_streamController.stream).delegate(inv);
}

class Alternative {
  List<Path> paths;
  Amount sourceAmount;

  toJson() => {
      "paths_computed": paths,
      "source_amount": sourceAmount
  };
  Alternative.fromJson(dynamic json) {
    paths = json["paths_computed"];
    sourceAmount = json["source_amount"];
  }
}