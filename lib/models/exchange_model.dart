class ExchangesResponse {
  final List<ExchangeModel> exchanges;

  ExchangesResponse({required this.exchanges});

  factory ExchangesResponse.fromJson(Map<String, dynamic> json) {
    return ExchangesResponse(
      exchanges: (json['exchanges'] as List)
          .map((e) => ExchangeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExchangeModel {
  final String name;
  final String address;

  ExchangeModel({
    required this.name,
    required this.address,
  });

  factory ExchangeModel.fromJson(Map<String, dynamic> json) {
    return ExchangeModel(
      name: json['name'] as String,
      address: json['address'] as String,
    );
  }
}
