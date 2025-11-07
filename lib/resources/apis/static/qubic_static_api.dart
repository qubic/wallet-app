import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/models/labeled_address_model.dart';
import 'package:qubic_wallet/models/smart_contracts_response.dart';
import 'package:qubic_wallet/services/dio_client.dart';

class QubicStaticApi {
  final Dio _dio;
  final Dio _generalDio;

  QubicStaticApi()
      : _dio = DioClient.getDio(baseUrl: "${Config.qubicStaticApiBaseUrl}/wallet-app"),
        _generalDio = DioClient.getDio(baseUrl: "${Config.qubicStaticApiBaseUrl}/general");

  Future<DappsResponse> getDapps() async {
    try {
      final response = await _dio.get('/dapps/dapps.json');
      return DappsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch dapps');
    }
  }

  Future<Map<String, dynamic>> getLocalizedDappData(String locale) async {
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

  Future<LabeledAddressesResponse> getLabeledAddresses() async {
    try {
      final response = await _generalDio.get('/data/address_labels.json');
      return LabeledAddressesResponse.fromJson(response.data);
    } catch (error) {
      throw Exception('Failed to fetch labeled addresses data');
    }
  }
}
