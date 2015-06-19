part of ripplelib.remote;


class PathFindStatus {
  List<Path> paths;
  Amount sourceAmount;

  PathFindStatus.fromJson(dynamic json) {
    paths = json["paths_computed"];
    sourceAmount = json["source_amount"];
  }

  toJson() => {
    "paths_computed": paths,
    "source_amount": sourceAmount
  };
}

class PathFindStream implements Stream<PathFindStatus> {

  final Remote _remote;
  final StreamController<PathFindStatus> _streamController = new StreamController.broadcast();

  StreamSubscription _statusSub;

  factory PathFindStream(Remote remote, AccountID sourceAccount, AccountID destinationAccount, Amount amount,
                 {PathSet paths, List<AccountID> bridges}) {
    return new PathFindStream._withRequest(
        remote.makePathFindRequest(sourceAccount, destinationAccount, amount, paths: paths, bridges: bridges));
  }

  PathFindStream._withRequest(Request pathFindRequest) : _remote = pathFindRequest.remote {
    _statusSub = _remote.onPathFindStatus.where((r) => r.id == pathFindRequest.id).listen(_handleFollowUp);
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
    _streamController.close();
    if(_statusSub != null)
      _statusSub.cancel();
    Request req = _remote.newRequest(Command.PATH_FIND);
    req.subcommand = "close";
    req.request().then(_handleResponse);
  }

  void _handleResponse(Response response) {
    if(!response.successful)
      _streamController.addError(response);
    _streamAll(response.result.alternatives);
  }

  void _handleFollowUp(JsonObject message) => _streamAll(message.alternatives);

  void _streamAll(Iterable<PathFindStatus> alts) => alts.forEach((alt) => _streamController.add(alt));

  @override
  noSuchMethod(Invocation inv) => reflect(_streamController.stream).delegate(inv);
}