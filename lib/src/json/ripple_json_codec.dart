part of ripplelib.json;

class RippleJsonCodec extends JsonCodec {

  static final JsonEncoder _encoder = new RippleJsonEncoder();
  static final JsonDecoder _decoder = new RippleJsonDecoder();

  const RippleJsonCodec();

  @override
  JsonEncoder get encoder => _encoder;

  @override
  JsonDecoder get decoder => _decoder;
}

class RippleJsonEncoder extends JsonEncoder {

  static dynamic _toEncodable(dynamic object) {
//    print("Encoding object of type ${object.runtimeType}");
    if(object is RippleSerializable)
      return object.toJson();
    if(object is DateTime)
      return RippleUtils.getSecondsSinceRippleEpoch(object);
    if(object is Decimal)
      return object.toString();
    if(object is Hash)
      return (object as Hash).toHex();
    return object.toJson();
  }

  RippleJsonEncoder() : super(_toEncodable);
  RippleJsonEncoder.withIndent(String indent) : super.withIndent(indent, _toEncodable);
}

class RippleJsonDecoder extends JsonDecoder {

  static final Map<String, Function> _revivers = {
      "account":                (j) => new AccountID.fromJson(j),
      "account_hash":           (j) => new Hash256(j),
      "Account":                (j) => new AccountID.fromJson(j),
      "AffectedNodes":          (j) => _convertObjectList(j, _mapObjectByFirstKey),
      "alternatives":           (j) => _convertObjectList(j, (j) => new PathFindStatus.fromJson(j)),
      "Amount":                 (j) => new Amount.fromJson(j),
      "amount":                 (j) => Decimal.parse(j),
      "balance":                (j) => Decimal.parse(j),
      "Balance":                (j) => new Amount.fromJson(j),
      "close_time":             (j) => RippleUtils.dateTimeFromSecondsSinceRippleEpoch(j),
      "CreatedNode":            (j) => new CreatedNode.fromJson(j),
      "currency":               (j) => new Currency.fromJson(j),
      "DeletedNode":            (j) => new DeletedNode.fromJson(j),
      "destination_account":    (j) => new AccountID.fromJson(j),
      "destination_currencies": (j) => _convertObjectList(j, (j) => new Currency.fromJson(j)),
      "Destination":            (j) => new AccountID.fromJson(j),
      "EmailHash":              (j) => new Hash128(j),
      "engine_result":          (j) => EngineResult.fromName(j),
      "Expiration":             (j) => RippleUtils.dateTimeFromSecondsSinceRippleEpoch(j),
      "Fee":                    (j) => new Amount.fromJson(j),
      "hash":                   (j) => j.length == 64 ? new Hash256(j) : j,
      "issuer":                 (j) => new AccountID.fromJson(j),
      "LedgerEntryType":        (j) => LedgerEntryType.fromJsonKey(j),
      "LedgerIndex":            (j) => new Hash256(j),
      "ledger_hash":            (j) => new Hash256(j),
      "Memo":                   (j) => new Memo.fromJson(j),
      "Memos":                  (j) => _convertObjectList(j, _mapObjectByFirstKey),
      "meta":                   (j) => new TransactionMeta.fromJson(j),
      "metaData":               (j) => new TransactionMeta.fromJson(j),
      "ModifiedNode":           (j) => new ModifiedNode.fromJson(j),
      "parent_hash":            (j) => new Hash256(j),
      "paths_computed":         (j) => _convertObjectList(j, (j) => new Path.fromJson(j)),
      "PreviousTxnID":          (j) => new Hash256(j),
      "receive_currencies":     (j) => _convertObjectList(j, (j) => new Currency.fromJson(j)),
      "send_currencies":        (j) => _convertObjectList(j, (j) => new Currency.fromJson(j)),
      "SigningPubKey":          (j) => CryptoUtils.hexToBytes(j),
      "source_amount":         (j) => new Amount.fromJson(j),
      "taker_pays":             (j) => new Amount.fromJson(j),
      "taker_gets":             (j) => new Amount.fromJson(j),
      "TakerPays":              (j) => new Amount.fromJson(j),
      "TakerGets":              (j) => new Amount.fromJson(j),
      "totalCoins":             (j) => Decimal.parse(j),
      "total_coins":            (j) => Decimal.parse(j),
      "transaction":            (j) => new Transaction.fromJson(j),
      "transaction_hash":       (j) => new Hash256(j),
      "TransactionType":        (j) => TransactionType.fromJsonValue(j),
      "tx":                     (j) => new Transaction.fromJson(j),
  };

  static dynamic _reviver(Object key, Object value) {
    if (_revivers.containsKey(key)) {
//      print("Reviving object with key $key");
      return _revivers[key](value);
    }
    if(value is Map)
      return new RippleJsonObject.fromMap(value, false);
    return value;
  }

  static List _convertObjectList(List objectList, Function mapper) =>
      new List.from(objectList.map(mapper));

  static Function _mapObjectByFirstKey = (Map object) => object[object.keys.first];

  RippleJsonDecoder() : super(_reviver);
}