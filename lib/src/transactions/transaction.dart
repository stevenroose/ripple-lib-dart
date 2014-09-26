part of ripple;


abstract class Transaction {

  TransactionType get type;
  int flags;
  int sourceTag;
  // TODO List<String> memos
  Account account;
  int sequence;
  Sha256Hash previousTxId;
  int lastLedgerSequence;
  Amount fee;
  Key signingPubKey;
  Uint8List txSignature;

}

class TransactionType {
  final String name;
  final int code;

  //TODO change codes
  static const TransactionType PAYMENT = const TransactionType._internal("Payment", 0);
  static const TransactionType OFFER_CREATE = const TransactionType._internal("OfferCreate", 0);
  static const TransactionType OFFER_CANCEL = const TransactionType._internal("OfferCancel", 0);
  static const TransactionType TRUST_SET = const TransactionType._internal("TrustSet", 0);
  static const TransactionType ACCOUNT_SET = const TransactionType._internal("AccountSet", 0);

  const TransactionType._internal(this.name, this.code);

  String toString() => name;
}

class TransactionFlag {

  final int flag;

  const TransactionFlag._internal(this.flag);

  // UNIVERSAL FLAGS

  // SPECIFIC FLAGS

  // Payment
  static const DIRECT_RIPPLE = const TransactionFlag._internal(0x00010000);
  static const PARTIAL_PAYMENT = const TransactionFlag._internal(0x00020000);
  static const LIMIT_QUALITY = const TransactionFlag._internal(0x00040000);
  static const CIRCLE = const TransactionFlag._internal(0x00080000);


}
