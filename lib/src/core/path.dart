part of ripplelib.core;

@proxy
class PathSet implements List<Path>, RippleSerialization {
  static const int _PATH_SEPARATOR_BYTE = 0xFF;
  static const int _PATHSET_END_BYTE = 0x00;

  List<Path> _paths;

  PathSet(Iterable<Path> paths) : _paths = paths is List ? paths : new List.from(paths);

  PathSet.fromJson(dynamic json) {
    Iterable pathList = json as Iterable;
    _paths = new List.from(pathList.map((path) => new Path.fromJson(path)));
  }

  @override
  toJson() => _paths;

  @override
  void toByteSink(ByteSink sink) {
    int n = 0;
    for(Path path in _paths) {
      if(n++ != 0)
        sink.add(_PATH_SEPARATOR_BYTE);
      for(Hop hop in path) {
        sink.add(hop.type);
        if(hop.hasAccount)  sink.add(hop.account.bytes);
        if(hop.hasCurrency) sink.add(hop.currency.bytes);
        if(hop.hasIssuer)   sink.add(hop.issuer.bytes);
      }
    }
    sink.add(_PATHSET_END_BYTE);
  }

  @override
  noSuchMethod(Invocation inv) => reflect(_paths).delegate(inv);
}

@proxy
class Path implements List<Hop> {
  List<Hop> _hops;

  Path.fromJson(dynamic json) {
    Iterable hopList = json as Iterable;
    _hops = new List.from(hopList.map((hop) => new Hop.fromJson(hop)));
  }

  toJson() => _hops;

  @override
  noSuchMethod(Invocation inv) => reflect(_hops).delegate(inv);
}

class Hop {
  // type masks
  static const int TYPE_ACCOUNT  = 0x01;
  static const int TYPE_CURRENCY = 0x10;
  static const int TYPE_ISSUER   = 0x20;
  static const int TYPE_ACCOUNT_CURRENCY_ISSUER = TYPE_CURRENCY | TYPE_ACCOUNT | TYPE_ISSUER;
  static const int TYPE_ACCOUNT_CURRENCY        = TYPE_CURRENCY | TYPE_ACCOUNT;
  static const int VALID_TYPE_MASK              =  ~(TYPE_ACCOUNT | TYPE_CURRENCY | TYPE_ISSUER);

  AccountID account;
  AccountID issuer;
  Currency currency;
  int _type;

  Hop(AccountID this.account, AccountID this.issuer, Currency this.currency);

  bool get hasAccount  => account != null;
  bool get hasIssuer   => issuer != null;
  bool get hasCurrency => currency != null;

  int get type {
    if(_type == null)
      _type = _serializeType();
    return _type;
  }

  int _serializeType() {
    int type = 0;
    if (hasAccount)  type |= TYPE_ACCOUNT;
    if (hasCurrency) type |= TYPE_CURRENCY;
    if (hasIssuer)   type |= TYPE_ISSUER;
    return type;
  }

  Hop.fromJson(dynamic json) {
    Map jsonMap = json as Map;
    account  = jsonMap["account"];
    issuer   = jsonMap["issuer"];
    currency = jsonMap["currency"];
    _type    = jsonMap["type"];
  }

  toJson() {
    Map jsonMap = new Map();
    jsonMap["type"] = type;
    if(hasAccount)  jsonMap["account"] = account;
    if(hasIssuer)   jsonMap["issuer"] = issuer;
    if(hasCurrency) jsonMap["currency"] = currency;
    return jsonMap;
  }
}