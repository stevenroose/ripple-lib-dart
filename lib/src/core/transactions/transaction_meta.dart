part of ripplelib.core;

class TransactionMeta extends RippleSerializedObject {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = {
      Field.AffectedNodes:      FieldRequirement.OPTIONAL,
      Field.TransactionIndex:   FieldRequirement.OPTIONAL,
      Field.TransactionResult:  FieldRequirement.OPTIONAL
  };

  List<AffectedNode> get affectedNodes => _get(Field.AffectedNodes);
  set affectedNodes(List<AffectedNode> affectedNodes) => _put(Field.AffectedNodes, affectedNodes);

  int get transactionIndex => _get(Field.TransactionIndex);
  set transactionIndex(int transactionIndex) => _put(Field.TransactionIndex, transactionIndex);

  EngineResult get transactionResult => _get(Field.TransactionResult);
  set transactionResult(EngineResult transactionResult) => _put(Field.TransactionResult, transactionResult);

  TransactionMeta.fromJson(dynamic json) : super._fromJson(json);
}