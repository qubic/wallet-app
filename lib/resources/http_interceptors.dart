import 'dart:async';
import 'package:http_interceptor/models/interceptor_contract.dart';
import 'package:http/http.dart' as http;
import 'package:qubic_wallet/helpers/app_logger.dart';

class LoggingInterceptor implements InterceptorContract {
  @override
  FutureOr<bool> shouldInterceptRequest() {
    return true;
  }

  @override
  FutureOr<bool> shouldInterceptResponse() {
    return true;
  }

  @override
  FutureOr<http.BaseRequest> interceptRequest(
      {required http.BaseRequest request}) {
    appLogger.d("Method: ${request.method} -- ${request.url}");
    // appLogger.d('Headers: ${request.headers}');
    if (request is http.Request) {
      appLogger.d("Body: ${request.body}");
    } else if (request is http.MultipartRequest) {
      appLogger.d("Multipart request with fields: ${request.fields}");
    }
    return request;
  }

  @override
  FutureOr<http.BaseResponse> interceptResponse(
      {required http.BaseResponse response}) {
    appLogger.d('Response of: ${response.request?.url}');
    // appLogger.d('Status: ${response.statusCode}');
    // appLogger.d('Headers: ${response.headers}');
    if (response is http.Response) {
      appLogger.d("Body: ${response.body}");
    }
    return response;
  }
}
