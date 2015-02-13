part of ripplelib.remote;


class ServerInfo {

  String _buildVersion;
  String _completeLedgers;
  String _hostId;
  int _ioLatency;
  Map _lastClose;
  int _loadFactor;
  int _peers;
  Uint8List _pubKey;
  ServerState _serverState;

  LedgerInfo _latestLedger;

  int _feeBase;
  int _feeRef;
  int _reserveBase;
  int _reserveInc;

  ServerInfo._();

  String get buildVersion => _buildVersion;
  String get completeLedgers => _completeLedgers;
  String get hostId => _hostId;
  int get ioLatency => _ioLatency;
  Map get lastClose => _lastClose;
  int get loadFactor => _loadFactor;
  int get peers => _peers;
  Uint8List get pubKey => _pubKey;
  ServerState get serverState => _serverState;

  LedgerInfo get latestLedger => _latestLedger;

  int get feeBase => _feeBase;
  int get feeRef => _feeRef;
  int get reserveBase => _reserveBase;
  int get reserveInc => _reserveInc;

  void _updateFromServerInfo(JsonObject json) {
    _buildVersion = _or(json["build_version"], _buildVersion);
    _completeLedgers = _or(json["complete_ledgers"], _completeLedgers);
    _hostId = _or(json["hostid"], _hostId);
    _ioLatency = _or(json["io_latency"], _ioLatency);
    _lastClose = _or(json["last_close"], _lastClose);
    _loadFactor = _or(json["load_factor"], _loadFactor);
    _peers = _or(json["peers"], _peers);
    _pubKey = _or(json["pubkey_node"], _pubKey);
    _serverState = _or(json["server_state"], _serverState);
  }

  _or(value, ifNull) => value != null ? value : ifNull;

}

class ServerState extends Enum {

  static const ServerState DISCONNECTED = const ServerState._("disconnected");
  static const ServerState CONNECTED    = const ServerState._("connected");
  static const ServerState SYNCING      = const ServerState._("syncing");
  static const ServerState TRACKING     = const ServerState._("tracking");
  static const ServerState FULL         = const ServerState._("full");
  static const ServerState VALIDATING   = const ServerState._("validating");
  static const ServerState PROPOSING    = const ServerState._("proposing");

  final String jsonValue;

  const ServerState._(String this.jsonValue);

  static ServerState fromJsonValue(String json) => values.firstWhere((c) => c.jsonValue == json);

  // required by Enum
  static ServerState valueOf(String e) => Enum.valueOf(ServerState, e);
  static List<ServerState> get values => Enum.values(ServerState);


}