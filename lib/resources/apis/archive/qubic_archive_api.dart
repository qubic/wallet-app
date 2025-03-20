import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/dtos/computors_dto.dart';
import 'package:qubic_wallet/dtos/explorer_transaction_info_dto.dart';
import 'package:qubic_wallet/dtos/network_overview_dto.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/models/pagination_request_model.dart';
import 'package:qubic_wallet/services/dio_client.dart';
import 'package:qubic_wallet/stores/network_store.dart';

class QubicArchiveApi {
  Dio _dio;
  final NetworkStore _networkStore;

  QubicArchiveApi(this._networkStore)
      : _dio = DioClient.getDio(baseUrl: _networkStore.rpcUrl);

  String get _baseUrl => _networkStore.rpcUrl;

  void updateDio() {
    _dio = DioClient.getDio(baseUrl: _networkStore.selectedNetwork.rpcUrl);
  }

  Future<List<ExplorerTransactionDto>> getExplorerTickTransactions(
      int tick) async {
    try {
      final response =
          await _dio.get('$_baseUrl${Config.tickTransactions(tick)}');
      return List<ExplorerTransactionDto>.from(response.data["transactions"]
          .map((e) => ExplorerTransactionDto.fromJson(e)));
    } catch (error) {
      throw ErrorHandler.handleError(error);
    }
  }

  Future<ComputorsDto> getComputors(int epoch) async {
    try {
      final response = await _dio.get('$_baseUrl${Config.computors(epoch)}');
      return ComputorsDto.fromJson(response.data["computors"]);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    }
  }

  Future<ExplorerTransactionDto> getTransaction(String transaction) async {
    try {
      final response =
          await _dio.get('$_baseUrl${Config.transaction(transaction)}');
      return ExplorerTransactionDto.fromJson(response.data);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    }
  }

  Future<List<TransferDto>> getAddressTransfers(
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

      TransactionResponse transactionResponse =
          TransactionResponse.fromJson(response.data);
      List<TransferDto> allTransfers = [];
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
}
