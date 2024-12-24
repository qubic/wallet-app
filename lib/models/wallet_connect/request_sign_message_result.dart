import 'package:qubic_wallet/models/qubic_sign_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_result.dart';

/// Results for approving a generic sign request
class RequestSignMessageResult extends RequestResult {
  final QubicSignResult? result;

  RequestSignMessageResult({this.result, super.errorCode, super.errorMessage});

  ///Important, always provide a toJson otherwise WC serilization will fail
  Map<String, dynamic> toJson() {
    if (errorMessage == null && errorCode == null) {
      return result!.toJson();
    }
    return {'errorMessage': errorMessage, 'errorCode': errorCode};
  }

  factory RequestSignMessageResult.success({required QubicSignResult result}) {
    return RequestSignMessageResult(result: result);
  }

  factory RequestSignMessageResult.error(
      {required String errorMessage, int? errorCode}) {
    return RequestSignMessageResult(
        errorMessage: errorMessage, errorCode: errorCode);
  }
}
