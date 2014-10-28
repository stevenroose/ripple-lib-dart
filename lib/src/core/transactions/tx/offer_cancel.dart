part of ripplelib.core;

class OfferCancel extends Transaction {

  Map<Field, FieldRequirement> _createFormatMap() =>
  super._createFormatMap()..addAll({
      Field.OfferSequence:  FieldRequirement.REQUIRED
  });

  int get offerSequence => _get(Field.OfferSequence);
  set offerSequence(int offerSequence) => _put(Field.OfferSequence, offerSequence);

  OfferCancel.fromJson(dynamic json) : super._fromJson(json) {
    _assertTransactionType(TransactionType.OFFER_CANCEL);
  }

}