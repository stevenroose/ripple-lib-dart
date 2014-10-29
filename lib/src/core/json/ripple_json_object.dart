part of ripplelib.core;

/**
 * This class only overrides [JsonObject]'s [toString()] method with one that
 * uses a [RippleJsonEncoder] instead of the default [JsonEncoder].
 */
class RippleJsonObject extends JsonObject {

  RippleJsonObject() : super();

  RippleJsonObject.fromMap(Map jsonMap, [bool recursive = false]) : super.fromMap(jsonMap, false);

  @override
  String toString() => new RippleJsonEncoder().convert(this);
}