class RequestResult {
  final String? errorMessage;
  final int? errorCode;

  RequestResult({this.errorMessage, this.errorCode});

  Map<String, dynamic> toErrorJson() {
    return {
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (errorCode != null) 'errorCode': errorCode,
    };
  }

  bool get hasError => errorMessage != null || errorCode != null;
}
