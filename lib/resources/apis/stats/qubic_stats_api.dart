import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/dtos/market_info_dto.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/services/dio_client.dart';
import 'package:qubic_wallet/stores/network_store.dart';

class QubicStatsApi {
  late Dio _dio;
  final NetworkStore _networkStore;

  QubicStatsApi(this._networkStore) {
    _dio = DioClient.getDio(baseUrl: _networkStore.selectedNetwork.rpcUrl);
  }

  void updateDio() {
    _dio = DioClient.getDio(baseUrl: _networkStore.selectedNetwork.rpcUrl);
  }

  Future<MarketInfoDto> getMarketInfo() async {
    try {
      final response = await _dio.get(
          '${_networkStore.selectedNetwork.rpcUrl}${Config.latestStatsUrl}');
      return MarketInfoDto.fromJson(response.data["data"]);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    }
  }
}
