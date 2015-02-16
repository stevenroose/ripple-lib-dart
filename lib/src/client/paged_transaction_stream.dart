part of ripplelib.client;

@proxy
class _PagedTransactionStream implements Stream<TransactionPage> {

  StreamController<TransactionPage> _controller = new StreamController.broadcast();

  Request _originalRequest;

  _PagedTransactionStream._withRequest(Request request) {
    _originalRequest = request;
    request.request().then(_handleResponse);
  }

  void _requestNextPage(marker) {
    Request request = _originalRequest.copy();
    request.marker = marker;
    request.request().then(_handleResponse);
  }

  void _handleResponse(Response response) {
    TransactionPage page =
        new TransactionPage._(response.transactions, response.marker, _requestNextPage);
    _controller.add(page);
  }

  @override
  noSuchMethod(Invocation inv) => reflect(_controller.stream).delegate(inv);

}

class TransactionPage {
  final List<TransactionResult> transactions;
  final _marker;
  final Function _nextCallback;

  TransactionPage._(this.transactions, this._marker, this._nextCallback);

  bool get hasNext => _marker != null;

  void requestNext() {
    if(hasNext) {
      _nextCallback(_marker);
    }
  }
}