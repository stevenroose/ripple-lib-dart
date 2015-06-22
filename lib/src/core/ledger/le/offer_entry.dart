part of ripplelib.core;


class OfferEntry extends LedgerEntry implements Offer {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = {
      Field.Account:             FieldRequirement.REQUIRED,
      Field.Sequence:            FieldRequirement.REQUIRED,
      Field.TakerGets:           FieldRequirement.REQUIRED,
      Field.TakerPays:           FieldRequirement.REQUIRED,
      Field.BookDirectory:       FieldRequirement.REQUIRED,
      Field.BookNode:            FieldRequirement.REQUIRED,
      Field.OwnerNode:           FieldRequirement.REQUIRED,
      Field.PreviousTxnID:       FieldRequirement.REQUIRED,
      Field.PreviousTxnLgrSeq:   FieldRequirement.REQUIRED,
      Field.Expiration:          FieldRequirement.OPTIONAL
  }..addAll(LedgerEntry._rippleFormatMap);

  OfferEntry() : super(LedgerEntryType.OFFER);

  OfferEntry._newInstance() : this();

  AccountID get account => _get(Field.Account);

  int get sequence => _get(Field.Sequence);

  Amount get takerGets => _get(Field.TakerGets);

  Amount get takerPays => _get(Field.TakerPays);

  Hash256 get bookDirectory => _get(Field.BookDirectory);

  BigInteger get bookNode => _get(Field.BookNode);

  BigInteger get ownerNode => _get(Field.Owner);

  Hash256 get previousTxId => _get(Field.PreviousTxnID);
  void set previousTxId(Hash256 txId) => _put(Field.PreviousTxnID, txId);

  int get previousTxLedgerSequence => _get(Field.PreviousTxnLgrSeq);

  DateTime get expiration => new RippleDateTime.fromSecondsSinceRippleEpoch(_get(Field.Expiration));


  double get ratio => (takerGets.value / takerPays.value).toDouble();

  /* JSON */

  OfferEntry.fromJson(dynamic json, [bool skipFieldCheck = RippleSerializedObject._DEFAULT_SKIP_FIELDCHECK]) :
      super._fromJson(json, skipFieldCheck) {
    _assertLedgerEntryType(LedgerEntryType.OFFER);
  }

}