part of ripplelib.core;



class EngineResult extends Enum implements RippleSerializable {
  static const EngineResult telLOCAL_ERROR = const EngineResult._(-399, "Local failure.");
  static const EngineResult telBAD_DOMAIN = const EngineResult._(-398, "Domain too long.");
  static const EngineResult telBAD_PATH_COUNT = const EngineResult._(-397, "Malformed: Too many paths.");
  static const EngineResult telBAD_PUBLIC_KEY = const EngineResult._(-396, "key too long.");
  static const EngineResult telFAILED_PROCESSING = const EngineResult._(-395, "Failed to correctly process transaction.");
  static const EngineResult telINSUF_FEE_P = const EngineResult._(-394, "Fee insufficient.");
  static const EngineResult telNO_DST_PARTIAL = const EngineResult._(-393, "Partial payment to creastatic const EngineResult te account not allowed.");

  static const EngineResult temMALFORMED = const EngineResult._(-299, "Malformed transaction.");
  static const EngineResult temBAD_AMOUNT = const EngineResult._(-298, "Can only send positive amounts.");
  static const EngineResult temBAD_AUTH_MASTER = const EngineResult._(-297, "Auth for unclaimed account needs correct masstatic const EngineResult ter key.");
  static const EngineResult temBAD_CURRENCY = const EngineResult._(-296, "Malformed: Bad currency.");
  static const EngineResult temBAD_EXPIRATION = const EngineResult._(-295, "Malformed: Bad expiration.");
  static const EngineResult temBAD_FEE = const EngineResult._(-294, "Invalid fee, negative or not XRP.");
  static const EngineResult temBAD_ISSUER = const EngineResult._(-293, "Malformed: Bad issuer.");
  static const EngineResult temBAD_LIMIT = const EngineResult._(-292, "Limits must be non-negative.");
  static const EngineResult temBAD_OFFER = const EngineResult._(-291, "Malformed: Bad offer.");
  static const EngineResult temBAD_PATH = const EngineResult._(-290, "Malformed: Bad path.");
  static const EngineResult temBAD_PATH_LOOP = const EngineResult._(-289, "Malformed: Loop in path.");
  static const EngineResult temBAD_SEND_XRP_LIMIT = const EngineResult._(-288, "Malformed: Limit quality is not allowed for XRP to XRP.");
  static const EngineResult temBAD_SEND_XRP_MAX = const EngineResult._(-287, "Malformed: Send max is not allowed for XRP to XRP.");
  static const EngineResult temBAD_SEND_XRP_NO_DIRECT = const EngineResult._(-286, "Malformed: No Ripple direct is not allowed for XRP to XRP.");
  static const EngineResult temBAD_SEND_XRP_PARTIAL = const EngineResult._(-285, "Malformed: Partial payment is not allowed for XRP to XRP.");
  static const EngineResult temBAD_SEND_XRP_PATHS = const EngineResult._(-284, "Malformed: Paths are not allowed for XRP to XRP.");
  static const EngineResult temBAD_SEQUENCE = const EngineResult._(-283, "Malformed: Sequence is not in the past.");
  static const EngineResult temBAD_SIGNATURE = const EngineResult._(-282, "Malformed: Bad signature.");
  static const EngineResult temBAD_SRC_ACCOUNT = const EngineResult._(-281, "Malformed: Bad source account.");
  static const EngineResult temBAD_TRANSFER_RATE = const EngineResult._(-280, "Malformed: Bad transfer rate");
  static const EngineResult temDST_IS_SRC = const EngineResult._(-279, "Destination may not be source.");
  static const EngineResult temDST_NEEDED = const EngineResult._(-278, "Destination not specified.");
  static const EngineResult temINVALID = const EngineResult._(-277, "The transaction is ill-formed.");
  static const EngineResult temINVALID_FLAG = const EngineResult._(-276, "The transaction has an invalid flag.");
  static const EngineResult temREDUNDANT = const EngineResult._(-275, "Sends same currency to self.");
  static const EngineResult temREDUNDANT_SEND_MAX = const EngineResult._(-274, "Send max is redundant.");
  static const EngineResult temRIPPLE_EMPTY = const EngineResult._(-273, "PathSet with no paths.");

  static const EngineResult temUNCERTAIN = const EngineResult._(-272, "In process of determining result. Never returned.");
  static const EngineResult temUNKNOWN = const EngineResult._(-271, "The transactions requires logic not implemented yet.");

  static const EngineResult tefFAILURE = const EngineResult._(-199, "Failed to apply.");
  static const EngineResult tefALREADY = const EngineResult._(-198, "The exact transaction was already in this ledger.");
  static const EngineResult tefBAD_ADD_AUTH = const EngineResult._(-197, "Not authorized to add account.");
  static const EngineResult tefBAD_AUTH = const EngineResult._(-196, "Transaction's key is not authorized.");
  static const EngineResult tefBAD_LEDGER = const EngineResult._(-195, "Ledger in unexpected state.");
  static const EngineResult tefCREATED = const EngineResult._(-194, "Can't add an already created account.");
  static const EngineResult tefDST_TAG_NEEDED = const EngineResult._(-193, "Destination tag required.");
  static const EngineResult tefEXCEPTION = const EngineResult._(-192, "Unexpected program state.");
  static const EngineResult tefINTERNAL = const EngineResult._(-191, "Internal error.");
  static const EngineResult tefNO_AUTH_REQUIRED = const EngineResult._(-190, "Auth is not required.");
  static const EngineResult tefPAST_SEQ = const EngineResult._(-189, "This sequence number has already past.");
  static const EngineResult tefWRONG_PRIOR = const EngineResult._(-188, "tefWRONG_PRIOR");
  static const EngineResult tefMASTER_DISABLED = const EngineResult._(-187, "tefMASTER_DISABLED");
  static const EngineResult tefMAX_LEDGER = const EngineResult._(-186, "Ledger sequence too high.");

  static const EngineResult terRETRY = const EngineResult._(-99, "Retry transaction.");
  static const EngineResult terFUNDS_SPENT = const EngineResult._(-98, "Can't set password, password set funds already spent.");
  static const EngineResult terINSUF_FEE_B = const EngineResult._(-97, "AccountID balance can't pay fee.");
  static const EngineResult terNO_ACCOUNT = const EngineResult._(-96, "The source account does not exist.");
  static const EngineResult terNO_AUTH = const EngineResult._(-95, "Not authorized to hold IOUs.");
  static const EngineResult terNO_LINE = const EngineResult._(-94, "No such line.");
  static const EngineResult terOWNERS = const EngineResult._(-93, "Non-zero owner count.");
  static const EngineResult terPRE_SEQ = const EngineResult._(-92, "Missing/inapplicable prior transaction.");
  static const EngineResult terLAST = const EngineResult._(-91, "Process last.");
  static const EngineResult terNO_RIPPLE = const EngineResult._(-90, "Process last.");

  static const EngineResult tesSUCCESS = const EngineResult._(0, "The transaction was applied.");
  static const EngineResult tecCLAIM = const EngineResult._(100, "Fee claimed. Sequence used. No action.");
  static const EngineResult tecPATH_PARTIAL = const EngineResult._(101, "Path could not send full amount.");
  static const EngineResult tecUNFUNDED_ADD = const EngineResult._(102, "Insufficient XRP balance for WalletAdd.");
  static const EngineResult tecUNFUNDED_OFFER = const EngineResult._(103, "Insufficient balance to fund created offer.");
  static const EngineResult tecUNFUNDED_PAYMENT = const EngineResult._(104, "Insufficient XRP balance to send.");
  static const EngineResult tecFAILED_PROCESSING = const EngineResult._(105, "Failed to correctly process transaction.");
  static const EngineResult tecDIR_FULL = const EngineResult._(121, "Can not add entry to full directory.");
  static const EngineResult tecINSUF_RESERVE_LINE = const EngineResult._(122, "Insufficient reserve to add trust line.");
  static const EngineResult tecINSUF_RESERVE_OFFER = const EngineResult._(123, "Insufficient reserve to create offer.");
  static const EngineResult tecNO_DST = const EngineResult._(124, "Destination does not exist. Send XRP to create it.");
  static const EngineResult tecNO_DST_INSUF_XRP = const EngineResult._(125, "Destination does not exist. Too little XRP sent to create it.");
  static const EngineResult tecNO_LINE_INSUF_RESERVE = const EngineResult._(126, "No such line. Too little reserve to create it.");
  static const EngineResult tecNO_LINE_REDUNDANT = const EngineResult._(127, "Can't set non-existant line to default.");
  static const EngineResult tecPATH_DRY = const EngineResult._(128, "Path could not send partial amount.");
  static const EngineResult tecUNFUNDED = const EngineResult._(129, "One of _ADD, _OFFER, or _SEND. Deprecated.");
  static const EngineResult tecMASTER_DISABLED = const EngineResult._(130, "tecMASTER_DISABLED");
  static const EngineResult tecNO_REGULAR_KEY = const EngineResult._(131, "tecNO_REGULAR_KEY");
  static const EngineResult tecOWNERS = const EngineResult._(132, "tecOWNERS");
  static const EngineResult tecNO_ISSUER = const EngineResult._(133, "Issuer account does not exist.");
  static const EngineResult tecNO_AUTH = const EngineResult._(134, "Not authorized to hold asset.");
  static const EngineResult tecNO_LINE = const EngineResult._(135, "No such line.");
  static const EngineResult tecINSUFF_FEE = const EngineResult._(136,  "Insufficient balance to pay fee.");
  static const EngineResult tecFROZEN = const EngineResult._(137, "Asset is frozen.");
  static const EngineResult tecNO_TARGET = const EngineResult._(138, "Target account does not exist.");
  static const EngineResult tecNO_PERMISSION = const EngineResult._(139, "No permission to perform requested operation.");
  static const EngineResult tecNO_ENTRY = const EngineResult._(140, "No matching entry found.");
  static const EngineResult tecINSUFFICIENT_RESERVE = const EngineResult._(141, "Insufficient reserve to complete requested operation.");


  final int code;
  final String human;

  const EngineResult._(int this.code, String this.human);

  // required by Enum
  static EngineResult valueOf(String e) => Enum.valueOf(EngineResult, e);
  static List<EngineResult> get values => Enum.values(EngineResult);


  static Map<int, EngineResult> _byCode;
  static EngineResult fromCode(int code) {
    if(_byCode == null) {
      Map bc = new Map<int, EngineResult>();
      EngineResult.values.forEach((er) => bc[er.code] = er);
      _byCode = bc;
    }
    return _byCode[code];
  }

  static EngineResult fromName(String name) => EngineResult.valueOf(name);

  String get name => toString();

  EngineResult get resultClass => findResultClass(this);

  // Result Classes
  static EngineResult findResultClass(EngineResult result) {
    if (result.code >= telLOCAL_ERROR.code && result.code < temMALFORMED.code) {
      return telLOCAL_ERROR;
    }
    if (result.code >= temMALFORMED.code && result.code < tefFAILURE.code) {
      return temMALFORMED;
    }
    if (result.code >= tefFAILURE.code && result.code < terRETRY.code) {
      return tefFAILURE;
    }
    if (result.code >= terRETRY.code && result.code < tesSUCCESS.code) {
      return terRETRY;
    }
    if (result.code >= tesSUCCESS.code && result.code < tecCLAIM.code) {
      return tesSUCCESS;
    }
    return tecCLAIM;
  }

  @override
  void toByteSink(Sink sink) => sink.add(code);

  @override
  Uint8List toBytes() => new Uint8List(1)..[0] = code;

  toJson() => toString();

}


