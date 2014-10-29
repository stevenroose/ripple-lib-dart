part of ripplelib.core;

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
      return (object as DateTime).millisecondsSinceEpoch;
    if(object is Decimal)
      return object.toString();
    if(object is Hash)
      return (object as Hash).toHex();
    return object.toJson();
  }

  RippleJsonEncoder() : super(_toEncodable);
}

class RippleJsonDecoder extends JsonDecoder {

  static final Map<String, Function> _revivers = {
      "Account":         (j) => new Account.fromJson(j),
      "account":         (j) => new Account.fromJson(j),
      "AffectedNodes":   (j) => _convertObjectList(j),
      "Amount":          (j) => new Amount.fromJson(j),
      "amount":          (j) => Decimal.parse(j),
      "Balance":         (j) => new Amount.fromJson(j),
      "CreatedNode":     (j) => new CreatedNode.fromJson(j),
      "currency":        (j) => new Currency.fromJson(j),
      "DeletedNode":     (j) => new DeletedNode.fromJson(j),
      "Destination":     (j) => new Account.fromJson(j),
      "EmailHash":       (j) => new Hash128(j),
      "engine_result":   (j) => EngineResult.fromName(j),
      "Expiration":      (j) => new DateTime.fromMillisecondsSinceEpoch(j),
      "Fee":             (j) => new Amount.fromJson(j),
      "hash":            (j) => j.length == 64 ? new Hash256(j) : j,
      "issuer":          (j) => new Account.fromJson(j),
      "LedgerEntryType": (j) => LedgerEntryType.fromJsonKey(j),
      "LedgerIndex":     (j) => new Hash256(j),
      "ledger_hash":     (j) => new Hash256(j),
      "Memo":            (j) => new Memo.fromJson(j),
      "Memos":           (j) => _convertObjectList(j),
      "meta":            (j) => new TransactionMeta.fromJson(j),
      "metaData":        (j) => new TransactionMeta.fromJson(j),
      "ModifiedNode":    (j) => new ModifiedNode.fromJson(j),
      "PreviousTxnID":   (j) => new Hash256(j),
      "SigningPubKey":   (j) => CryptoUtils.hexToBytes(j),
      "TakerPays":       (j) => new Amount.fromJson(j),
      "TakerGets":       (j) => new Amount.fromJson(j),
      "transaction":     (j) => new Transaction.fromJson(j),
      "TransactionType": (j) => TransactionType.fromJsonValue(j),
  };

  static dynamic _reviver(Object key, Object value) {
    if (_revivers.containsKey(key)) {
//      print("Reviving object with key $key");
      return _revivers[key](value);
    }
    if(value is Map)
      return new JsonObject.fromMap(value, false);
    return value;
  }

  static List _convertObjectList(List objectList) =>
      new List.from(objectList.map((Map object) => object[object.keys.first]));

  RippleJsonDecoder() : super(_reviver);
}