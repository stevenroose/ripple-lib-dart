part of ripplelib.core;


class Payment extends Transaction {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = {
      Field.Destination:    FieldRequirement.REQUIRED,
      Field.Amount:         FieldRequirement.REQUIRED,
      Field.Paths:          FieldRequirement.DEFAULT,
      Field.SendMax:        FieldRequirement.OPTIONAL,
      Field.DestinationTag: FieldRequirement.OPTIONAL,
      Field.InvoiceID:      FieldRequirement.OPTIONAL
  }..addAll(Transaction._rippleFormatMap);

  TransactionType get type => TransactionType.PAYMENT;
  set type(TransactionType type) => throw new StateError("Cannot change transaction type");

  Account get destination => _get(Field.Destination);
  set destination(Account destination) => _put(Field.Destination, destination);

  Amount get amount => _get(Field.Amount);
  set amount(Amount amount) => _put(Field.Amount, amount);

  Amount get sendMax => _get(Field.SendMax);
  set sendMax(Amount sendMax) => _put(Field.SendMax, sendMax);

  PathSet get paths => _get(Field.Paths);
  set paths(PathSet paths) => _put(Field.Paths, paths);

  int get destinationTag => _get(Field.DestinationTag);
  set destinationTag(int destinationTag) => _put(Field.DestinationTag, destinationTag);

  Hash256 get invoiceId => _get(Field.InvoiceID);
  set invoiceId(Hash256 invoiceId) => _put(Field.InvoiceID, invoiceId);

  Payment.fromJson(dynamic json) : super._fromJson(json) {
    _assertTransactionType(TransactionType.PAYMENT);
  }

}