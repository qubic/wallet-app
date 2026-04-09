import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/dtos/query_transaction_dto.dart';
import 'package:qubic_wallet/dtos/transactions_dto.dart';
import 'package:qubic_wallet/helpers/encoding_helpers.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/services/dio_client.dart';
import 'package:qubic_wallet/stores/network_store.dart';

class QubicQueryApi {
  Dio _dio;
  final NetworkStore _networkStore;

  QubicQueryApi(this._networkStore)
      : _dio = DioClient.getDio(baseUrl: _networkStore.rpcUrl);

  void updateDio() {
    _dio = DioClient.getDio(baseUrl: _networkStore.rpcUrl);
  }

  String get _baseUrl => _networkStore.rpcUrl;

  /// Maps a flat [QueryTransactionDto] from the query API to the
  /// [TransactionDto] shape that callers already expect.
  TransactionDto _toTransactionDto(QueryTransactionDto q) {
    return TransactionDto(
      transaction: Transaction(
        sourceId: q.source,
        destId: q.destination,
        amount: q.amount,
        tickNumber: q.tickNumber,
        inputType: q.inputType,
        inputSize: q.inputSize,
        inputHex: base64ToHex(q.inputData),
        signatureHex: base64ToHex(q.signature),
        txId: q.hash,
      ),
      timestamp: q.timestamp,
      moneyFlew: q.moneyFlew,
    );
  }

  /// Returns the tickNumber of the last tick processed by the query backend.
  /// Used to determine when to validate pending transactions.
  Future<int> getLastProcessedTick() async {
    try {
      final response = await _dio.get(
          '$_baseUrl${Config.lastProcessedTick}');
      return response.data['tickNumber'] as int;
    } catch (error) {
      throw await ErrorHandler.handleError(error);
    }
  }

  /// POST /query/v1/getTransactionsForIdentity
  /// Returns a page of [TransactionDto] for [publicId].
  ///
  /// [offset] is 0-based. [pageSize] items are returned per page.
  /// Returns an empty list when no transactions exist or on 404.
  Future<List<TransactionDto>> getAddressTransfers(
      String publicId, int offset, int pageSize) async {
    try {
      final response = await _dio.post(
        '$_baseUrl${Config.transactionsForIdentity}',
        data: {
          'identity': publicId,
          'pagination': {
            'offset': offset,
            'size': pageSize,
          },
        },
      );

      final transactions =
          response.data['transactions'] as List<dynamic>? ?? [];
      return transactions
          .map((e) => _toTransactionDto(
              QueryTransactionDto.fromJson(e as Map<String, dynamic>)))
          .toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == Config.notFoundStatusCode) {
        return [];
      }
      throw await ErrorHandler.handleError(error);
    } catch (error) {
      throw await ErrorHandler.handleError(error);
    }
  }

  /// POST /query/v1/getTransactionByHash
  /// Returns the [TransactionDto] for [txId], or null if not found (404).
  /// Used to validate whether a pending transaction was processed.
  Future<TransactionDto?> getTransactionByHash(String txId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl${Config.transactionByHash}',
        data: {'hash': txId},
      );
      final q =
          QueryTransactionDto.fromJson(response.data as Map<String, dynamic>);
      return _toTransactionDto(q);
    } on DioException catch (error) {
      if (error.response?.statusCode == Config.notFoundStatusCode) {
        return null;
      }
      throw await ErrorHandler.handleError(error);
    } catch (error) {
      throw await ErrorHandler.handleError(error);
    }
  }
}
