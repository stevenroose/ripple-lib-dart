part of ripplelib.core;


class TransactionType extends Enum implements RippleSerializable {

  static const TransactionType INVALID          = const TransactionType._( -1, "Invalid");
  static const TransactionType PAYMENT          = const TransactionType._(  0, "Payment");
  static const TransactionType ACCOUNT_SET      = const TransactionType._(  3, "AccountSet");
  static const TransactionType SET_REGULAR_KEY  = const TransactionType._(  5, "SetRegularKey");
  static const TransactionType OFFER_CREATE     = const TransactionType._(  7, "OfferCreate");
  static const TransactionType OFFER_CANCEL     = const TransactionType._(  8, "OfferCancel");
  static const TransactionType TRUST_SET        = const TransactionType._( 20, "TrustSet");

  // required by Enum
  static TransactionType valueOf(String e) => Enum.valueOf(TransactionType, e);
  static List<TransactionType> get values => Enum.values(TransactionType);

  final String jsonValue;
  final int code;

  const TransactionType._(this.code, this.jsonValue);

  toJson() => jsonValue;

  static TransactionType fromJsonValue(String key) => TransactionType.values.firstWhere((tt) => tt.jsonValue == key);
  static TransactionType fromCode(int code) => TransactionType.values.firstWhere((tt) => tt.code == code);

  @override
  void toByteSink(Sink sink) => sink.add(code);

  @override
  Uint8List toBytes() => new Uint8List(1)..[0] = code;
}
