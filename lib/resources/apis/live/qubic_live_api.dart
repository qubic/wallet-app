import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/balances16_response.dart';
import 'package:qubic_wallet/dtos/current_balance_dto.dart';
import 'package:qubic_wallet/dtos/current_tick_dto.dart';
import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';
import 'package:qubic_wallet/dtos/query_smart_contract_request.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/models/token_response.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/services/dio_client.dart';
import 'package:qubic_wallet/stores/network_store.dart';

/// Registered contract-function name for the QUTIL GetBalances16 procedure.
const String _qUtilGetBalances16 = "qUtilGetBalances16";

/// QUTIL GetBalances16 returns up to 16 balances per query call.
const int _balancesBatchSize = 16;

class QubicLiveApi {
  late Dio _dio;
  final NetworkStore _networkStore;

  QubicLiveApi(this._networkStore) {
    _dio = DioClient.getDio(baseUrl: _networkStore.currentNetwork.rpcUrl);
  }

  void updateDio() {
    _dio = DioClient.getDio(baseUrl: _networkStore.currentNetwork.rpcUrl);
  }

  Future<CurrentTickDto> getCurrentTick() async {
    try {
      final response = await _dio
          .get('${_networkStore.currentNetwork.rpcUrl}${Config.currentTick}');
      return CurrentTickDto.fromJson(response.data["tickInfo"]);
    } catch (error) {
      throw await ErrorHandler.handleError(error);
    }
  }

  Future<String> submitTransaction(String transaction) async {
    try {
      final response = await _dio.post(
        '${_networkStore.currentNetwork.rpcUrl}${Config.submitTransaction}',
        data: {"encodedTransaction": transaction},
      );
      return response.data["transactionId"];
    } catch (error) {
      throw await ErrorHandler.handleError(error);
    }
  }

  /// Read-only smart-contract query. Sends the encoded request produced by the
  /// bridge and returns the base64 `responseData` for the bridge to decode.
  Future<String> querySmartContract(QuerySmartContractRequest request) async {
    try {
      final response = await _dio.post(
        '${_networkStore.currentNetwork.rpcUrl}${Config.querySmartContract}',
        data: request.toJson(),
      );
      return response.data["responseData"] as String;
    } catch (error) {
      throw await ErrorHandler.handleError(error);
    }
  }

  /// Fetches QU balances on-chain via the QUTIL `GetBalances16` procedure.
  /// Encoding/decoding happens in the JS/CLI bridge ([QubicCmd]); only the
  /// `querySmartContract` HTTP call lives here. [currentTick] stamps the
  /// returned balances' `validForTick`.
  Future<List<CurrentBalanceDto>> getQubicBalances(
      List<String> publicIds, int currentTick) async {
    if (publicIds.isEmpty) return [];
    try {
      final cmd = getIt<QubicCmd>();

      final List<List<String>> batches = [];
      for (var i = 0; i < publicIds.length; i += _balancesBatchSize) {
        batches.add(publicIds.sublist(
            i, min(i + _balancesBatchSize, publicIds.length)));
      }

      final batchResults = await Future.wait(batches.map((batch) async {
        final request = await cmd.buildContractInput(
            _qUtilGetBalances16, jsonEncode({"publicKeys": batch}));

        final responseData = await querySmartContract(request);

        final decoded = await cmd.decodeContractOutput(
            _qUtilGetBalances16, responseData, Balances16Response.fromJson);

        return List<CurrentBalanceDto>.generate(batch.length, (j) {
          return CurrentBalanceDto(
            id: batch[j],
            balance: decoded.balances[j].toInt(),
            validForTick: currentTick,
            latestIncomingTransferTick: 0,
            latestOutgoingTransferTick: 0,
            incomingAmount: "",
            outgoingAmount: "",
            numberOfIncomingTransfers: 0,
            numberOfOutgoingTransfers: 0,
          );
        });
      }));

      return batchResults.expand((e) => e).toList();
    } catch (e) {
      throw await ErrorHandler.handleError(e);
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
      throw await ErrorHandler.handleError(e);
    }
  }

  Future<TokensResponse> getTokens() async {
    try {
      final response = await _dio
          .get('${_networkStore.currentNetwork.rpcUrl}${Config.assets}');
      return TokensResponse.fromJson(response.data);
    } catch (error) {
      throw await ErrorHandler.handleError(error);
    }
  }
}
