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

  static String getTransactionType(int type) {
    return "$type ${type == 0 ? "Standard" : "SC"}";
  }

  static const mainAssetIssuer =
      "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFXIB";
}
