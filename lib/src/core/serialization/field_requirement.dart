part of ripplelib.core;

class FieldRequirement extends Enum {

  static const FieldRequirement INVALID  = const FieldRequirement._(-1);
  static const FieldRequirement REQUIRED = const FieldRequirement._(0);
  static const FieldRequirement OPTIONAL = const FieldRequirement._(1);
  static const FieldRequirement DEFAULT  = const FieldRequirement._(2);

  final int id;
  const FieldRequirement._(this.id);

  // required by Enum
  static FieldRequirement valueOf(String e) => Enum.valueOf(FieldRequirement, e);
  static List<FieldRequirement> get values => Enum.values(FieldRequirement);
}