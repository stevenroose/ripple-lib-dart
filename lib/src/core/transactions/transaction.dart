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

  TransactionType get type => _get(Field.TransactionType);
  set type(TransactionType type) => _put(Field.TransactionType, type);

  AccountID get account => _get(Field.Account);
  set account(AccountID account) => _put(Field.Account, account);

  int get sequence => _get(Field.Sequence);
  set sequence(int sequence) => _put(Field.Sequence, sequence);

  int get flags => _get(Field.Flags);
  set flags(int flags) => _put(Field.Flags, flags);

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

  Key get signingPubKey => _get(Field.SigningPubKey);
  set signingPubKey(Key key) => _put(Field.SigningPubKey, key);

  Uint8List get signature => _get(Field.TxnSignature);
  set signature(Uint8List signature) => _put(Field.TxnSignature, signature);

  // field that transaction-results have
  Hash256 get hash => _get(Field.Hash); //TODO maybe calculate hash when it is not present
  set hash(Hash256 hash) {throw new UnsupportedError("Cannot change the hash of a transaction");}

  Transaction() {
    //TODO make constructors for all transactions
  }

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


class TransactionFlag {

  final int flag;

  const TransactionFlag._internal(this.flag);

  // UNIVERSAL FLAGS

  // SPECIFIC FLAGS

  // Payment
  static const DIRECT_RIPPLE = const TransactionFlag._internal(0x00010000);
  static const PARTIAL_PAYMENT = const TransactionFlag._internal(0x00020000);
  static const LIMIT_QUALITY = const TransactionFlag._internal(0x00040000);
  static const CIRCLE = const TransactionFlag._internal(0x00080000);
}
