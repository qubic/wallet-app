import 'dart:convert';
import 'dart:typed_data';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/smart_contracts/release_transfer_rights_info.dart';

/// Helper class for serializing Release Transfer Rights transaction input
///
/// TransferShareManagementRights_input (52 bytes):
///   Asset asset (issuer 32 + assetName 8) + sint64 numberOfShares + uint32 newManagingContractIndex
///
/// RevokeAssetManagementRights_input (48 bytes):
///   Asset asset (issuer 32 + assetName 8) + sint64 numberOfShares

class ReleaseTransferRightsHelper {
  /// Writes issuer identity (32 bytes) and asset name (8 bytes, null-padded)
  /// into [buffer] starting at [offset]. Returns the new offset (offset + 40).
  static Future<int> _writeAsset(
      ByteData buffer, int offset, String issuerIdentity, String assetName) async {
    // Issuer Identity: 60-char Qubic address → 32 bytes via base-26 encoding
    final qubicCmd = getIt<QubicCmd>();
    final issuerBytes = Uint8List.fromList(
        await qubicCmd.qubicJs.publicKeyStringToBytes(issuerIdentity));

    if (issuerBytes.length != ReleaseTransferRightsInfo.issuerIdentitySize) {
      throw Exception('Invalid issuer bytes length: ${issuerBytes.length}');
    }
    for (int i = 0; i < ReleaseTransferRightsInfo.issuerIdentitySize; i++) {
      buffer.setUint8(offset++, issuerBytes[i]);
    }

    // Asset Name: uppercase ASCII, null-padded to 8 bytes
    final assetNameBytes = utf8.encode(assetName.toUpperCase());
    if (assetNameBytes.length > ReleaseTransferRightsInfo.assetNameSize) {
      throw ArgumentError(
          'Asset name exceeds maximum length of ${ReleaseTransferRightsInfo.assetNameSize} bytes. '
          'Got ${assetNameBytes.length} bytes.');
    }
    for (int i = 0; i < ReleaseTransferRightsInfo.assetNameSize; i++) {
      buffer.setUint8(offset++, i < assetNameBytes.length ? assetNameBytes[i] : 0);
    }

    return offset;
  }

  /// Serialize TransferShareManagementRights input (52 bytes) to base64.
  static Future<String> serializeInput({
    required String issuerIdentity,
    required String assetName,
    required int numberOfShares,
    required int newManagingContractIndex,
  }) async {
    if (numberOfShares <= 0) {
      throw ArgumentError('numberOfShares must be positive, got: $numberOfShares');
    }

    final buffer = ByteData(ReleaseTransferRightsInfo.inputStructureSize);
    int offset = await _writeAsset(buffer, 0, issuerIdentity, assetName);

    buffer.setInt64(offset, numberOfShares, Endian.little);
    offset += ReleaseTransferRightsInfo.numberOfSharesSize;

    buffer.setUint32(offset, newManagingContractIndex, Endian.little);

    return base64Encode(buffer.buffer.asUint8List());
  }

  /// Serialize RevokeAssetManagementRights input (48 bytes) to base64.
  static Future<String> serializeRevokeInput({
    required String issuerIdentity,
    required String assetName,
    required int numberOfShares,
  }) async {
    if (numberOfShares <= 0) {
      throw ArgumentError('numberOfShares must be positive, got: $numberOfShares');
    }

    final buffer = ByteData(ReleaseTransferRightsInfo.revokeInputStructureSize);
    int offset = await _writeAsset(buffer, 0, issuerIdentity, assetName);

    buffer.setInt64(offset, numberOfShares, Endian.little);
    offset += ReleaseTransferRightsInfo.numberOfSharesSize;

    return base64Encode(buffer.buffer.asUint8List());
  }
}
