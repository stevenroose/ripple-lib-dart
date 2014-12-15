part of ripplelib.core;

class KeyPair {

  // EC curve definition "secp256k1"
  static final _ec_q = new BigInteger("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", 16);
  static final _ec_a = new BigInteger("0", 16);
  static final _ec_b = new BigInteger("7", 16);
  static final _ec_g = new BigInteger("0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8", 16);
  static final _ec_n = new BigInteger("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", 16);
  static final _ec_h = new BigInteger("1", 16);

  static final ECCurve _EC_CURVE = new fp.ECCurve(_ec_q, _ec_a, _ec_b);

  static final ECDomainParameters EC_PARAMS = new ECDomainParametersImpl(
    "secp256k1", _EC_CURVE, _EC_CURVE.decodePoint(_ec_g.toByteArray()), _ec_n, _ec_h, null);

  static final BigInteger HALF_CURVE_ORDER = _ec_n.shiftRight(1);

  BigInteger _priv;
  Uint8List _pub;
  // chache
  Hash160 _pubKeyHash;

  KeyPair._internal(this._priv, this._pub);

  factory KeyPair.public(Uint8List publicKey) {
    if(publicKey is! Uint8List)
      throw new ArgumentError("Public key must be of type Uint8List");
    return new KeyPair._internal(null, publicKey);
  }

  factory KeyPair.private(dynamic privateKey, [Uint8List publicKey]) {
    if(privateKey is Uint8List)
      privateKey = new BigInteger.fromBytes(1, privateKey);
    if(privateKey is! BigInteger)
      throw new ArgumentError("Private key must be either of type BigInteger or Uint8List");
    if(publicKey != null && publicKey is! Uint8List)
      throw new ArgumentError("Public key must be of type Uint8List");
    if(publicKey == null)
      publicKey = publicKeyFromPrivateKey(privateKey);
    return new KeyPair._internal(privateKey, publicKey);
  }

  BigInteger get privateKey => _priv;
  Uint8List get publickey => _pub;

  Hash160 get pubKeyHash {
    if(_pubKeyHash == null)
      _pubKeyHash = new Hash160(RippleUtils.sha256hash160(_pub));
    return _pubKeyHash;
  }

  bool get hasPrivateKey => _priv != null;

  AccountID get accountID => new AccountID(pubKeyHash);


  /**
   * Signs the given hash and returns the R and S components as BigIntegers. In the Bitcoin protocol, they are
   * usually encoded using DER format, so you want [ECDSASignature#encodeToDER()]
   * instead. However sometimes the independent components can be useful, for instance, if you're doing to do further
   * EC maths on them.
   *
   * @param aesKey The AES key to use for decryption of the private key. If null then no decryption is required.
   */
  ECDSASignature sign(Hash256 input, [KeyParameter aesKey]) {
    if(!hasPrivateKey)
      throw new StateError("This KeyPair is only a public key");

    ECDSASigner signer = _createSigner(new ECPrivateKey(privateKey, EC_PARAMS));
    ECSignature ecSig = signer.generateSignature(input.asBytes());
    ECDSASignature signature = new ECDSASignature(ecSig.r, ecSig.s);
    signature.ensureCanonical();
    return signature;
  }

  bool verify(Uint8List data, ECDSASignature signature, Uint8List pubkey) {
    ECDSASigner signer = _createSigner(new ECPublicKey(EC_PARAMS.curve.decodePoint(pubkey), EC_PARAMS));
    ECSignature ecSig = new ECSignature(signature.r, signature.s);
    return signer.verifySignature(data, ecSig);
  }

  static ECDSASigner _createSigner(dynamic key) {
    var params;
    if(key is ECPublicKey)
      params = new PublicKeyParameter(key);
    else if(key is ECPrivateKey)
      params = new PrivateKeyParameter(key);
    else throw new ArgumentError("Something went wrong");

    Mac signerMac = new HMac(new SHA256Digest(), 64);
    // = new Mac("SHA-256/HMAC")
    return new ECDSASigner(null, signerMac)
      ..init(params is PrivateKeyParameter, params);
  }


  /**
   * Retrieve the public key from the given private key.
   * Use `new BigInteger.fromBytes(signum, magnitude)` to convert a byte array into a BigInteger.
   */
  static Uint8List publicKeyFromPrivateKey(
    BigInteger privateKey, [bool compressed = false]) {
    ECPoint point = EC_PARAMS.G * privateKey;
    return point.getEncoded(compressed);
  }

}

class ECDSASignature {
  BigInteger r;
  BigInteger s;

  ECDSASignature(BigInteger this.r, BigInteger this.s);

  void ensureCanonical() {
    if(s > KeyPair.HALF_CURVE_ORDER) {
      // The order of the curve is the number of valid points that exist on that curve. If S is in the upper
      // half of the number of valid points, then bring it back to the lower half. Otherwise, imagine that
      //    N = 10
      //    s = 8, so (-8 % 10 == 2) thus both (r, 8) and (r, 2) are valid solutions.
      //    10 - 8 == 2, giving us always the latter solution, which is canonical.
      s = KeyPair.EC_PARAMS.n - s;
    }
  }

  Uint8List encodeToDER() {
    ASN1Sequence seq = new ASN1Sequence();
    seq.add(new ASN1Integer(r));
    seq.add(new ASN1Integer(s));
    return seq.encodedBytes;
  }

  factory ECDSASignature.fromDER(Uint8List bytes) {
    ASN1Parser parser = new ASN1Parser(bytes);
    ASN1Sequence seq = parser.nextObject() as ASN1Sequence;
    BigInteger r = (seq.elements[0] as ASN1Integer).valueAsPositiveBigInteger;
    BigInteger s = (seq.elements[1] as ASN1Integer).valueAsPositiveBigInteger;
    return new ECDSASignature(r, s);
  }
}