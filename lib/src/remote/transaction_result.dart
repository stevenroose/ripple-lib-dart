part of ripplelib.remote;

class TransactionResult extends RippleJsonObject implements Comparable<TransactionResult> {

  int ledgerIndex;
  Hash256 hash;

  Transaction get transaction => this["transaction"];
  TransactionMeta get meta => this["meta"];
  bool get validated => this["validated"];

  EngineResult get transactionResult => meta.transactionResult;

  TransactionType get type => transaction.type;

  TransactionResult(Transaction transaction, TransactionMeta meta, [int this.ledgerIndex = -1, Hash256 this.hash]) {
    if(hash == null)
      hash = transaction.hash;
    this["transaction"] = transaction;
    this["meta"] = meta;
  }

  TransactionResult.fromJson(dynamic json) : super.fromMap(json, false) {
    hash = transaction.hash;
  }

  int compareTo(TransactionResult other) {
    int i = this.ledgerIndex - other.ledgerIndex;
    if(i == 0)
      i = this.meta.transactionIndex - other.meta.transactionIndex;
    return i;
  }
}