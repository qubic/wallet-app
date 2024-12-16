/// A class for a signed transaction returning from QubicJS
class SignedTransaction {
  final String transactionKey;
  final String tansactionId;

  SignedTransaction({required this.transactionKey, required this.tansactionId});

  factory SignedTransaction.fromJson(Map<String, dynamic> json) {
    return SignedTransaction(
      transactionKey: json['transaction'],
      tansactionId: json['transactionId'],
    );
  }
}
