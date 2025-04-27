class QubicSendManyTransfer {
  final String amount;
  final String destId;

  QubicSendManyTransfer({required this.amount, required this.destId});

  factory QubicSendManyTransfer.fromJson(Map<String, dynamic> json) {
    return QubicSendManyTransfer(
      amount: json['amount'].toString(),
      destId: json['destId'] ?? '',
    );
  }

  @override
  String toString() =>
      'QubicSendManyTransfer(amount: $amount, destId: $destId)';
}
