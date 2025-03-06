class QubicAssetTransfer {
  final String? assetName;
  final String? assetIssuer;
  final String? numberOfUnits;
  QubicAssetTransfer(
      {required this.assetName,
      required this.assetIssuer,
      required this.numberOfUnits});

  factory QubicAssetTransfer.fromJson(Map<String, dynamic> json) {
    return QubicAssetTransfer(
        assetName: json['assetName'],
        assetIssuer: json['assetIssuer'],
        numberOfUnits: json['numberOfUnits']['value']);
  }

  @override
  String toString() =>
      'QubicAssetTransfer(assetName: $assetName, assetIssuer: $assetIssuer, numberOfUnits: $numberOfUnits)';
}
