part of ripplelib.client;


class ServerInfo {

  Remote _remote;

  String _buildVersion;
  String _completeLedgers;
  String _hostId;
  int _ioLatency;
  Map _lastClose;
  int _loadBase = 256;
  int _loadFactor;
  int _peers;
  Uint8List _pubKey;
  ServerState _serverState;

  LedgerInfo _latestLedger;

  Amount _baseFee;
  int _refFee;
  Amount _baseReserve;
  Amount _incReserve;

  ServerInfo._(this._remote);

  String get buildVersion => _buildVersion;
  String get completeLedgers => _completeLedgers;
  String get hostId => _hostId;
  int get ioLatency => _ioLatency;
  Map get lastClose => _lastClose;

  /* LOAD */
  int get loadFactor => _loadFactor;
  int get loadBase => _loadBase;

  int get peers => _peers;
  Uint8List get pubKey => _pubKey;
  ServerState get serverState => _serverState;

  LedgerInfo get latestLedger => _latestLedger;

  Amount get baseFee => _baseFee;
  int get refFee => _refFee;
  Amount get baseReserve => _baseReserve;
  Amount get incReserve => _incReserve;

  /* FEE CALCULATION */

  double get _feeUnitDrops {
    double fee = 1.0;
    fee *= baseFee.xrpDrops.intValue() / refFee;
    fee *= loadFactor / loadBase;
    fee *= _remote.feeCushion;
    return fee;
  }

  Amount computeTxFee(Transaction tx) {
    var fee = _feeUnitDrops * tx.feeUnits;
    return new Amount.drops(fee.ceil());
  }

  /* UPDATE */

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
    _latestLedger = new LedgerInfo._fromServerInfoJson(json["validated_ledger"]);
    _baseFee = new Amount.XRP(json["base_fee_xrp"]);
    _baseReserve = new Amount.XRP(json["reserve_base_xrp"]);
    _incReserve = new Amount.XRP(json["reserve_inc_xrp"]);
  }

  void _updateFromServerStatus(JsonObject json) {
    _loadBase = _or(json["load_base"], _loadBase);
    _loadFactor = _or(json["load_factor"], _loadFactor);
    _serverState = _or(ServerState.fromJsonValue(json["server_status"]), _serverState);
  }

  void _updateFromLedgerClosed(JsonObject json) {
    _latestLedger = new LedgerInfo._fromLedgerClosedJson(json);
    _baseFee = new Amount.drops(json["fee_base"]);
    _refFee = json["fee_ref"];
    _baseReserve = new Amount.drops(json["reserve_base"]);
    _incReserve = new Amount.drops(json["reserve_inc"]);
    _completeLedgers = _or(json["validated_ledgers"], _completeLedgers);
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