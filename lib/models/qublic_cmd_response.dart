import 'package:qubic_wallet/models/qubic_import_vault_seed.dart';

class QubicCmdResponse {
  late bool status;
  String? publicId; //createPublicId
  String? error;
  String? transaction; //for createTransactionAssetMove and createTransaction
  String? base64; //for wallet.createVaultFile
  List<QubicImportVaultSeed>? seeds; //for import seeds
  bool? isValid;
  String? signedData; //For signRaw, signASCII, signUTF8
  String? digest; //For signRaw, signASCII, signUTF8
  String? signature; //For signRaw, signASCII, signUTF8

  QubicCmdResponse(
      {required this.status,
      this.publicId,
      this.error,
      this.transaction,
      this.base64,
      this.seeds,
      this.isValid,
      this.signedData,
      this.digest,
      this.signature});

  factory QubicCmdResponse.fromJson(Map<String, dynamic> json) {
    List<QubicImportVaultSeed>? seeds;
    if (json.containsKey("seeds")) {
      seeds = <QubicImportVaultSeed>[];
      for (var seed in json['seeds']) {
        seeds.add(QubicImportVaultSeed(
            seed['alias'], seed['publicId'], seed['seed']));
      }
    }

    return QubicCmdResponse(
        status: json['status'] == "ok" ? true : false,
        publicId: json.containsKey("publicId") ? json['publicId'] : null,
        error: json.containsKey("error") ? json['error'] : null,
        transaction:
            json.containsKey("transaction") ? json['transaction'] : null,
        base64: json.containsKey("base64") ? json['base64'] : null,
        seeds: json.containsKey("seeds") ? seeds : null,
        isValid: json.containsKey("isValid") ? json['isValid'] : null,
        signedData: json.containsKey("signedData") ? json['signedData'] : null,
        digest: json.containsKey("digest") ? json['digest'] : null,
        signature: json.containsKey("signature") ? json['signature'] : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status ? "true" : false;
    data['publicId'] = publicId;
    data['error'] = error;
    data['transaction'] = transaction;
    data['base64'] = base64;
    data['isValid'] = isValid;
    data['signedData'] = signedData;
    data['digest'] = digest;
    data['signature'] = signature;

    return data;
  }
}
