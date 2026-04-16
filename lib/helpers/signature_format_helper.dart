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
/// cross-compatible signed message format.
///
/// Signed message format:
/// ```json
/// { "identity": "AAA...ZZZ", "message": "text", "signature": "AAA...PPP" }
/// ```
/// Where signature is 130 chars of shifted-hex (A-P alphabet) encoding
/// 65 bytes: 64-byte Schnorrq signature + 1-byte K12 checksum.
class SignatureFormatHelper {
  static const int _codeUnitA = 65; // 'A'
  static final RegExp _identityRe = RegExp(r'^[A-Z]{60}$');
  static final RegExp _signatureRe = RegExp(r'^[A-Pa-p]{130}$');

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
  /// Input must be A-P characters (case-insensitive) with even length.
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

  /// Build signed message JSON from raw signature bytes + K12 checksum.
  ///
  /// [signatureBytes] must be exactly 64 bytes (raw Schnorrq signature).
  /// [k12Checksum] is the 1-byte K12 checksum of the signature.
  /// Appends the checksum byte (65 bytes total) and encodes as 130-char
  /// shifted-hex, matching the Qubic.NET Wallet and Toolkit format.
  ///
  /// Returns a pretty-printed JSON string.
  static String buildSignedMessageJson({
    required String identity,
    required String message,
    required Uint8List signatureBytes,
    required int k12Checksum,
  }) {
    if (signatureBytes.length != 64) {
      throw ArgumentError(
          'Expected 64-byte signature, got ${signatureBytes.length}');
    }

    // Build 65-byte array: 64 sig + 1 K12 checksum
    final sigWithChecksum = Uint8List(65);
    sigWithChecksum.setAll(0, signatureBytes);
    sigWithChecksum[64] = k12Checksum;

    // Encode as shifted-hex (130 chars)
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
      if (identity.isEmpty || signature.isEmpty) {
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
  static bool isValidIdentityFormat(String identity) =>
      _identityRe.hasMatch(identity);

  /// Validate signature format: exactly 130 A-P characters (case-insensitive).
  /// 65 bytes = 64-byte Schnorrq signature + 1-byte K12 checksum.
  static bool isValidSignatureFormat(String signature) =>
      _signatureRe.hasMatch(signature);
}
