part of ripplelib.core;


//TODO unused, remove
@proxy
class RippleSerializedList<T extends RippleSerializedObject> extends RippleSerialization implements List<T> {

  List<T> _contents;

  RippleSerializedList() {
    _contents = new List<T>();
  }

  RippleSerializedList.from(Iterable<T> from) {
    _contents = new List.from(from);
  }

  @override
  void toByteSink(Sink sink) => _contents.forEach(
          (T obj) => _writeSerializedValue(sink, FieldType.OBJECT, obj));

  @override
  toJson() {} // never reached because this is a List

  @override
  noSuchMethod(Invocation inv) => reflect(_contents).delegate(inv);

}