import 'package:qubic_wallet/smart_contracts/qx_info.dart';

/// A Qubic asset representing asset data in the new format.
class QubicAssetDto {
  final String ownerIdentity;
  final int type;
  final int padding;
  final int managingContractIndex;
  final int issuanceIndex;
  int numberOfUnits;
  final IssuedAsset issuedAsset;
  final AssetInfo info;
  QubicAssetDto({
    required this.ownerIdentity,
    required this.type,
    required this.padding,
    required this.managingContractIndex,
    required this.issuanceIndex,
    required this.numberOfUnits,
    required this.issuedAsset,
    required this.info,
  });
  bool get isSmartContractShare =>
      issuedAsset.issuerIdentity == QxInfo.mainAssetIssuer;

  factory QubicAssetDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final info = json['info'];

    return QubicAssetDto(
      ownerIdentity: data['ownerIdentity'],
      type: data['type'],
      padding: data['padding'],
      managingContractIndex: data['managingContractIndex'],
      issuanceIndex: data['issuanceIndex'],
      numberOfUnits: int.tryParse(data['numberOfUnits']) ?? 0,
      issuedAsset: IssuedAsset.fromJson(data['issuedAsset']),
      info: AssetInfo.fromJson(info),
    );
  }

  Map<String, dynamic> toWalletConnectJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['assetName'] = issuedAsset.name;
    data['issuerIdentity'] = issuedAsset.issuerIdentity;
    data['ownedAmount'] = numberOfUnits;
    return data;
  }

  @override
  bool operator ==(covariant QubicAssetDto other) {
    if (identical(this, other)) return true;

    return other.ownerIdentity == ownerIdentity &&
        other.type == type &&
        other.padding == padding &&
        other.managingContractIndex == managingContractIndex &&
        other.issuanceIndex == issuanceIndex &&
        other.numberOfUnits == numberOfUnits &&
        other.issuedAsset == issuedAsset &&
        other.info == info;
  }

  @override
  int get hashCode {
    return ownerIdentity.hashCode ^
        type.hashCode ^
        padding.hashCode ^
        managingContractIndex.hashCode ^
        issuanceIndex.hashCode ^
        numberOfUnits.hashCode ^
        issuedAsset.hashCode ^
        info.hashCode;
  }
}

class IssuedAsset {
  final String issuerIdentity;
  final int type;
  final String name;
  final int numberOfDecimalPlaces;
  final List<int> unitOfMeasurement;

  IssuedAsset({
    required this.issuerIdentity,
    required this.type,
    required this.name,
    required this.numberOfDecimalPlaces,
    required this.unitOfMeasurement,
  });

  factory IssuedAsset.fromJson(Map<String, dynamic> json) {
    return IssuedAsset(
      issuerIdentity: json['issuerIdentity'],
      type: json['type'],
      name: json['name'],
      numberOfDecimalPlaces: json['numberOfDecimalPlaces'],
      unitOfMeasurement: List<int>.from(json['unitOfMeasurement']),
    );
  }
}

class AssetInfo {
  final int tick;
  final int universeIndex;

  AssetInfo({
    required this.tick,
    required this.universeIndex,
  });

  factory AssetInfo.fromJson(Map<String, dynamic> json) {
    return AssetInfo(
      tick: json['tick'],
      universeIndex: json['universeIndex'],
    );
  }
}
