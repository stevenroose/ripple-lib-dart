part of ripplelib.core;

class OfferCreate extends Transaction {

  Map<Field, FieldRequirement> _createFormatMap() =>
  super._createFormatMap()..addAll({
      Field.TakerPays:      FieldRequirement.REQUIRED,
      Field.TakerGets:      FieldRequirement.REQUIRED,
      Field.Expiration:     FieldRequirement.OPTIONAL,
      Field.OfferSequence:  FieldRequirement.OPTIONAL
  });

  Amount get takerGets => _get(Field.TakerGets);
  set takerGets(Amount takerGets) => _put(Field.TakerGets, takerGets);

  Amount get takerPays => _get(Field.TakerPays);
  set takerPays(Amount takerPays) => _put(Field.TakerPays, takerPays);

  DateTime get expiration => _get(Field.Expiration);
  set expiration(DateTime expiration) => _put(Field.Expiration, expiration);

  int get offerSequence => _get(Field.OfferSequence);
  set offerSequence(int offerSequence) => _put(Field.OfferSequence, offerSequence);

  OfferCreate.fromJson(dynamic json) : super._fromJson(json) {
    _assertTransactionType(TransactionType.OFFER_CREATE);
  }

}