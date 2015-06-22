part of ripplelib.core;

class AccountSet extends Transaction {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = {
      Field.ClearFlag:      FieldRequirement.OPTIONAL,
      Field.Domain:         FieldRequirement.OPTIONAL,
      Field.EmailHash:      FieldRequirement.OPTIONAL,
      Field.MessageKey:     FieldRequirement.OPTIONAL,
      Field.SetFlag:        FieldRequirement.OPTIONAL,
      Field.TransferRate:   FieldRequirement.OPTIONAL,
      Field.WalletLocator:  FieldRequirement.OPTIONAL,
      Field.WalletSize:     FieldRequirement.OPTIONAL
  }..addAll(Transaction._rippleFormatMap);

  int get clearFlag => _get(Field.ClearFlag);
  set clearFlag(int clearFlag) => _put(Field.ClearFlag, clearFlag);

  String get domain => _get(Field.Domain);
  set domain(String domain) => _put(Field.Domain, domain);

  Hash128 get emailHash => _get(Field.EmailHash);
  set emailHash(Hash128 emailHash) => _put(Field.EmailHash, emailHash);

  KeyPair get messageKey => new KeyPair.public(_get(Field.MessageKey));
  set messageKey(KeyPair messageKey) => _put(Field.MessageKey, messageKey.publickey);

  int get setFlag => _get(Field.SetFlag);
  set setFlag(int setFlag) => _put(Field.SetFlag, setFlag);

  int get transferRate => _get(Field.TransferRate);
  set transferRate(int transferRate) => _put(Field.TransferRate, transferRate);

  Hash256 get walletLocator => _get(Field.WalletLocator);
  set walletLocator(Hash256 walletLocator) => _put(Field.WalletLocator, walletLocator);

  int get walletSize => _get(Field.WalletSize);
  set walletSize(int walletSize) => _put(Field.WalletSize, walletSize);

  AccountSet.fromJson(dynamic json, [bool skipFieldCheck = RippleSerializedObject._DEFAULT_SKIP_FIELDCHECK]) :
      super._fromJson(json, skipFieldCheck) {
    _assertTransactionType(TransactionType.ACCOUNT_SET);
  }

}