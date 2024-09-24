import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/current_tick_dto.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/services/dio_client.dart';
import 'package:qubic_wallet/stores/application_store.dart';

class QubicArchiveApi {
  final Dio _dio = DioClient.getDio(baseUrl: _baseUrl);
  static const String _baseUrl = Config.archiveDomain;

  final ApplicationStore _appStore = getIt<ApplicationStore>();

  Future<CurrentTickDto> getCurrentTick() async {
    try {
      _appStore.incrementPendingRequests();
      final response = await _dio.get('$_baseUrl${Config.latestTickUrl}');
      return CurrentTickDto.fromJson(response.data);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    } finally {
      _appStore.decreasePendingRequests();
    }
  }
}
