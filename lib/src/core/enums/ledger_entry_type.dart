part of ripplelib.core;

class LedgerEntryType extends Enum implements RippleSerializable {
  static const LedgerEntryType INVALID = const LedgerEntryType._(-1, "Invalid");
  static const LedgerEntryType ACCOUNT_ROOT = const LedgerEntryType._(97, "AccountRoot");
  static const LedgerEntryType DIRECTORY = const LedgerEntryType._(100, "DirectoryNode");
  static const LedgerEntryType GENERATOR_MAP = const LedgerEntryType._(103, "GeneratorMap");
  static const LedgerEntryType RIPPLE_STATE = const LedgerEntryType._(114, "RippleState");
  static const LedgerEntryType OFFER = const LedgerEntryType._(111, "Offer");
  static const LedgerEntryType CONTRACT = const LedgerEntryType._(99, "Contract");
  static const LedgerEntryType LEDGER_HASHES = const LedgerEntryType._(104, "LedgerHashes");
  static const LedgerEntryType ENABLED_AMENDMENTS = const LedgerEntryType._(102, "EnabledAmendments");
  static const LedgerEntryType FEE_SETTINGS = const LedgerEntryType._(115, "FeeSettings");
  static const LedgerEntryType TICKET = const LedgerEntryType._(84, "Ticket");

  final int code;
  final String jsonValue;

  const LedgerEntryType._(int this.code, String this.jsonValue);

  // required by Enum
  static LedgerEntryType valueOf(String e) => Enum.valueOf(LedgerEntryType, e);
  static List<LedgerEntryType> get values => Enum.values(LedgerEntryType);

  static LedgerEntryType fromCode(int code) => values.firstWhere((let) => let.code == code);
  static LedgerEntryType fromJsonKey(String json) => values.firstWhere((let) => let.jsonValue == json);

  @override
  void toByteSink(ByteSink sink) => sink.add(code);

  @override
  Uint8List toBytes() => new Uint8List(1)..[0] = code;

  toJson() => jsonValue;
}