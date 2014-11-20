part of ripplelib.remote;

class SubscriptionManager extends Object with Events {

  static final EventType OnSubscribed   = new EventType<JsonObject>();
  static final EventType OnUnsubscribed = new EventType<JsonObject>();

  Stream<JsonObject> get onSubscribed   => on(OnSubscribed);
  Stream<JsonObject> get onUnsubscribed => on(OnUnsubscribed);

  Set<SubscriptionStream> _streams = new Set<SubscriptionStream>();
  Set<Account> _accounts = new Set<Account>();
  Set<Account> _accountsProposed = new Set<Account>();

  void addStream(SubscriptionStream stream) {
    if(_streams.add(stream))
      emit(OnSubscribed, _generateSubscriptionObject([stream], null, null));
  }

  void removeStream(SubscriptionStream stream) {
    if(_streams.remove(stream))
      emit(OnUnsubscribed, _generateSubscriptionObject([stream], null, null));
  }

  void addAccount(Account account, [bool proposed = false]) {
    if(proposed) {
      if (_accountsProposed.add(account))
        emit(OnSubscribed, _generateSubscriptionObject(null, null, [account]));
    } else {
      if (_accounts.add(account))
        emit(OnSubscribed, _generateSubscriptionObject(null, [account], null));
    }
  }

  void removeAccount(Account account, [bool proposed = false]) {
    if(proposed) {
      if (_accountsProposed.remove(account))
        emit(OnUnsubscribed, _generateSubscriptionObject(null, null, [account]));
    } else {
      if (_accounts.remove(account))
        emit(OnUnsubscribed, _generateSubscriptionObject(null, [account], null));
    }
  }

  JsonObject get subscriptionObject => _generateSubscriptionObject(_streams, _accounts, _accountsProposed);

  // helper method

  static JsonObject _generateSubscriptionObject(Iterable<SubscriptionStream> streams, Iterable<Account> accounts,
      Iterable<Account> accountsProposed) {
    JsonObject subs = new JsonObject();
    if(streams != null && !streams.isEmpty)
      subs.streams = streams.toList();
    if(accounts != null && !accounts.isEmpty)
      subs.accounts = accounts.toList();
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