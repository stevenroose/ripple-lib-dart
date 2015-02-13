part of ripplelib.core;


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

  Map findFinalFields();

  LedgerEntry constructLedgerEntry() {
    LedgerEntry le = new LedgerEntry._newInstanceOf(ledgerEntryType);
    _fields.forEach((field, value) {
      if(field != Field.NewFields && field != Field.PreviousFields && field != Field.FinalFields) {
        le._put(field, value);
      }
    });
    findFinalFields().forEach((field, value) => le._put(Field.fromJsonKey(field), value));
    return le;
  }

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

  Map findFinalFields() => newFields;

  CreatedNode.fromJson(dynamic json) : super._fromJson(json);
}

class DeletedNode extends AffectedNode {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = new Map.from(AffectedNode._rippleFormatMap)..addAll({
    Field.FinalFields:  FieldRequirement.OPTIONAL
  });

  Map get finalFields => _get(Field.FinalFields);
  Map get previousFields => _get(Field.PreviousFields);

  Map findFinalFields() => finalFields;

  DeletedNode.fromJson(dynamic json) : super._fromJson(json);
}

class ModifiedNode extends AffectedNode {

  @override
  Map<Field, FieldRequirement> get _rippleFormat => _rippleFormatMap;
  static final Map<Field, FieldRequirement> _rippleFormatMap = new Map.from(AffectedNode._rippleFormatMap)..addAll({
    Field.PreviousFields: FieldRequirement.OPTIONAL,
    Field.FinalFields:    FieldRequirement.OPTIONAL
  });

  Map get finalFields => _get(Field.FinalFields);
  Map get previousFields => _get(Field.PreviousFields);

  Map findFinalFields() => finalFields;

  ModifiedNode.fromJson(dynamic json) : super._fromJson(json);
}