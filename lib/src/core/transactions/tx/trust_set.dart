part of ripplelib.core;

class TrustSet extends Transaction {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = {
      Field.QualityIn:    FieldRequirement.OPTIONAL,
      Field.QualityOut:   FieldRequirement.OPTIONAL,
      Field.LimitAmount:  FieldRequirement.OPTIONAL
  }..addAll(Transaction._rippleFormatMap);

  int get qualityIn => _get(Field.QualityIn);
  set qualityIn(int qualityIn) => _put(Field.QualityIn, qualityIn);

  int get qualityOut => _get(Field.QualityOut);
  set qualityOut(int qualityOut) => _put(Field.QualityOut, qualityOut);

  LimitAmount get limitAmount => _get(Field.LimitAmount);
  set limitAmount(LimitAmount limitAmount) => _put(Field.LimitAmount, limitAmount);

  TrustSet.fromJson(dynamic json) : super._fromJson(json) {
    _assertTransactionType(TransactionType.TRUST_SET);
  }

}