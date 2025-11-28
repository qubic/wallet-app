import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';

/// Represents a grouped asset (token) with all its managing contract contributions
class GroupedAssetDto {
  final String tokenName;
  final IssuedAsset issuedAsset;
  final int totalUnits;
  final List<AssetContractContribution> contractContributions;

  GroupedAssetDto({
    required this.tokenName,
    required this.issuedAsset,
    required this.totalUnits,
    required this.contractContributions,
  });

  /// Check if this is a smart contract share
  bool get isSmartContractShare =>
      contractContributions.isNotEmpty &&
      contractContributions.first.sourceAsset.isSmartContractShare;
}

/// Represents a single managing contract contribution to a token
class AssetContractContribution {
  final int managingContractIndex;
  final int numberOfUnits;
  final QubicAssetDto sourceAsset;

  AssetContractContribution({
    required this.managingContractIndex,
    required this.numberOfUnits,
    required this.sourceAsset,
  });
}
