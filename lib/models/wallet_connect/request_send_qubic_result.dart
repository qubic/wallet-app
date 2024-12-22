import 'package:qubic_wallet/models/wallet_connect/request_result.dart';

/// Results for approving token transfer
class RequestSendQubicResult extends RequestResult {
  final int? tick;
  final String? transactionId;

  RequestSendQubicResult(
      {this.tick, this.transactionId, super.errorCode, super.errorMessage});

  ///Important, always provide a toJson otherwise WC serilization will fail
  Map<String, dynamic> toJson() {
    if (!hasError) {
      return {'tick': tick, 'transactionId': transactionId};
    }
    return toErrorJson();
  }

  factory RequestSendQubicResult.success(
      {required int? tick, required String? transactionId}) {
    return RequestSendQubicResult(tick: tick, transactionId: transactionId);
  }

  factory RequestSendQubicResult.error(
      {required String errorMessage, int? errorCode}) {
    return RequestSendQubicResult(
        errorMessage: errorMessage, errorCode: errorCode);
  }
}
