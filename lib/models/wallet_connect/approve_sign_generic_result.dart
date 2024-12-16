import 'package:qubic_wallet/models/qubic_sign_result.dart';

/// Results for approving a generic sign request
class ApproveSignGenericResult {
  final QubicSignResult? result;
  final String? errorMessage;
  final int? errorCode;
  ApproveSignGenericResult(
      {required this.result, this.errorCode, this.errorMessage});

  ///Important, always provide a toJson otherwise WC serilization will fail
  Map<String, dynamic> toJson() {
    if (errorMessage == null && errorCode == null) {
      if (result == null) {
        throw Exception('result is required');
      } else {
        return {
          'result': {
            'signedData': result!.signedData,
            'digest': result!.digest,
            'signature': result!.signature
          }
        };
      }
    }
    return {
      'result': null,
      'errorMessage': errorMessage,
      'errorCode': errorCode
    };
  }
}
