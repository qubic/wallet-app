/// Results for approving a generic sign request
class ApproveSignTransactionResult {
  final String? signedTransactionBase64;
  final String? errorMessage;
  final int? errorCode;
  ApproveSignTransactionResult(
      {required this.signedTransactionBase64,
      this.errorCode,
      this.errorMessage});

  ///Important, always provide a toJson otherwise WC serilization will fail
  Map<String, dynamic> toJson() {
    if (errorMessage == null && errorCode == null) {
      return {'signedTransactionBase64': signedTransactionBase64};
    }
    return {
      'signedTransactionBase64': signedTransactionBase64,
      'errorMessage': errorMessage,
      'errorCode': errorCode
    };
  }
}
