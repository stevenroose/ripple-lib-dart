part of ripplelib.remote;

/**
 *
 *
 */
class Remote extends Object with Events {

  static final Logger logger = new Logger("ripplelib.remote");

  static final EventType OnMessage              = new EventType<JsonObject>();
  static final EventType OnErrorMessage         = new EventType<JsonObject>();
  static final EventType OnSendMessage          = new EventType<JsonObject>();
  static final EventType OnServerUpdate         = new EventType<ServerInfo>();
  static final EventType OnLedgerClosed         = new EventType<ServerInfo>();
  static final EventType OnPathFindStatus       = new EventType<JsonObject>();
  static final EventType OnProposedTransaction  = new EventType<TransactionResult>();
  static final EventType OnValidatedTransaction = new EventType<TransactionResult>();

  Stream<JsonObject>        get onMessage              => on(OnMessage);
  Stream<JsonObject>        get onErrorMessage         => on(OnErrorMessage);
  Stream<JsonObject>        get onSendMessage          => on(OnSendMessage);
  Stream<ServerInfo>        get onServerUpdate         => on(OnServerUpdate);
  Stream<ServerInfo>        get onLedgerClosed         => on(OnLedgerClosed);
  Stream<JsonObject>        get onPathFindStatus       => on(OnPathFindStatus);
  Stream<TransactionResult> get onProposedTransaction  => on(OnProposedTransaction);
  Stream<TransactionResult> get onValidatedTransaction => on(OnValidatedTransaction);


  WebSocket _ws;

  int _requestID = 0;
  LRUMap<int, Request> _pendingRequests = new LRUMap<int, Request>(capacity: 50);


  static Future<Remote> connect(dynamic url, {bool isTrusted: false}) async {
    WebSocket ws = await WebSocket.connect(url);
    logger.info("Connected to websocket at $url");
    return new Remote.withExistingWebSocket(ws, isTrusted: isTrusted);
  }

  Remote.withExistingWebSocket(WebSocket this._ws, {bool isTrusted: false}) {
    // initialisers
    _trusted = isTrusted;
    _subscriptionManager = new SubscriptionManager._(this);
    // listen on socket
    _ws.listen((message) {
      logger.finer("Message received: $message");
      _handleMessage(message);
    }, onError: (error) => logger.warning("Error with WebSocket: $error"));
    // make initial server info request
    requestServerInfo();
  }

  Uri get url => _ws.url;

  /**
   * Calculated fees are multiplied with this value to incorporate an increase in base fee.
   * F.e. when the load increases and we did not yet receive a server status update.
   */
  double feeCushion = 1.2;

  bool _trusted;
  bool get isTrusted => _trusted;

  @override
  String toString() => "Ripple remote on $url";

  SubscriptionManager _subscriptionManager;
  SubscriptionManager get subscriptions => _subscriptionManager;

  ServerInfo _info;
  ServerInfo get info => _info;

  Future<Response> request(Request request) {
    _pendingRequests[request.id] = request;
    sendMessage(request);
    return request.onResponse.catchError((error) {
      emit(OnErrorMessage, error);
      throw error;
    });
  }

  /**
   * Send a message over the web socket.
   *
   * Accepts both raw Strings and JSON-serializable objects.
   */
  void sendMessage(dynamic/*String|RippleJsonMessage|RippleSerializable*/ message) {
    String messageString;
    if(message is String) {
      messageString = message;
      message = const RippleJsonCodec().decode(messageString);
    } else {
      messageString = const RippleJsonCodec().encode(message);
    }
    this.emit(Remote.OnSendMessage, message);
    _ws.add(messageString);
    logger.finer("Message sent: $messageString");
  }

  /* message handling */

  void _handleMessage(String messageString) {
    JsonObject message = const RippleJsonCodec().decode(messageString);
    emit(OnMessage, message);

    switch(MessageType.fromJsonKey(message.type)) {
      case MessageType.SERVER_STATUS:
        _updateServerInfo(message);
        break;
      case MessageType.LEDGER_CLOSED:
        _updateServerInfo(message);
        emit(OnLedgerClosed, _info);
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
        emit(OnErrorMessage, message);
        _handleError(message);
        break;
      default:
        logger.warning("Unhandled message: $message");
        break;
    }
  }

  void _handleResponse(JsonObject message) {
    Request request = _pendingRequests.remove(message.id);
    if(request != null) {
      request._handleResponse(message);
    } else {
      logger.warning("Received response to unrecognized request: $message");
    }
  }

  LRUMap<Hash256, bool> _latestTransactionsValidity = new LRUMap<Hash256, bool>(capacity: 100);

  void _handleTransaction(JsonObject message) {
    TransactionResult tx = new TransactionResult.fromJson(message);
    bool lastValidated = _latestTransactionsValidity[tx.hash];
    _latestTransactionsValidity[tx.hash] = tx.validated;
    // do nothing when already known as valid tx
    if(lastValidated == true)
      return;
    // emit the transaction as valid when valid
    if(tx.validated)
      emit(OnValidatedTransaction, tx);
    // emit transaction when not previously emitted
    if(lastValidated == null)
      emit(OnProposedTransaction, tx);
  }

  void _handleError(JsonObject message) {
    logger.warning("Received error: $message");
  }

  void _updateServerInfo(JsonObject message) {
    if(_info == null) {
      _info = new ServerInfo._(this);
      if(message.type != MessageType.RESPONSE || !message.result.containsKey("info")) {
        logger.warning("First ServerInfo update should be from a requestServerInfo message. Instead: $message");
      }
    }
    if(message.type == MessageType.RESPONSE && message.result.containsKey("info")) {
      _info._updateFromServerInfo(message.result.info);
    } else if(message.type == MessageType.LEDGER_CLOSED) {
      _info._updateFromLedgerClosed(message);
    } else if(message.type == MessageType.SERVER_STATUS) {
      _info._updateFromServerStatus(message);
    } else {
      logger.warning("Unrecognised ServerInfo update: $message");
      return;
    }
    emit(OnServerUpdate, _info);
  }

  Future<ServerInfo> ensureUpdatedServerInfo() {
    if(subscriptions.streams.contains(SubscriptionStream.SERVER) ||
       subscriptions.streams.contains(SubscriptionStream.LEDGER)) {
      return new Future.value(_info);
    } else {
      return requestServerInfo().then((_) => _info);
    }
  }

  Amount computeTxFee(Transaction tx) => info.computeTxFee(tx);

  Request newRequest(Command cmd) => new Request(this, cmd, _requestID++);

  /**
   *  ALL SPECIFIC REQUEST METHODS FOR THE RIPPLED API
   *
   *  For more info on all API calls, visit
   *  https://ripple.com/build/rippled-apis/
   */

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
    // make sure the Offer objects have the account field
    req.preProcessResponse((JsonObject response) {
      if(response.status == "success") {
        AccountID account = response.result.account;
        for(Offer offer in response.result.offers) {
          if(offer.account == null)
            offer.account = account;
        }
      }
      return response;
    });
    return req;
  }

  Future<Response> requestAccountTransactions(dynamic account,
                                              { int minLedgerIndex,
                                                int maxLedgerIndex,
                                                int limit,
                                                bool binary,
                                                bool forward}) =>
  makeAccountTransactionsRequest(account, minLedgerIndex: minLedgerIndex, maxLedgerIndex: maxLedgerIndex, limit: limit,
      binary: binary, forward: forward).request();

  Request makeAccountTransactionsRequest(dynamic account,
                                         { int minLedgerIndex,
                                           int maxLedgerIndex,
                                           int limit,
                                           bool binary,
                                           bool forward}) {
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

  Future<Response> requestBookOffers(Issue takerPays, Issue takerGets,
                                     { AccountID taker,
                                       LedgerSelector ledger,
                                       int limit,
                                       bool proof}) =>
      makeBookOffersRequest(takerPays, takerGets, taker: taker, ledger: ledger, limit: limit, proof: proof).request();

  Request makeBookOffersRequest(Issue takerPays, Issue takerGets,
                                { AccountID taker,
                                  LedgerSelector ledger,
                                  int limit,
                                  bool proof}) {
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
   * Returns a stream of [PathFindStatus] objects that you can listen to.
   * Also, you can use the [handleError] method to intercept errors on the stream.
   *
   * Don't forget to close the stream when you are done.
   */
  PathFindStream findPaths(AccountID sourceAccount, AccountID destinationAccount, Amount amount,
                           {PathSet paths, List<AccountID> bridges}) =>
      new PathFindStream._withRequest(
          makePathFindRequest(sourceAccount, destinationAccount, amount, paths: paths, bridges: bridges));

  /**
   * This request will initiate a stream of responses with found paths. It is advised to use either
   * [requestRipplePathFind] to do a one-time search or use [findPaths] to handle the response stream.
   */
  Future<Response> requestPathFind(AccountID sourceAccount, AccountID destinationAccount, Amount amount,
                              {PathSet paths, List<AccountID> bridges}) =>
      makePathFindRequest(sourceAccount, destinationAccount, amount, paths: paths, bridges: bridges).request();

  Request makePathFindRequest(AccountID sourceAccount, AccountID destinationAccount, Amount amount,
                              {PathSet paths, List<AccountID> bridges}) {
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

  /**
   * Do a one-time search for payment paths, it is not guaranteed that the best path will be provided.
   *
   * Use [findPaths] instead if you want an updating stream with the best payment path found.
   */
  Future<Response> requestRipplePathFind(AccountID sourceAccount, AccountID destinationAccount, Amount amount,
                                         {List<Issue> currencies, LedgerSelector ledger}) =>
      makeRipplePathFindRequest(sourceAccount, destinationAccount, amount, currencies, ledger: ledger).request();

  Request makeRipplePathFindRequest(AccountID sourceAccount, AccountID destinationAccount, Amount amount,
                                    List<Issue> currencies, {LedgerSelector ledger}) {
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

  Future<Response> requestSign(Transaction transaction, KeyPair key, {bool offline}) =>
      makeSignRequest(transaction, key, offline: offline).request();

  Request makeSignRequest(Transaction transaction, KeyPair key, {bool offline}) {
    if(!isTrusted)
      throw new UnsupportedError("This method is not supported on untrusted remotes!");
    Request req = newRequest(Command.SIGN);
    req.tx_json = transaction;
    req.secret = key.encodedPrivateKey;
    if(offline != null)
      req.offline = offline;
    return req;
  }

  Future<Response> requestSubmit(Transaction transaction, KeyPair key, {bool offline, bool failHard}) =>
      makeSubmitRequest(transaction: transaction, key: key, offline: offline, failHard: failHard).request();

  Future<Response> requestSubmitRaw(Uint8List signedTransaction) =>
      makeSubmitRequest(rawTx: signedTransaction).request();

  /**
   * If [rawTx] is given, the others are ignored.
   */
  Request makeSubmitRequest({Uint8List rawTx, Transaction transaction, KeyPair key, bool offline, bool failHard}) {
    Request req = newRequest(Command.SUBMIT);
    if(rawTx != null) {
      req.tx_blob = rawTx;
    } else {
      if(!isTrusted)
        throw new UnsupportedError("This method is not supported on untrusted remotes!");
      req.tx_json = transaction;
      req.secret = key.encodedPrivateKey;
      if(offline != null)
        req.offline = offline;
      if(failHard != null)
        req.fail_hard = failHard;
    }
    return req;
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

  Future<Response> requestServerInfo() => makeServerInfoRequest().request().then((response) {
    _updateServerInfo(response);
    return response;
  });

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









