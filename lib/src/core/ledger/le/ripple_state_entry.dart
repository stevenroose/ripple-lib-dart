part of ripplelib.core;


class RippleStateEntry extends LedgerEntry {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = {
      Field.Balance:              FieldRequirement.REQUIRED,
      Field.LowLimit:             FieldRequirement.REQUIRED,
      Field.HighLimit:            FieldRequirement.REQUIRED,
      Field.PreviousTxnID:        FieldRequirement.REQUIRED,
      Field.PreviousTxnLgrSeq:    FieldRequirement.REQUIRED,
      Field.LowNode:              FieldRequirement.OPTIONAL,
      Field.LowQualityIn:         FieldRequirement.OPTIONAL,
      Field.LowQualityOut:        FieldRequirement.OPTIONAL,
      Field.HighNode:             FieldRequirement.OPTIONAL,
      Field.HighQualityIn:        FieldRequirement.OPTIONAL,
      Field.HighQualityOut:       FieldRequirement.OPTIONAL
  }..addAll(LedgerEntry._rippleFormatMap);

  RippleStateEntry() : super(LedgerEntryType.RIPPLE_STATE);

  RippleStateEntry._newInstance() : this();

  Amount get balance => _get(Field.Balance);

  Amount get lowLimit => _get(Field.LowLimit);

  Amount get highLimit => _get(Field.HighLimit);

  Hash256 get previousTxId => _get(Field.PreviousTxnID);

  int get previousTxLedgerSequence => _get(Field.PreviousTxnLgrSeq);

  BigInteger get lowNode => _get(Field.LowNode);

  int get lowQualityIn => _get(Field.LowQualityIn);

  int get lowQualityOut => _get(Field.LowQualityOut);

  BigInteger get highNode => _get(Field.HighNode);

  int get highQualityIn => _get(Field.HighQualityIn);

  int get highQualityOut => _get(Field.HighQualityOut);

  /* JSON */

  RippleStateEntry.fromJson(dynamic json, [bool skipFieldCheck = RippleSerializedObject._DEFAULT_SKIP_FIELDCHECK]) :
      super._fromJson(json, skipFieldCheck) {
    _assertLedgerEntryType(LedgerEntryType.RIPPLE_STATE);
  }

}