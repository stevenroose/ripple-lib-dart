part of ripplelib.core;


class AccountID extends Hash160 implements RippleSerializable {

  static final AccountID ACCOUNT_ZERO = new AccountID(BigInteger.ZERO);
  static final AccountID ACCOUNT_ONE  = new AccountID(BigInteger.ONE);

  static final AccountID XRP_ISSUER = ACCOUNT_ZERO;

  factory AccountID(dynamic account) {
    // bytes
    if(account is List<int>)
      return new AccountID.fromBytes(account);
    if(account is Hash160)
      return new AccountID.fromBytes(account.bytes);
    // string
    if(account is String) {
      // hex string of payload
      if(account.length == 20 * 2)
        return new AccountID.fromBytes(CryptoUtils.hexToBytes(account));
      // base58check encoded "address"
      if(account.startsWith("r") && account.length >= 26)
        return new AccountID.fromBytes(RippleEncoding.decodeAccount(account)).._address = account;
      throw new FormatException("String does not represent an AccountID: $account");
    }
    // biginteger
    if(account is BigInteger) {
      return new AccountID(new Hash160(account));
    }
    throw new ArgumentError("Invalid account argument: $account");
  }

  AccountID.fromBytes(List<int> bytes) : super(bytes);

  String _address;

  String get address {
    if(_address == null)
      _address = RippleEncoding.encodeAccount(bytes);
    return _address;
  }

  @override
  String toString() => address;

  /* JSON */

  @override
  toJson() => toString();
  factory AccountID.fromJson(dynamic json) => new AccountID(json);

  /* RIPPLE SERIALIZATION */

  @override
  void toByteSink(Sink sink) {
    sink.add(bytes);
  }

  @override
  Uint8List toBytes() => bytes;

  /* Address encoding */

  static const int VERSION_ACCOUNT = 0;
  static const String ALPHABET_ACCOUNT = "rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz";
}
