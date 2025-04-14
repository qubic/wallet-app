import 'package:qubic_wallet/config.dart';

/// QX Related constants
abstract class QxInfo {
  /// Qx Address
  static const String address =
      "BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARMID";

  /// Cost for issuing an asset
  static const issueAssetFee = 1000000000;

  /// Cost for transferring an asset
  static const transferAssetFee = 100;

  /// Input type for issuing an asset
  static const issueAssetInputType = 1;

  /// Input type for transferring an asset
  static const transferAssetInputType = 2;

  static const mainAssetIssuer = Config.zeroAddress;

  static bool isQxTransferShares(String? destId, int? inputType) =>
      destId == address && inputType == transferAssetInputType;
}
