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
    if(object is RippleSerializable)
      return object.toJson();
    if(object is RippleDateTime)
      return object.secondsSinceRippleEpoch;
    if(object is DateTime)
      return new RippleDateTime.fromDateTime(object).secondsSinceRippleEpoch;
    if(object is Decimal)
      return object.toString();
    if(object is Hash)
      return object.toHex();
    return object.toJson();
  }

  RippleJsonEncoder() : super(_toEncodable);
  RippleJsonEncoder.withIndent(String indent) : super.withIndent(indent, _toEncodable);
}

class RippleJsonDecoder extends JsonDecoder {

  static final Map<String, Function> _revivers = {
      "account":                (j) => new AccountID.fromJson(j),
      "account_data":           (j) => new AccountRootEntry.fromJson(j),
      "account_hash":           (j) => new Hash256(j),
      "Account":                (j) => new AccountID.fromJson(j),
      "AffectedNodes":          (j) => _convertObjectList(j, _mapObjectByFirstKey),
      "alternatives":           (j) => _convertObjectList(j, (j) => new PathFindStatus.fromJson(j)),
      "Amount":                 (j) => new Amount.fromJson(j),
      "amount":                 (j) => Decimal.parse(j),
      "asks":                   (j) => _convertObjectList(j, (j) => new OfferEntry.fromJson(j)),
      "balance":                (j) => Decimal.parse(j),
      "Balance":                (j) => new Amount.fromJson(j),
      "bids":                   (j) => _convertObjectList(j, (j) => new OfferEntry.fromJson(j)),
      "close_time":             (j) => new RippleDateTime.fromSecondsSinceRippleEpoch(j),
      "CreatedNode":            (j) => new CreatedNode.fromJson(j),
      "currency":               (j) => new Currency.fromJson(j),
      "DeletedNode":            (j) => new DeletedNode.fromJson(j),
      "destination_account":    (j) => new AccountID.fromJson(j),
      "destination_currencies": (j) => _convertObjectList(j, (j) => new Currency.fromJson(j)),
      "Destination":            (j) => new AccountID.fromJson(j),
      "EmailHash":              (j) => new Hash128(j),
      "engine_result":          (j) => EngineResult.fromName(j),
      "Expiration":             (j) => new RippleDateTime.fromSecondsSinceRippleEpoch(j),
      "Fee":                    (j) => new Amount.fromJson(j),
      "Flags":                  (j) => new Flags(j),
      "hash":                   (j) => j.length == 64 ? new Hash256(j) : j,
      "issuer":                 (j) => new AccountID.fromJson(j),
      "LedgerEntryType":        (j) => LedgerEntryType.fromJsonKey(j),
      "LedgerIndex":            (j) => new Hash256(j),
      "ledger_hash":            (j) => new Hash256(j),
      "ledger_time":            (j) => new RippleDateTime.fromSecondsSinceRippleEpoch(j),
      "limit":                  (j) => (j is int ? j : Decimal.parse(j)), // limit is both in trust lines as some responses
      "limit_peer":             (j) => Decimal.parse(j),
      "lines":                  (j) => _convertObjectList(j, (j) => new TrustLine.fromJson(j)),
      "Memo":                   (j) => new Memo.fromJson(j),
      "Memos":                  (j) => _convertObjectList(j, _mapObjectByFirstKey),
      "meta":                   (j) => new TransactionMeta.fromJson(j),
      "metaData":               (j) => new TransactionMeta.fromJson(j),
      "ModifiedNode":           (j) => new ModifiedNode.fromJson(j),
      "offers":                 (j) => _convertObjectList(j, (j) => new Offer.fromJson(j)),
      "parent_hash":            (j) => new Hash256(j),
      "paths_computed":         (j) => _convertObjectList(j, (j) => new Path.fromJson(j)),
      "PreviousTxnID":          (j) => new Hash256(j),
      "pubkey_node":            (j) => CryptoUtils.hexToBytes(j),
      "receive_currencies":     (j) => _convertObjectList(j, (j) => new Currency.fromJson(j)),
      "send_currencies":        (j) => _convertObjectList(j, (j) => new Currency.fromJson(j)),
      "server_state":           (j) => ServerState.fromJsonValue(j),
      "SigningPubKey":          (j) => CryptoUtils.hexToBytes(j),
      "source_amount":          (j) => new Amount.fromJson(j),
      "taker_pays":             (j) => new Amount.fromJson(j),
      "taker_gets":             (j) => new Amount.fromJson(j),
      "TakerPays":              (j) => new Amount.fromJson(j),
      "TakerGets":              (j) => new Amount.fromJson(j),
      "totalCoins":             (j) => Decimal.parse(j),
      "total_coins":            (j) => Decimal.parse(j),
      "transaction":            (j) => j is String ? new Hash256(j) : new Transaction.fromJson(j),
      "transaction_hash":       (j) => new Hash256(j),
      "TransactionType":        (j) => TransactionType.fromJsonValue(j),
      "tx":                     (j) => new Transaction.fromJson(j),
      "tx_json":                (j) => new Transaction.fromJson(j)
  };

  static dynamic _reviver(Object key, Object value) {
    if (_revivers.containsKey(key)) {
      return _revivers[key](value);
    }
    if(value is Map)
      return new RippleJsonObject.fromMap(value, false);
    return value;
  }

  static List _convertObjectList(List objectList, Function mapper) =>
      new List.from(objectList.map(mapper));

  static Object _mapObjectByFirstKey(Map object) => object[object.keys.first];

  RippleJsonDecoder() : super(_reviver);
}
