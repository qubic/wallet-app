import 'package:qubic_wallet/models/wallet_connect/request_result.dart';

/// Results for approving token transfer
class RequestSendTransactionResult extends RequestResult {
  final int? tick;
  final String? transactionId;

  RequestSendTransactionResult(
      {this.tick, this.transactionId, super.errorCode, super.errorMessage});

  ///Important, always provide a toJson otherwise WC serilization will fail
  Map<String, dynamic> toJson() {
    if (!hasError) {
      return {'tick': tick, 'transactionId': transactionId};
    }
    return toErrorJson();
  }

  factory RequestSendTransactionResult.success(
      {required int? tick, required String? transactionId}) {
    return RequestSendTransactionResult(
        tick: tick, transactionId: transactionId);
  }

  factory RequestSendTransactionResult.error(
      {required String errorMessage, int? errorCode}) {
    return RequestSendTransactionResult(
        errorMessage: errorMessage, errorCode: errorCode);
  }
}
