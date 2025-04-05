class QubicAssetTransfer {
  final String assetName;
  final String newOwnerAndPossessor;
  final String numberOfUnits;
  QubicAssetTransfer(
      {required this.assetName,
      required this.newOwnerAndPossessor,
      required this.numberOfUnits});

  factory QubicAssetTransfer.fromJson(Map<String, dynamic> json) {
    return QubicAssetTransfer(
        assetName: json['assetName'],
        newOwnerAndPossessor: json['assetIssuer'],
        numberOfUnits: json['numberOfUnits']['value']);
  }

  @override
  String toString() =>
      'QubicAssetTransfer(assetName: $assetName, newOwnerAndPossessor: $newOwnerAndPossessor, numberOfUnits: $numberOfUnits)';
}
