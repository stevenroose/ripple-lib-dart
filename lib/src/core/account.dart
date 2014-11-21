part of ripplelib.core;


class AccountID extends Hash160 implements RippleSerializable {

  static final AccountID XRP_ISSUER = new AccountID(BigInteger.ZERO);

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
        return new AccountID.fromBytes(decodeAddress(account)).._address = account;
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
      _address = encodeAddress(bytes);
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
  void toByteSink(ByteSink sink) {
    sink.add(bytes);
  }

  @override
  Uint8List toBytes() => bytes;

  /* Address encoding */

  static const int VERSION_ACCOUNT = 0;
  static const String ALPHABET_ACCOUNT = "rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz";

  static String encodeAddress(List<int> bytes) =>
    new Base58CheckEncoder(ALPHABET_ACCOUNT, RippleUtils.sha256Digest).convert(new Base58CheckPayload(VERSION_ACCOUNT, bytes));

  static List<int> decodeAddress(String address) {
    Base58CheckPayload pl = new Base58CheckDecoder(ALPHABET_ACCOUNT, RippleUtils.sha256Digest).convert(address);
    if(pl.version != VERSION_ACCOUNT || pl.payload.length != 20)
      throw new FormatException("Invalid Base58Check account address encoding");
    return pl.payload;
  }
}
