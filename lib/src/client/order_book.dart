part of ripplelib.remote;


/**
 * An OrderBook keeps track of outstanding offers between two issues.
 * It's possible to monitor orders in either one or both directions.
 *
 * It is possible that external codes unsubscribes to the transactions that are required to keep an order book
 * updated. For example, if you create two OrderBook instances for the same issue pair, closing one of them would also
 * close the other one.
 * To prevent this, you can provide the [keepOpen] parameter to the constructor or the [open] method.
 *
 * ## Usage example
 *
 *     Issue bitstampBTC = new Issue("BTC/rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B");
 *     OrderBook book = new OrderBook(bitstampBTC, Issue.XRP, remote: myRemote).open().then((book) {
 *       // display initial values
 *       displaySortedOffersToGUI(book.bids, book.asks);
 *       // subscribe to updates
 *       book.onUpdate.listen((OrderBookUpdate update) {
 *         if(update.isBid) {
 *           updateBidListDisplay(update.oldEntry, update.newEntry);
 *         } else {
 *           updateAskListDisplay(update.oldEntry, update.newEntry);
 *         }
 *       });
 *     });
 */
class OrderBook extends Object with Events {

  static final log = new Logger("ripplelib.orderbook");

  static final EventType OnOpened = new EventType<OrderBook>();
  static final EventType OnUpdate = new EventType<OrderBookUpdate>();
  static final EventType OnClosed = new EventType<OrderBook>();

  /**
   * Compare two offers so that the better offer comes first.
   */
  static int _compareByRatio(Offer o1, Offer o2) => o2.ratio.compareTo(o1.ratio);

  Stream<OrderBook>       get onOpened => on(OnOpened);
  Stream<OrderBookUpdate> get onUpdate => on(OnUpdate);
  Stream<OrderBook>       get onClosed => on(OnClosed);

  final OrderBookDetails _details;

  // the Remote we communicate with
  Remote _remote;
  // all the subscriptions that help us and should be closed when we end
  List<StreamSubscription> _subs = new List<StreamSubscription>();
  bool _keepOpen;

  SplayTreeSet<Offer> _book;
  SplayTreeSet<Offer> _reverseBook;

  OrderBook(Issue takerGets, Issue takerPays, {bool both: true, Remote remote, bool keepOpen})
      : _details = new OrderBookDetails(takerGets, takerPays, both) {
    _remote = remote;
    _keepOpen = keepOpen;
    _book = new SplayTreeSet<Offer>(_compareByRatio);
    _reverseBook = new SplayTreeSet<Offer>(_compareByRatio);
  }

  OrderBookDetails get details => _details;
  Issue get takerGets => _details.takerGets;
  Issue get takerPays => _details.takerPays;

  /**
   * An ordered set of offers of the normal side of the order book.
   */
  Set<Offer> get bids => new UnmodifiableSetView(_book);
  /**
   * An ordered set of offers of the reverse side of the order book.
   * Null if [details.both] is false.
   */
  Set<Offer> get asks => new UnmodifiableSetView(_reverseBook);
  /** Same as [bids]. */
  Set<Offer> get offers => bids;

  Future<OrderBook> open({bool keepOpen: false, Remote remote}) {
    if(!_subs.isEmpty)
      throw new StateError("OrderBook is already open.");
    if(remote != null)
      _remote = remote;
    log.info("Opening order book $_details on $_remote.");
    _keepOpen = keepOpen;
    return _remote.subscriptions.addOrderBook(takerGets, takerPays, snapshot: true, both: details.both).then((Response response) {
      if(!response.successful)
        throw new StateError("Something went wrong opening OrderBook: ${response.error}");
      _handleInitialBookData(response);
      // report opened successful
      emit(OnOpened, this);
      log.info("Order book $_details on $_remote opened.");
      // sub to future updates
      _subs.add(_remote.onValidatedTransaction.listen(_handleTransaction));
      // close when the remote disconnects
      _subs.add(_remote.onDisconnected.listen((r) => _closed()));
      return this;
    });
  }

  /**
   * Close the OrderBook.
   */
  Future<Response> close() {
    log.info("Closing order book $_details on $_remote.");
    _keepOpen = false;
    _book.clear();
    _reverseBook.clear();
    return _remote.subscriptions.removeOrderBook(takerGets, takerPays);
  }

  void _closed() {
    _subs.forEach((s) => s.cancel());
    _subs.clear();
    emit(OnClosed, this);
    log.info("Order book $_details on $_remote closed.");
  }

  void _startUnsubMonitor() {
    _subs.add(_remote.subscriptions.onUnsubscribed.listen((JsonObject unsubs) {
      if(unsubs.books.any(_matchingBook)) {
        // unsubscribed from updates for this order book
        if(_keepOpen) {
          log.warning("Something tried to unsubscribe from this orderbook. Will resubscribe. ($details)");
          _remote.subscriptions.addOrderBook(takerGets, takerPays, snapshot: false).then((response) {
            if(response.successful) {
              log.info("Resubscribed to order book after unexpected unsubscribe");
            }
          });
        } else {
          log.info("Unsubscribed from orderbook.");
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


  void _handleInitialBookData(Response response) {
    assert(_book.isEmpty && (!details.both || _reverseBook.isEmpty));
    if(details.both) {
      _book.addAll(response.result.bids);
      _reverseBook.addAll(response.result.asks);
    } else {
      _book.addAll(response.result.offers);
    }
  }

  void _handleTransaction(TransactionResult tx) {
    tx.meta.affectedNodes.forEach((AffectedNode node) {
      if(node.ledgerEntryType == LedgerEntryType.OFFER) {
        Offer offer = node.constructLedgerEntry();
        Set<Offer> book =
            (offer.takerGets.issue == takerGets && offer.takerPays.issue == takerPays ? _book :
            (offer.takerGets.issue == takerPays && offer.takerPays.issue == takerGets ? _reverseBook : null) );
        if(book == null)
          return;
        OrderBookUpdate update;
        if(node is CreatedNode) {
          offer.previousTxId = tx.hash;
          book.add(offer);
          update = new OrderBookUpdate._(this, null, offer);
        } else if(node is DeletedNode) {
          var old = book.firstWhere((o) => o.previousTxId == offer.previousTxId, orElse: () => null);
          if(old == null) {
            // probably an offer outside the scope of the book (imposed by limits of the server)
            log.info("Deleted Offer not found in order book: $offer");
            return;
          }
          book.remove(old);
          update = new OrderBookUpdate._(this, old, null);
        } else {
          assert(node is ModifiedNode);
          var old = book.firstWhere((o) => o.previousTxId == offer.previousTxId, orElse: () => null);
          if(old == null) {
            // this is more problematic: modified offers most often are offers that are partially funded,
            //  so they are on the top of the order book
            log.info("Modified Offer not found in order book: $offer");
            book.add(offer);
            update = new OrderBookUpdate._(this, null, offer);
          } else {
            book.remove(old);
            book.add(offer);
            update = new OrderBookUpdate._(this, old, offer);
          }
        }
        emit(OnUpdate, update);
      }
    });
  }

}

class OrderBookUpdate {
  final OrderBook book;
  final Offer oldEntry;
  final Offer newEntry;

  OrderBookUpdate._(this.book, this.oldEntry, this.newEntry);

  bool get isBid {
    Offer entry = isDelete ? oldEntry : newEntry;
    return entry.takerGets.issue == book.takerGets &&
        entry.takerPays.issue == book.takerPays;
  }
  bool get isAsk => !isBid;

  bool get isUpdate => oldEntry != null && newEntry != null;
  bool get isDelete => newEntry == null;
  bool get isCreate => oldEntry == null;
}