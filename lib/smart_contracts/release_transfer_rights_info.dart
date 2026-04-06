/// Procedure type discriminator for management rights operations.
enum ManagementRightsProcedureType { transfer, revoke }

/// Information and constants for Release Transfer Rights functionality
/// Data is dynamically loaded from smart_contracts.json via QubicEcosystemStore
class ReleaseTransferRightsInfo {
  // Field sizes in bytes
  static const int issuerIdentitySize = 32; // Identity (public key) size
  static const int assetNameSize = 8;       // Asset name size
  static const int numberOfSharesSize = 8;  // sint64 size
  static const int contractIndexSize = 4;   // uint32 size

  // TransferShareManagementRights input structure size (52 bytes)
  // Asset asset (issuer: 32 bytes + assetName: 8 bytes) = 40 bytes
  // sint64 numberOfShares = 8 bytes
  // uint32 newManagingContractIndex = 4 bytes
  // Total = 52 bytes
  static const int inputStructureSize = issuerIdentitySize + assetNameSize + numberOfSharesSize + contractIndexSize;

  // RevokeAssetManagementRights input structure size (48 bytes)
  // Asset asset (issuer: 32 bytes + assetName: 8 bytes) = 40 bytes
  // sint64 numberOfShares = 8 bytes
  // Total = 48 bytes (no newManagingContractIndex)
  static const int revokeInputStructureSize = issuerIdentitySize + assetNameSize + numberOfSharesSize;

  // Source identifier constants (from smart_contracts.json), stored lowercase for direct comparison
  static const String transferSourceIdentifier = "transfersharemanagementrights";
  static const String revokeSourceIdentifier = "revokeassetmanagementrights";

  // Default fee when releasing FROM a contract
  static const int defaultReleaseFee = 0;
}
