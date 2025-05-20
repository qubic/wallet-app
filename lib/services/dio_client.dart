import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';

class DioClient {
  static Dio getDio({required String baseUrl}) {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.options.headers = {'Content-Type': 'application/json'};
    // Interceptors for logging requests
    dio.interceptors.add(CustomLogInterceptor());

    if (Config.useProxy) {
      // Use IOHttpClientAdapter instead of DefaultHttpClientAdapter
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        HttpClient client = HttpClient();

        // Set proxy
        client.findProxy = (uri) {
          return "PROXY ${Config.proxyIP}:${Config.proxyPort}"; // Replace with your proxy IP and port
        };

        // Allow self-signed certificates (if needed)
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    return dio;
  }
}

class CustomLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    appLogger.d("Method: ${options.method} -- ${options.uri}");
    // Log the request body if it's a regular request
    if (options.data != null && options.data is Map) {
      appLogger.d("Body: ${options.data}");
    } else if (options.data != null) {
      appLogger.d("Body: ${options.data.toString()}");
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    appLogger.d("Response of: ${response.requestOptions.uri}");
    if (response.data != null) {
      appLogger.d("Body: ${response.data}");
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    appLogger.e("Error in request to: ${err.requestOptions.uri}");
    if (err.response?.data != null) {
      appLogger.e("Error Body: ${err.response?.data}");
    }
    super.onError(err, handler);
  }
}
