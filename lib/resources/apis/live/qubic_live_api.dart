import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/current_tick_dto.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/services/dio_client.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/network_store.dart';

class QubicLiveApi {
  late Dio _dio;
  final NetworkStore _networkStore;
  final ApplicationStore _appStore = getIt.get<ApplicationStore>();

  QubicLiveApi(this._networkStore) {
    _dio = DioClient.getDio(baseUrl: _networkStore.selectedNetwork.rpcUrl);
  }

  void updateDio() {
    _dio = DioClient.getDio(baseUrl: _networkStore.selectedNetwork.rpcUrl);
  }

  Future<CurrentTickDto> getCurrentTick() async {
    try {
      _appStore.incrementPendingRequests();
      final response = await _dio
          .get('${_networkStore.selectedNetwork.rpcUrl}${Config.currentTick}');
      return CurrentTickDto.fromJson(response.data["tickInfo"]);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    } finally {
      _appStore.decreasePendingRequests();
    }
  }

  Future<String> submitTransaction(String transaction) async {
    try {
      _appStore.incrementPendingRequests();
      final response = await _dio.post(
        '${_networkStore.selectedNetwork.rpcUrl}${Config.submitTransaction}',
        data: {"encodedTransaction": transaction},
      );
      return response.data["transactionId"];
    } catch (error) {
      throw ErrorHandler.handleError(error);
    } finally {
      _appStore.decreasePendingRequests();
    }
  }
}
