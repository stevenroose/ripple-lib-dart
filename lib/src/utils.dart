part of ripple;

abstract class Utils {


  /**
   * Calculates the SHA-256 hash of the input data.
   */
  static List<int> sha256Digest(List<int> input) {
    SHA256 digest = new SHA256();
    digest.add(input);
    return new Uint8List.fromList(digest.close());
  }

}