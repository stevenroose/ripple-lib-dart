part of ripplelib.core;


abstract class RippleEncoding {

  static const String BASE58_ALPHABET = "rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz";

  static const int VERSION_ACCOUNT                 = 0;
  static const int VERSION_ACCOUNT_PUBLIC_KEY      = 35;
  static const int VERSION_ACCOUNT_PRIVATE_KEY     = 34;
  static const int VERSION_FAMILY_SEED             = 33;
  static const int VERSION_FAMILY_PUBLIC_GENERATOR = 41;

  static final Base58CheckCodec _codec = new Base58CheckCodec(BASE58_ALPHABET, RippleUtils.sha256Digest);


  static String encode(Uint8List payload, int version, [int length = -1]) {
    if(length >= 0 && payload.length != length)
      throw new FormatException("Invalid length: ${payload.length}; expected: $length");
    return _codec.encode(new Base58CheckPayload(version, payload));
  }

  static Uint8List decode(String encoded, [int version, int length = -1]) {
    Base58CheckPayload payload = _codec.decode(encoded);
    if(version != null && payload.version != version)
      throw new FormatException("Invalid version code: ${payload.version}; expected: $version");
    if(length >= 0 && payload.payload.length != length)
      throw new FormatException("Invalid length: ${payload.payload.length}; expected: $length");
    return payload.payload;
  }


  static String encodeAccount(Uint8List account) =>
      encode(account, VERSION_ACCOUNT);

  static Uint8List decodeAccount(String account) =>
      decode(account, VERSION_ACCOUNT, 20);


  static String encodePublicKey(Uint8List key) =>
      encode(key, VERSION_ACCOUNT_PUBLIC_KEY);

  static Uint8List decodePublicKey(String key) =>
      decode(key, VERSION_ACCOUNT_PUBLIC_KEY, 33);


  static String encodePrivateKey(Uint8List key) =>
      encode(key, VERSION_ACCOUNT_PRIVATE_KEY);

  static Uint8List decodePrivateKey(String key) =>
      decode(key, VERSION_ACCOUNT_PRIVATE_KEY, 32);


  static String encodeFamilySeed(Uint8List seed) =>
      encode(seed, VERSION_FAMILY_SEED);

  static Uint8List decodeFamilySeed(String seed) =>
      decode(seed, VERSION_FAMILY_SEED, 16);


  static String encodeFamilyPublicGenerator(Uint8List generator) =>
      encode(generator, VERSION_FAMILY_PUBLIC_GENERATOR);

  static Uint8List decodeFamilyPublicGenerator(String generator) =>
      decode(generator, VERSION_FAMILY_PUBLIC_GENERATOR, 33);



}