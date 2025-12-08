class TokensResponse {
  final List<TokenModel> assets;

  TokensResponse({required this.assets});

  factory TokensResponse.fromJson(Map<String, dynamic> json) {
    return TokensResponse(
      assets: (json['assets'] as List)
          .map((e) => TokenModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TokenModel {
  final String issuerIdentity;
  final String name;
  final int universeIndex;
  final int numberOfDecimalPlaces;
  final int type;
  final List<int> unitOfMeasurement;
  final int tick;

  TokenModel({
    required this.issuerIdentity,
    required this.name,
    required this.universeIndex,
    required this.numberOfDecimalPlaces,
    required this.type,
    required this.unitOfMeasurement,
    required this.tick,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return TokenModel(
      issuerIdentity: data['issuerIdentity'] as String,
      type: data['type'] as int,
      name: data['name'] as String,
      numberOfDecimalPlaces: data['numberOfDecimalPlaces'] as int,
      unitOfMeasurement:
          (data['unitOfMeasurement'] as List).map((e) => e as int).toList(),
      tick: json['tick'] as int,
      universeIndex: json['universeIndex'] as int,
    );
  }
}
