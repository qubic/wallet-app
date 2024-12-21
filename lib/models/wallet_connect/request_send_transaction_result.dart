import 'package:qubic_wallet/models/wallet_connect/request_result.dart';

class RequestSendTransactionResult extends RequestResult {
  final String transactionId;

  RequestSendTransactionResult({
    required this.transactionId,
    super.errorCode,
    super.errorMessage,
  });

  Map<String, dynamic> toJson() {
    if (!hasError) {
      return {'transactionId': transactionId};
    }
    return toErrorJson();
  }
}
