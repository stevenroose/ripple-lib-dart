part of ripplelib.client;


class PaymentProcess implements Stream<PaymentOption> {

  final Remote _remote;
  final Account _account;

  final AccountID destination;
  final Amount amount;

  PathFindStream _paths;

  StreamController<PaymentOption> _controller = new StreamController.broadcast();

  PaymentProcess._(this._remote, this._account, this.destination, this.amount) {
    _paths = _remote.findPaths(_account.id, destination, amount)..listen((PathFindStatus paths) {
      _controller.add(new PaymentOption._(this, paths));
    }, onError: _controller.addError);
  }

  void cancel() {
    _paths.close();
    _controller.close();
  }

  Future<Response> _finish(PathFindStatus status, Path preference, KeyPair key) {
    List<Path> finalPaths = preference != null ? [preference] : status.paths;
    Payment payment = new Payment(destination, amount, paths: finalPaths);//TODO specify sendMax?
    return _account.submitTransaction(payment, key: key).then((Response response) {
      if(response.successful) {
        cancel();
      }
      return response;
    });
  }

  @override
  noSuchMethod(Invocation inv) => reflect(_controller.stream).delegate(inv);

}

class PaymentOption {
  final PathFindStatus _status;

  Amount get cost => _status.sourceAmount;
  List<Path> get paths => _status.paths;

  final PaymentProcess _process;
  PaymentOption._(this._process, this._status);

  Future<Response> confirm([Path preferredPath, KeyPair key]) {
    if(preferredPath != null && !paths.contains(preferredPath))
      throw new ArgumentError("The given preferred path is not one of the provided options.");
    return _process._finish(_status, preferredPath, key);
  }
}