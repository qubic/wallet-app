class LabeledAddressesResponse {
  final List<LabeledAddressModel> addressLabels;

  LabeledAddressesResponse({required this.addressLabels});

  factory LabeledAddressesResponse.fromJson(Map<String, dynamic> json) {
    return LabeledAddressesResponse(
      addressLabels: (json['address_labels'] as List)
          .map((e) => LabeledAddressModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LabeledAddressModel {
  final String label;
  final String address;

  LabeledAddressModel({
    required this.label,
    required this.address,
  });

  factory LabeledAddressModel.fromJson(Map<String, dynamic> json) {
    return LabeledAddressModel(
      label: json['label'] as String,
      address: json['address'] as String,
    );
  }
}
