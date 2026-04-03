// This is a placeholder file to prevent non-web builds from crashing.
// It provides the same method names as the real dart:html so the compiler doesn't panic.

class AnchorElement {
  String? href;
  String? download;
  AnchorElement({this.href});
  
  void click() {}

  // Added this to satisfy the compiler for mobile builds
  dynamic setAttribute(String name, String value) {
    return this;
  }
}

class Blob {
  Blob(List<dynamic> bytes);
}

class Url {
  static String createObjectUrlFromBlob(dynamic blob) => '';
  static void revokeObjectUrl(String url) {}
}