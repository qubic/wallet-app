/// WalletConnect Methods
abstract class WcMethods {
  /// Get the client to request a list of all accounts in wallet
  static const wRequestAccounts = "wallet_requestAccounts";

  /// Send qubic from an account to a destination address
  static const wSendQubic = "sendQubic";

  /// Send assets from an account to a destination address
  static const wSendAsset = "sendAsset";
}

abstract class WcEvents {
  /// The list of accounts has changed
  static const accountsChanged = "accountsChanged";

  /// The amount of tokens in an account has changed
  static const tokenAmountChanged = "tokenAmountChanged";

  /// The amount of qubics in an account has changed
  static const amountChanged = "amountChanged";

  /// A generic result of method invocation
  static const methodResult = "methodResult";
}
