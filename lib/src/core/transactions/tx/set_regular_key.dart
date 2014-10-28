part of ripplelib.core;

class SetRegularKey extends Transaction {

  Map<Field, FieldRequirement> _createFormatMap() =>
  super._createFormatMap()..addAll({
      Field.RegularKey: FieldRequirement.OPTIONAL
  });

  Key get regularKey => _get(Field.RegularKey);
  set regularKey(Key regularKey) => _put(Field.RegularKey, regularKey);

  SetRegularKey.fromJson(dynamic json) : super._fromJson(json) {
    _assertTransactionType(TransactionType.SET_REGULAR_KEY);
  }

}