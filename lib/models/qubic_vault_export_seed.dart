// Model class to be used to export a seed from the wallet to a Qubic Vault file
class QubicVaultExportSeed {
  final String alias; //The seed alias
  final String seed; //The unencrypted seed
  final String publicId; //The public id of the seed

  QubicVaultExportSeed(
      {required this.alias, required this.seed, required this.publicId});

  /// Converts this instance of [QubicVaultExportSeed] to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['alias'] = alias;
    data['seed'] = seed;
    data['publicId'] = publicId;
    return data;
  }

  Map<String, dynamic> toJsonEsc() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['alias'] = alias.replaceAll("\"", "'");
    data['seed'] = seed.replaceAll("\"", "'");
    data['publicId'] = publicId.replaceAll("\"", "'");
    return data;
  }

  /// Creates a new instance of [CurrentBalanceDto] from a JSON map.
  factory QubicVaultExportSeed.fromJson(Map<String, dynamic> json) {
    return QubicVaultExportSeed(
      alias: json['alias'],
      publicId: json['publicId'],
      seed: json['seed'],
    );
  }
}