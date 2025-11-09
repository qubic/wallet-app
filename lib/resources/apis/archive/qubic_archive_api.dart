import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/dtos/computors_dto.dart';
import 'package:qubic_wallet/dtos/transactions_dto.dart';
import 'package:qubic_wallet/dtos/network_overview_dto.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/models/pagination_request_model.dart';
import 'package:qubic_wallet/models/token_response.dart';
import 'package:qubic_wallet/services/dio_client.dart';
import 'package:qubic_wallet/stores/network_store.dart';

class QubicArchiveApi {
  Dio _dio;
  final NetworkStore _networkStore;

  QubicArchiveApi(this._networkStore)
      : _dio = DioClient.getDio(baseUrl: _networkStore.rpcUrl);

  String get _baseUrl => _networkStore.rpcUrl;

  void updateDio() {
    _dio = DioClient.getDio(baseUrl: _networkStore.currentNetwork.rpcUrl);
  }

  Future<ComputorsDto> getComputors(int epoch) async {
    try {
      final response = await _dio.get('$_baseUrl${Config.computors(epoch)}');
      return ComputorsDto.fromJson(response.data["computors"]);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    }
  }

  Future<List<TransactionDto>> getAddressTransfers(
      String publicId, PaginationRequestModel pagination) async {
    try {
      final response = await _dio.get(
        '$_baseUrl${Config.addressTransfers(publicId)}',
        queryParameters: {
          ...pagination.toJson(),
          "startTick": 1,
          "endTick": 999999999,
        },
      );

      TransactionsDto transactionResponse =
          TransactionsDto.fromJson(response.data);
      List<TransactionDto> allTransfers = [];
      for (var group in transactionResponse.transactions) {
        allTransfers.addAll(group.transactions);
      }

      return allTransfers;
    } catch (error) {
      throw ErrorHandler.handleError(error);
    }
  }

  Future<NetworkTicksDto> getNetworkTicks(
      int epoch, PaginationRequestModel pagination) async {
    try {
      final response = await _dio.get('$_baseUrl${Config.networkTicks(epoch)}',
          queryParameters: pagination.toJson());
      return NetworkTicksDto.fromJson(response.data);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    }
  }

  Future<TransactionDto?> getTransaction(String txId) async {
    try {
      final response = await _dio.get('$_baseUrl${Config.transaction(txId)}');
      return TransactionDto.fromJson(response.data);
    } on DioException catch (error) {
      if (error.response?.statusCode == Config.notFoundStatusCode) {
        return null;
      }
      throw ErrorHandler.handleError(error);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    }
  }

  Future<int> getLatestTickProcessed() async {
    try {
      final response = await _dio.get(
          '${_networkStore.currentNetwork.rpcUrl}${Config.latestTickProcessed}');
      return response.data["latestTick"];
    } catch (error) {
      throw ErrorHandler.handleError(error);
    }
  }

  Future<TokensResponse> getTokens() async {
    try {
      final response = await _dio.get('$_baseUrl${Config.assets}');
      return TokensResponse.fromJson(response.data);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    }
  }
}
