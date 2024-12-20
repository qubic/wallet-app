class RequestSendTransactionResult {
  final String transactionId;
  final String? errorMessage;
  final int? errorCode;

  RequestSendTransactionResult({
    required this.transactionId,
    this.errorCode,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() {
    return {'transactionId': transactionId};
  }
}
