/// Results for approving a generic sign request
class RequestSignTransactionResult {
  final String? signedTransaction;
  final String? transactionId;
  final int? tick;
  final String? errorMessage;
  final int? errorCode;

  RequestSignTransactionResult({
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
    return {'errorMessage': errorMessage, 'errorCode': errorCode};
  }
}
