import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/models/labeled_address_model.dart';
import 'package:qubic_wallet/models/smart_contracts_response.dart';
import 'package:qubic_wallet/services/dio_client.dart';

class QubicStaticApi {
  final Dio _dio;

  QubicStaticApi()
      : _dio = DioClient.getDio(baseUrl: Config.qubicStaticApiBaseUrl);

  /// Returns the URL for terms of service HTML for the given locale
  /// Falls back to English if the locale is not supported
  String getTermsUrl(String locale) {
    final supportedLocale = Config.getSupportedLocale(locale);
    return '${Config.qubicStaticApiBaseUrl}/wallet-app/terms/$supportedLocale.html';
  }

  Future<DappsResponse> getDapps() async {
    try {
      final response = await _dio.get(Config.dapps);
      return DappsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch dapps');
    }
  }

  Future<Map<String, dynamic>> getLocalizedDappData(String locale) async {
    try {
      final response = await _dio.get(Config.dappLocale(locale));
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch localized dapp');
    }
  }

  Future<SmartContractsResponse> getSmartContracts() async {
    try {
      final response = await _dio.get(Config.smartContracts);
      return SmartContractsResponse.fromJson(response.data);
    } catch (error) {
      throw Exception('Failed to fetch smart contracts data');
    }
  }

  Future<LabeledAddressesResponse> getLabeledAddresses() async {
    try {
      final response = await _dio.get(Config.labeledAddresses);
      return LabeledAddressesResponse.fromJson(response.data);
    } catch (error) {
      throw Exception('Failed to fetch labeled addresses data');
    }
  }
}
