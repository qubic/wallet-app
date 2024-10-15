/// Results for approving a generic sign request
class ApproveSignGenericResult {
  final String? signedMessage;
  final String? errorMessage;
  final int? errorCode;
  ApproveSignGenericResult(
      {required this.signedMessage, this.errorCode, this.errorMessage});

  ///Important, always provide a toJson otherwise WC serilization will fail
  Map<String, dynamic> toJson() {
    if (errorMessage == null && errorCode == null) {
      return {'signedMessage': signedMessage};
    }
    return {
      'signedMessage': signedMessage,
      'errorMessage': errorMessage,
      'errorCode': errorCode
    };
  }
}
