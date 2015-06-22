part of ripplelib.core;

class OfferCancel extends Transaction {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = {
      Field.OfferSequence:  FieldRequirement.REQUIRED
  }..addAll(Transaction._rippleFormatMap);

  int get offerSequence => _get(Field.OfferSequence);
  set offerSequence(int offerSequence) => _put(Field.OfferSequence, offerSequence);

  OfferCancel.fromJson(dynamic json, [bool skipFieldCheck = RippleSerializedObject._DEFAULT_SKIP_FIELDCHECK]) :
      super._fromJson(json, skipFieldCheck) {
    _assertTransactionType(TransactionType.OFFER_CANCEL);
  }

}