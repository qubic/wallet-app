/// A class for a signed transaction returning from QubicJS
class SignedTransaction {
  final String transactionKey;
  final String transactionId;

  SignedTransaction(
      {required this.transactionKey, required this.transactionId});

  factory SignedTransaction.fromJson(Map<String, dynamic> json) {
    return SignedTransaction(
      transactionKey: json['transaction'],
      transactionId: json['transactionId'],
    );
  }
}
