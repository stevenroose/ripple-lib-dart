part of ripplelib.remote;

class MessageType extends Enum {
  static const MessageType LEDGER_CLOSED = const MessageType._("ledgerClosed");
  static const MessageType RESPONSE = const MessageType._("response");
  static const MessageType TRANSACTION = const MessageType._("transaction");
  static const MessageType SERVER_STATUS = const MessageType._("serverStatus");
  static const MessageType PATH_FIND = const MessageType._("path_find");
  static const MessageType ERROR = const MessageType._("error");

  final String jsonKey;

  const MessageType._(String this.jsonKey);

  static MessageType fromJsonKey(String key) => values.firstWhere((mt) => mt.jsonKey == key);

  // required by Enum
  static MessageType valueOf(String e) => Enum.valueOf(MessageType, e);
  static List<MessageType> get values => Enum.values(MessageType);
}