part of ripplelib.client;


class SubscriptionManager extends Object with Events {

  static final EventType OnSubscribed   = new EventType<JsonObject>();
  static final EventType OnUnsubscribed = new EventType<JsonObject>();

  Stream<JsonObject> get onSubscribed   => on(OnSubscribed);
  Stream<JsonObject> get onUnsubscribed => on(OnUnsubscribed);

  final Remote _remote;

  Set<SubscriptionStream> _streams = new Set<SubscriptionStream>();
  Set<AccountID> _accounts = new Set<AccountID>();
  Set<AccountID> _accountsProposed = new Set<AccountID>();
  Set<OrderBookDetails> _orderBooks = new Set<OrderBookDetails>();

  SubscriptionManager._(this._remote);

  /**
   * This constructor does not make the actual subscriptions. Use [resubAll()] to do this.
   */
  SubscriptionManager._fromSubscriptionObject(this._remote, JsonObject subs) {
    if(subs.containsKey("streams"))
      _streams = new Set.from(subs.streams);
    if(subs.containsKey("accounts"))
      _accounts = new Set.from(subs.accounts);
    if(subs.containsKey("accounts_proposed"))
      _accountsProposed = new Set.from(subs.accounts_proposed);
    if(subs.containsKey("books"))
      _orderBooks = new Set.from(subs.books.map((j) => new OrderBookDetails.fromJson(j)));
  }

  Set<SubscriptionStream> get streams => new UnmodifiableSetView(_streams);
  Set<AccountID>          get accounts => new UnmodifiableSetView(_accounts);
  Set<AccountID>          get accountsProposed => new UnmodifiableSetView(_accountsProposed);
  Set<OrderBookDetails>   get orderBooks => new UnmodifiableSetView(_orderBooks);

  Future<Response> addStream(SubscriptionStream stream) {
    _streams.add(stream);
    return _subscribe(_generateSubscriptionObject(streams: [stream]));
  }

  Future<Response> removeStream(SubscriptionStream stream) {
    _streams.remove(stream);
    return _unsubscribe(_generateSubscriptionObject(streams: [stream]));
  }

  Future<Response> addAccount(AccountID account, [bool proposed = false]) {
    if(proposed) {
      _accountsProposed.add(account);
      return _subscribe(_generateSubscriptionObject(accountsProposed: [account]));
    } else {
      _accounts.add(account);
      return _subscribe(_generateSubscriptionObject(accounts: [account]));
    }
  }

  Future<Response> removeAccount(AccountID account, [bool proposed = false]) {
    if(proposed) {
      _accountsProposed.remove(account);
      return _unsubscribe(_generateSubscriptionObject(accountsProposed: [account]));
    } else {
      _accounts.remove(account);
      return _unsubscribe(_generateSubscriptionObject(accounts: [account]));
    }
  }

  Future<Response> addOrderBook(Issue takerGets, Issue takerPays, {AccountID taker, bool snapshot, bool both}) {
    OrderBookDetails book = new OrderBookDetails(takerGets, takerPays, both);
    _orderBooks.remove(book);
    _orderBooks.add(book);
    JsonObject bookObject = book.toJSON();
    bookObject.taker = taker != null ? taker : AccountID.ACCOUNT_ONE;
    if(snapshot != null)
      bookObject.snapshot = snapshot;
    return _subscribe(_generateSubscriptionObject(orderBooks: [bookObject]));
  }

  Future<Response> removeOrderBook(Issue takerGets, Issue takerPays, [bool both]) {
    OrderBookDetails book = _orderBooks.lookup(new OrderBookDetails(takerGets, takerPays));
    _orderBooks.remove(book);
    JsonObject bookObject = book.toJSON();
    if(both != null) // overwrite both value
      bookObject.both = both;
    return _unsubscribe(_generateSubscriptionObject(orderBooks: [bookObject]));
  }

  /**
   * Remove all subscriptions.
   */
  Future<Response> removeAll() {
    JsonObject subs = subscriptionObject;
    _streams.clear();
    _accounts.clear();
    _accountsProposed.clear();
    _orderBooks.clear();
    return _unsubscribe(subs);
  }

  /**
   * Explicitly resubscribe to all open subscriptions.
   */
  Future<Response> resubAll() {
    return _subscribe(subscriptionObject);
  }

  JsonObject get subscriptionObject => _generateSubscriptionObject(
    streams: _streams,
    accounts: _accounts,
    accountsProposed: _accountsProposed,
    orderBooks: _orderBooks.map((b) => b.toJSON()));

  // helper method

  Future<Response> _subscribe(JsonObject subObject) {
    Request req = _remote.newRequest(Command.SUBSCRIBE)
      ..updateJson(subObject);
    return req.request().then((Response response) {
      if(response.successful)
        emit(OnSubscribed, subObject);
      return response;
    });
  }

  Future<Response> _unsubscribe(JsonObject subObject) {
    Request req = _remote.newRequest(Command.UNSUBSCRIBE)
      ..updateJson(subObject);
    return req.request().then((Response response) {
      if(response.successful)
        emit(OnUnsubscribed, subObject);
      return response;
    });
  }

  static JsonObject _generateSubscriptionObject({Iterable<SubscriptionStream> streams, Iterable<AccountID> accounts,
      Iterable<AccountID> accountsProposed, Iterable<JsonObject> orderBooks}) {
    JsonObject subs = new JsonObject();
    if(streams != null && !streams.isEmpty)
      subs.streams = streams.toList();
    if(accounts != null && !accounts.isEmpty)
      subs.accounts = accounts.toList();
    if(accountsProposed != null && !accountsProposed.isEmpty)
      subs.accounts_proposed = accountsProposed.toList();
    if(orderBooks != null && !orderBooks.isEmpty)
      subs.books = orderBooks.toList();
    return subs;
  }

}

class SubscriptionStream extends Enum {
  static const SubscriptionStream SERVER                = const SubscriptionStream._("server");
  static const SubscriptionStream LEDGER                = const SubscriptionStream._("ledger");
  static const SubscriptionStream TRANSACTIONS          = const SubscriptionStream._("transactions");
  static const SubscriptionStream TRANSACTIONS_PROPOSED = const SubscriptionStream._("transactions_proposed");

  final String jsonValue;

  const SubscriptionStream._(String this.jsonValue);

  toJson() => jsonValue;

  static TransactionType fromJsonValue(String key) => TransactionType.values.firstWhere((tt) => tt.jsonValue == key);

  // required by Enum
  static SubscriptionStream valueOf(String subscriptionStream) => Enum.valueOf(SubscriptionStream, subscriptionStream);
  static List<SubscriptionStream> get values => Enum.values(SubscriptionStream);
}


/**
 * Use this class to store order books as subscriptions because they are identified only by taker_gets and taker_pays.
 */
class OrderBookDetails {
  // perhaps use the active orderbook class here
  final Issue takerGets;
  final Issue takerPays;
  final bool both;
  OrderBookDetails(this.takerGets, this.takerPays, [this.both]);
  @override
  bool operator ==(Object other) => other is OrderBookDetails &&
      takerGets == other.takerGets && takerPays == other.takerPays;
  @override
  int get hashCode => takerGets.hashCode ^ ( takerPays.hashCode * 13);
  @override
  String toString() => "OrderBook(get:$takerGets; pay:$takerPays)";

  OrderBookDetails.fromJson(Map json) :
      takerGets = json["taker_gets"],
      takerPays = json["taker_pays"],
      both = json["both"];
  JsonObject toJSON() {
    JsonObject json = new JsonObject()
      ..taker_gets = takerGets
      ..taker_pays = takerPays;
    if(both != null)
      json.both = both;
    return json;
  }
}