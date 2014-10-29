part of ripplelib.core;

abstract class RippleSerializable {
  void toByteSink(ByteSink sink);
  Uint8List toBytes();
  dynamic toJson();
}

abstract class RippleSerialization implements RippleSerializable {

  /* METHODS TO IMPLEMENT */

  void toByteSink(ByteSink sink);

  dynamic toJson();

  /* OTHER PUBLIC METHODS */

  Uint8List toBytes() {
    ByteSink bs = new ByteSink();
    toByteSink(bs);
    return bs.toUint8List();
  }

  String toHex() => CryptoUtils.bytesToHex(toBytes());

  /* HELPER METHODS */

  // helper methods for serialization
  void _writeField(ByteSink sink, Field field, dynamic value) {
    if(!field.isSerialized)
      throw new StateError("Field $field should not be serialized");
    // write field header
    sink.add(field.bytes);
    // write value
    if(field.isVlEncoded) {
      ByteSink tempSink = new ByteSink();
      _writeSerializedValue(tempSink, field.type, value);
      sink.add(_encodeVl(tempSink.size));
      sink.add(tempSink.toUint8List());
    } else {
      _writeSerializedValue(sink, field.type, value);
    }
  }

  static List<int> _encodeVl(int length) {
    if(length <= 192) {
      return [length];
    } else if(length <= 12480) {
      length -= 193;
      return [(193 + (length >> 8)), (length & 0xff)];
    } else if(length <= 918744) {
      length -= 12481;
      return [(241 + (length >> 16)), ((length >> 8) & 0xff), (length & 0xff)];
    }
    throw new StateError("Vl length to high: $length");
  }

  void _writeSerializedValue(ByteSink sink, FieldType type, dynamic value) {
    if(value is RippleSerializable)
      value.toByteSink(sink);
    else
      _writeNativeType(sink, type, value);
    if(type == FieldType.OBJECT)
      sink.add(Field.ObjectEndMarker.bytes);
    else if(type == FieldType.ARRAY)
      sink.add(Field.ArrayEndMarker.bytes);
  }

  void _writeNativeType(ByteSink sink, FieldType type, dynamic value) {
    switch(type) {
      case FieldType.UINT8:
        sink.add(Utils.uintToBytesLE(value, 1));
        break;
      case FieldType.UINT16:
        sink.add(Utils.uintToBytesLE(value, 2));
        break;
      case FieldType.UINT32:
        sink.add(Utils.uintToBytesLE(value, 4));
        break;
      case FieldType.UINT64:
        _writeUint64(sink, value);
        break;
      case FieldType.HASH128:
      case FieldType.HASH256:
      case FieldType.HASH160:
        sink.add(value.asBytes());
        break;
      case FieldType.VARLEN:
        if(value is String) value = const Utf8Encoder().convert(value);
        sink.add(value);
        break;
    //TODO complete
    }
  }

  void _writeUint64(ByteSink sink, BigInteger uint64) {
    sink.add(Utils.bigIntegerToBytes(uint64, 8));
  }

}