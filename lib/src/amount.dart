part of ripple;

class Amount implements Comparable<Amount> {

  static const int XRP_DROP_SCALE = 6;

  final Decimal amount;
  final Currency currency;
  final Account issuer;

  Amount._internal(Decimal this.amount, Currency this.currency, Account this.issuer)

  factory Amount(dynamic amount, [Currency currency = Currency.XRP, Account issuer = Account.XRP_ISSUER]) {
    if(amount is Decimal)
      return new Amount._internal(amount, currency, issuer);
    if(amount is int)
      return new Amount._internal(new Decimal.fromInt(amount), currency, issuer);
    if(amount is String)
      return new Amount._internal(Decimal.parse(amount), currency, issuer);
    if(amount is BigInteger)
      return new Amount._internal(Decimal.parse(amount.toString()), currency, issuer);
    throw new ArgumentError("Invalid type for amount");
  }

  Issue get issue => new Issue(currency, issuer);

  bool get isNative => currency == Currency.XRP && issuer == Account.XRP_ISSUER;

  BigInteger get drops {
    if(!isNative)
      throw new StateError("Amount is not native");
    return new BigInteger(toDropsString());
  }

  @override
  String toString() => isNative ? toDropsString() : "$amount $currency/$issuer";

  String toDropsString() {
    if(!isNative)
      throw new StateError("Amount is not native");
    return (amount * new Decimal.fromInt(10) ^ XRP_DROP_SCALE).toStringAsFixed(0);
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

  Object toJson() => isNative ? toDropsString() :
      {"currency": currency, "amount": amount.toString(), "issuer": issuer};
  factory Amount.fromJson(var json) => json is! Map ? new Amount(json) :
      new Amount(json["amount"], json["currency"], json["issuer"]);

}
