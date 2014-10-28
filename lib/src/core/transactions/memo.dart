part of ripplelib.core;

class Memo extends RippleSerializedObject {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => {};

  String get memoType => _get(Field.MemoType);
  set memoType(String memoType) => _put(Field.MemoType, memoType);

  Memo(String memoType) {
    this.memoType = memoType;
  }

  Memo.fromJson(dynamic json) : super._fromJson(json);

}