part of ripplelib.core;

class Field extends Enum implements Comparable<Field> {

  static Field Generic = new Field._(0, "Generic", FieldType.UNKNOWN);
  static Field Invalid = new Field._(-1, "Invalid", FieldType.UNKNOWN);

  static Field LedgerEntryType = new Field._(1, "LedgerEntryType", FieldType.UINT16);
  static Field TransactionType = new Field._(2, "TransactionType", FieldType.UINT16);

  static Field Flags = new Field._(2, "Flags", FieldType.UINT32);
  static Field SourceTag = new Field._(3, "SourceTag", FieldType.UINT32);
  static Field Sequence = new Field._(4, "Sequence", FieldType.UINT32);
  static Field PreviousTxnLgrSeq = new Field._(5, "PreviousTxnLgrSeq", FieldType.UINT32);
  static Field LedgerSequence = new Field._(6, "LedgerSequence", FieldType.UINT32);
  static Field CloseTime = new Field._(7, "CloseTime", FieldType.UINT32);
  static Field ParentCloseTime = new Field._(8, "ParentCloseTime", FieldType.UINT32);
  static Field SigningTime = new Field._(9, "SigningTime", FieldType.UINT32);
  static Field Expiration = new Field._(10, "Expiration", FieldType.UINT32);
  static Field TransferRate = new Field._(11, "TransferRate", FieldType.UINT32);
  static Field WalletSize = new Field._(12, "WalletSize", FieldType.UINT32);
  static Field OwnerCount = new Field._(13, "OwnerCount", FieldType.UINT32);
  static Field DestinationTag = new Field._(14, "DestinationTag", FieldType.UINT32);
  static Field HighQualityIn = new Field._(16, "HighQualityIn", FieldType.UINT32);
  static Field HighQualityOut = new Field._(17, "HighQualityOut", FieldType.UINT32);
  static Field LowQualityIn = new Field._(18, "LowQualityIn", FieldType.UINT32);
  static Field LowQualityOut = new Field._(19, "LowQualityOut", FieldType.UINT32);
  static Field QualityIn = new Field._(20, "QualityIn", FieldType.UINT32);
  static Field QualityOut = new Field._(21, "QualityOut", FieldType.UINT32);
  static Field StampEscrow = new Field._(22, "StampEscrow", FieldType.UINT32);
  static Field BondAmount = new Field._(23, "BondAmount", FieldType.UINT32);
  static Field LoadFee = new Field._(24, "LoadFee", FieldType.UINT32);
  static Field OfferSequence = new Field._(25, "OfferSequence", FieldType.UINT32);
  static Field FirstLedgerSequence = new Field._(26, "FirstLedgerSequence", FieldType.UINT32); // Deprecated: do not use
  // Added new semantics in 9486fc416ca7c59b8930b734266eed4d5b714c50
  static Field LastLedgerSequence = new Field._(27, "LastLedgerSequence", FieldType.UINT32);
  static Field TransactionIndex = new Field._(28, "TransactionIndex", FieldType.UINT32);
  static Field OperationLimit = new Field._(29, "OperationLimit", FieldType.UINT32);
  static Field ReferenceFeeUnits = new Field._(30, "ReferenceFeeUnits", FieldType.UINT32);
  static Field ReserveBase = new Field._(31, "ReserveBase", FieldType.UINT32);
  static Field ReserveIncrement = new Field._(32, "ReserveIncrement", FieldType.UINT32);
  static Field SetFlag = new Field._(33, "SetFlag", FieldType.UINT32);
  static Field ClearFlag = new Field._(34, "ClearFlag", FieldType.UINT32);

  static Field IndexNext = new Field._(1, "IndexNext", FieldType.UINT64);
  static Field IndexPrevious = new Field._(2, "IndexPrevious", FieldType.UINT64);
  static Field BookNode = new Field._(3, "BookNode", FieldType.UINT64);
  static Field OwnerNode = new Field._(4, "OwnerNode", FieldType.UINT64);
  static Field BaseFee = new Field._(5, "BaseFee", FieldType.UINT64);
  static Field ExchangeRate = new Field._(6, "ExchangeRate", FieldType.UINT64);
  static Field LowNode = new Field._(7, "LowNode", FieldType.UINT64);
  static Field HighNode = new Field._(8, "HighNode", FieldType.UINT64);

  static Field EmailHash = new Field._(1, "EmailHash", FieldType.HASH128);

  static Field LedgerHash = new Field._(1, "LedgerHash", FieldType.HASH256);
  static Field ParentHash = new Field._(2, "ParentHash", FieldType.HASH256);
  static Field TransactionHash = new Field._(3, "TransactionHash", FieldType.HASH256);
  static Field AccountHash = new Field._(4, "AccountHash", FieldType.HASH256);
  static Field PreviousTxnID = new Field._(5, "PreviousTxnID", FieldType.HASH256);
  static Field LedgerIndex = new Field._(6, "LedgerIndex", FieldType.HASH256);
  static Field WalletLocator = new Field._(7, "WalletLocator", FieldType.HASH256);
  static Field RootIndex = new Field._(8, "RootIndex", FieldType.HASH256);
  // Added in rippled commit: 9486fc416ca7c59b8930b734266eed4d5b714c50
  static Field AccountTxnID = new Field._(9, "AccountTxnID", FieldType.HASH256);
  static Field BookDirectory = new Field._(16, "BookDirectory", FieldType.HASH256);
  static Field InvoiceID = new Field._(17, "InvoiceID", FieldType.HASH256);
  static Field Nickname = new Field._(18, "Nickname", FieldType.HASH256);
  static Field Amendment = new Field._(19, "Amendment", FieldType.HASH256);
  static Field TicketID = new Field._(20, "TicketID", FieldType.HASH256);
  static Field Hash = new Field._(257, "hash", FieldType.HASH256);
  static Field Index = new Field._(258, "index", FieldType.HASH256);

  static Field Amount = new Field._(1, "Amount", FieldType.AMOUNT);
  static Field Balance = new Field._(2, "Balance", FieldType.AMOUNT);
  static Field LimitAmount = new Field._(3, "LimitAmount", FieldType.AMOUNT);
  static Field TakerPays = new Field._(4, "TakerPays", FieldType.AMOUNT);
  static Field TakerGets = new Field._(5, "TakerGets", FieldType.AMOUNT);
  static Field LowLimit = new Field._(6, "LowLimit", FieldType.AMOUNT);
  static Field HighLimit = new Field._(7, "HighLimit", FieldType.AMOUNT);
  static Field Fee = new Field._(8, "Fee", FieldType.AMOUNT);
  static Field SendMax = new Field._(9, "SendMax", FieldType.AMOUNT);
  static Field MinimumOffer = new Field._(16, "MinimumOffer", FieldType.AMOUNT);
  static Field RippleEscrow = new Field._(17, "RippleEscrow", FieldType.AMOUNT);
  // Added in rippled commit: e7f0b8eca69dd47419eee7b82c8716b3aa5a9e39
  static Field DeliveredAmount = new Field._(18, "DeliveredAmount", FieldType.AMOUNT);
  // These are auxillary fields
//  static Field   static Field quality = new Field._(257, FieldType.AMOUNT);
  static Field taker_gets_funded = new Field._(258, "taker_gets_funded", FieldType.AMOUNT);
  static Field taker_pays_funded = new Field._(259, "taker_pays_funded", FieldType.AMOUNT);

  static Field PublicKey = new Field._(1, "PublicKey", FieldType.VARLEN);
  static Field MessageKey = new Field._(2, "MessageKey", FieldType.VARLEN);
  static Field SigningPubKey = new Field._(3, "SigningPubKey", FieldType.VARLEN);
  static Field TxnSignature = new Field._(4, "TxnSignature", FieldType.VARLEN);
  static Field Generator = new Field._(5, "Generator", FieldType.VARLEN);
  static Field Signature = new Field._(6, "Signature", FieldType.VARLEN);
  static Field Domain = new Field._(7, "Domain", FieldType.VARLEN);
  static Field FundCode = new Field._(8, "FundCode", FieldType.VARLEN);
  static Field RemoveCode = new Field._(9, "RemoveCode", FieldType.VARLEN);
  static Field ExpireCode = new Field._(10, "ExpireCode", FieldType.VARLEN);
  static Field CreateCode = new Field._(11, "CreateCode", FieldType.VARLEN);
  static Field MemoType = new Field._(12, "MemoType", FieldType.VARLEN);
  static Field MemoData = new Field._(13, "MemoData", FieldType.VARLEN);
  static Field MemoFormat = new Field._(14, "MemoFormat", FieldType.VARLEN);

  static Field Account = new Field._(1, "Account", FieldType.ACCOUNT);
  static Field Owner = new Field._(2, "Owner", FieldType.ACCOUNT);
  static Field Destination = new Field._(3, "Destination", FieldType.ACCOUNT);
  static Field Issuer = new Field._(4, "Issuer", FieldType.ACCOUNT);
  static Field Target = new Field._(7, "Target", FieldType.ACCOUNT);
  static Field RegularKey = new Field._(8, "RegularKey", FieldType.ACCOUNT);

  static Field ObjectEndMarker = new Field._(1, "ObjectEndMarker", FieldType.OBJECT);
  static Field TransactionMetaData = new Field._(2, "TransactionMetaData", FieldType.OBJECT);
  static Field CreatedNode = new Field._(3, "CreatedNode", FieldType.OBJECT);
  static Field DeletedNode = new Field._(4, "DeletedNode", FieldType.OBJECT);
  static Field ModifiedNode = new Field._(5, "ModifiedNode", FieldType.OBJECT);
  static Field PreviousFields = new Field._(6, "PreviousFields", FieldType.OBJECT);
  static Field FinalFields = new Field._(7, "FinalFields", FieldType.OBJECT);
  static Field NewFields = new Field._(8, "NewFields", FieldType.OBJECT);
  static Field TemplateEntry = new Field._(9, "TemplateEntry", FieldType.OBJECT);
  static Field Memo = new Field._(10, "Memo", FieldType.OBJECT);

  static Field ArrayEndMarker = new Field._(1, "ArrayEndMarker", FieldType.ARRAY);
  static Field SigningAccounts = new Field._(2, "SigningAccounts", FieldType.ARRAY);
  static Field TxnSignatures = new Field._(3, "TxnSignatures", FieldType.ARRAY);
  static Field Signatures = new Field._(4, "Signatures", FieldType.ARRAY);
  static Field Template = new Field._(5, "Template", FieldType.ARRAY);
  static Field Necessary = new Field._(6, "Necessary", FieldType.ARRAY);
  static Field Sufficient = new Field._(7, "Sufficient", FieldType.ARRAY);
  static Field AffectedNodes = new Field._(8, "AffectedNodes", FieldType.ARRAY);
  static Field Memos = new Field._(9, "Memos", FieldType.ARRAY);

  static Field CloseResolution = new Field._(1, "CloseResolution", FieldType.UINT8);
  static Field TemplateEntryType = new Field._(2, "TemplateEntryType", FieldType.UINT8);
  static Field TransactionResult = new Field._(3, "TransactionResult", FieldType.UINT8);

  static Field TakerPaysCurrency = new Field._(1, "TakerPaysCurrency", FieldType.HASH160);
  static Field TakerPaysIssuer = new Field._(2, "TakerPaysIssuer", FieldType.HASH160);
  static Field TakerGetsCurrency = new Field._(3, "TakerGetsCurrency", FieldType.HASH160);
  static Field TakerGetsIssuer = new Field._(4, "TakerGetsIssuer", FieldType.HASH160);

  static Field Paths = new Field._(1, "Paths", FieldType.PATH_SET);

  static Field Indexes = new Field._(1, "Indexes", FieldType.VECTOR256);
  static Field Hashes = new Field._(2, "Hashes", FieldType.VECTOR256);
  static Field Features = new Field._(3, "Features", FieldType.VECTOR256);

  static Field Transaction = new Field._(1, "Transaction", FieldType.TRANSACTION);
  static Field LedgerEntry = new Field._(1, "LedgerEntry", FieldType.LEDGER_ENTRY);
  static Field Validation = new Field._(1, "Validation", FieldType.VALIDATION);

  /**
   * This is a dummy field that is used when unknown fields are found in json objects.
   *
   * Because [hashCode] and [==] are overridden to only take into account the [jsonKey],
   * dummy fields can also be used as keys in Maps.
   */
  Field.jsonField(String this.jsonKey) : id = -3, type = FieldType.UNKNOWN {
    _code = -3;
    _isSerialized = false;
    _signingField = false;
  }

  bool get isJsonOnly => id == -3;

  // required by Enum
  static Field valueOf(String e) => Enum.valueOf(Field, e);
  static List<Field> get values => Enum.values(Field);


  final int id;
  final String jsonKey;
  final FieldType type;

  int _code;
  bool _isSerialized;
  bool _signingField;
  bool _isVlEncoded = false;
  Uint8List _bytes;

  Field._(this.id, this.jsonKey, this.type, {bool isSerialized, bool signingField, bool isVlEncoded}) {
    _code = (type.id << 16) | id;
    _isSerialized = isSerialized == null ? _isFieldSerialized(this) : isSerialized;
    _signingField = signingField == null ? _isSerialized : signingField;
    _isVlEncoded  = isVlEncoded  == null ? _isVlEncoded : isVlEncoded;
    _byCode[_code] = this;
    _byJsonKey[jsonKey] = this;
    _bytes = toBytes(this);
  }

  int get code => _code;
  bool get isSerialized => _isSerialized;
  bool get signingField => _signingField;
  bool get isVlEncoded => _isVlEncoded;
  Uint8List get bytes => _bytes;

  // splaymaptree to preserve order
  static Map<int, Field> _byCode = new SplayTreeMap<int, Field>();
  static Field fromCode(int code) {
    Enum.ensureValuesInstantiated(Field);
    return _byCode[code];
  }

  static Map<String, Field> _byJsonKey = new Map<String, Field>();
  static Field fromJsonKey(String jsonKey) {
    Enum.ensureValuesInstantiated(Field);
    return _byJsonKey.containsKey(jsonKey) ? _byJsonKey[jsonKey] : new Field.jsonField(jsonKey);
  }

  @override
  String toString() => isJsonOnly ? jsonKey : super.toString();

  @override
  bool operator ==(other) => other is Field && jsonKey == other.jsonKey;

  @override
  int get hashCode => jsonKey.hashCode;

  @override
  int compareTo(Field other) => _code - other._code;

  static Uint8List toBytes(Field field) {
    int name = field.id;
    int type = field.type.id;
    List<int> header = new List<int>();
    if (type < 16) {
      if (name < 16) {
        // common type, common name
        header.add((type << 4) | name);
      } else {
        // common type, uncommon name
        header.add(type << 4);
        header.add(name);
      }
    } else if (name < 16) {
      // uncommon type, common name
      header.add(name);
      header.add(type);
    } else {
      // uncommon type, uncommon name
      header.add(0);
      header.add(type);
      header.add(name);
    }
    return new Uint8List.fromList(header);
  }

  static bool _isFieldSerialized(Field f) => ((f.type.id > 0) && (f.type.id < 256) && (f.id > 0) && (f.id < 256));

}