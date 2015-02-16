part of ripplelib.core;

class Amount extends RippleSerialization implements Comparable<Amount> {

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

  final Decimal value;
  final Currency currency;
  final AccountID issuer;
  final bool _unchecked;

  static final Decimal _ZERO_DECIMAL = new Decimal.fromInt(0);

  Amount._(Decimal this.value, Currency this.currency, AccountID this.issuer, [bool this._unchecked = true]) {
    if(!_unchecked) {
      if(isNative) {
        if(value.abs() > MAX_NATIVE_VALUE)
          throw new StateError("Amount too big: $value");
        if(value.scale > MAXIMUM_NATIVE_SCALE)
          throw new StateError("Amount has scale higher that allowed: $value");
      } else {
        if (value.precision > MAXIMUM_IOU_PRECISION) {
          throw new StateError("Too large precision for IOU: $value");
        }
      }
    }
  }

  factory Amount(dynamic value, [Currency currency, AccountID issuer, bool unchecked = true]) {
    // default values
    if (currency == null)
      currency = Currency.XRP;
    if (issuer == null && currency == Currency.XRP)
      issuer = AccountID.XRP_ISSUER;
    // different accepted amount types
    value = _convertDecimalAmount(value);
    return new Amount._(value, currency, issuer, unchecked);
  }

  factory Amount.XRP(dynamic value, [bool unchecked = true]) =>
      new Amount._(_convertDecimalAmount(value), Currency.XRP, AccountID.XRP_ISSUER, unchecked);

  factory Amount.drops(dynamic drops, [bool unchecked = true]) =>
      new Amount.XRP(_convertDecimalAmount(drops) / XRP_IN_DROPS, unchecked);

  static Decimal _convertDecimalAmount(dynamic amount) {
    if (amount is String)
      return Decimal.parse(amount);
    if (amount is Decimal)
      return amount;
    if (amount is int)
      return new Decimal.fromInt(amount);
    if (amount is BigInteger)
      return Decimal.parse(amount.toString());
    if(amount is double)
      return Decimal.parse("$amount");
    throw new ArgumentError("Invalid type for amount: $amount");
  }

  Issue get issue => new Issue(currency, issuer);

  bool get isNative => currency == Currency.XRP && issuer == AccountID.XRP_ISSUER;

  bool get hasIssuer => issuer != null;

  BigInteger get xrpDrops {
    if (!isNative)
      throw new StateError("Amount is not native");
    return _exactBigIntegerScaledByPowerOfTen(XRP_DROP_SCALE);
  }

  Amount update({dynamic value, Currency currency, AccountID issuer}) =>
      new Amount._(value != null ? _convertDecimalAmount(value) : this.value,
                   currency != null ? currency : this.currency,
                   issuer != null ? issuer : this.issuer);

  @override
  String toString() => isNative ? "$value XRP" : "$value $currency" + (hasIssuer ? "/$issuer" : "");

  String toDropsString() => xrpDrops.toString();

  @override
  bool operator ==(Object other) => other is Amount && other.value == value &&
      other.currency == currency && other.issuer == issuer;

  @override
  int get hashCode => value.hashCode ^ currency.hashCode ^ issuer.hashCode;

  @override
  int compareTo(Amount other) => value.compareTo(other.value);

  bool get isNegative => value.isNegative;

  Decimal _castOther(dynamic other) => other is Amount ? other.value : _convertDecimalAmount(other);

  Amount operator +(dynamic other) => new Amount._(value + _castOther(other), currency, issuer, _unchecked);

  Amount operator -(dynamic other) => new Amount._(value - _castOther(other), currency, issuer, _unchecked);

  Amount operator *(dynamic other) => new Amount._(value * _castOther(other), currency, issuer, _unchecked);

  Amount operator /(dynamic other) => new Amount._(value / _castOther(other), currency, issuer, _unchecked);

  Amount operator -() => new Amount._(-value, currency, issuer);

  bool operator <(dynamic other) => value < _castOther(other);

  bool operator <=(dynamic other) => value <= _castOther(other);

  bool operator >(dynamic other) => value > _castOther(other);

  bool operator >=(dynamic other) => value >= _castOther(other);

  Amount min(Amount other) => this <= other ? this : other;

  Amount max(Amount other) => this >= other ? this : other;

  /* JSON */

  @override
  toJson() {
    if(!hasIssuer)
      throw new StateError("Cannot serialize currency without issuer");
    return isNative ? toDropsString() : {
      "currency": currency,
      "value": value.toString(),
      "issuer": issuer
    };
  }

  factory Amount.fromJson(var json) {
    if (json is String)
      return new Amount.drops(json);
    else
      return new Amount(json["value"], json["currency"], json["issuer"]);
  }

  /* SERIALIZATION */

  @override
  void toByteSink(Sink sink) {
    if(!hasIssuer)
      throw new StateError("Cannot serialize currency without issuer");
    BigInteger mantissa = _calculateMantissa();
    if (isNative) {
      if (!isNegative)
        mantissa = mantissa | BINARY_FLAG_IS_NON_NEGATIVE_NATIVE;
      _writeUint64(sink, mantissa);
    } else {
      int exponent = _calculateIOUExponent();
      BigInteger packed;
      if(value.signum == 0)
        packed = BINARY_FLAG_IS_IOU;
      else if(isNegative)
        packed = mantissa | new BigInteger(512 + 0 + 97 + exponent).shiftLeft(64 - 10);
      else
        packed = mantissa | new BigInteger(512 + 256 + 97 + exponent).shiftLeft(64 - 10);

      _writeUint64(sink, packed);
      sink.add(currency.bytes);
      sink.add(issuer.bytes);
    }
  }

  static final Decimal _DEC_1  = new Decimal.fromInt(1);
  static final Decimal _DEC_10 = new Decimal.fromInt(10);
  BigInteger _exactBigIntegerScaledByPowerOfTen(int n) => n >= 0
    ? new BigInteger((RippleUtils.timesPowerOfTen(value, _DEC_10,  n)).toStringAsFixed(0))
    : new BigInteger((value ~/ RippleUtils.timesPowerOfTen(_DEC_1, _DEC_10, -n)).toStringAsFixed(0));

  tmp(int n) => _exactBigIntegerScaledByPowerOfTen(n);

  BigInteger _calculateMantissa() {
    if(isNegative)
      return xrpDrops;
    else {
      return _exactBigIntegerScaledByPowerOfTen(-_calculateIOUExponent()).abs();
    }
  }

  int _calculateIOUExponent() =>  -MAXIMUM_IOU_PRECISION + value.precision - value.scale;

}
