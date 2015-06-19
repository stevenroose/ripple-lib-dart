part of ripplelib.remote;


class LedgerInfo {

  final Hash256 hash;
  final int index;
  final DateTime time;
  final int transactionCount;

  const LedgerInfo(Hash256 this.hash, int this.index, DateTime this.time, int this.transactionCount);

  factory LedgerInfo._fromServerInfoJson(JsonObject json) =>
      new LedgerInfo(json["hash"],
                     json["seq"],
                     new DateTime.now().subtract(new Duration(seconds: json["age"])),
                     json["txn_count"]);

factory LedgerInfo._fromLedgerClosedJson(JsonObject json) =>
     new LedgerInfo(json["hash"],
                    json["ledger_index"],
                    json["ledger_time"],
                    json["txn_count"]);

  Duration get age => new DateTime.now().difference(time);

  @override
  bool operator ==(other) => other is LedgerInfo && hash == other.hash;

  @override
  int get hashCode => hash.hashCode;


}