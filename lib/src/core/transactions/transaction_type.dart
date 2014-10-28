part of ripplelib.core;


class TransactionType extends Enum implements RippleSerializable {

  //TODO change codes
  static const TransactionType ACCOUNT_SET      = const TransactionType._("AccountSet", 0);
  static const TransactionType OFFER_CANCEL     = const TransactionType._("OfferCancel", 0);
  static const TransactionType OFFER_CREATE     = const TransactionType._("OfferCreate", 0);
  static const TransactionType PAYMENT          = const TransactionType._("Payment", 0);
  static const TransactionType SET_REGULAR_KEY  = const TransactionType._("SetRegularKey", 0);
  static const TransactionType TRUST_SET        = const TransactionType._("TrustSet", 0);

  // required by Enum
  static TransactionType valueOf(String e) => Enum.valueOf(TransactionType, e);
  static List<TransactionType> get values => Enum.values(TransactionType);

  final String jsonValue;
  final int code;

  const TransactionType._(this.jsonValue, this.code);

  toJson() => jsonValue;

  static TransactionType fromJsonValue(String key) => TransactionType.values.firstWhere((tt) => tt.jsonValue == key);
  static TransactionType fromCode(int code) => TransactionType.values.firstWhere((tt) => tt.code == code);

  @override
  void toByteSink(ByteSink sink) => sink.add(code);

  @override
  Uint8List toBytes() => new Uint8List(1)..[0] = code;
}
