/// Results for approving a generic sign request
class ApproveSignGenericResult {
  final String? signedMessageBase64;
  final String? errorMessage;
  final int? errorCode;
  ApproveSignGenericResult(
      {required this.signedMessageBase64, this.errorCode, this.errorMessage});

  ///Important, always provide a toJson otherwise WC serilization will fail
  Map<String, dynamic> toJson() {
    if (errorMessage == null && errorCode == null) {
      return {'signedMessageBase64': signedMessageBase64};
    }
    return {
      'signedMessageBase64': signedMessageBase64,
      'errorMessage': errorMessage,
      'errorCode': errorCode
    };
  }
}
