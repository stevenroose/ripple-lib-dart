part of ripplelib.core;


abstract class Transaction extends RippleSerializedObject {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = {
      Field.TransactionType:    FieldRequirement.REQUIRED,
      Field.Account:            FieldRequirement.REQUIRED,
      Field.Sequence:           FieldRequirement.REQUIRED,
      Field.Fee:                FieldRequirement.REQUIRED,
      Field.SigningPubKey:      FieldRequirement.REQUIRED,
      Field.Flags:              FieldRequirement.OPTIONAL,
      Field.SourceTag:          FieldRequirement.OPTIONAL,
      Field.Memos:              FieldRequirement.OPTIONAL,
      Field.PreviousTxnID:      FieldRequirement.OPTIONAL,
      Field.LastLedgerSequence: FieldRequirement.OPTIONAL,
      Field.TxnSignature:       FieldRequirement.OPTIONAL,
      Field.Hash:               FieldRequirement.OPTIONAL
  };

  Transaction(TransactionType type) {
    this.type = type;
  }

  TransactionType get type => _get(Field.TransactionType);
  set type(TransactionType type) => _put(Field.TransactionType, type);

  AccountID get account => _get(Field.Account);
  set account(AccountID account) => _put(Field.Account, account);

  int get sequence => _get(Field.Sequence);
  set sequence(int sequence) => _put(Field.Sequence, sequence);

  Flags get flags => _get(Field.Flags);
  set flags(Flags flags) => _put(Field.Flags, flags);

  int get sourceTag => _get(Field.SourceTag);
  set sourceTag(int sourceTag) => _put(Field.SourceTag, sourceTag);

  List<Memo> get memos => _get(Field.Memos);
  set memos(List<Memo> memos) => _put(Field.Memos, memos);

  Hash256 get previousTxId => _get(Field.PreviousTxnID);
  set previousTxId(Hash256 previousTxId) => _put(Field.PreviousTxnID, previousTxId);

  int get lastLedgerSequence => _get(Field.LastLedgerSequence);
  set lastLedgerSequence(int lls) => _put(Field.LastLedgerSequence, lls);

  Amount get fee => _get(Field.Fee);
  set fee(Amount fee) => _put(Field.Fee, fee);

  KeyPair get signingPubKey => new KeyPair.public(_get(Field.SigningPubKey));
  set signingPubKey(KeyPair key) => _put(Field.SigningPubKey, key.publickey);

  ECDSASignature get signature => new ECDSASignature.fromDER(_get(Field.TxnSignature));
  set signature(ECDSASignature signature) => _put(Field.TxnSignature, signature.encodeToDER());

  // field that TransactionResults have (and use)
  Hash256 get hash {
    if(_has(Field.Hash)) {
      return _get(Field.Hash);
    } else {
      Hash256 h = signingHash;
      _put(Field.Hash, h);
      return h;
    }
  }
  set hash(Hash256 hash) { throw new UnsupportedError("Cannot change the hash of a transaction"); }

  Hash256 get signingHash {
    _DigestByteSink sink = new _DigestByteSink(new SHA512Digest());
    sink.add(HashPrefix.TX_SIGN.bytes);
    fieldsToByteSink(sink, (Field f) => f.signingField);
    return new Hash256(sink.digestBytes);
  }

  void sign(KeyPair key) {
    this.signingPubKey = key;
    this.signature = key.sign(signingHash);
  }


  /* CALCULATE FEE */

  int get feeUnits {
    // taken from ripple-lib
    return 10;
  }

  /* JSON */

  Transaction._fromJson(dynamic json) : super._fromJson(json);

  factory Transaction.fromJson(dynamic json) {
    var type = json["TransactionType"];
    if(type is! TransactionType)
      type = TransactionType.fromJsonValue(type);
    switch(type) {
      case TransactionType.ACCOUNT_SET:
        return new AccountSet.fromJson(json);
      case TransactionType.OFFER_CANCEL:
        return new OfferCancel.fromJson(json);
      case TransactionType.OFFER_CREATE:
        return new OfferCreate.fromJson(json);
      case TransactionType.PAYMENT:
        return new Payment.fromJson(json);
      case TransactionType.SET_REGULAR_KEY:
        return new SetRegularKey.fromJson(json);
      case TransactionType.TRUST_SET:
        return new TrustSet.fromJson(json);
    }
    throw new FormatException("Invalid transaction JSON");
  }

  void _assertTransactionType(TransactionType assertedType) {
    if(this.type != assertedType)
      throw new ArgumentError("Invalid JSON for this transaction");
  }

}

class _DigestByteSink implements Sink {

  Digest _digest;

  Uint8List _digestBytes;
  Uint8List get digestBytes => _digestBytes;

  _DigestByteSink(Digest this._digest);

  void add(dynamic bytes) {
    if(bytes is int)
      bytes = new Uint8List(1)..[0] = bytes;
    if(bytes is! Uint8List)
      bytes = new Uint8List.fromList(bytes);
    _digest.update(bytes, 0, bytes.length);
  }

  void close() {
    Uint8List result = new Uint8List(64);
    _digest.doFinal(result, 0);
    _digestBytes = result.sublist(0, 32);
  }
}