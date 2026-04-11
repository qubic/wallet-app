import 'dart:convert';

/// Converts a Base64-encoded string to a lowercase hex string.
/// Returns an empty string for empty input or invalid Base64.
String base64ToHex(String base64Str) {
  if (base64Str.isEmpty) return '';
  try {
    final bytes = base64Decode(base64Str);
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  } catch (_) {
    return '';
  }
}
