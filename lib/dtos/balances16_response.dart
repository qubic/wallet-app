/// Decoded result of the QUTIL `GetBalances16` procedure.
///
/// Produced by the contract bridge (`decodeContractOutput`) from the base64
/// `responseData` returned by `querySmartContract`. Contains up to 16 balances,
/// positionally matching the public keys sent in the request.
class Balances16Response {
  final List<BigInt> balances;

  const Balances16Response({required this.balances});

  factory Balances16Response.fromJson(Map<String, dynamic> json) =>
      Balances16Response(
        balances: (json['balances'] as List<dynamic>)
            .map((e) => BigInt.parse(e.toString()))
            .toList(),
      );
}
