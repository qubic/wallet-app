import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';

/// Typed models for the `/aggregation/v1/getIdentitiesAssets` response.
///
/// Mirrors the web wallet's `api.aggregation.model.ts`
/// (`IdentityAssetRecord` / `IdentityAssetEntry` / `IdentitiesAssetsResponse`).
/// The mapping to the app's [QubicAssetDto] lives in
/// [IdentitiesAssetsResponse.toOwnedAssets] so it can be unit-tested without
/// the network layer.
class IdentityAssetRecord {
  final String assetIssuer;
  final String assetName;
  final int managingContractIndex;
  final String numberOfShares;
  final int tickNumber;

  const IdentityAssetRecord({
    required this.assetIssuer,
    required this.assetName,
    required this.managingContractIndex,
    required this.numberOfShares,
    required this.tickNumber,
  });

  factory IdentityAssetRecord.fromJson(Map<String, dynamic> json) =>
      IdentityAssetRecord(
        assetIssuer: json['assetIssuer'] as String? ?? '',
        assetName: json['assetName'] as String? ?? '',
        managingContractIndex: json['managingContractIndex'] as int? ?? 0,
        numberOfShares: json['numberOfShares']?.toString() ?? '0',
        tickNumber: json['tickNumber'] as int? ?? 0,
      );
}

class IdentityAssetEntry {
  final String identity;
  final List<IdentityAssetRecord> ownerships;
  final List<IdentityAssetRecord> possessions;

  const IdentityAssetEntry({
    required this.identity,
    required this.ownerships,
    required this.possessions,
  });

  factory IdentityAssetEntry.fromJson(Map<String, dynamic> json) =>
      IdentityAssetEntry(
        identity: json['identity'] as String? ?? '',
        ownerships: _records(json['ownerships']),
        possessions: _records(json['possessions']),
      );

  static List<IdentityAssetRecord> _records(dynamic list) =>
      (list as List?)
          ?.map((e) => IdentityAssetRecord.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [];
}

class IdentitiesAssetsResponse {
  final List<IdentityAssetEntry> identityAssets;

  const IdentitiesAssetsResponse({required this.identityAssets});

  factory IdentitiesAssetsResponse.fromJson(Map<String, dynamic> json) =>
      IdentitiesAssetsResponse(
        identityAssets: (json['identityAssets'] as List?)
                ?.map((e) =>
                    IdentityAssetEntry.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  /// Flattens every identity's **ownership** records into [QubicAssetDto]s,
  /// keeping only records with a positive share count. Possessions are ignored
  /// (owned-only, matching the prior `/owned` behavior and Angular's primary
  /// `ownedAmount`).
  List<QubicAssetDto> toOwnedAssets() {
    final List<QubicAssetDto> assets = [];
    for (final entry in identityAssets) {
      for (final record in entry.ownerships) {
        final asset = QubicAssetDto.fromAggregation(
          ownerIdentity: entry.identity,
          assetIssuer: record.assetIssuer,
          assetName: record.assetName,
          managingContractIndex: record.managingContractIndex,
          numberOfShares: record.numberOfShares,
          tickNumber: record.tickNumber,
        );
        if (asset.numberOfUnits > 0) {
          assets.add(asset);
        }
      }
    }
    return assets;
  }
}
