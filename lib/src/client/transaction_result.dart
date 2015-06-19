part of ripplelib.remote;

class TransactionResult<T extends Transaction> extends RippleJsonObject implements Comparable<TransactionResult> {

  int ledgerIndex;
  Hash256 hash;

  T get transaction => this["transaction"];
  TransactionMeta get meta => this["meta"];
  bool get validated => this["validated"];

  EngineResult get engineResult => meta.transactionResult;

  TransactionResult(T transaction, TransactionMeta meta, [int this.ledgerIndex = -1, Hash256 this.hash]) {
    if(hash == null)
      hash = transaction.hash;
    this["transaction"] = transaction;
    this["meta"] = meta;
  }

  TransactionResult.fromJson(dynamic json) : super.fromMap(json, false) {
    hash = transaction.hash;
    ledgerIndex = json["ledger_index"];
  }

  /**
   * Compare this transaction to [other] based on the ledger index and transaction index.
   */
  @override
  int compareTo(TransactionResult other) {
    int i = this.ledgerIndex - other.ledgerIndex;
    return i != 0 ? i : this.meta.transactionIndex - other.meta.transactionIndex;
  }

  /**
   * This method is intended for regular user accounts.
   *
   * For gateway accounts, it is advised to use [involvesIssuer].
   */
  bool isRelevantFor(AccountID account) {
    Transaction tx = transaction;
    if(tx.account == account)
      return true;
    if(tx is Payment && tx.destination == account)
      return true;
    Function amountCheck = (am) => am.issuer == account;
    for(AffectedNode node in meta.affectedNodes) {
      if(node.ledgerEntryType == LedgerEntryType.ACCOUNT_ROOT &&
          node.findFinalFields()["Account"] == account) {
        return true;
      } else if(node.ledgerEntryType == LedgerEntryType.RIPPLE_STATE) {
        Map fields = node.findFinalFields();
        if(fields == null)
          continue;
        if(fields["HighLimit"].issuer == account || fields["LowLimit"].issuer == account)
          return true;
      }
    }
    return false;
  }

  bool involvesIssuer(AccountID issuer)    => _involves((am) => am.issuer == issuer);
  bool involvesCurrency(Currency currency) => _involves((am) => am.currency == currency);
  bool involvesIssue(Issue issue)          => _involves((am) => am.issue == issue);

  bool _involves(bool amountCheck(Amount)) {
    for(AffectedNode node in meta.affectedNodes) {
      if(node.ledgerEntryType == LedgerEntryType.OFFER) {
        Map fields = node.findFinalFields();
        if(fields == null)
          continue;
        if(amountCheck(fields["TakerGets"]) || amountCheck(fields["TakerPays"]))
          return true;
      } else if(node.ledgerEntryType == LedgerEntryType.RIPPLE_STATE) {
        Map fields = node.findFinalFields();
        if(fields == null)
          continue;
        if(amountCheck(fields["HighLimit"]) || amountCheck(fields["LowLimit"]))
          return true;
      }
    }
    return false;
  }
}