part of ripplelib.remote;


class OrderBook extends Object with Events {

  static final EventType OnOpened = new EventType<OrderBook>();
  static final EventType OnUpdate = new EventType<OrderBook>();
  static final EventType OnClosed = new EventType<OrderBook>();

  final OrderBookDetails _details;

  // the Remote we communicate with
  Remote _remote;
  // all the subscriptions that help us and should be closed when we end
  List<StreamSubscription> _subs = new List<StreamSubscription>();
  bool _forceKeepOpen;

  OrderBook(Issue takerGets, Issue takerPays, [bool both = false, Remote remote])
      : _details = new OrderBookDetails(takerGets, takerPays, both) {
    _remote = remote;
  }

  OrderBookDetails get details => _details;
  Issue get takerGets => _details.takerGets;
  Issue get takerPays => _details.takerPays;

  Stream<OrderBook> get onOpened => on(OnOpened);
  Stream<OrderBook> get onUpdate => on(OnUpdate);
  Stream<OrderBook> get onClosed => on(OnClosed);

  void open({bool keepOpen: false, Remote remote}) {
    if(!_subs.isEmpty)
      throw new StateError("OrderBook is already open.");
    if(remote != null)
      _remote = remote;
    _forceKeepOpen = keepOpen;
    _remote.subscriptions.addOrderBook(takerGets, takerPays, snapshot: true).then((Response response) {
      if(!response.successful)
        throw new StateError("Something went wrong opening OrderBook: ${response.error}");
      _handleInitialBookData(response.result.offers);
      // report opened successful
      emit(OnOpened, this);
      // sub to future updates
      _subs.add(_remote.onProposedTransaction.listen(_handleUpdate));
      // close when the remote disconnects
      _subs.add(_remote.onDisconnected.listen((r) => _closed()));
    });
  }

  /*************************
   * THE CLOSING MECHANISM *
   *************************

   * These are the promises we want to make
   * - whenever the subscription to updates ends, we close
   *    -> unless forceKeepOpen() has been called
   * - when close() is called, we overwrite forceKeepOpen and close no matter what
   */

  /**
   * Close the OrderBook.
   */
  void close() {
    _forceKeepOpen = false;
    _remote.subscriptions.removeOrderBook(takerGets, takerPays);
  }


  void _closed() {
    _subs.forEach((s) => s.cancel());
    _subs.clear();
    emit(OnClosed, this);
  }

  void _startUnsubMonitor() {
    _subs.add(_remote.subscriptions.onUnsubscribed.listen((JsonObject unsubs) {
      if(unsubs.books.any(_matchingBook)) {
        // unsubscribed from updates for this order book
        if(_forceKeepOpen) {
          _remote.subscriptions.addOrderBook(takerGets, takerPays, snapshot: false);
        } else {
          _closed();
        }
      }
    }));
  }

  bool _matchingBook(JsonObject book) => book != null &&
      (
        ( book.taker_gets == takerGets && book.taker_pays == takerPays ) ||
        ( book.taker_gets == takerPays && book.taker_pays == takerGets &&
            (_details.both || (book.containsKey("both") && book.both)) )
      );


  void _handleInitialBookData(List<JsonObject> offers) {

  }

  void _handleUpdate(TransactionResult tx) {

  }

}