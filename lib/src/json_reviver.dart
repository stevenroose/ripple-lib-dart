part of ripple;

/**
 * The reviver used for Dart's JsonCodec class. Use the revive method.
 */
abstract class JsonReviver {

  static const Map<String, Function> _revivers = {
      "Account": (j) => new Account.fromJson(j),
      "amount": (j) => Decimal.parse(j),
      "Balance": (j) => Decimal.parse(j),
      "currency": (j) => new Currency.fromJson(j),
      "issuer": (j) => new Account.fromJson(j),
      "TakerPays": (j) => new Amount.fromJson(j),
      "TakerGets": (j) => new Amount.fromJson(j),
  };

  static Object revive(Object key, Object value) {
    if(key is! String)
      return value;
    if(!_revivers.containsKey(key))
      return value;
    return _revivers[key](value);
  }

}