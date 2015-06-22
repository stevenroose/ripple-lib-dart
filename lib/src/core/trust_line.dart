part of ripplelib.core;



class TrustLine {

  AccountID _issuer;
  Decimal _balance;
  Currency _currency;
  Decimal _limit;
  Decimal _peerLimit;
  int _inQuality;
  int _outQuality;
  bool _rippleAllowed;
  bool _peerRippleAllowed;

  AccountID get issuer => _issuer;
  Decimal get balance => _balance;
  Currency get currency => _currency;
  Decimal get limit => _limit;
  Decimal get peerLimit => _peerLimit;
  int get inQuality => _inQuality;
  int get outQuality => _outQuality;
  bool get rippleAllowed => _rippleAllowed;
  bool get peerRippleAllowed => _peerRippleAllowed;

  Issue get issue => new Issue(currency, issuer);

  TrustLine(AccountID issuer,
            dynamic balance,
            Currency currency,
            { Decimal limit,
              Decimal limitPeer,
              int inQuality: 0,
              int outQuality: 0,
              bool rippleAllowed: true,
              bool peerRippleAllowed: true}) {
    _issuer = issuer;
    _balance = balance is Decimal ? balance : Decimal.parse(balance.toString());
    _currency = currency;
    _limit = limit != null ? limit : new Decimal.fromInt(0);
    _peerLimit = peerLimit != null ? peerLimit : new Decimal.fromInt(0);
    _inQuality = inQuality;
    _outQuality = outQuality;
    _rippleAllowed = rippleAllowed;
    _peerRippleAllowed = peerRippleAllowed;
  }

  TrustLine.fromRippleState(AccountID referenceAccount, RippleStateEntry rs) {
    if(rs.lowLimit.issuer == referenceAccount) {
      _issuer = rs.highLimit.issuer;
      _currency = rs.lowLimit.currency;
      _limit = rs.lowLimit.value;
      _peerLimit = rs.highLimit.value;
      _inQuality = rs.lowQualityIn;
      _outQuality = rs.lowQualityOut;
      _rippleAllowed = !rs.flags.has(LedgerFlag.LOW_NO_RIPPLE);
      _peerRippleAllowed = !rs.flags.has(LedgerFlag.HIGH_NO_RIPPLE);
    } else if(rs.highLimit.issuer == referenceAccount) {
      _issuer = rs.lowLimit.issuer;
      _currency = rs.highLimit.currency;
      _limit = rs.highLimit.value;
      _peerLimit = rs.lowLimit.value;
      _inQuality = rs.highQualityIn;
      _outQuality = rs.highQualityOut;
      _rippleAllowed = !rs.flags.has(LedgerFlag.HIGH_NO_RIPPLE);
      _peerRippleAllowed = !rs.flags.has(LedgerFlag.LOW_NO_RIPPLE);
    } else {
      throw new ArgumentError("Invalid RippleState entry for the reference account.");
    }
  }

  @override
  bool operator ==(other) => other is TrustLine &&
      _issuer == other._issuer &&
      _currency == other._currency &&
      _limit == other._limit &&
      _peerLimit == other._peerLimit &&
      _inQuality == other._inQuality &&
      _outQuality == other._outQuality &&
      _rippleAllowed == other._rippleAllowed &&
      _peerRippleAllowed == other._peerRippleAllowed;

  TrustLine.fromJson(Map json) {
    _issuer = json["account"];
    _balance = json["balance"];
    _currency = json["currency"];
    _limit = json.containsKey("limit") ? json["limit"] : new Decimal.fromInt(0);
    _peerLimit = json.containsKey("limit_peer") ? json["limit_peer"] : new Decimal.fromInt(0);
    _inQuality = json.containsKey("quality_in") ? json["quality_in"] : 0;
    _outQuality = json.containsKey("quality_out") ? json["quality_out"] : 0;
    _rippleAllowed = json.containsKey("no_ripple") ? json["no_ripple"] : true;
    _peerRippleAllowed = json.containsKey("no_ripple_peer") ? json["no_ripple_peer"] : true;
  }

  Map toJson() => {
    "account": issuer,
    "balance": balance,
    "currency": currency,
    "limit": limit,
    "limit_peer": peerLimit,
    "quality_in": inQuality,
    "quality_out": outQuality,
    "no_ripple": !rippleAllowed,
    "no_ripple_peer": !peerRippleAllowed
  };


}