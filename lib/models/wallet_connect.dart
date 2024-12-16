/// WalletConnect Methods
abstract class WcMethods {
  /// Get the client to request a list of all accounts in wallet
  static const wRequestAccounts = "qubic_requestAccounts";

  /// Send qubic from an account to a destination address
  static const wSendQubic = "qubic_sendQubic";

  /// Send assets from an account to a destination address
  static const wSendAsset = "qubic_sendAsset";

  /// Sign a transaction
  static const wSignTransaction = "qubic_signTransaction";

  /// Sign a generic message
  static const wSign = "qubic_sign";
}

/// WalletConnect Events
abstract class WcEvents {
  /// The list of accounts has changed
  static const accountsChanged = "accountsChanged";

  /// The amount of tokens in an account has changed
  static const tokenAmountChanged = "tokenAmountChanged";

  /// The amount of qubics in an account has changed
  static const amountChanged = "amountChanged";
}

/// WalletConnect Errors
abstract class WcErrors {
  static const qwGeneralError = -1;
  static const qwUserUnavailable = -1;
}
