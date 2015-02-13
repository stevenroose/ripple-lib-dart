part of ripplelib.core;


class HashPrefix {

  static final HashPrefix TRANSACTION_ID = new HashPrefix._(0x54584E00);
  // transaction plus metadata
  static final HashPrefix TX_NODE = new HashPrefix._(0x534E4400);
  // account state
  static final HashPrefix LEAF_NODE = new HashPrefix._(0x4D4C4E00);
  // inner node in tree
  static final HashPrefix INNER_NODE = new HashPrefix._(0x4D494E00);
  // ledger master data for signing
  static final HashPrefix LEDGER_MASTER = new HashPrefix._(0x4C575200);
  // inner transaction to sign
  static final HashPrefix TX_SIGN = new HashPrefix._(0x53545800);
  // validation for signing
  static final HashPrefix VALIDATION = new HashPrefix._(0x56414C00);
  // proposal for signing
  static final HashPrefix PROPOSAL = new HashPrefix._(0x50525000);



  final int prefix;
  final Uint8List _bytes;
  Uint8List get bytes => new Uint8List.fromList(_bytes);

  HashPrefix._(int pfx) :
      prefix = pfx,
      _bytes = RippleUtils.uintToBytesBE(pfx, 4);
}