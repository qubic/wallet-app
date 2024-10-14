/// Results for approving a generic sign request
class ApproveSignTransactionResult {
  final String? signedTransaction;
  final String? errorMessage;
  final int? errorCode;
  final int? tick;
  ApproveSignTransactionResult({
    required this.signedTransaction,
    required this.tick,
    this.errorCode,
    this.errorMessage,
  });

  ///Important, always provide a toJson otherwise WC serilization will fail
  Map<String, dynamic> toJson() {
    if (errorMessage == null && errorCode == null) {
      return {'signedTransaction': signedTransaction};
    }
    return {
      'signedTransaction': signedTransaction,
      'tick': tick,
      'errorMessage': errorMessage,
      'errorCode': errorCode
    };
  }
}
