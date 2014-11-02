part of ripplelib.core;

class SetRegularKey extends Transaction {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = {
      Field.RegularKey: FieldRequirement.OPTIONAL
  }..addAll(Transaction._rippleFormatMap);

  Key get regularKey => _get(Field.RegularKey);
  set regularKey(Key regularKey) => _put(Field.RegularKey, regularKey);

  SetRegularKey.fromJson(dynamic json) : super._fromJson(json) {
    _assertTransactionType(TransactionType.SET_REGULAR_KEY);
  }

}