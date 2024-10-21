import 'package:dio/dio.dart';

class DioClient {
  static Dio getDio({required String baseUrl}) {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.options.headers = {'Content-Type': 'application/json'};
    // Interceptors for logging requests
    dio.interceptors.add(LogInterceptor(
      responseHeader: false,
      responseBody: true,
      requestBody: true,
    ));
    return dio;
  }
}
