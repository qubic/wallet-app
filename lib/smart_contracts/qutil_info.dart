class QutilInfo {
  static const address =
      "EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAVWRF";

  /// QUTIL smart-contract index (querySmartContract `contractIndex`).
  static const contractIndex = 4;

  static const sendToManyType = 1;

  static bool isSendToManyTransfer(String? destId, int? inputType) =>
      destId == address && inputType == sendToManyType;

  // GetBalances16 (read-only) — fetches up to 16 balances in one query.
  //   input  (512 bytes): 16 × PublicKey (32 bytes each), zero-padded
  //   output (128 bytes): 16 × sint64 balance (little-endian)
  static const getBalances16InputType = 9; // function id
  static const publicKeySize = 32; // bytes per public key
  static const balanceSize = 8; // sint64 size
  static const maxBalancesPerCall = 16; // identities per GetBalances16 call
  static const getBalances16InputSize =
      publicKeySize * maxBalancesPerCall; // 512
}
