part of ripplelib.client;

class Command extends Enum {
  static const Command ACCOUNT_CURRENCIES = const Command._("account_currencies");
  static const Command ACCOUNT_INFO = const Command._("account_info");
  static const Command ACCOUNT_LINES = const Command._("account_lines");
  static const Command ACCOUNT_OFFERS = const Command._("account_offers");
  static const Command ACCOUNT_TX = const Command._("account_tx");
  static const Command BLACKLIST = const Command._("blacklist");
  static const Command BOOK_OFFERS = const Command._("book_offers");
  static const Command CONNECT = const Command._("connect");
  static const Command CONSENSUS_INFO = const Command._("consensus_info");
  static const Command FEATURE = const Command._("feature");
  static const Command FETCH_INFO = const Command._("fetch_info");
  static const Command GET_COUNTS = const Command._("get_counts");
  static const Command INTERNAL = const Command._("internal");
  static const Command LEDGER = const Command._("ledger");
  static const Command LEDGER_ACCEPT = const Command._("ledger_accept");
  static const Command LEDGER_CLEANER = const Command._("ledger_cleaner");
  static const Command LEDGER_CLOSED = const Command._("ledger_closed");
  static const Command LEDGER_CURRENT = const Command._("ledger_current");
  static const Command LEDGER_DATA = const Command._("ledger_data");
  static const Command LEDGER_ENTRY = const Command._("ledger_entry");
  static const Command LEDGER_HEADER = const Command._("ledger_header");
  static const Command LEDGER_REQUEST = const Command._("ledger_request");
  static const Command LOG_LEVEL = const Command._("log_level");
  static const Command LOGROTATE = const Command._("logrotate");
  static const Command OWNER_INFO = const Command._("owner_info");
  static const Command PATH_FIND = const Command._("path_find");
  static const Command PEERS = const Command._("peers");
  static const Command PING = const Command._("ping");
  static const Command PRINT = const Command._("print");
  static const Command PROOF_CREATE = const Command._("proof_create");
  static const Command PROOF_SOLVE = const Command._("proof_solve");
  static const Command PROOF_VERIFY = const Command._("proof_verify");
  static const Command RANDOM = const Command._("random");
  static const Command RIPPLE_PATH_FIND = const Command._("ripple_path_find");
  static const Command SERVER_INFO = const Command._("server_info");
  static const Command SERVER_STATE = const Command._("server_state");
  static const Command SIGN = const Command._("sign");
  static const Command SMS = const Command._("sms");
  static const Command STOP = const Command._("stop");
  static const Command SUBMIT = const Command._("submit");
  static const Command SUBSCRIBE = const Command._("subscribe");
  static const Command TRANSACTION_ENTRY = const Command._("transaction_entry");
  static const Command TX = const Command._("tx");
  static const Command TX_HISTORY = const Command._("tx_history");
  static const Command UNL_ADD = const Command._("unl_add");
  static const Command UNL_DELETE = const Command._("unl_delete");
  static const Command UNL_LIST = const Command._("unl_list");
  static const Command UNL_LOAD = const Command._("unl_load");
  static const Command UNL_NETWORK = const Command._("unl_network");
  static const Command UNL_RESET = const Command._("unl_reset");
  static const Command UNL_SCORE = const Command._("unl_score");
  static const Command UNSUBSCRIBE = const Command._("unsubscribe");
  static const Command VALIDATION_CREATE = const Command._("validation_create");
  static const Command VALIDATION_SEED = const Command._("validation_seed");
  static const Command WALLET_ACCOUNTS = const Command._("wallet_accounts");
  static const Command WALLET_PROPOSE = const Command._("wallet_propose");
  static const Command WALLET_SEED = const Command._("wallet_seed");

  final String jsonValue;

  const Command._(String this.jsonValue);

  static Command fromJsonValue(String json) => values.firstWhere((c) => c.jsonValue == json);

  // required by Enum
  static Command valueOf(String e) => Enum.valueOf(Command, e);
  static List<Command> get values => Enum.values(Command);
}
