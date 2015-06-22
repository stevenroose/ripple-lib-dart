part of ripplelib.core;



class Offer extends Offer {

  Amount takerGets;
  Amount takerPays;
  int sequence;
  Flags flags;
  AccountID account;


  Offer(Amount this.takerGets, Amount this.takerPays, {int this.sequence, Flags this.flags, AccountID this.account});

  Offer.fromJson(dynamic json) {
    takerGets = json["taker_gets"];
    takerPays = json["taker_pays"];
    account = json["account"];
    sequence = json["seq"];
    flags = new Flags(json["flags"]);
  }

  dynamic toJson() => {
    "flags": flags,
    "seq": sequence,
    "taker_gets": takerGets,
    "taker_pays": takerPays,
    "account": account
  };

  Amount get takerGets => takerGets;
  Amount get takerPays => takerPays;

  int get sequence => sequence;
  Flags get flags => flags;

  AccountID get  account => account;

}