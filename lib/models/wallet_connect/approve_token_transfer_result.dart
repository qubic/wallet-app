/// Results for approving token transfer
class ApproveTokenTransferResult {
  final int? tick;
  final String? errorMessage;
  final int? errorCode;
  ApproveTokenTransferResult(
      {required this.tick, this.errorCode, this.errorMessage});

  ///Important, always provide a toJson otherwise WC serilization will fail
  Map<String, dynamic> toJson() {
    if (errorMessage == null && errorCode == null) {
      return {'tick': tick};
    }
    return {'tick': tick, 'errorMessage': errorMessage, 'errorCode': errorCode};
  }
}
