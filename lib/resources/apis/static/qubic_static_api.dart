import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/models/app_version_check_model.dart'
    show AppVersionCheckModel;
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

  Future<AppVersionCheckModel?> getAppVersionCheck() async {
    try {
      // TODO: Replace with real API call before production
      if (Config.useDevEnvironment) {
        return AppVersionCheckModel.fromJson({
          'version': '2.5.0',
          'release_notes':
              '- Critical security fixes\n- Improved transaction reliability\n- Enhanced wallet performance',
          'show_later_button': false,
          'show_ignore_button': false,
          'platforms': ['android', 'ios'],
        });
      }

      final response = await _dio.get(Config.appVersionCheck);
      return AppVersionCheckModel.fromJson(response.data);
    } catch (e) {
      appLogger.e('[QubicStaticApi] Failed to fetch app version check: $e');
      throw Exception('Failed to fetch app version check');
    }
  }
}
