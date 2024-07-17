class QubicCmdResponse {
  late bool status;
  String? publicId; //createPublicId
  String? error;
  String? transaction; //for createTransactionAssetMove and createTransaction
  String? base64; //for wallet.createVaultFile

  QubicCmdResponse(
      {required this.status,
      this.publicId,
      this.error,
      this.transaction,
      this.base64});

  factory QubicCmdResponse.fromJson(Map<String, dynamic> json) {
    return QubicCmdResponse(
      status: json['status'] == "ok" ? true : false,
      publicId: json.containsKey("publicId") ? json['publicId'] : null,
      error: json.containsKey("error") ? json['error'] : null,
      transaction: json.containsKey("transaction") ? json['transaction'] : null,
      base64: json.containsKey("base64") ? json['base64'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status ? "true" : false;
    data['publicId'] = publicId;
    data['error'] = error;
    data['transaction'] = transaction;
    data['base64'] = base64;
    return data;
  }
}
