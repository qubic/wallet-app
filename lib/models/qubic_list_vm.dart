import 'dart:core';

import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';

import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';

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

class QubicListVmAdapter extends TypeAdapter<QubicListVm> {
  @override
  final typeId = 4;

  @override
  QubicListVm read(BinaryReader reader) {
    String publicId = reader.readString();
    String name = reader.readString();
    int? amount = reader.read() as int?;
    int? amountTick = reader.read() as int?;
    Map<String, QubicAssetDto> assets =
        (reader.read() as Map).cast<String, QubicAssetDto>();
    bool watchOnly = reader.readBool();

    return QubicListVm(publicId, name, amount, amountTick, assets, watchOnly);
  }

  @override
  void write(BinaryWriter writer, QubicListVm obj) {
    writer.writeString(obj.publicId);
    writer.writeString(obj.name);
    writer.write(obj.amount);
    writer.write(obj.amountTick);
    writer.write(obj.assets);
    writer.writeBool(obj.watchOnly);
  }
}
