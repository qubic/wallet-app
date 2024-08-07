import 'dart:core';

class QubicImportVaultSeed {
  late String? _alias; //The private seed of the ID
  late String _publicId; //The public ID
  late String? _seed; //A descriptive name of the ID

  factory QubicImportVaultSeed.fromJson(Map<String, dynamic> json) {
    var alias = json['alias'];
    var publicId = json['publicId'];
    var seed = json['seed'];
    return QubicImportVaultSeed(alias, publicId, seed);
  }

  void validateSeed(String seed) {
    if (!RegExp(r'^[a-z]+$').hasMatch(seed)) {
      throw Exception("Invalid seed. Seed must be lowercase.");
    }
    if (seed.length != 55) {
      throw Exception("Invalid seed. Seed must be 55 characters long.");
    }
  }

  void validatePublicID(String publicId) {
    if (!RegExp(r'^[A-Z]+$').hasMatch(publicId)) {
      throw Exception("Invalid public ID. Public ID must be uppercase.");
    }

    if (publicId.length != 60) {
      throw Exception(
          "Invalid public ID. Public ID must be 60 characters long.");
    }
  }

  void validateAlias(String? alias) {
    if ((alias == null) || (alias!.isEmpty)) {
      throw Exception("Invalid alias. Alias must not be empty.");
    }
  }

  QubicImportVaultSeed(String alias, String publicId, String seed) {
    validateAlias(alias);
    validatePublicID(publicId);
    if (seed.isNotEmpty) {
      validateSeed(seed);
    }
    _alias = alias.replaceAll(",", "_");
    _publicId = publicId.replaceAll(",", "_");
    _seed = seed.replaceAll(",", "_");
  }

  void setPrivateSeed(String privateSeed) {
    validateSeed(privateSeed);
    _seed = privateSeed.replaceAll(",", "_");
  }

  void setPublicId(String publicId) {
    validatePublicID(publicId);
    _publicId = publicId.replaceAll(",", "_");
  }

  void setAlias(String alias) {
    validateAlias(alias);
    _alias = alias.replaceAll(",", "_");
  }

  String? getSeed() {
    return _seed;
  }

  String getPublicId() {
    return _publicId;
  }

  String? getAlias() {
    return _alias;
  }
}
