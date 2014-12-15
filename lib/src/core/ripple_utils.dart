part of ripplelib.core;

abstract class RippleUtils {


  /**
   * Calculates the SHA-256 hash of the input data.
   */
  static List<int> sha256Digest(List<int> input) {
    SHA256 digest = new SHA256();
    digest.add(input);
    return new Uint8List.fromList(digest.close());
  }

  /**
   * Calculates the power of any object that has the * operator.
   *
   * Only powers of 1 or higher are allowed.
   */
  static dynamic timesPowerOfTen(dynamic value, dynamic ten, int exponent) {
    while(exponent-- > 0)
      value = value * ten;
    return value;
  }

  /**
   * Converts the integer to a byte array in little endian. Ony positive integers allowed.
   */
  static Uint8List uintToBytesLE(int val, [int size = -1]) {
    if(val < 0) throw new Exception("Only positive values allowed.");
    List<int> result = new List();
    while(val > 0) {
      int mod = val & 0xff;
      val = val >> 8;
      result.add(mod);
    }
    if(size >= 0 && result.length > size) throw new Exception("Value doesn't fit in given size.");
    while(result.length < size) result.add(0);
    return new Uint8List.fromList(result);
  }

  /**
   * The regular BigInteger.toByteArray() method isn't quite what we often need: it appends a
   * leading zero to indicate that the number is positive and may need padding.
   */
  static Uint8List bigIntegerToBytes(BigInteger b, int numBytes) {
    if (b == null) {
      return null;
    }
    Uint8List bytes = new Uint8List(numBytes);
    Uint8List biBytes = new Uint8List.fromList(b.toByteArray());
    int start = (biBytes.length == numBytes + 1) ? 1 : 0;
    int length = min(biBytes.length, numBytes);
    bytes.setRange(numBytes - length, numBytes, biBytes.sublist(start, start + length));
    return bytes;
  }

  /* RIPPLE TIME */

  static final DateTime RIPPLE_EPOCH = new DateTime.utc(2000, 1, 1, 0, 0, 0, 0);

  /**
   * Convert milliseconds since the Ripple epoch to a [DateTime] object.
   */
  static DateTime dateTimeFromSecondsSinceRippleEpoch(int secondsSinceRippleEpoch) =>
      RIPPLE_EPOCH.add(new Duration(seconds: secondsSinceRippleEpoch));

  /**
   * Get the milliseconds since thr Ripple epoch from this date.
   */
  static int getSecondsSinceRippleEpoch(DateTime dateTime) {
    if(dateTime.isBefore(RIPPLE_EPOCH))
      throw new ArgumentError("Given time was before the Ripple epoch: $dateTime");
    return dateTime.difference(RIPPLE_EPOCH).inSeconds;
  }

  static const int _XRP_DROPS = 1000000;
  static double dropsToXRP(int drops) => drops / _XRP_DROPS;
  static int xrpToDrops(double xrp) => (xrp * _XRP_DROPS).truncate();



  /**
   * Calculates the SHA-256 hash of the input data.
   */
  static Uint8List singleDigest(Uint8List input) {
    SHA256 digest = new SHA256();
    digest.add(input);
    return new Uint8List.fromList(digest.close());
  }

  /**
   * Calculates the double-round SHA-256 hash of the input data.
   */
  static Uint8List doubleDigest(Uint8List input) {
    SHA256 digest = new SHA256();
    digest.add(input);
    SHA256 digest2 = new SHA256()
      ..add(digest.close());
    return new Uint8List.fromList(digest2.close());
  }

  /**
   * Calculates the RIPEMD-160 hash of the given input.
   */
  static Uint8List ripemd160Digest(Uint8List input) {
    RIPEMD160Digest digest = new RIPEMD160Digest();
    digest.update(input, 0, input.length);
    Uint8List result = new Uint8List(20);
    digest.doFinal(result, 0);
    return result;
  }

  /**
   * Calculates the RIPEMD-160 hash of the SHA-256 hash of the input.
   * This is used to convert an ECDSA public key to a Bitcoin address.
   */
  static Uint8List sha256hash160(Uint8List input) {
    return ripemd160Digest(singleDigest(input));
  }

}