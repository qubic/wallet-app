import 'dart:core';

import 'package:qubic_wallet/models/qublic_cmd_response.dart';

class QubicSignResult {
  late String signedData; //The private seed of the ID
  late String digest; //The public ID
  late String signature; //A descriptive name of the ID

  factory QubicSignResult.fromJson(Map<String, dynamic> json) {
    var signedData = json['signedData'];
    var digest = json['digest'];
    var signature = json['signature'];
    return QubicSignResult(signedData, digest, signature);
  }

  factory QubicSignResult.fromCMDResponse(QubicCmdResponse response) {
    var signedData = response.signedData!;
    var digest = response.digest!;
    var signature = response.signature!;
    return QubicSignResult(signedData, digest, signature);
  }

  Map<String, dynamic> toJson() => {
        "signedData": signedData,
        "digest": digest,
        "signature": signature,
      };

  QubicSignResult(this.signedData, this.digest, this.signature);
}
