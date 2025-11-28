/// Information and constants for Release Transfer Rights functionality
/// Data is dynamically loaded from smart_contracts.json via QubicEcosystemStore
class ReleaseTransferRightsInfo {
  // Field sizes in bytes
  static const int issuerIdentitySize = 32; // Identity (public key) size
  static const int assetNameSize = 8;       // Asset name size
  static const int numberOfSharesSize = 8;  // sint64 size
  static const int contractIndexSize = 4;   // uint32 size

  // Input structure size in bytes (constant across all contracts)
  // Asset asset (issuer: 32 bytes + assetName: 8 bytes) = 40 bytes
  // sint64 numberOfShares = 8 bytes
  // uint32 newManagingContractIndex = 4 bytes
  // Total = 52 bytes
  static const int inputStructureSize = issuerIdentitySize + assetNameSize + numberOfSharesSize + contractIndexSize;

  // Procedure name constant (same across all supporting contracts)
  static const String procedureName = "Transfer Share Management Rights";

  // Default fee when releasing FROM a contract
  static const int defaultReleaseFee = 0;
}
