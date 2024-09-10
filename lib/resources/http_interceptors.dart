import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http_interceptor/models/interceptor_contract.dart';
import 'package:http/http.dart' as http;

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
    if (kDebugMode) {
      print('Request:');
      log(request.method, name: "Method");
      log('${request.url}', name: "URL");
      // log('${request.headers}', name: "Headers");
      if (request is http.Request) {
        log(request.body, name: "Body");
      } else if (request is http.MultipartRequest) {
        log('${request.fields}', name: "Multipart request with fields");
      }
    }
    return request;
  }

  @override
  FutureOr<http.BaseResponse> interceptResponse(
      {required http.BaseResponse response}) {
    if (kDebugMode) {
      log('Response:');
      log('${response.statusCode}', name: "Status");
      // log('${response.headers}', name: "Headers");
      if (response is http.Response) {
        log(response.body, name: "Body");
      }
    }
    return response;
  }
}
