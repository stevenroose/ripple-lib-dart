part of ripplelib.core;

/**
 * Use this class as a mixin to allow for JSON serialization.
 *
 * Classes using this mixin should have the toJson() method that converts the object to a
 * JSON-serializable object, like a String, number, Map, List or null.
 *
 * This mixin will introduce a toJSON() method to directly convert the object to a JSON string.
 *
 * The name confusion is because toJson() is the default method name used by the Dart JsonCodec to
 * convert an object into a JSON-serializable one, while toJSON() is used by ripple-lib to convert
 * objects to JSON strings.
 */
abstract class JSONable {

  String toJSON() => const JsonEncoder().convert(this);

}