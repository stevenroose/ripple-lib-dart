part of ripplelib.remote;


/**
 * Utility class around [Remote].
 *
 * The [Remote] class provides all the API functionality of a rippled server.
 * [Client] uses this API to provide an easy way to perform basic actions on the Ripple network.
 *
 * It can keep track of accounts, order books and the latest ledger.
 */
abstract class Client extends Object with Events {

  static final Logger log = new Logger("ripplelib.client");

  Remote _remote;

  /**
   * @param Use the param [remotes] to specify one or more remote servers.
   * Allowed types are a single [String] or [Remote] or an [Iterable] of them.
   */
  Client(dynamic/*Remote|String*/ remote, dynamic/*AccountID|String*/ mainAccount) {
    _remote = _castRemote(remote);
  }

  /**
   * Get the currently used Remote.
   */
  Remote get remote => _remote;

  Future<Client> connect() => _remote.connect().then((_) => this);


  /* STREAMS */

  Stream<TransactionResult> get onTransaction {
    if(!remote.subscriptions.streams.contains(SubscriptionStream.TRANSACTIONS))
      remote.subscriptions.addStream(SubscriptionStream.TRANSACTIONS);
    return remote.onValidatedTransaction;
  }


  /* ORDER BOOKS */

  Set<OrderBook> _openOrderBooks = new Set<OrderBook>();

  OrderBook openOrderBook(Issue takerGets, Issue takerPays, [bool both = false]) {
    OrderBook book = new OrderBook(takerGets, takerPays, both);
    _openOrderBooks.add(book);
    book.onClosed.listen(_openOrderBooks.remove);
    return book..open(remote: remote);
  }

  void closeAllOrderBooks() {
    while(_openOrderBooks.isNotEmpty) {
      _openOrderBooks.remove(_openOrderBooks.last..close());
    }
  }


  /* UTILITY FUNCTIONS */

  Remote _castRemote(dynamic remote) {
    if(remote is Remote)
      return remote;
    if(remote is String)
      return _createRemote(remote);
    throw new ArgumentError("Invalid type for remote argument: ${remote.runtimeType}");
  }

  /**
   * Abstract method to be implemented by either an io or an html version of the library.
   */
  Remote _createRemote(String uri);


}