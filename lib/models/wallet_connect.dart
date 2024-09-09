/// WalletConnect Methods
abstract class wcMethods {
  /// Get the client to request a list of all accounts in wallet
  static const wRequestAccounts = "wallet_requestAccounts";

  /// Send qubic from an account to a destination address
  static const wSendQubic = "sendQubic";

  /// Send assets from an account to a destination address
  static const wSendAsset = "sendAsset";
}

abstract class wcEvents {
  /// The list of accounts has changed
  static const accountsChanged = "accountsChanged";

  /// The tick has changed
  static const tickChanged = "tickChanged";

  /// The amount of tokens in an account has changed
  static const tokenAmountChanged = "tokenAmountChanged";

  /// The amount of qubics in an account has changed
  static const amountChanged = "amountChanged";
}

/// A request event - for in app exchange of info when a dApp makes a request (e.g. wallet_requestAccounts)
class RequestEvent {
  final String topic;
  const RequestEvent({required this.topic});
}

// A request event for wallet_requestAccounts
class RequestAccountsEvent extends RequestEvent {
  RequestAccountsEvent({required super.topic});
}
