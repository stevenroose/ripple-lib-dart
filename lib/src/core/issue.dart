part of ripplelib.core;

class Issue {

  static final Issue XRP = new Issue(Currency.XRP, Account.XRP_ISSUER);

  final Currency currency;
  final Account issuer;

  Issue(Currency this.currency, Account this.issuer);

  factory Issue.fromString(String issue) {
    List<String> split = issue.split("/");
    if(split[0] == "XRP") {
      if(split.length > 1 && split[1] != Account.XRP_ISSUER.address)
        throw new ArgumentError("XRP cannot have an issuer!");
      return XRP;
    }
    return new Issue(new Currency.iso(split[0]),
        split.length < 2 ? null : new Account(split[1]));
  }

  bool get isNative => this == XRP;

  bool get hasIssuer => issuer != null;

  Amount amount(Decimal amount) => new Amount(amount, currency, issuer);

  @override
  String toString() => isNative || issuer == null ? currency.toString() : "$currency/$issuer";

  @override
  bool operator ==(Object other) => other is Issue &&
      other.issuer == issuer && other.currency == currency;

  @override
  int get hashCode => currency.hashCode ^ (issuer == null ? 0 : issuer.hashCode);

  /* JSON */

  Object toJson() {
    Map result = {"currency": currency};
    if(!isNative)
      result["issuer"] = issuer;
    return result;
  }
  factory Issue.fromJson(var json) => new Issue(json["currency"], json.length > 1 ? json["issuer"] : Account.XRP_ISSUER);

}