part of ripplelib.core;


abstract class LedgerEntry extends RippleSerializedObject {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = {
    Field.LedgerIndex:     FieldRequirement.OPTIONAL,
    Field.LedgerEntryType: FieldRequirement.REQUIRED,
    Field.Flags:           FieldRequirement.REQUIRED
  };

  LedgerEntry(LedgerEntryType type) {
    _put(Field.LedgerEntryType, type);
  }

  factory LedgerEntry._newInstanceOf(LedgerEntryType type) {
    switch(type) {
      case LedgerEntryType.ACCOUNT_ROOT:
        return new AccountRootEntry._newInstance();
      case LedgerEntryType.OFFER:
        return new OfferEntry._newInstance();
      case LedgerEntryType.RIPPLE_STATE:
        return new RippleStateEntry._newInstance();
      //TODO complete
    }
    throw new ArgumentError("Invalid or unsupported ledger entry type: $type");
  }

  LedgerEntryType get type => _get(Field.LedgerEntryType);

  Hash256 get ledgerIndex => _get(Field.LedgerIndex);
  void set ledgerIndex(Hash256 ledgerIndex) => _put(Field.LedgerIndex, ledgerIndex);

  Hash256 get index => _get(Field.Index);
  void set index(Hash256 index) => _put(Field.Index, index);

  Flags get flags => _get(Field.Flags);
  void set flags(Flags flags) => _put(Field.Flags, flags);

  Iterable<AccountID> get owners {
    Set<AccountID> owners = new Set<AccountID>();
    if(_has(Field.LowLimit))
      owners.add(_get(Field.LowLimit).issuer);
    if(_has(Field.HighLimit))
      owners.add(_get(Field.HighLimit).issuer);
    if(_has(Field.Account))
      owners.add(_get(Field.Account));
    return owners;
  }

  LedgerEntry._fromJson(dynamic json, [bool skipFieldCheck = false]) : super._fromJson(json, skipFieldCheck);

  void _assertLedgerEntryType(LedgerEntryType assertedType) {
    if(this.type != assertedType)
      throw new ArgumentError("Invalid JSON for this transaction");
  }

}