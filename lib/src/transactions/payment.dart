part of ripple;


class Payment extends Transaction {

  TransactionType get type => TransactionType.PAYMENT;

  Account destination;
  Amount amount;
  Amount sendMax;
  Set<Path> paths;
  int destinationTag;
  Hash256 invoiceId;



}