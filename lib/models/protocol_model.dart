class ProtocolResponse {
  final List<TransactionInputType> transactionInputTypes;

  ProtocolResponse({required this.transactionInputTypes});

  factory ProtocolResponse.fromJson(Map<String, dynamic> json) {
    return ProtocolResponse(
      transactionInputTypes: (json['transaction_input_types'] as List? ?? [])
          .map((e) => TransactionInputType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TransactionInputType {
  final int id;
  final String label;

  TransactionInputType({required this.id, required this.label});

  factory TransactionInputType.fromJson(Map<String, dynamic> json) {
    return TransactionInputType(
      id: json['id'] as int,
      label: json['label'] as String,
    );
  }
}
