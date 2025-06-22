import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/services/dio_client.dart';

class QubicHelpersApi {
  Dio _dio;

  QubicHelpersApi()
      : _dio = DioClient.getDio(
            baseUrl: "https://raw.githubusercontent.com/qubic/dapps-explorer");

  Future<DappsResponse> getDapps() async {
    try {
      final response = await _dio.get('/main/data/dapps.json');
      final data = jsonDecode(response.data);
      return DappsResponse.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch dapps: $e');
    }
  }

  Future<Map<String, dynamic>> getLocalizedJson(String locale) async {
    try {
      final response = await _dio.get('/refs/heads/main/locales/$locale.json');
      return jsonDecode(response.data);
    } catch (e) {
      throw Exception('Failed to fetch localized dapp: $e');
    }
  }
}
