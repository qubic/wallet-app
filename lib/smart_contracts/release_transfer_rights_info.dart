/// Information and constants for Release Transfer Rights functionality
/// Data is dynamically loaded from smart_contracts.json via QubicEcosystemStore
class ReleaseTransferRightsInfo {
  // Input structure size in bytes (constant across all contracts)
  // Asset asset (issuer: 32 bytes + assetName: 8 bytes) = 40 bytes
  // sint64 numberOfShares = 8 bytes
  // uint32 newManagingContractIndex = 4 bytes
  // Total = 52 bytes
  static const int inputStructureSize = 52;

  // Procedure name constant (same across all supporting contracts)
  static const String procedureName = "Transfer Share Management Rights";

  // Default fee when releasing FROM a contract
  static const int defaultReleaseFee = 0;
}
