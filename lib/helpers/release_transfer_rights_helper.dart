import 'dart:convert';
import 'dart:typed_data';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/smart_contracts/release_transfer_rights_info.dart';

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
  /// Returns: Base64-encoded string of the serialized input
  static Future<String> serializeInput({
    required String issuerIdentity,
    required String assetName,
    required int numberOfShares,
    required int newManagingContractIndex,
  }) async {
    final buffer = ByteData(ReleaseTransferRightsInfo.inputStructureSize);
    int offset = 0;

    // 1. Issuer Identity
    // Convert 60-character identity to bytes using ts-library-wrapper
    final qubicCmd = getIt<QubicCmd>();
    final issuerBytesList =
        await qubicCmd.qubicJs.publicKeyStringToBytes(issuerIdentity);
    final issuerBytes = Uint8List.fromList(issuerBytesList);

    if (issuerBytes.length != ReleaseTransferRightsInfo.issuerIdentitySize) {
      throw Exception('Invalid issuer bytes length: ${issuerBytes.length}');
    }

    for (int i = 0; i < ReleaseTransferRightsInfo.issuerIdentitySize; i++) {
      buffer.setUint8(offset++, issuerBytes[i]);
    }

    // 2. Asset Name (null-padded)
    final assetNameBytes = utf8.encode(assetName.toUpperCase());
    for (int i = 0; i < ReleaseTransferRightsInfo.assetNameSize; i++) {
      buffer.setUint8(
          offset++, i < assetNameBytes.length ? assetNameBytes[i] : 0);
    }

    // 3. Number of Shares (little-endian signed int64)
    buffer.setInt64(offset, numberOfShares, Endian.little);
    offset += ReleaseTransferRightsInfo.numberOfSharesSize;

    // 4. New Managing Contract Index (little-endian uint32)
    buffer.setUint32(offset, newManagingContractIndex, Endian.little);
    offset += ReleaseTransferRightsInfo.contractIndexSize;

    // Convert to base64 string
    final bytes = buffer.buffer.asUint8List();
    return base64Encode(bytes);
  }
}
