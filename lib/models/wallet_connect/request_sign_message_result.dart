import 'package:qubic_wallet/models/qubic_sign_result.dart';

/// Results for approving a generic sign request
class RequestSignMessageResult {
  final QubicSignResult? result;
  final String? errorMessage;
  final int? errorCode;

  RequestSignMessageResult(
      {required this.result, this.errorCode, this.errorMessage});

  ///Important, always provide a toJson otherwise WC serilization will fail
  Map<String, dynamic> toJson() {
    if (errorMessage == null && errorCode == null) {
      return result!.toJson();
    }
    return {'errorMessage': errorMessage, 'errorCode': errorCode};
  }
}
