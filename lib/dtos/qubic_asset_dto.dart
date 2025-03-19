import 'package:qubic_wallet/smart_contracts/qx_info.dart';

class QubicAssetWC {
  final int contractIndex;
  final String assetName;
  final String issuerIdentity;
  final String? contractName;
  final int? ownedAmount;
  final int? possessedAmount;

  QubicAssetWC(
      {required this.contractIndex,
      required this.assetName,
      required this.issuerIdentity,
      required this.contractName,
      required this.ownedAmount,
      required this.possessedAmount});

  factory QubicAssetWC.fromQubicAssetDto(QubicAssetDto source) {
    return QubicAssetWC(
        contractIndex: source.contractIndex,
        assetName: source.assetName,
        issuerIdentity: source.issuerIdentity,
        contractName: source.contractName,
        ownedAmount: source.ownedAmount,
        possessedAmount: source.possessedAmount);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['assetName'] = assetName;
    data['issuerIdentity'] = issuerIdentity;
    data['ownedAmount'] = ownedAmount;
    return data;
  }
}

/// A Qubic asset.
class QubicAssetDto {
  /// The public ID of where the asset belongs
  final String publicId;

  /// The index of the contract.
  final int contractIndex;

  /// The name of the contract.
  final String assetName;

  //The issuer identity of the asset
  final String issuerIdentity;

  /// The name of the contract.
  String? contractName;

  /// The amount of shares owned by the asset.
  int? ownedAmount;

  // The amount possesed by the owner
  int? possessedAmount;

  // The nodes reporting the asset owning
  List<String> reportingNodes;

  /// The reported tick for the asset
  final int tick;

  /// Creates a new instance of the [QubicAsset] class.
  QubicAssetDto({
    required this.publicId,
    required this.contractIndex,
    required this.contractName,
    required this.ownedAmount,
    required this.assetName,
    required this.issuerIdentity,
    required this.possessedAmount,
    required this.reportingNodes,
    required this.tick,
  });

  ///If true the asset is a smart contract share else it's a QX Token
  static isSmartContractShare(QubicAssetDto asset) {
    return asset.issuerIdentity == QxInfo.mainAssetIssuer;
  }

  clone() {
    return QubicAssetDto(
        publicId: publicId,
        contractIndex: contractIndex,
        contractName: contractName,
        ownedAmount: ownedAmount,
        assetName: assetName,
        issuerIdentity: issuerIdentity,
        possessedAmount: possessedAmount,
        reportingNodes: reportingNodes,
        tick: tick);
  }

  /// Creates a new instance of the [QubicAsset] class from a JSON map.
  factory QubicAssetDto.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('publicId') || json['publicId'] == null) {
      throw FormatException('Missing required field publicId JSON: $json');
    }
    if (!json.containsKey('contractIndex') || json['contractIndex'] == null) {
      throw FormatException('Missing required field contractIndex JSON: $json');
    }
    if ((!json.containsKey('contractName') || json['contractName'] == null) &&
        (!json.containsKey('assetName') || json['assetName'] == null)) {
      throw FormatException(
          'Missing required field contractName / assetName JSON: $json');
    }
    if ((!json.containsKey('possessedAmount') ||
            json['possessedAmount'] == null) &&
        (!json.containsKey('ownedAmount') || json['ownedAmount'] == null)) {
      throw FormatException(
          'Missing required field possessedAmount / ownedAmount JSON: $json');
    }
    if (!json.containsKey('tick') || json['tick'] == null) {
      throw FormatException('Missing required field tick JSON: $json');
    }

    return QubicAssetDto(
      publicId: json['publicId'],
      assetName: json['assetName'],
      issuerIdentity: json['issuerIdentity'],
      possessedAmount: json['possessedAmount'] ??= 0,
      reportingNodes: List<String>.from(json['reportingNodes']),
      contractIndex: json['contractIndex'],
      contractName: json['contractName'],
      ownedAmount: json['ownedAmount'] ??= 0,
      tick: json['tick'],
    );
  }

  /// Converts this [QubicAsset] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['publicId'] = publicId;
    data['contractIndex'] = contractIndex;
    data['contractName'] = contractName;
    data['assetName'] = assetName;
    data['issuerIdentity'] = issuerIdentity;
    data['possessedAmount'] = possessedAmount;
    data['reportingNodes'] = reportingNodes;

    data['ownedAmount'] = ownedAmount;
    data['tick'] = tick;
    return data;
  }

  Map<String, dynamic> toWalletConnectJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['assetName'] = assetName;
    data['issuerIdentity'] = issuerIdentity;
    data['ownedAmount'] = ownedAmount;
    return data;
  }
}
