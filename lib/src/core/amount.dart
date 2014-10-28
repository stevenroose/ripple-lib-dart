part of ripplelib.core;

class Amount implements RippleSerializable, Comparable<Amount> {

  static const int XRP_DROP_SCALE = 6;
  static final Decimal XRP_IN_DROPS = Decimal.parse("1000000");

  // The maximum amount of digits in mantissa of an IOU amount
  static const int MAXIMUM_IOU_PRECISION = 16;
  // The smallest quantity of an XRP is a drop, 1 millionth of an XRP
  static const int MAXIMUM_NATIVE_SCALE = 6;
  // Defines bounds for native amounts
  static final Decimal MAX_NATIVE_VALUE = Decimal.parse("100000000000.0");
  static final Decimal MIN_NATIVE_VALUE = Decimal.parse("0.000001");

  // These are flags used when serializing to binary form
  static final BigInteger BINARY_FLAG_IS_IOU = new BigInteger("8000000000000000", 16);
  static final BigInteger BINARY_FLAG_IS_NON_NEGATIVE_NATIVE = new BigInteger("4000000000000000", 16);

  final Decimal amount;
  final Currency currency;
  final Account issuer;

  static final Decimal _ZERO_DECIMAL = new Decimal.fromInt(0);

  Amount._internal(Decimal this.amount, Currency this.currency, Account this.issuer) {
    if(isNative) {
      if(amount.abs() > MAX_NATIVE_VALUE)
        throw new StateError("Amount too big: $amount");
      if(amount.abs() < MIN_NATIVE_VALUE && amount != _ZERO_DECIMAL)
        throw new StateError("Amount too small: $amount");
    } else { //TODO
//      if(amount.precision() > MAXIMUM_IOU_PRECISION)
//        throw new StateError("Too large precision for IOU: $amount");
    }
  }

  factory Amount(dynamic amount, [Currency currency, Account issuer]) {
    // default values
    if(currency == null)
      currency = Currency.XRP;
    if(issuer == null)
      issuer = Account.XRP_ISSUER;
    // different accepted amount types
    amount = _convertAmount(amount);
    return new Amount._internal(amount, currency, issuer);
  }

  factory Amount.XRP(dynamic amount) => new Amount._internal(_convertAmount(amount), Currency.XRP, Account.XRP_ISSUER);

  factory Amount.drops(dynamic drops) => new Amount.XRP(_convertAmount(drops) / XRP_IN_DROPS);

  static Decimal _convertAmount(dynamic amount) {
    if(amount is String)
      return Decimal.parse(amount);
    if(amount is Decimal)
      return amount;
    if(amount is int)
      return new Decimal.fromInt(amount);
    if(amount is BigInteger)
      return Decimal.parse(amount.toString());
    throw new ArgumentError("Invalid type for amount: $amount");
  }

  Issue get issue => new Issue(currency, issuer);

  bool get isNative => currency == Currency.XRP && issuer == Account.XRP_ISSUER;

  BigInteger get xrpDrops {
    if(!isNative)
      throw new StateError("Amount is not native");
    return new BigInteger(toDropsString());
  }

  @override
  String toString() => isNative ? "$amount XRP" : "$amount $currency/$issuer";

  String toDropsString() {
    if(!isNative)
      throw new StateError("Amount is not native");
    return (amount * Utils.pow(new Decimal.fromInt(10), XRP_DROP_SCALE)).toStringAsFixed(0);
  }

  @override
  bool operator ==(Amount other) => other is Amount && other.amount == amount &&
      other.currency == currency && other.issuer == issuer;

  @override
  int get hashCode => amount.hashCode ^ currency.hashCode ^ issuer.hashCode;

  @override
  int compareTo(Amount other) => amount.compareTo(other.amount);

  bool get isNegative => amount.isNegative;
  Amount operator +(dynamic other) => new Amount(amount + (other is Amount ? other.amount : other), currency, issuer);
  Amount operator -(dynamic other) => new Amount(amount - (other is Amount ? other.amount : other), currency, issuer);
  Amount operator *(dynamic other) => new Amount(amount * (other is Amount ? other.amount : other), currency, issuer);
  Amount operator /(dynamic other) => new Amount(amount / (other is Amount ? other.amount : other), currency, issuer);
  Amount operator -() => new Amount(-amount, currency, issuer);
  bool operator <(dynamic other)  => amount <  (other is Amount ? other.amount : other);
  bool operator <=(dynamic other) => amount <= (other is Amount ? other.amount : other);
  bool operator >(dynamic other)  => amount >  (other is Amount ? other.amount : other);
  bool operator >=(dynamic other) => amount >= (other is Amount ? other.amount : other);
  Amount min(Amount other) => this <= other ? this : other;
  Amount max(Amount other) => this >= other ? this : other;

  /* JSON */

  toJson() => isNative ? toDropsString() :
      {"currency": currency, "amount": amount.toString(), "issuer": issuer};
  factory Amount.fromJson(var json) {
    if(json is String)
      return new Amount.drops(json);
    else
      return new Amount(json["value"], json["currency"], json["issuer"]);
  }

}
