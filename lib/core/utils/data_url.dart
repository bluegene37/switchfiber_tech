import 'dart:convert';
import 'dart:typed_data';

/// Image fields on a job order are plain strings holding either a data URL
/// (`data:image/jpeg;base64,...`) captured on site, or a path the office
/// uploaded from the web console. These helpers move between bytes and that
/// string form and tell the two apart.
class DataUrl {
  DataUrl._();

  static final RegExp _pattern =
      RegExp(r'^data:(image/[a-zA-Z0-9.+-]+);base64,(.*)$', dotAll: true);

  /// Wrap raw image bytes as a data URL with the given MIME type.
  static String encode(Uint8List bytes, {String mimeType = 'image/jpeg'}) =>
      'data:$mimeType;base64,${base64Encode(bytes)}';

  /// Whether [value] is an inline image the app can render itself.
  static bool isDataUrl(String? value) =>
      value != null && _pattern.hasMatch(value.trim());

  /// The MIME type of a data URL, or null for anything else.
  static String? mimeTypeOf(String? value) =>
      value == null ? null : _pattern.firstMatch(value.trim())?.group(1);

  /// Decode a data URL to bytes. Null for paths, URLs, empty strings and
  /// malformed base64, so callers can fall back to a placeholder.
  static Uint8List? decode(String? value) {
    if (value == null) return null;
    final match = _pattern.firstMatch(value.trim());
    if (match == null) return null;
    try {
      return base64Decode(base64.normalize(match.group(2)!));
    } on FormatException {
      return null;
    }
  }

  /// Approximate size of the image a data URL carries, in bytes.
  static int approxBytes(String value) {
    final comma = value.indexOf(',');
    if (comma < 0) return 0;
    return (value.length - comma - 1) * 3 ~/ 4;
  }

  /// Human-readable size such as `240 KB`.
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
