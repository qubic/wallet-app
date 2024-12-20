/// Results for approving token transfer
class RequestSendQubicResult {
  final int? tick;
  final String? transactionId;
  final String? errorMessage;
  final int? errorCode;

  RequestSendQubicResult(
      {required this.tick,
      required this.transactionId,
      this.errorCode,
      this.errorMessage});

  ///Important, always provide a toJson otherwise WC serilization will fail
  Map<String, dynamic> toJson() {
    if (errorMessage == null && errorCode == null) {
      return {'tick': tick, 'transactionId': transactionId};
    }
    return {'errorMessage': errorMessage, 'errorCode': errorCode};
  }
}
