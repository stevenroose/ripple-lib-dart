part of ripplelib.core;

class SetRegularKey extends Transaction {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = {
      Field.RegularKey: FieldRequirement.OPTIONAL
  }..addAll(Transaction._rippleFormatMap);

  AccountID get regularKey => _get(Field.RegularKey);
  set regularKey(AccountID regularKey) => _put(Field.RegularKey, regularKey);

  SetRegularKey.fromJson(dynamic json, [bool skipFieldCheck = RippleSerializedObject._DEFAULT_SKIP_FIELDCHECK]) :
      super._fromJson(json, skipFieldCheck) {
    _assertTransactionType(TransactionType.SET_REGULAR_KEY);
  }

}