part of ripplelib.remote;

/**
 *
 *
 */
abstract class Remote extends Object with Events {

  static final Logger logger = () {
    hierarchicalLoggingEnabled = true;
    return new Logger("ripplelib-remote");
  }();
  // (Remote).toString() gives just "Remote" instead of the full name
  static void _log(String message, [Level level = Level.INFO]) => logger.log(level, message);

  static final EventType OnConnected            = new EventType<Remote>();
  static final EventType OnDisconnected         = new EventType<Remote>();
  static final EventType OnMessage              = new EventType<JsonObject>();
  static final EventType OnSendMessage          = new EventType<JsonObject>();
  static final EventType OnLedgerClosed         = new EventType(); //TODO
  static final EventType OnPathFindStatus       = new EventType<JsonObject>();
  static final EventType OnSubscribed           = new EventType<JsonObject>();
  static final EventType OnUnsubscribed         = new EventType<JsonObject>();
  static final EventType OnTransaction          = new EventType<TransactionResult>();
  static final EventType OnValidatedTransaction = new EventType<TransactionResult>();


  int _requestID = 0;
  LRUMap<int, Request> _pendingRequests = new LRUMap<int, Request>(capacity: 30);

  SubscriptionManager subscriptions;

  Remote() {
    subscriptions = _initSubscriptionManager();
  }

  /**
   * Create SubscriptionManager and define handlers for new subscriptions.
   */
  SubscriptionManager _initSubscriptionManager() => new SubscriptionManager()
    ..on(SubscriptionManager.OnSubscribed, (JsonObject subObject) {
      _log("Subscribing: $subObject", Level.FINE);
      Request req = newRequest(Command.SUBSCRIBE)..updateJson(subObject);
      req.request().then((Response response) {
        if(response.successful)
          emit(OnSubscribed, subObject);
      });
    })
    ..on(SubscriptionManager.OnUnsubscribed, (JsonObject subObject) {
      _log("Unsubscribing: $subObject", Level.FINE);
      Request req = newRequest(Command.UNSUBSCRIBE)..updateJson(subObject);
      req.request().then((Response response) {
        if(response.successful)
          emit(OnUnsubscribed, subObject);
      });
    });

  /* ABSTRACT METHODS */

  Future<Remote> connect();
  void disconnect();
  bool get isConnected;

  Future<Response> request(Request request) {
    _pendingRequests[request.id] = request;
    sendMessage(request);
    return request.once(Request.OnResponse);
  }

  /**
   * Send a message over the web socket.
   *
   * Accepts both raw Strings and JSON-serializable objects.
   */
  void sendMessage(dynamic message);

  /* message handling */

  void handleMessage(String messageString) {
    JsonObject message = const RippleJsonCodec().decode(messageString);
    emit(OnMessage, message);

    switch(MessageType.fromJsonKey(message.type)) {
      case MessageType.SERVER_STATUS:
        _updateServerInfo(message);
        break;
      case MessageType.LEDGER_CLOSED:
        emit(OnLedgerClosed, null);
        _updateServerInfo(message);
        //TODO
        break;
      case MessageType.RESPONSE:
        _handleResponse(message);
        break;
      case MessageType.TRANSACTION:
        _handleTransaction(message);
        break;
      case MessageType.PATH_FIND:
        emit(OnPathFindStatus, message);
        break;
      case MessageType.ERROR:
        _handleError(message);
        break;
      default:
        _log("Unhandled message: $message", Level.WARNING);
        break;
    }
  }

  void _handleResponse(JsonObject message) {
    Request request = _pendingRequests.remove(message.id);
    if(request == null) {
      _log("Received response to unrecognized request: $message", Level.WARNING);
      return;
    }
    request.handleResponse(message);
  }

  LRUMap<Hash256, bool> _latestTransactions = new LRUMap<Hash256, bool>(capacity: 100);

  void _handleTransaction(JsonObject message) {
    TransactionResult tx = new TransactionResult.fromJson(message);
    bool lastValidated = _latestTransactions[tx.hash];
    _latestTransactions[tx.hash] = tx.validated;
    // do nothing when already known as valid tx
    if(lastValidated == true)
      return;
    // emit the transaction as valid when valid
    if(tx.validated)
      emit(OnValidatedTransaction, tx);
    // emit transaction when not previously emitted
    if(lastValidated == null)
      emit(OnTransaction, tx);
  }

  void _handleError(JsonObject message) {
    _log("Received error: $message", Level.WARNING);
  }

  void _updateServerInfo(JsonObject message) {
    //TODO
  }

  Request newRequest(Command cmd) => new Request(this, cmd, _requestID++);

  /* ALL SPECIFIC REQUEST METHODS */

  Future<Response> requestAccountCurrencies(dynamic account) =>
      makeAccountCurrenciesRequest(account).request();

  Request makeAccountCurrenciesRequest(dynamic account) {
    Request req = newRequest(Command.ACCOUNT_CURRENCIES);
    req.account = account;
    return req;
  }

  Future<Response> requestAccountInfo(dynamic account, {LedgerSelector ledger, bool strict}) =>
      makeAccountInfoRequest(account, ledger: ledger, strict: strict).request();

  Request makeAccountInfoRequest(dynamic account, {LedgerSelector ledger, bool strict}) {
    Request req = newRequest(Command.ACCOUNT_INFO);
    req.account = account;
    if(ledger != null)
      req.ledger_index = ledger;
    if(strict != null)
      req.strict = strict;
    return req;
  }

  Future<Response> requestAccountLines(dynamic account, {dynamic peer, LedgerSelector ledger}) =>
      makeAccountLinesRequest(account, peer: peer, ledger: ledger).request();

  Request makeAccountLinesRequest(dynamic account, {dynamic peer, LedgerSelector ledger}) {
    Request req = newRequest(Command.ACCOUNT_LINES);
    req.account = account;
    if(peer != null)
      req.peer = peer;
    if(ledger != null)
      req.ledger_index = ledger;
    return req;
  }

  Future<Response> requestAccountOffers(dynamic account, {LedgerSelector ledger}) =>
      makeAccountOffersRequest(account, ledger: ledger).request();

  Request makeAccountOffersRequest(dynamic account, {LedgerSelector ledger}) {
    Request req = newRequest(Command.ACCOUNT_OFFERS);
    req.account = account;
    if(ledger != null)
      req.ledger_index = ledger;
    return req;
  }

  Future<Response> requestAccountTransactions(dynamic account, {int minLedgerIndex, int maxLedgerIndex, int limit, bool binary, bool forward}) =>
  makeAccountTransactionsRequest(account, minLedgerIndex: minLedgerIndex, maxLedgerIndex: maxLedgerIndex, limit: limit,
      binary: binary, forward: forward).request();

  Request makeAccountTransactionsRequest(dynamic account, {int minLedgerIndex, int maxLedgerIndex, int limit, bool binary, bool forward}) {
    Request req = newRequest(Command.ACCOUNT_TX);
    req.account = account;
    if(limit != null)
      req.limit = limit;
    if(minLedgerIndex != null)
      req.ledger_index_min = minLedgerIndex;
    if(maxLedgerIndex != null)
      req.ledger_index_max = maxLedgerIndex;
    if(binary != null)
      req.binary = binary;
    if(forward != null)
      req.forward = forward;
    return req;
  }

  Future<Response> requestBookOffers(Issue takerPays, Issue takerGets, {Account taker, LedgerSelector ledger, int limit, bool proof}) =>
      makeBookOffersRequest(takerPays, takerGets, taker: taker, ledger: ledger, limit: limit, proof: proof).request();

  Request makeBookOffersRequest(Issue takerPays, Issue takerGets, {Account taker, LedgerSelector ledger, int limit, bool proof}) {
    Request req = newRequest(Command.BOOK_OFFERS);
    req.taker_pays = takerPays;
    req.taker_gets = takerGets;
    if(taker != null)
      req.taker = taker;
    if(ledger != null)
      req.ledger_index = ledger;
    if(limit != null)
      req.limit = limit;
    if(proof != null)
      req.proof = proof;
    return req;
  }

  Future<Response> requestLedger(LedgerSelector ledger, {bool full, bool accounts, bool transactions, bool expand}) =>
      makeLedgerRequest(ledger, full: full, accounts: accounts, transactions: transactions, expand: expand).request();

  Request makeLedgerRequest(LedgerSelector ledger, {bool full, bool accounts, bool transactions, bool expand}) {
    Request req = newRequest(Command.LEDGER);
    req.ledger_index = ledger;
    if(full != null)
      req.full = full;
    if(accounts != null)
      req.accounts = accounts;
    if(transactions != null)
      req.transactions = transactions;
    if(expand != null)
      req["expand"] = expand; //.expand is defined in JsonObject
    return req;
  }

  Future<Response> requestLedgerClosed() => makeLedgerClosedRequest().request();

  Request makeLedgerClosedRequest() {
    Request req = newRequest(Command.LEDGER_CLOSED);
    return req;
  }

  Future<Response> requestLedgerCurrent() => makeLedgerCurrentRequest().request();

  Request makeLedgerCurrentRequest() {
    Request req = newRequest(Command.LEDGER_CURRENT);
    return req;
  }

  Future<Response> requestLedgerData(LedgerSelector ledger, {bool binary, int limit}) =>
      makeLedgerDataRequest(ledger, binary: binary, limit: limit).request();

  Request makeLedgerDataRequest(LedgerSelector ledger, {bool binary, int limit}) {
    Request req = newRequest(Command.LEDGER_CLOSED);
    if(binary != null)
      req.binary = binary;
    if(limit != null)
      req.limit = limit;
    return req;
  }

  /**
   * This is a more complex request. Finish it yourself according to the documentation
   * at [https://wiki.ripple.com/JSON_Messages#ledger_entry].
   */
  Request makeLedgerEntryRequest(Hash256 index, int ledgerIndex) {
    Request req = newRequest(Command.LEDGER_ENTRY);
    req.ledger_index = ledgerIndex;
    req.index = index;
    return req;
  }

  /**
   * Find payment paths.
   *
   * Returns a stream of [Alternative] objects that you can listen to.
   * Also, you can use the [handleError] method to intercept errors on the stream.
   *
   * Don't forget to close the stream when you are done.
   */
  PathFindStream findPaths(Account sourceAccount, Account destinationAccount, Amount amount,
                           {PathSet paths, List<Account> bridges}) =>
      new PathFindStream._withRequest(
          makePathFindRequest(sourceAccount, destinationAccount, amount, paths: paths, bridges: bridges));

  /**
   * It is advised to use [findPaths] instead.
   */
  Future<Response> requestPathFind(Account sourceAccount, Account destinationAccount, Amount amount,
                              {PathSet paths, List<Account> bridges}) =>
      makePathFindRequest(sourceAccount, destinationAccount, amount, paths: paths, bridges: bridges).request();

  Request makePathFindRequest(Account sourceAccount, Account destinationAccount, Amount amount,
                              {PathSet paths, List<Account> bridges}) {
    Request req = newRequest(Command.PATH_FIND);
    req.subcommand = "create";
    req.source_account = sourceAccount;
    req.destination_account = destinationAccount;
    req.destination_amount = amount;
    if(paths != null)
      req.paths = paths;
    if(bridges != null)
      req.bridges = bridges;
    return req;
  }

  Future<Response> requestPing() => makePingRequest().request();

  Request makePingRequest() {
    Request req = newRequest(Command.PING);
    return req;
  }

  Future<Response> requestRandom() => makeRandomRequest().request();

  Request makeRandomRequest() {
    Request req = newRequest(Command.RANDOM);
    return req;
  }

  Future<Response> requestRipplePathFind(Account sourceAccount, Account destinationAccount, Amount amount,
                                         {List<Issue> currencies, LedgerSelector ledger}) =>
      makeRipplePathFindRequest(sourceAccount, destinationAccount, amount, currencies, ledger: ledger).request();

  Request makeRipplePathFindRequest(Account sourceAccount, Account destinationAccount, Amount amount, List<Issue> currencies,
                                    {LedgerSelector ledger}) {
    Request req = newRequest(Command.RIPPLE_PATH_FIND);
    req.source_account = sourceAccount;
    req.destination_account = destinationAccount;
    req.destination_amount = amount;
    if(currencies != null)
      req.source_currencies = currencies;
    if(ledger != null) {
      if(ledger is _HashLedgerSelector)
        req.ledger_hash = ledger;
      else
        req.ledger_index = ledger;
    }
    return req;
  }

  Future<Response> requestSign(Transaction transaction, Secret secret, {bool offline}) =>
      makeSignRequest(transaction, secret, offline: offline).request();

  Request makeSignRequest(Transaction transaction, Secret secret, {bool offline}) {
    Request req = newRequest(Command.SIGN);
    req.tx_json = transaction;
    req.secret = secret;
    if(offline != null)
      req.offline = offline;
  }

  Future<Response> requestSubmit(Transaction transaction, Secret secret, {bool offline, bool failHard}) =>
      makeSubmitRequest(transaction, secret, offline: offline, failHard: failHard).request();

  Request makeSubmitRequest(Transaction transaction, Secret secret, {bool offline, bool failHard}) {
    Request req = newRequest(Command.SUBMIT);
    req.tx_json = transaction;
    req.secret = secret;
    if(offline != null)
      req.offline = offline;
    if(failHard != null)
      req.fail_hard = failHard;
  }

  Future<Response> requestTransaction(Hash256 txHash, {bool binary}) =>
  makeTransactionRequest(txHash, binary: binary).request();

  Request makeTransactionRequest(Hash256 txHash, {bool binary}) {
    Request req = newRequest(Command.TX);
    req.transaction = txHash;
    if(binary != null)
      req.binary = binary;
    return req;
  }

  Future<Response> requestTransactionEntry(Hash256 txHash, LedgerSelector ledger) =>
      makeTransactionEntryRequest(txHash, ledger).request();

  Request makeTransactionEntryRequest(Hash256 txHash, LedgerSelector ledger) {
    Request req = newRequest(Command.TRANSACTION_ENTRY);
    req.transaction_hash = txHash;
    if(ledger != null) {
      if(ledger is _HashLedgerSelector)
        req.ledger_hash = ledger;
      else
        req.ledger_index = ledger;
    }
    return req;
  }

  /**
   * Does not seem to work anymore.
   */
  @Deprecated("The rippled test instance does not recognize this request.")
  Future<Response> requestTransactionHistory(LedgerSelector startIndex) =>
      makeTransactionHistoryRequest(startIndex).request();

  Request makeTransactionHistoryRequest(LedgerSelector startIndex) {
    Request req = newRequest(Command.TX_HISTORY);
    req.start = startIndex;
    return req;
  }

  /* ADMIN REQUESTS (NOT COMPLETE) */

  Future<Response> requestServerInfo() => makeServerInfoRequest().request();

  Request makeServerInfoRequest() {
    Request req = newRequest(Command.SERVER_INFO);
    return req;
  }




}

class LedgerSelector {
  static const LedgerSelector CLOSED = const _DefaultLedgerSelector("closed");
  static const LedgerSelector CURRENT = const _DefaultLedgerSelector("current");
  static const LedgerSelector VALIDATED = const _DefaultLedgerSelector("validated");

  factory LedgerSelector.hash(Hash256 ledgerHash) => new _HashLedgerSelector(ledgerHash);
  factory LedgerSelector.sequence(int sequenceNumber) => new _SequenceLedgerSelector(sequenceNumber);

  final dynamic _jsonValue;
  const LedgerSelector._internal(dynamic this._jsonValue);

  @override
  String toString() => _jsonValue.toString();
  toJson() => _jsonValue;

  //not used (yet?)
  void applyTo(Request req) {
    if(this is _HashLedgerSelector)
      req.ledger_hash = this;
    else
      req.ledger_index = this;
  }
}

class _DefaultLedgerSelector extends LedgerSelector {
  const _DefaultLedgerSelector(String code) : super._internal(code);
}
class _HashLedgerSelector extends LedgerSelector {
  _HashLedgerSelector(Hash256 ledgerHash) : super._internal(ledgerHash.toHex());
}
class _SequenceLedgerSelector extends LedgerSelector {
  _SequenceLedgerSelector(int sequenceNumber) : super._internal(sequenceNumber);
}









