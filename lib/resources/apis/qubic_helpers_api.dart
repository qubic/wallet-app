import 'package:dio/dio.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/models/smart_contracts_response.dart';
import 'package:qubic_wallet/services/dio_client.dart';

class QubicHelpersApi {
  final Dio _dio;
  final Dio _generalDio;

  QubicHelpersApi()
      : _dio =
            DioClient.getDio(baseUrl: "https://static.qubic.org/v1/wallet-app"),
        _generalDio =
            DioClient.getDio(baseUrl: "https://static.qubic.org/v1/general");

  Future<DappsResponse> getDapps() async {
    try {
      final response = await _dio.get('/dapps/dapps.json');
      return DappsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch dapps');
    }
  }

  Future<Map<String, dynamic>> getLocalizedJson(String locale) async {
    try {
      final response = await _dio.get('/dapps/locales/$locale.json');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch localized dapp');
    }
  }

  Future<SmartContractsResponse> getSmartContracts() async {
    try {
      final response = await _generalDio.get('/data/smart_contracts.json');
      return SmartContractsResponse.fromJson(response.data);
    } catch (error) {
      throw Exception('Failed to fetch smart contracts data');
    }
  }
}
