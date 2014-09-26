part of ripple;

class Issue {

  static final Issue XRP = new Issue(Currency.XRP, Account.XRP_ISSUER);

  final Currency currency;
  final Account issuer;

  Issue(Currency this.currency, Account this.issuer);

  factory Issue.fromString(String issue) {
    List<String> split = issue.split("/");
    return new Issue(new Currency.iso(split[0]), new Account(split[1]));
  }

  bool get isNative => this == XRP;

  Amount amount(Decimal amount) => new Amount(amount, currency, issuer);

  @override
  String toString() => isNative ? currency.toString() : "$currency/$issuer";

  @override
  bool operator ==(Issue other) => other is Issue &&
      other.issuer == issuer && other.currency == currency;

  @override
  int get hashCode => currency.hashCode ^ issuer.hashCode;

  /* JSON */

  Object toJson() {
    Map result = {"currency": currency};
    if(!isNative)
      result["issuer"] = issuer;
    return result;
  }
  factory Issue.fromJson(var json) => new Issue(json["currency"], json.length > 1 ? json["issuer"] : Account.XRP_ISSUER);

}