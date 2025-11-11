import 'dart:convert';
import 'dart:typed_data';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/resources/qubic_js.dart';

/// Helper class for serializing Release Transfer Rights transaction input
///
/// This implements the TransferShareManagementRights_input struct from Qx.h:
/// ```
/// struct TransferShareManagementRights_input {
///     Asset asset;
///     sint64 numberOfShares;
///     uint32 newManagingContractIndex;
/// };
/// ```
///
/// Input Structure (52 bytes total):
/// 1. Asset issuer (32 bytes): Identity address converted to bytes using base-26 encoding
/// 2. Asset name (8 bytes): Uppercase ASCII, null-padded
/// 3. Number of shares (8 bytes): Signed 64-bit integer, little-endian
/// 4. New managing contract index (4 bytes): Unsigned 32-bit integer, little-endian

class ReleaseTransferRightsHelper {
  /// Serialize the release transfer rights input structure to base64 string
  ///
  /// Parameters:
  /// - [issuerIdentity]: 60-character Qubic identity address (uppercase A-Z, will be converted to 32 bytes using base-26)
  /// - [assetName]: Asset name (max 8 characters, will be uppercase and null-padded)
  /// - [numberOfShares]: Number of shares to transfer (signed 64-bit integer)
  /// - [newManagingContractIndex]: Contract index to transfer management rights to (32-bit unsigned)
  ///
  /// Returns: Base64-encoded string of 52 bytes
  static Future<String> serializeInput({
    required String issuerIdentity,
    required String assetName,
    required int numberOfShares,
    required int newManagingContractIndex,
  }) async {
    final buffer = ByteData(52);
    int offset = 0;

    // 1. Issuer Identity (32 bytes)
    // Convert 60-character identity to 32 bytes using ts-library-wrapper
    final qubicJs = getIt<QubicJs>();
    final issuerBytesList =
        await qubicJs.publicKeyStringToBytes(issuerIdentity);
    final issuerBytes = Uint8List.fromList(issuerBytesList);

    if (issuerBytes.length != 32) {
      throw Exception('Invalid issuer bytes length: ${issuerBytes.length}');
    }

    for (int i = 0; i < 32; i++) {
      buffer.setUint8(offset++, issuerBytes[i]);
    }

    // 2. Asset Name (8 bytes, null-padded)
    final assetNameBytes = utf8.encode(assetName.toUpperCase());
    for (int i = 0; i < 8; i++) {
      buffer.setUint8(
          offset++, i < assetNameBytes.length ? assetNameBytes[i] : 0);
    }

    // 3. Number of Shares (8 bytes, little-endian signed int64)
    buffer.setInt64(offset, numberOfShares, Endian.little);
    offset += 8;

    // 4. New Managing Contract Index (4 bytes, little-endian uint32)
    buffer.setUint32(offset, newManagingContractIndex, Endian.little);
    offset += 4;

    // Convert to base64 string
    final bytes = buffer.buffer.asUint8List();
    return base64Encode(bytes);
  }

  /// Validate input parameters
  static void validateInput({
    required String issuerIdentity,
    required String assetName,
    required int numberOfShares,
    required int newManagingContractIndex,
  }) {
    if (issuerIdentity.length != 60) {
      throw ArgumentError('Issuer identity must be 60 characters long');
    }

    if (assetName.isEmpty || assetName.length > 8) {
      throw ArgumentError('Asset name must be 1-8 characters long');
    }

    if (numberOfShares <= 0) {
      throw ArgumentError('Number of shares must be positive');
    }

    if (newManagingContractIndex < 0 || newManagingContractIndex > 0xFFFFFFFF) {
      throw ArgumentError(
          'Contract index must be a valid 32-bit unsigned integer');
    }
  }
}
