import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/current_balance_dto.dart';
import 'package:qubic_wallet/dtos/current_tick_dto.dart';
import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/services/dio_client.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/network_store.dart';

class QubicLiveApi {
  late Dio _dio;
  final NetworkStore _networkStore;
  final ApplicationStore _appStore = getIt.get<ApplicationStore>();

  QubicLiveApi(this._networkStore) {
    _dio = DioClient.getDio(baseUrl: _networkStore.currentNetwork.rpcUrl);
  }

  void updateDio() {
    _dio = DioClient.getDio(baseUrl: _networkStore.currentNetwork.rpcUrl);
  }

  Future<CurrentTickDto> getCurrentTick() async {
    try {
      _appStore.incrementPendingRequests();
      final response = await _dio
          .get('${_networkStore.currentNetwork.rpcUrl}${Config.currentTick}');
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
        '${_networkStore.currentNetwork.rpcUrl}${Config.submitTransaction}',
        data: {"encodedTransaction": transaction},
      );
      return response.data["transactionId"];
    } catch (error) {
      throw ErrorHandler.handleError(error);
    } finally {
      _appStore.decreasePendingRequests();
    }
  }

  Future<List<CurrentBalanceDto>> getQubicBalances(
      List<String> publicIds) async {
    try {
      _appStore.incrementPendingRequests();
      final response = await Future.wait([
        for (var address in publicIds)
          _dio.get(
              '${_networkStore.currentNetwork.rpcUrl}${Config.addressQubicBalance(address)}')
      ]);
      return List<CurrentBalanceDto>.from(
          response.map((e) => CurrentBalanceDto.fromJson(e.data["balance"])));
    } catch (e) {
      throw ErrorHandler.handleError(e);
    } finally {
      _appStore.decreasePendingRequests();
    }
  }

  Future<List<QubicAssetDto>> getCurrentAssets(List<String> publicIds) async {
    try {
      final response = await Future.wait([
        for (var address in publicIds)
          _dio.get(
              '${_networkStore.currentNetwork.rpcUrl}${Config.addressAssetsBalance(address)}')
      ]);
      return response
          .where((e) => e.data["ownedAssets"].isNotEmpty)
          .expand((e) => (e.data["ownedAssets"] as List)
              .map((asset) => QubicAssetDto.fromJson(asset)))
          .toList();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    } finally {
      _appStore.decreasePendingRequests();
    }
  }
}
