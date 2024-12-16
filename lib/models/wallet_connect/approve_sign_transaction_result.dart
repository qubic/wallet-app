/// Results for approving a generic sign request
class ApproveSignTransactionResult {
  final String? signedTransaction;
  final String? transactionId;
  final String? errorMessage;
  final int? errorCode;
  final int? tick;
  ApproveSignTransactionResult({
    required this.signedTransaction,
    required this.transactionId,
    required this.tick,
    this.errorCode,
    this.errorMessage,
  });

  ///Important, always provide a toJson otherwise WC serilization will fail
  Map<String, dynamic> toJson() {
    if (errorMessage == null && errorCode == null) {
      return {
        'signedTransaction': signedTransaction,
        'transactionId': transactionId
      };
    }
    return {
      'signedTransaction': signedTransaction,
      'tick': tick,
      'errorMessage': errorMessage,
      'errorCode': errorCode
    };
  }
}
