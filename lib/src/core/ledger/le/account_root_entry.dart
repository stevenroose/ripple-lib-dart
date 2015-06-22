part of ripplelib.core;


class AccountRootEntry extends LedgerEntry {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = {
      Field.Account:             FieldRequirement.REQUIRED,
      Field.Sequence:            FieldRequirement.REQUIRED,
      Field.Balance:             FieldRequirement.REQUIRED,
      Field.OwnerCount:          FieldRequirement.REQUIRED,
      Field.PreviousTxnID:       FieldRequirement.REQUIRED,
      Field.PreviousTxnLgrSeq:   FieldRequirement.REQUIRED,
      Field.RegularKey:          FieldRequirement.OPTIONAL,
      Field.EmailHash:           FieldRequirement.OPTIONAL,
      Field.WalletLocator:       FieldRequirement.OPTIONAL,
      Field.WalletSize:          FieldRequirement.OPTIONAL,
      Field.MessageKey:          FieldRequirement.OPTIONAL,
      Field.TransferRate:        FieldRequirement.OPTIONAL,
      Field.Domain:              FieldRequirement.OPTIONAL
  }..addAll(LedgerEntry._rippleFormatMap);


  AccountRootEntry() : super(LedgerEntryType.ACCOUNT_ROOT);

  AccountRootEntry._newInstance() : this();


  AccountID get account => _get(Field.Account);

  int get sequence => _get(Field.Sequence);
  void set sequence(int sequence) => _put(Field.Sequence, sequence);

  Amount get balance => _get(Field.Balance);
  void set balance(Amount balance) => _put(Field.Balance, balance);

  int get ownerCount => _get(Field.OwnerCount);

  Hash256 get previousTxId => _get(Field.PreviousTxnID);

  int get previousTxLedgerSequence => _get(Field.PreviousTxnLgrSeq);

  AccountID get regularKey => _get(Field.RegularKey);

  Hash128 get emailHash => _get(Field.EmailHash);

  Hash256 get walletLocator => _get(Field.WalletLocator);

  int get walletSize => _get(Field.WalletSize);

  KeyPair get messageKey => new KeyPair.public(_get(Field.MessageKey));

  int get transferRate => _get(Field.TransferRate);

  String get domain => const Utf8Decoder().convert(_get(Field.Domain));


  /* JSON */

  AccountRootEntry.fromJson(dynamic json, [bool skipFieldCheck = RippleSerializedObject._DEFAULT_SKIP_FIELDCHECK]) :
      super._fromJson(json, skipFieldCheck) {
    _assertLedgerEntryType(LedgerEntryType.ACCOUNT_ROOT);
  }

}