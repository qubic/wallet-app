import 'dart:convert';
import 'dart:typed_data';

/// Data class for a parsed signed message
class SignedMessageData {
  final String identity;
  final String message;
  final String signature;

  const SignedMessageData({
    required this.identity,
    required this.message,
    required this.signature,
  });
}

/// Utility for converting between QubicSignResult format and the
/// cross-compatible Angular wallet format.
///
/// Angular wallet format:
/// ```json
/// { "identity": "AAA...ZZZ", "message": "text", "signature": "AAA...PPP" }
/// ```
/// Where signature is 130 chars of shifted-hex (A-P alphabet) encoding
/// 65 bytes: 64-byte Schnorrq signature + 1-byte K12 checksum.
class SignatureFormatHelper {
  static const int _codeUnitA = 65; // 'A'

  /// Encode bytes to shifted-hex (A-P alphabet).
  ///
  /// Each byte becomes two characters: high nibble then low nibble,
  /// where A=0x0, B=0x1, ..., P=0xF.
  static String encodeShiftedHex(Uint8List bytes) {
    final buffer = StringBuffer();
    for (int i = 0; i < bytes.length; i++) {
      buffer.writeCharCode(_codeUnitA + (bytes[i] >> 4));
      buffer.writeCharCode(_codeUnitA + (bytes[i] & 0x0F));
    }
    return buffer.toString();
  }

  /// Decode shifted-hex string (A-P alphabet) to bytes.
  ///
  /// Input must be uppercase A-P characters with even length.
  /// Throws [FormatException] on invalid input.
  static Uint8List decodeShiftedHex(String encoded) {
    final upper = encoded.toUpperCase();
    if (upper.length % 2 != 0) {
      throw const FormatException('Shifted-hex string must have even length');
    }
    final bytes = Uint8List(upper.length ~/ 2);
    for (int i = 0; i < bytes.length; i++) {
      final hi = upper.codeUnitAt(i * 2) - _codeUnitA;
      final lo = upper.codeUnitAt(i * 2 + 1) - _codeUnitA;
      if (hi < 0 || hi > 15 || lo < 0 || lo > 15) {
        throw FormatException(
            'Invalid shifted-hex character at position ${i * 2}');
      }
      bytes[i] = (hi << 4) | lo;
    }
    return bytes;
  }

  /// Build cross-compatible signed message JSON from raw signature bytes.
  ///
  /// [signatureBytes] must be exactly 64 bytes (raw Schnorrq signature).
  /// This method computes a K12 checksum, appends it, and re-encodes
  /// as shifted-hex.
  ///
  /// Returns a pretty-printed JSON string matching the Angular wallet format.
  static String buildSignedMessageJson({
    required String identity,
    required String message,
    required Uint8List signatureBytes,
  }) {
    if (signatureBytes.length != 64) {
      throw ArgumentError(
          'Expected 64-byte signature, got ${signatureBytes.length}');
    }

    // Compute 1-byte K12 checksum of the 64-byte signature
    // NOTE: K12 hashing requires the qubic helper. For now, we use a
    // simple checksum. During integration testing, verify this matches
    // the Angular wallet's K12 output and replace if needed.
    final checksum = _computeSimpleChecksum(signatureBytes);

    // Build 65-byte array: 64 sig + 1 checksum
    final sigWithChecksum = Uint8List(65);
    sigWithChecksum.setAll(0, signatureBytes);
    sigWithChecksum[64] = checksum;

    // Encode as shifted-hex
    final encodedSig = encodeShiftedHex(sigWithChecksum);

    final result = {
      'identity': identity,
      'message': message,
      'signature': encodedSig,
    };

    return const JsonEncoder.withIndent('  ').convert(result);
  }

  /// Parse and validate a signed message JSON string.
  ///
  /// Returns [SignedMessageData] if valid, null if JSON is malformed
  /// or required fields are missing.
  static SignedMessageData? parseSignedMessage(String jsonString) {
    try {
      final parsed = jsonDecode(jsonString);
      if (parsed is! Map<String, dynamic>) return null;

      final identity = parsed['identity'];
      final message = parsed['message'];
      final signature = parsed['signature'];

      if (identity is! String || message is! String || signature is! String) {
        return null;
      }
      if (identity.isEmpty || message.isEmpty || signature.isEmpty) {
        return null;
      }

      return SignedMessageData(
        identity: identity,
        message: message,
        signature: signature,
      );
    } catch (_) {
      return null;
    }
  }

  /// Validate identity format: exactly 60 uppercase A-Z characters.
  static bool isValidIdentityFormat(String identity) {
    return RegExp(r'^[A-Z]{60}$').hasMatch(identity);
  }

  /// Validate signature format: exactly 130 A-P characters (case-insensitive).
  static bool isValidSignatureFormat(String signature) {
    return RegExp(r'^[A-Pa-p]{130}$').hasMatch(signature);
  }

  /// Validate shifted-hex signature checksum.
  ///
  /// Decodes the 130-char signature to 65 bytes, then verifies that
  /// byte 65 matches the K12 checksum of bytes 1-64.
  /// Returns true if checksum is valid.
  static bool validateSignatureChecksum(String signature) {
    try {
      final decoded = decodeShiftedHex(signature);
      if (decoded.length != 65) return false;

      final sigBytes = decoded.sublist(0, 64);
      final checksum = decoded[64];

      final expectedChecksum = _computeSimpleChecksum(sigBytes);
      return checksum == expectedChecksum;
    } catch (_) {
      return false;
    }
  }

  /// Simple checksum placeholder — XOR fold of all bytes.
  ///
  /// TODO: Replace with actual K12 hash once the Dart K12 dependency
  /// is resolved (via qubic helper binary or Dart FFI).
  /// The Angular wallet uses: K12(signature, checksumOut, 1)
  /// which produces a 1-byte K12 digest of the 64-byte signature.
  static int _computeSimpleChecksum(Uint8List bytes) {
    int checksum = 0;
    for (final b in bytes) {
      checksum ^= b;
    }
    return checksum;
  }
}
