import 'package:qubic_wallet/models/wallet_connect/request_result.dart';

/// Results for approving a generic sign request
class RequestSignTransactionResult extends RequestResult {
  final String? signedTransaction;
  final String? transactionId;
  final int? tick;

  RequestSignTransactionResult({
    this.signedTransaction,
    this.transactionId,
    this.tick,
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

  factory RequestSignTransactionResult.success({
    required String? signedTransaction,
    required String? transactionId,
    required int? tick,
  }) {
    return RequestSignTransactionResult(
      signedTransaction: signedTransaction,
      transactionId: transactionId,
      tick: tick,
    );
  }

  factory RequestSignTransactionResult.error({
    required String errorMessage,
    int? errorCode,
  }) {
    return RequestSignTransactionResult(
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }
}
