part of ripplelib.core;


abstract class RippleSerializedObject extends RippleSerialization {

  RippleSerializedObject() {

  }

  RippleSerializedObject._fromJson(dynamic json, [bool skipFieldCheck = false]) {
    if(json is! Map)
      throw new ArgumentError("Must be a JSON object");
    json.forEach((String key, dynamic value) {
      Field field = Field.fromJsonKey(key);
      _put(field, value);
    });
    if(!skipFieldCheck)
      _checkRequiredFields();
  }

  void fieldsToByteSink(Sink sink, [bool fieldFilter(Field)]) {
    if(fieldFilter == null)
      fieldFilter = (Field f) => f.isSerialized;
    Map<Field, FieldRequirement> format = _rippleFormat;
    Set<Field> fields = new Set.from(format.keys); // we will remove covered fields
    _fields.keys.where(fieldFilter).forEach((Field f) {
      // check if this field is valid for
      if(format[f] == FieldRequirement.INVALID)
        throw new FormatException("Invalid field formatting: field $f is invalid for this object.");
      // if a field is not in the map, we just ignore it
      if(fields.contains(f)) {
        _writeField(sink, f, _get(f));
        fields.remove(f);
      }
    });
    // check if no required field were missing
    fields.forEach((Field f) {
      if(format[f] == FieldRequirement.REQUIRED)
        throw new FormatException("Required field is missing: $f");
    });
  }

  @override
  void toByteSink(Sink sink) => fieldsToByteSink(sink);

  @override
  dynamic toJson() {
    Map json = new Map();
    for(Field field in _fields.keys) {
      var fieldValue = _get(field);
      if(fieldValue is Uint8List)
        fieldValue = CryptoUtils.bytesToHex(fieldValue);
      json[field.jsonKey] = fieldValue;
    }
    return json;
  }

  /* DATA MGMT */

  // must be a tree map to arrange order of the fields
  SplayTreeMap<Field, dynamic> _fields = new SplayTreeMap<Field, dynamic>();

  void _put(Field field, dynamic value) {
//    if(value.runtimeType != field.type.nativeType) {
//      throw new FormatException("Json value of field $field is of wrong type: ${value.runtimeType}, expected ${field.type.nativeType}");
//    }
    if(value == null)
      _fields.remove(field);
    else
      _fields[field] = value;
  }

  bool _has(Field field) => _fields.containsKey(field);

  dynamic _get(Field field) {
    return _fields[field];
  }

  /* DATA FORMATTING AND REQUIREMENTS */

  /**
   * Return the format map of this object.
   * It's advised to use a static value for this purpose for
   * efficiency
   */
  Map<Field, FieldRequirement> get _rippleFormat;

  void _checkRequiredFields() {
    Map<Field, FieldRequirement> format = _rippleFormat;
    Set<Field> fields = new Set.from(format.keys);
    _fields.forEach((Field f, dynamic value) {
      if(format[f] == FieldRequirement.INVALID)
        throw new FormatException("Invalid field $f in this object");
      fields.remove(f);
    });
    fields.forEach((Field f) {
      if(format[f] == FieldRequirement.REQUIRED)
        throw new FormatException("Required field $f is missing from this object");
    });
  }

}