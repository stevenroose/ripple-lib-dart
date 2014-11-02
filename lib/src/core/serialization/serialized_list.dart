part of ripplelib.core;


//TODO unused, remove
@proxy
class SerializedList<T extends RippleSerializedObject> extends RippleSerialization implements List<T> {

  List<T> _contents;

  SerializedList() {
    _contents = new List<T>();
  }

  SerializedList.from(Iterable<T> from) {
    _contents = new List.from(from);
  }

  @override
  void toByteSink(ByteSink sink) => _contents.forEach(
          (T obj) => _writeSerializedValue(sink, FieldType.OBJECT, obj));

  @override
  toJson() {} // never reached because this is a List

  @override
  noSuchMethod(Invocation inv) => reflect(_contents).delegate(inv);

}