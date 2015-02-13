part of ripplelib.remote;


/**
 * The Account class tracks the state of a Ripple account and enables transactions to be made on its behalf.
 *
 *
 * ## Features
 *
 *  - subscribe to updates to the AccountRoot entry for the account
 *  - subscribe to transactions relevant for the account
 *  - subscribe to transactions made by the account
 *  - subscribe to sent or received payments from the account
 *  - calculate the complete balance sheet of the account
 *  - retrieve a list of transactions for the account
 * (When the private key is provided as well:)
 *  - make (and sign) transactions on behalf of the account
 *
 *
 * ## Usage examples
 *
 * ### Retrieving balance sheet
 *
 *     new Account(myAccountId, remote: myRemote)..startTracking((account) {
 *       account.balancesByIssuer.forEach((Issue issue, Decimal amount) {
 *         print("$myAccount has $amount ${issue.currency} at gateway ${issue.issuer}");
 *       });
 *     });
 *
 * ### Making a payment
 *
 *     new Account(myAccountId, key: myPrivateKey, remote: myRemote)..startTracking((account) {
 *       var payment = account.startPayment(destinationAccount, paymentAmount).listen((PaymentOption option) {
 *         addOptionToPaymentUI(option, onConfirm: (opt) => opt.confirm().then((response) {
 *           if(response.successful) {
 *             print("Transaction made successfully!");
 *           }
 *         }), onAbort: payment.cancel);
 *       });
 *     });
 *
 * ### Traversing the latest transactions of an account
 *
 *     int remainingTransactions = 50;
 *     new Account(myAccountId, key: myPrivateKey, remote: myRemote)..startTracking((account) {
 *       account.findTransactions(forward: false, limit: remainingTransactions).listen((TransactionPage page) {
 *         for(TransactionResult tx in page.transactions) {
 *           if(remainingTransactions-- > 0) {
 *             print(tx);
 *           } else {
 *             break;
 *           }
 *         }
 *         if(remainingTransactions > 0) {
 *           page.requestNext();
 *         }
 *       });
 *     });
 *
 *
 * Note: This implementation is targeted towards regular user accounts. Most rippled remote servers impose
 * limits to the amount of data you can retrieve (like a max number of trust lines), what makes
 * it less usable for gateway accounts.
 */
class Account extends Object with Events {

  static final log = new Logger("ripplelib.account");

  static final EventType OnUpdate              = new EventType<Account>();
  static final EventType OnInfoUpdate          = new EventType<Account>();
  static final EventType OnBalanceUpdate       = new EventType<Account>();
  static final EventType OnTransaction         = new EventType<TransactionResult>();
  static final EventType OnOwnTransaction      = new EventType<TransactionResult>();
  static final EventType OnPaymentReceived     = new EventType<TransactionResult<Payment>>();
  static final EventType OnPaymentSent         = new EventType<TransactionResult<Payment>>();

  Stream<Account>                    get onUpdate              => on(OnUpdate);
  Stream<Account>                    get onInfoUpdate          => on(OnInfoUpdate);
  Stream<Account>                    get onBalanceUpdate       => on(OnBalanceUpdate);
  Stream<TransactionResult>          get onTransaction         => on(OnTransaction);
  Stream<TransactionResult>          get onOwnTransaction      => on(OnOwnTransaction);
  Stream<TransactionResult<Payment>> get onPaymentReceived     => on(OnPaymentReceived);
  Stream<TransactionResult<Payment>> get onPaymentSent         => on(OnPaymentReceived);

  final AccountID id;

  // the main account ledger entry
  AccountRoot _root;
  AccountRoot get info => _root;

  Map<Issue, TrustLine> _trust;
  Map<Issue, TrustLine> get trustLines => new UnmodifiableMapView(_trust);

  Remote _remote;
  StreamSubscription _txSub;

  Account(AccountID this.id, {KeyPair key, Remote remote}) {
    _remote = remote;
    if(key != null)
      this.key = key;
    on(OnInfoUpdate,    (t) => emit(OnUpdate, t));
    on(OnBalanceUpdate, (t) => emit(OnUpdate, t));
  }

  Account.fromKeyPair(KeyPair key, {Remote remote}) : id = key.account {
    this.key = key;
  }

  Future<Account> startTracking({Remote remote}) {
    if(_txSub != null)
      throw new StateError("Already tracking.");
    if(remote != null)
      _remote = remote;
    log.info("Start tracking account $id on $_remote");
    _txSub = _remote.onValidatedTransaction.where(isRelevantTransaction).listen(_handleRelevantTransaction);
    return Future.wait([
      update(),
      _remote.subscriptions.addAccount(id)
    ]).then((_) => this);
  }

  void stopTracking() {
    _remote.subscriptions.removeAccount(id);
    _txSub.cancel();
    _txSub = null;
  }

  Future<Account> update() => Future.wait([
      _remote.requestAccountInfo(id, ledger: LedgerSelector.VALIDATED).then((Response response) {
        _handleNewAccountRoot(response.result.account_data);
      }),
      _remote.requestAccountLines(id, ledger: LedgerSelector.VALIDATED).then((Response response) {
        _updateTrustLines(response.result.lines);
      })
    ]).then((_) {
      log.fine("Updated account root and trust lines of $id");
      return this;
  });

  Map<String, Decimal> get balances {
    Map<String, Decimal> balances = new Map<String, Decimal>();
    balances["XRP"] = info.balance.value;
    trustLines.forEach((Issue issue, TrustLine line) {
      var iso = line.currency.isoCode;
      var bal = balances.containsKey(iso) ? balances[iso] : new Decimal.fromInt(0);
      balances[iso] = bal + line.balance;
    });
    return balances;
  }

  Map<Issue, Decimal> get balancesByIssuer {
    Map<Issue, Decimal> balances = new Map<Issue, Decimal>();
    balances[Issue.XRP] = info.balance.value;
    trustLines.forEach((Issue issue, TrustLine line) {
      var bal = balances.containsKey(issue) ? balances[issue] : new Decimal.fromInt(0);
      balances[issue] = bal + line.balance;
    });
    return balances;
  }

  /**
   * Retrieve transactions from this account.
   *
   * Results are presented as pages.
   *
   * @param limit The number of transactions per page.
   */
  Stream<TransactionPage> findTransactions({int minLedgerIndex: -1, int limit, bool forward: false, bool binary: false}) =>
      new _PagedTransactionStream._withRequest(_remote.makeAccountTransactionsRequest(
          id, minLedgerIndex: minLedgerIndex, limit: limit, forward: forward, binary: binary));

  /* SPENDING */

  KeyPair _key;

  bool get hasKey => key != null;

  KeyPair get key => _key;
  void set key(KeyPair key) {
    if(key.account != id)
      throw new ArgumentError("Wrong key for this account");
    if(!key.hasPrivateKey)
      throw new ArgumentError("A key provided to account must be a private key");
    _key = key;
  }

  Future<Response> submitTransaction(Transaction tx, {KeyPair key}) {
    KeyPair useKey;
    if(key != null) {
      if(key.account == id) {
        useKey = key;
      } else {
        throw new ArgumentError("The provided key is not for this account");
      }
    } else if(hasKey) {
      useKey = this.key;
    } else {
      throw new StateError("Cannot make transactions without private key");
    }
    return update().then((_) {
      tx.account = id;
      tx.sequence = _root.sequence + 1;
      tx.sign(useKey);
      log.fine("Submitting transaction for $id: $tx");
      return _remote.requestSubmitRaw(tx.toBytes());
    });
  }

  PaymentProcess startPayment(AccountID destination, Amount amount) =>
      new PaymentProcess._(_remote, this, destination, amount);

  /* TRANSACTION HANDLING */

  bool isRelevantTransaction(TransactionResult tx) => tx.isRelevantFor(id);

  void _handleRelevantTransaction(TransactionResult txr) {
    log.finer("Relevant transaction for $id: $txr");
    emit(OnTransaction, txr);
    Transaction tx = txr.transaction;
    if(tx.account == id) {
      emit(OnOwnTransaction, txr);
    }
    if(tx is Payment) {
      if(tx.destination == id) {
        emit(OnPaymentReceived, txr);
      }
      if(tx.account == id) {
        emit(OnPaymentSent, txr);
      }
    }
    txr.meta.affectedNodes.forEach((AffectedNode node) {
      if(node.ledgerEntryType == LedgerEntryType.ACCOUNT_ROOT && node.findFinalFields()["Account"] == id) {
        _handleNewAccountRoot(node);
      } else if(node.ledgerEntryType == LedgerEntryType.RIPPLE_STATE) {
        Map fields = node.findFinalFields();
        if(fields != null && (fields["HighLimit"].issuer == id || fields["LowLimit"].issuer == id)) {
          _updateTrustLine(new TrustLine.fromRippleState(id, node.constructLedgerEntry()));
        }
      }
    });
  }

  void _handleNewAccountRoot(dynamic accountRoot) {
    if(accountRoot is AccountRoot) {
      _updateAccountRoot(accountRoot);
    } else if(accountRoot is AffectedNode) {
      _updateAccountRoot(accountRoot.constructLedgerEntry());
    } else {
      log.warning("Unrecognized account root type: $accountRoot");
    }
  }

  void _updateAccountRoot(AccountRoot newRoot) {
    bool balanceChanged = _root != null && _root.balance != newRoot.balance;
    _root = newRoot;
    emit(OnInfoUpdate, this);
    if(balanceChanged)
      emit(OnBalanceUpdate, this);
  }

  void _updateTrustLine(TrustLine line) {
    if(_trust[line.issue] != line) {
      _trust[line.issue] = line;
      emit(OnBalanceUpdate, this);
    }
  }

  void _updateTrustLines(Iterable<TrustLine> lines) {
    Map mapLines(Iterable<TrustLine> lines) {
      Map result = new Map();
      lines.forEach((TrustLine line) {
        result[line.issue] = line;
      });
      return result;
    }
    if(_trust == null) {
      _trust = mapLines(lines);
      emit(OnBalanceUpdate, this);
    } else if(_trust.length != lines.length) {
      _trust = mapLines(lines);
      emit(OnBalanceUpdate, this);
    } else {
      for(TrustLine line in lines) {
        if(_trust[line.issue] != line) {
          _trust = mapLines(lines);
          emit(OnBalanceUpdate, this);
          break;
        }
      }
    }
  }



}