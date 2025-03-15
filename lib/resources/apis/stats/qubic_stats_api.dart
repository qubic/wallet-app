import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/dtos/market_info_dto.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/services/dio_client.dart';

class QubicStatsApi {
  final Dio _dio = DioClient.getDio(baseUrl: _baseUrl);
  static const String _baseUrl = Config.qubicMainnetRpcDomain;

  Future<MarketInfoDto> getMarketInfo() async {
    try {
      final response = await _dio.get('$_baseUrl${Config.latestStatsUrl}');
      return MarketInfoDto.fromJson(response.data["data"]);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    }
  }
}
