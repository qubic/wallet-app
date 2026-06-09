import 'package:qubic_wallet/smart_contracts/qx_info.dart';

/// A Qubic asset (one ownership position) as shown in the wallet.
///
/// Carries only the fields the UI consumes: the owner, the managing contract,
/// the owned unit count, and the issued-asset name/issuer (plus the tick used
/// to pick the latest record when de-duplicating). Built from the aggregation
/// endpoint via [QubicAssetDto.fromAggregation].
class QubicAssetDto {
  final String ownerIdentity;
  final int managingContractIndex;
  int numberOfUnits;
  final IssuedAsset issuedAsset;
  final AssetInfo info;

  QubicAssetDto({
    required this.ownerIdentity,
    required this.managingContractIndex,
    required this.numberOfUnits,
    required this.issuedAsset,
    required this.info,
  });

  bool get isSmartContractShare =>
      issuedAsset.issuerIdentity == QxInfo.mainAssetIssuer;

  factory QubicAssetDto.fromAggregation({
    required String ownerIdentity,
    required String assetIssuer,
    required String assetName,
    required int managingContractIndex,
    required String numberOfShares,
    required int tickNumber,
  }) {
    return QubicAssetDto(
      ownerIdentity: ownerIdentity,
      managingContractIndex: managingContractIndex,
      numberOfUnits: int.tryParse(numberOfShares) ?? 0,
      issuedAsset: IssuedAsset(
        issuerIdentity: assetIssuer,
        name: assetName,
      ),
      info: AssetInfo(tick: tickNumber),
    );
  }

  Map<String, dynamic> toWalletConnectJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['assetName'] = issuedAsset.name;
    data['issuerIdentity'] = issuedAsset.issuerIdentity;
    data['ownedAmount'] = numberOfUnits;
    data['managingContractIndex'] = managingContractIndex;
    return data;
  }

  @override
  bool operator ==(covariant QubicAssetDto other) {
    if (identical(this, other)) return true;

    return other.ownerIdentity == ownerIdentity &&
        other.managingContractIndex == managingContractIndex &&
        other.numberOfUnits == numberOfUnits &&
        other.issuedAsset == issuedAsset &&
        other.info == info;
  }

  @override
  int get hashCode {
    return ownerIdentity.hashCode ^
        managingContractIndex.hashCode ^
        numberOfUnits.hashCode ^
        issuedAsset.hashCode ^
        info.hashCode;
  }
}

class IssuedAsset {
  final String issuerIdentity;
  final String name;

  IssuedAsset({
    required this.issuerIdentity,
    required this.name,
  });
}

class AssetInfo {
  final int tick;

  AssetInfo({required this.tick});
}
