part of ripplelib.core;

class Currency extends Hash160 implements RippleSerializable {

  static final Currency XRP = new Currency._xrp();
  Currency._xrp() : super(Hash160.ZERO_HASH), _isoCode = "XRP";

  factory Currency(dynamic currency) {
    if(currency is String) {
      if(currency.length == 3)
        return new Currency.iso(currency);
      if(currency.length == 20)
        return new Currency.fromBytes(CryptoUtils.hexToBytes(currency));
      throw new ArgumentError("Invalid currency string $currency");
    }
    if(currency is Uint8List) {
      return new Currency.fromBytes(currency);
    }
    throw new ArgumentError("Invalid argument for a Currency: $currency");
  }

  Currency.fromBytes(dynamic bytes) : super(bytes) { _parse(); }

  factory Currency.iso(String isoCode) {
    if(isoCode.length != 3)
      throw new ArgumentError("ISO codes are of length 3");
    if(isoCode == "XRP")
      return XRP;
    Uint8List bytes = new Uint8List(20);
    bytes[12] = isoCode.codeUnitAt(0) & 0xFF;
    bytes[13] = isoCode.codeUnitAt(1) & 0xFF;
    bytes[14] = isoCode.codeUnitAt(2) & 0xFF;
    return new Currency(bytes);
  }

  factory Currency.fromParameters(String isoCode, DateTime interestStart, double interestRate) {
    if(isoCode.length != 3)
      throw new ArgumentError("ISO codes are of length 3");
    if(isoCode == "XRP")
      return XRP;
    Uint8List bytes = new Uint8List(20);
    bytes[0] = isoCode.codeUnitAt(0) & 0xFF;
    bytes[1] = isoCode.codeUnitAt(1) & 0xFF;
    bytes[2] = isoCode.codeUnitAt(2) & 0xFF;
//    int seconds = RippleDateTime.calculateSecondsSinceRippleEpoch(interestStart);
//    bytes[4] = (seconds << 24) & 0xFF;
//    bytes[5] = (seconds << 16) & 0xFF;
//    bytes[6] = (seconds << 8) & 0xFF;
//    bytes[7] = (seconds) & 0xFF;
    // ^ deprecated format
    bytes[4] = bytes[5] = bytes[6] = bytes[7] = 0;
    bytes.setRange(8, 16, new Float64List.fromList([interestRate]).buffer.asUint8List());
    return new Currency(bytes);
  }

  String _isoCode;
  DateTime _interestStart;
  double _interestRate;

  String get isoCode => _isoCode;
  DateTime get interestStart => _interestStart;
  double get interestRate => _interestRate;

  void _parse() {
    if(this == Hash160.ZERO_HASH) {
      _isoCode = "XRP";
    }

    var isZeroExceptInStandardPositions = true;
    for(var i = 0 ; i < 20 ; i++) {
      isZeroExceptInStandardPositions = isZeroExceptInStandardPositions && (i == 12 || i == 13 || i == 14 || bytes[i] == 0);
    }

    if(isZeroExceptInStandardPositions) {
      _isoCode = new String.fromCharCodes(bytes.getRange(12,15));
    } else {
      _isoCode = new String.fromCharCodes(bytes.getRange(0,3));
      _interestStart = new DateTime.fromMillisecondsSinceEpoch((bytes[4] << 24) + (bytes[5] << 16) + (bytes[6] <<  8) + bytes[7]);
      _interestRate = this.buffer.asFloat64List(this.offsetInBytes, 1).single;
    }
  }

  bool get isNative => this == XRP;

  bool get hasInterest => _interestStart != null && _interestRate != null;

  @override
  String toString() => isoCode;

  /* JSON */

  @override
  toJson() => hasInterest ? toHex() : isoCode;
  factory Currency.fromJson(var json) => json.length == 3 ? new Currency.iso(json) :
      new Currency(CryptoUtils.hexToBytes(json));

  /* RIPPLE SERIALIZATION */

  @override
  void toByteSink(Sink sink) => sink.add(bytes);

  @override
  Uint8List toBytes() => bytes;
}