/// Request payload for the RPC `querySmartContract` endpoint.
///
/// Sent as the POST body of [QubicLiveApi.querySmartContract]. Mirrors the RPC
/// schema `{ contractIndex, inputType, inputSize, requestData(base64) }`.
class QuerySmartContractRequest {
  final int contractIndex;
  final int inputType;
  final int inputSize;
  final String requestData;

  const QuerySmartContractRequest({
    required this.contractIndex,
    required this.inputType,
    required this.inputSize,
    required this.requestData,
  });

  factory QuerySmartContractRequest.fromJson(Map<String, dynamic> json) =>
      QuerySmartContractRequest(
        contractIndex: json['contractIndex'] as int,
        inputType: json['inputType'] as int,
        inputSize: json['inputSize'] as int,
        requestData: json['requestData'] as String,
      );

  Map<String, dynamic> toJson() => {
        'contractIndex': contractIndex,
        'inputType': inputType,
        'inputSize': inputSize,
        'requestData': requestData,
      };
}
