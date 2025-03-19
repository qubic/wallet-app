import 'dart:math';

import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/current_balance_dto.dart';
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

  Future<List<CurrentBalanceDto>> getQubicBalances(
      List<String> publicIds) async {
    late var balances = <CurrentBalanceDto>[];

    for (var address in publicIds) {
      try {
        _appStore.incrementPendingRequests();
        final response = await _dio.get(
            '${_networkStore.selectedNetwork.rpcUrl}${Config.addressQubicBalance(address)}');
        balances.add(CurrentBalanceDto(
            publicId: response.data["balance"]["id"],
            amount: int.parse(response.data["balance"]["balance"]),
            tick: response.data["balance"]["validForTick"]));
      } catch (error) {
        throw ErrorHandler.handleError(error);
      } finally {
        _appStore.decreasePendingRequests();
      }
    }

    return balances;
  }

  Future<List<QubicAssetDto>> getCurrentAssets(List<String> publicIds) async {
    late List<QubicAssetDto> assets = <QubicAssetDto>[];

    for (var address in publicIds) {
      try {
        _appStore.incrementPendingRequests();
        //final response =
        await _dio.get(
            '${_networkStore.selectedNetwork.rpcUrl}${Config.addressAssetsBalance(address)}');

        // to iterate in the response.data["ownedAssets"]["data"] that is the array of assets
        /*
        assets.add(QubicAssetDto(
            assetName: response.data["ownedAssets"]["data"]["issuedAsset"]
                ["name"],
            issuerIdentity: response.data["ownedAssets"]["data"]["issuedAsset"]
                ["issuerIdentity"],
            publicId: response.data["ownedAssets"]["data"]["ownerIdentity"],
            contractIndex: response.data["ownedAssets"]["data"]
                ["managingContractIndex"],
            ownedAmount: int.parse(
                response.data["ownedAssets"]["data"]["numberOfUnits"]),
            contractName: null,
            tick: response.data["ownedAssets"]["info"]["tick"],
            reportingNodes: [],
            possessedAmount: null));*/
      } catch (error) {
        throw ErrorHandler.handleError(error);
      } finally {
        _appStore.decreasePendingRequests();
      }
    }
    return assets;
  }
}
