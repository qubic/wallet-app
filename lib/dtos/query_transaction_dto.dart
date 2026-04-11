class QueryTransactionDto {
  final String hash;
  final String source;
  final String destination;
  final String amount;
  final int tickNumber;
  final String timestamp;
  final int inputType;
  final int inputSize;
  final String inputData;
  final String signature;
  final bool moneyFlew;

  QueryTransactionDto({
    required this.hash,
    required this.source,
    required this.destination,
    required this.amount,
    required this.tickNumber,
    required this.timestamp,
    required this.inputType,
    required this.inputSize,
    required this.inputData,
    required this.signature,
    required this.moneyFlew,
  });

  factory QueryTransactionDto.fromJson(Map<String, dynamic> json) {
    return QueryTransactionDto(
      hash: json['hash'] as String,
      source: json['source'] as String,
      destination: json['destination'] as String,
      amount: json['amount'] as String,
      tickNumber: json['tickNumber'] as int,
      timestamp: json['timestamp'] as String,
      inputType: json['inputType'] as int,
      inputSize: json['inputSize'] as int,
      inputData: json['inputData'] as String,
      signature: json['signature'] as String,
      moneyFlew: json['moneyFlew'] as bool,
    );
  }
}
