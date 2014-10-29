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

abstract class AffectedNode extends RippleSerializedObject {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = {
      Field.LedgerEntryType:  FieldRequirement.OPTIONAL,
      Field.LedgerIndex:      FieldRequirement.OPTIONAL
  };

  LedgerEntryType get ledgerEntryType => _get(Field.LedgerEntryType);
  set ledgerEntryType(LedgerEntryType type) => _put(Field.LedgerEntryType, type);

  Hash256 get ledgerIndex => _get(Field.LedgerIndex);
  set ledgerIndex(Hash256 ledgerIndex) => _put(Field.LedgerIndex, ledgerIndex);

  /**
   * Parse an AffectedNode JSON object: an object consisting of a single
   * key (the affected type) with as value the actual AffectedNode object.
   */
  factory AffectedNode.fromJson(Map json) {
    String type = json.keys.first;
    switch(type) {
      case "CreatedNode":
        return new CreatedNode.fromJson(json[type]);
      case "DeletedNode":
        return new DeletedNode.fromJson(json[type]);
      case "ModifiedNode":
        return new ModifiedNode.fromJson(json[type]);
    }
    throw new FormatException("Invalid JSON object: does not represent an AffectedNode");
  }

  toJson() => {this.runtimeType.toString(): super.toJson()};

  AffectedNode._fromJson(dynamic json) : super._fromJson(json);
}

class CreatedNode extends AffectedNode {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = new Map.from(AffectedNode._rippleFormatMap)..addAll({
      Field.NewFields:  FieldRequirement.OPTIONAL
  });

  Map get newFields => _get(Field.NewFields);

  CreatedNode.fromJson(dynamic json) : super._fromJson(json);
}

class DeletedNode extends AffectedNode {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = new Map.from(AffectedNode._rippleFormatMap)..addAll({
      Field.FinalFields:  FieldRequirement.OPTIONAL
  });

  Map get finalFields => _get(Field.FinalFields);

  DeletedNode.fromJson(dynamic json) : super._fromJson(json);
}

class ModifiedNode extends AffectedNode {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = new Map.from(AffectedNode._rippleFormatMap)..addAll({
      Field.NewFields:    FieldRequirement.OPTIONAL,
      Field.FinalFields:  FieldRequirement.OPTIONAL
  });

  Map get finalFields => _get(Field.FinalFields);
  Map get newFields => _get(Field.NewFields);

  ModifiedNode.fromJson(dynamic json) : super._fromJson(json);
}