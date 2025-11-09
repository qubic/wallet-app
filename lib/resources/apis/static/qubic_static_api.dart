import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/dtos/wallet_metadata_dto.dart';
import 'package:qubic_wallet/models/labeled_address_model.dart';
import 'package:qubic_wallet/models/smart_contracts_response.dart';
import 'package:qubic_wallet/services/dio_client.dart';

class QubicStaticApi {
  final Dio _dio;

  QubicStaticApi()
      : _dio = DioClient.getDio(baseUrl: Config.qubicStaticApiBaseUrl);

  Future<WalletMetadataDto> getMetadata() async {
    try {
      final response = await _dio.get(Config.walletMetadata);
      return WalletMetadataDto.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch wallet metadata');
    }
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
