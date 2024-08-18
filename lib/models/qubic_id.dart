import 'dart:core';

class QubicId {
  late String? _privateSeed; //The private seed of the ID
  late String _publicId; //The public ID
  late String _name; //A descriptive name of the ID
  late double? _amount; //The amount of the ID
  late bool _watchOnly; // This ID is watch only, means _privateSeed = -1

  factory QubicId.fromJson(Map<String, dynamic> json) {
    var privateSeed = json['privateSeed'];
    var publicId = json['publicId'];
    var name = json['name'];
    var amount = json['amount'];
    return QubicId(privateSeed, publicId, name, amount);
  }

  QubicId(String? privateSeed, String publicId, String name, double? amount) {
    _privateSeed = privateSeed?.replaceAll(",", "_");
    _publicId = publicId.replaceAll(",", "_");
    _name = name.replaceAll(",", "_");
    _amount = amount;
    _watchOnly = _privateSeed == '-1' ? true : false;
  }

  double? getAmount() {
    return _amount;
  }

  void setPrivateSeed(String? privateSeed) {
    _privateSeed = privateSeed?.replaceAll(",", "_");
    _watchOnly = _privateSeed == '-1' ? true : false;
  }

  void setPublicId(String publicId) {
    _publicId = publicId.replaceAll(",", "_");
  }

  void setName(String name) {
    _name = name.replaceAll(",", "_");
  }

  getPrivateSeed() {
    return _privateSeed;
  }

  getPublicId() {
    return _publicId;
  }

  getName() {
    return _name;
  }

  isWatchOnly() => _watchOnly;
}
