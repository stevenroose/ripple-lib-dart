part of ripplelib.core;

class Currency extends Hash160 {

  static final Currency XRP = new Currency(Hash160.ZERO_HASH);

  Currency(dynamic bytes) : super(bytes) { _parse(); }

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
    bytes[4] = (interestStart.millisecondsSinceEpoch << 24) & 0xFF;
    bytes[5] = (interestStart.millisecondsSinceEpoch << 16) & 0xFF;
    bytes[6] = (interestStart.millisecondsSinceEpoch << 8) & 0xFF;
    bytes[7] = (interestStart.millisecondsSinceEpoch) & 0xFF;
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

  toJson() => hasInterest ? toHex() : isoCode;
  factory Currency.fromJson(var json) => json.length == 3 ? new Currency.iso(json) :
      new Currency(CryptoUtils.hexToBytes(json));

}