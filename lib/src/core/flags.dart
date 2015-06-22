part of ripplelib.core;


/**
 * Represents a bitstring of which every bit is a flag that can be either true or false.
 *
 * Flags in Ripple are 32-bits long.
 */
class Flags {

  final int value;

  const Flags._internal(this.value);

  @override
  bool operator ==(other) => other is TransactionFlag && other.value == value;

  @override
  int get hashCode => _hashCodeXor ^ value.hashCode;
  static final int _hashCodeXor = "Flags".hashCode;

  Flags or(Flags other) =>
      new Flags._internal(value | (other.value & 0xff));
  Flags operator |(Flags other) => or(other);

  Flags not() => new Flags._internal(~value);
  Flags operator ~() => not();

  bool has(Flags flag) => this == this.or(flag);

  dynamic toJson() => value;
}


class TransactionFlag extends Flags {

  /* UNIVERSAL FLAGS */
  static const TransactionFlag FULLY_CANONICAL_SIG = const TransactionFlag._(0x80000000);
  static const TransactionFlag UNIVERSAL = FULLY_CANONICAL_SIG;
  static final TransactionFlag UNIVERSAL_MASK = ~UNIVERSAL;

  // AccountSet flags:
  static const TransactionFlag REQUIRE_DEST_TAG = const TransactionFlag._(0x00010000);
  static const TransactionFlag OPTIONAL_DEST_TAG = const TransactionFlag._(0x00020000);
  static const TransactionFlag REQUIRE_AUTH = const TransactionFlag._(0x00040000);
  static const TransactionFlag OPTIONAL_AUTH = const TransactionFlag._(0x00080000);
  static const TransactionFlag DISALLOW_XRP = const TransactionFlag._(0x00100000);
  static const TransactionFlag ALLOW_XRP = const TransactionFlag._(0x00200000);
  static final TransactionFlag ACCOUNT_SET_MASK = ~(UNIVERSAL | REQUIRE_DEST_TAG | OPTIONAL_DEST_TAG
                                                              | REQUIRE_AUTH    | OPTIONAL_AUTH
                                                              | DISALLOW_XRP    | ALLOW_XRP);

  // AccountSet SetFlag/ClearFlag values
  static const TransactionFlag ASF_REQUIRE_DEST   = const TransactionFlag._(1);
  static const TransactionFlag ASF_REQUIRE_AUTH   = const TransactionFlag._(2);
  static const TransactionFlag ASF_DISALLOW_XRP   = const TransactionFlag._(3);
  static const TransactionFlag ASF_DISABLE_MASTER = const TransactionFlag._(4);
  static const TransactionFlag ASF_ACCOUNT_TX_ID  = const TransactionFlag._(5);
  static const TransactionFlag ASF_NO_FREEZE      = const TransactionFlag._(6);
  static const TransactionFlag ASF_GLOBAL_FREEZE  = const TransactionFlag._(7);

  // OfferCreate flags:
  static const TransactionFlag PASSIVE = const TransactionFlag._(0x00010000);
  static const TransactionFlag IMMEDIATE_OR_CANCEL = const TransactionFlag._(0x00020000);
  static const TransactionFlag FILL_OR_KILL = const TransactionFlag._(0x00040000);
  static const TransactionFlag SELL = const TransactionFlag._(0x00080000);
  static final TransactionFlag OFFER_CREATE_MASK = ~(UNIVERSAL | PASSIVE | IMMEDIATE_OR_CANCEL | FILL_OR_KILL | SELL);

  // Payment flags:
  static const TransactionFlag NO_DIRECT_RIPPLE = const TransactionFlag._(0x00010000);
  static const TransactionFlag PARTIAL_PAYMENT = const TransactionFlag._(0x00020000);
  static const TransactionFlag LIMIT_QUALITY = const TransactionFlag._(0x00040000);
  static const TransactionFlag CIRCLE = const TransactionFlag._(0x00080000);
  static final TransactionFlag PAYMENT_MASK = ~(UNIVERSAL | PARTIAL_PAYMENT | LIMIT_QUALITY | NO_DIRECT_RIPPLE);

  // TrustSet flags:
  static const TransactionFlag SET_AUTH = const TransactionFlag._(0x00010000);
  static const TransactionFlag SET_NO_RIPPLE = const TransactionFlag._(0x00020000);
  static const TransactionFlag CLEAR_NO_RIPPLE = const TransactionFlag._(0x00040000);
  static const TransactionFlag SET_FREEZE            = const TransactionFlag._(0x00100000);
  static const TransactionFlag CLEAR_FREEZE          = const TransactionFlag._(0x00200000);
  static final TransactionFlag TRUST_SET_MASK = ~(UNIVERSAL | SET_AUTH | SET_NO_RIPPLE | CLEAR_NO_RIPPLE | SET_FREEZE | CLEAR_FREEZE);


  const TransactionFlag._(int value) : super._internal(value);
}

class LedgerFlag extends Flags {

  // ltACCOUNT_ROOT
  static const LedgerFlag PASSWORD_SPENT = const LedgerFlag._(0x00010000);   // True, if password set fee is spent.
  static const LedgerFlag REQUIRE_DEST_TAG = const LedgerFlag._(0x00020000);   // True, to require a DestinationTag for payments.
  static const LedgerFlag REQUIRE_AUTH = const LedgerFlag._(0x00040000);   // True, to require a authorization to hold IOUs.
  static const LedgerFlag DISALLOW_XRP = const LedgerFlag._(0x00080000);   // True, to disallow sending XRP.
  static const LedgerFlag DISABLE_MASTER = const LedgerFlag._(0x00100000);   // True, force regular key
  static const LedgerFlag NO_FREEZE         = const LedgerFlag._(0x00200000);  // True, cannot freeze ripple states
  static const LedgerFlag GLOBAL_FREEZE     = const LedgerFlag._(0x00400000);   // True, all assets frozen

  // ltOFFER
  static const LedgerFlag PASSIVE = const LedgerFlag._(0x00010000);
  static const LedgerFlag SELL = const LedgerFlag._(0x00020000);  // True, offer was placed as a sell.

  // ltRIPPLE_STATE
  static const LedgerFlag LOW_RESERVE = const LedgerFlag._(0x00010000); // True, if entry counts toward reserve.
  static const LedgerFlag HIGH_RESERVE = const LedgerFlag._(0x00020000);
  static const LedgerFlag LOW_AUTH = const LedgerFlag._(0x00040000);
  static const LedgerFlag HIGH_AUTH = const LedgerFlag._(0x00080000);
  static const LedgerFlag LOW_NO_RIPPLE = const LedgerFlag._(0x00100000);
  static const LedgerFlag HIGH_NO_RIPPLE = const LedgerFlag._(0x00200000);
  static const LedgerFlag LOW_FREEZE = const LedgerFlag._(0x00400000);   // True, low side has set freeze flag
  static const LedgerFlag HIGH_FREEZE = const LedgerFlag._(0x00800000); // True, high side has set freeze flag


  const LedgerFlag._(int value) : super._internal(value);
}