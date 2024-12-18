class ApproveSendTransactionResult {
  final String transactionId;
  final String? errorMessage;
  final int? errorCode;
  ApproveSendTransactionResult({
    required this.transactionId,
    this.errorCode,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() {
    return {'transactionId': transactionId};
  }
}
