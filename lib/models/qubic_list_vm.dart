import 'dart:core';
import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';
import 'package:qubic_wallet/dtos/grouped_asset_dto.dart';

@observable
class QubicListVm {
  @observable
  late String _publicId; //The public ID
  @observable
  late String _name; //A descriptive  name of the ID
  @observable
  late int? amount; //The amount of the ID

  @observable
  late int? amountTick; //The tick when amount was valid for

  @observable
  Map<String, QubicAssetDto> assets = {};

  @observable
  late bool? hasPendingTransaction;

  @observable
  late bool watchOnly;

  QubicListVm(String publicId, String name, this.amount, this.amountTick,
      Map<String, QubicAssetDto>? assets, this.watchOnly) {
    _publicId = publicId.replaceAll(",", "_");
    _name = name.replaceAll(",", "_");

    this.assets.clear();
    if (assets != null) {
      this.assets.addAll(assets);
    }
  }

  set publicId(String publicId) {
    _publicId = publicId.replaceAll(",", "_");
  }

  String get publicId {
    return _publicId;
  }

  set name(String name) {
    _name = name.replaceAll(",", "_");
  }

  String get name {
    return _name;
  }

  void clearShares() {
    assets = {};
  }

  /// Sets the number of shares (without mutation)
  void setAssets(List<QubicAssetDto> newAssets) {
    Map<String, QubicAssetDto> mergedAssets = {};

    for (int i = 0; i < newAssets.length; i++) {
      String name =
          "${newAssets[i].issuedAsset.name}-${newAssets[i].managingContractIndex}";
      if (mergedAssets.containsKey(name)) {
        if (mergedAssets[name]!.info.tick < newAssets[i].info.tick) {
          mergedAssets[name] = newAssets[i];
        }
      } else {
        mergedAssets[name] = newAssets[i];
      }
    }

    assets = Map<String, QubicAssetDto>.from(mergedAssets);
  }

  Map<String, QubicAssetDto> getAssets() {
    return assets;
  }

  Map<String, QubicAssetDto> getClonedAssets() {
    Map<String, QubicAssetDto> newShares = {};
    assets.forEach((key, value) {
      newShares[key] = value;
    });
    return newShares;
  }

  /// Groups assets by token name and aggregates balances across managing contracts
  List<GroupedAssetDto> getGroupedAssets() {
    Map<String, List<QubicAssetDto>> groupedByToken = {};

    // Group assets by token name only
    assets.forEach((key, asset) {
      String tokenName = asset.issuedAsset.name;
      if (!groupedByToken.containsKey(tokenName)) {
        groupedByToken[tokenName] = [];
      }
      groupedByToken[tokenName]!.add(asset);
    });

    // Create GroupedAssetDto for each token
    List<GroupedAssetDto> result = [];
    groupedByToken.forEach((tokenName, assetList) {
      int totalUnits = 0;
      List<AssetContractContribution> contributions = [];

      for (var asset in assetList) {
        totalUnits += asset.numberOfUnits;
        contributions.add(AssetContractContribution(
          managingContractIndex: asset.managingContractIndex,
          numberOfUnits: asset.numberOfUnits,
          sourceAsset: asset,
        ));
      }

      result.add(GroupedAssetDto(
        tokenName: tokenName,
        issuedAsset: assetList.first.issuedAsset,
        totalUnits: totalUnits,
        contractContributions: contributions,
      ));
    });

    return result;
  }

  factory QubicListVm.clone(QubicListVm original) {
    return QubicListVm(
        original.publicId,
        original.name,
        original.amount,
        original.amountTick,
        Map<String, QubicAssetDto>.from(original.getClonedAssets()),
        original.watchOnly);
  }
}
