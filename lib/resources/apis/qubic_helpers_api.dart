import 'package:dio/dio.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/services/dio_client.dart';

class QubicHelpersApi {
  final Dio _dio;

  QubicHelpersApi()
      : _dio =
            DioClient.getDio(baseUrl: "https://static.qubic.org/v1/wallet-app");

  Future<DappsResponse> getDapps() async {
    try {
      final response = await _dio.get('/dapps/dapps.json');
      return DappsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch dapps: $e');
    }
  }

  Future<Map<String, dynamic>> getLocalizedJson(String locale) async {
    try {
      final response = await _dio.get('/dapps/locales/$locale.json');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch localized dapp: $e');
    }
  }
}
