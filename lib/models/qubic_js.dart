abstract class QubicJSFunctions {
  /// Signs a transaction to move assets
  static const createTransactionAssetMove = "createTransactionAssetMove";

  // Signs a transaction to move Qubic
  static const createTransaction = "createTransaction";

  // Signs a transaction with payload
  static const createTransactionWithPayload = "createTransactionWithPayload";

  // Creates a public ID
  static const createPublicId = "createPublicId";

  // Creates a vault file
  static const createVaultFile = "wallet.createVaultFile";

  // Verifies an identity
  static const verifyIdentity = "verifyIdentity";

  // Creates signed from Raw data (base64)
  static const signRaw = "createSigned.fromRaw";

  // Creates signed from ASCII data
  static const signASCII = "createSigned.fromASCII";

// Creates signed from UTF-8 data
  static const signUTF8 = "createSigned.fromUTF8";

  // Imports a vault from a string
  static const importVault = "wallet.importVault";

  // Import a vault from a file (LINUX ONLY)
  static const importVaultFile = "wallet.importVaultFile";
  // Parse an asset transfer payload
  static const parseAssetTransferPayload = "parseAssetTransferPayload";
  // Parse QUtil SendMany transfer payload
  static const parseTransferSendManyPayload = "parseTransferSendManyPayload";

  // Qubic identity conversion function
  static const String publicKeyStringToBytes = 'publicKeyStringToBytes';
}
