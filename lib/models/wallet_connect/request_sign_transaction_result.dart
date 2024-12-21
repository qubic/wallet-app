import 'package:qubic_wallet/models/wallet_connect/request_result.dart';

/// Results for approving a generic sign request
class RequestSignTransactionResult extends RequestResult {
  final String? signedTransaction;
  final String? transactionId;
  final int? tick;

  RequestSignTransactionResult({
    required this.signedTransaction,
    required this.transactionId,
    required this.tick,
    super.errorCode,
    super.errorMessage,
  });

  ///Important, always provide a toJson otherwise WC serilization will fail
  Map<String, dynamic> toJson() {
    if (!hasError) {
      return {
        'signedTransaction': signedTransaction,
        'transactionId': transactionId
      };
    }
    return toErrorJson();
  }
}
