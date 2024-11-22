import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/dtos/computors_dto.dart';
import 'package:qubic_wallet/dtos/explorer_tick_info_dto.dart';
import 'package:qubic_wallet/dtos/explorer_transaction_info_dto.dart';
import 'package:qubic_wallet/dtos/network_overview_dto.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/models/pagination_request_model.dart';
import 'package:qubic_wallet/services/dio_client.dart';

class QubicArchiveApi {
  final Dio _dio = DioClient.getDio(baseUrl: _baseUrl);
  static const String _baseUrl = Config.archiveDomain;

  // final ExplorerStore _explorerStore = getIt<ExplorerStore>();

  Future<ExplorerTickDto?> getExplorerTick(int tick) async {
    try {
      // _explorerStore.incrementPendingRequests();
      final response = await _dio.get('$_baseUrl${Config.tickData(tick)}');
      return response.data["tickData"] == null
          ? ExplorerTickDto(tickNumber: tick)
          : ExplorerTickDto.fromJson(response.data["tickData"]);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    } finally {
//_explorerStore.decreasePendingRequests();
    }
  }

  Future<List<ExplorerTransactionDto>> getExplorerTickTransactions(
      int tick) async {
    try {
      //  _explorerStore.incrementPendingRequests();
      final response =
          await _dio.get('$_baseUrl${Config.tickTransactions(tick)}');
      return List<ExplorerTransactionDto>.from(response.data["transactions"]
          .map((e) => ExplorerTransactionDto.fromJson(e)));
    } catch (error) {
      throw ErrorHandler.handleError(error);
    } finally {
      // _explorerStore.decreasePendingRequests();
    }
  }

  Future<ComputorsDto> getComputors(int epoch) async {
    try {
      //  _explorerStore.incrementPendingRequests();
      final response = await _dio.get('$_baseUrl${Config.computors(epoch)}');
      return ComputorsDto.fromJson(response.data["computors"]);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    } finally {
      // _explorerStore.decreasePendingRequests();
    }
  }

  Future<ExplorerTransactionDto> getTransaction(String transaction) async {
    try {
      //_explorerStore.incrementPendingRequests();
      final response =
          await _dio.get('$_baseUrl${Config.transaction(transaction)}');
      return ExplorerTransactionDto.fromJson(response.data);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    } finally {
      //   _explorerStore.decreasePendingRequests();
    }
  }

  Future<NetworkTicksDto> getNetworkTicks(
      int epoch, PaginationRequestModel pagination) async {
    try {
      //  _explorerStore.incrementPendingRequests();
      final response = await _dio.get('$_baseUrl${Config.networkTicks(epoch)}',
          queryParameters: pagination.toJson());
      return NetworkTicksDto.fromJson(response.data);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    } finally {
      //    _explorerStore.decreasePendingRequests();
    }
  }
}
