/**
 * This is a test that just runs the RPC requests.
 *
 * It's no real unit tests, but it covers a lot of the code for JSON encoding and decoding,
 * binary serialization, working of classes, ...
 */
library ripplelib.test.remote.requests;

import "package:test/test.dart";

import "package:ripplelib/json.dart";
import "package:ripplelib/remote.dart";
import "dart:async";
import "dart:convert";
import "package:cryptoutils/cryptoutils.dart";

import "package:logging/logging.dart";


AccountID me = new AccountID("rK1w3Zcd6eiEJ2N29gipexpXQuR7gPDLQg");
Issue myBTC = new Issue.fromString("BTC/rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B");
Hash256 testTxHash = new Hash256("2F128C9A157D9F0309DEC6D89286DF9297D9A5D62A7393EF53CA911488D4AB32");


JsonEncoder prettyPrinter = new RippleJsonEncoder.withIndent('  ');
void prettyPrint(dynamic json) {
  print(prettyPrinter.convert(json));
}

Future main() async {
  Remote remote = await Remote.connect("ws://s1.ripple.com:443/");
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);
  remote.onErrorMessage.listen(Logger.root.warning);

  group("ripplelib.test.remote.requests", () {
    test("requestAccountCurrencies", () {
      expect(remote.requestAccountCurrencies(me).then((response) {
        expect(response.result.receive_currencies, contains(myBTC.currency));
        expect(response.result.receive_currencies[0].isoCode, isNotNull);
      }), completes);
    });
    test("requestAccountInfo", () {
      expect(remote.requestAccountInfo(me).then((response) {
        expect(response.result.account_data, new isInstanceOf<AccountRootEntry>());
        AccountRootEntry root = response.result.account_data as AccountRootEntry;
        expect(root.balance > 100, isTrue);
        expect(root.previousTxId.bytes.length, equals(32));
        expect(root.account, equals(me));
      }), completes);
    });
    test("requestAccountLines", () {
      expect(remote.requestAccountLines(me).then((response) {
        expect(response.result.lines[2].balance.precision, isNotNull);
        //TODO fix TrustLine object
      }), completes);
    });
    test("requestAccountOffers", () {
      expect(remote.requestAccountOffers(me).then((response) {
        expect(response.result.offers[0].takerPays.issuer.address, isNotNull);
      }), completes);
    });
    test("requestAccountTransactions", () {
      expect(remote.requestAccountTransactions(me, minLedgerIndex: -1).then((response) {
        //      print(response.result);
        var hashes = response.result.transactions.map((tx) => tx.tx.hash);
        expect(hashes, contains(testTxHash),
            reason: "This error can be history-related. Update the test information.");
      }), completes);
    });
    test("requestBookOffers", () {
      expect(remote.requestBookOffers(myBTC, Issue.XRP).then((response) {
        //      print(response.result);
        expect(response.result.offers.length, isPositive);
        //TODO fix ledger entries
      }), completes);
    });
    test("requestLedger", () {
      expect(remote.requestLedger(LedgerSelector.VALIDATED).then((response) {
        expect(response.result.ledger.closed, isTrue);
        expect(response.result.ledger.close_time.isBefore(new DateTime.now()), isTrue);
        expect(response.result.ledger.closed, isTrue);
        expect(response.result.ledger.closed, isTrue);
        expect(response.result.ledger.total_coins, lessThan(Amount.MAX_NATIVE_VALUE * Amount.XRP_IN_DROPS));
      }), completes);
    });
    test("requestLedgerClosed", () {
      expect(remote.requestLedgerClosed().then((response) {
        expect(response.result.ledger_hash, new isInstanceOf<Hash256>());
      }), completes);
    });
    test("requestLedgerCurrent", () {
      expect(remote.requestLedgerCurrent().then((response) {
        expect(response.result.ledger_current_index, isPositive);
      }), completes);
    });
    test("requestLedgerData", () {
      expect(remote.requestLedgerData(LedgerSelector.VALIDATED).then((response) {
        expect(response.result.ledger_hash, new isInstanceOf<Hash256>());
      }), completes);
    });
    test("requestPathFind", () {
      expect(remote.requestPathFind(me, myBTC.issuer, new Amount.XRP(100)).then((response) {
        //TODO fix path finding
        //      print(response.result);
//        prettyPrint(response);
      }), completes);
    });
    test("requestPing", () {
      expect(remote.requestPing().then((response) {
        expect(response.result, isEmpty);
      }), completes);
    });
    test("requestRipplePathFind", () {
      expect(remote.requestRipplePathFind(me, myBTC.issuer, new Amount.XRP(100)).then((response) {
//        expect(response.result.alternatives[0].paths_computed.length, isPositive);
//        expect(response.result.destination_currencies, contains(Currency.XRP));
        //      print(response.result);
//        prettyPrint(response);
      }), completes);
    });
    //TODO complete submit, sign, ...
    test("requestTransaction", () {
      expect(remote.requestTransaction(testTxHash).then((response) {
        //TODO make issue about json revivers => https://github.com/ripple/rippled/pull/681
        //      print(response.result);
//        prettyPrint(response);
      }), completes);
    });
    test("requestTransactionEntry", () {
      expect(remote.requestTransactionEntry(testTxHash, new LedgerSelector.sequence(8024443)).then((response) {
        //TODO fix ledger entries 8024443
        //      print(response.result);
//        prettyPrint(response);
      }), completes);
    });
    test("requestTransactionHistory", () {
      expect(remote.requestTransactionHistory(LedgerSelector.VALIDATED).then((response) {
        //      print(response.result);
        expect(response.result, isNull);
//        prettyPrint(response);
      }), completes);
    });
  });
}