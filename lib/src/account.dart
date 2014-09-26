part of ripple;


class Account extends Hash160 {

  static final Account XRP_ISSUER = new Account(BigInteger.ZERO);

  factory Account(dynamic account) {
    // bytes
    if(account is List<int>) {
      return new Account.fromBytes(account);
    }
    // string
    if(account is String) {
      // hex string of payload
      if(account.length == 20 * 2)
        return new Account.fromBytes(CryptoUtils.hexToBytes(account));
      // base58check encoded "address"
      if(account.startsWith("r") && account.length >= 26)
        return new Account.fromBytes(decodeAddress(account));
      throw new FormatException("String does not represent an Account");
    }
    // biginteger
    if(account is BigInteger) {
      return new Account.fromBytes(new Hash160(account));
    }
  }

  Account.fromBytes(List<int> bytes) : super(bytes);

  String _address;

  String get address {
    if(_address == null)
      _address = encodeAddress(this);
    return _address;
  }

  @override
  String toString() => address;

  /* JSON */

  Object toJson() => toString();
  factory Account.fromJson(var json) => new Account(json);

  /* Address encoding */

  static const int VERSION_ACCOUNT = 0;
  static const String ALPHABET_ACCOUNT = "rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz";

  static String encodeAddress(List<int> bytes) =>
    new Base58CheckEncoder(ALPHABET_ACCOUNT, Utils.sha256Digest).convert(new Base58CheckPayload(VERSION_ACCOUNT, bytes));

  static List<int> decodeAddress(String address) {
    Base58CheckPayload pl = new Base58CheckDecoder(ALPHABET_ACCOUNT, Utils.sha256Digest).convert(address);
    if(pl.version != VERSION_ACCOUNT || pl.payload.length != 20)
      throw new FormatException("Invalid Base58Check account address encoding");
    return pl.payload;
  }
}
