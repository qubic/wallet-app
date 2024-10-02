import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/current_tick_dto.dart';
import 'package:qubic_wallet/dtos/explorer_tick_info_dto.dart';
import 'package:qubic_wallet/dtos/explorer_transaction_info_dto.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/services/dio_client.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/explorer_store.dart';

class QubicArchiveApi {
  final Dio _dio = DioClient.getDio(baseUrl: _baseUrl);
  static const String _baseUrl = Config.archiveDomain;

  final ApplicationStore _appStore = getIt<ApplicationStore>();
  final ExplorerStore _explorerStore = getIt<ExplorerStore>();

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

  Future<ExplorerTickDto> getExplorerTick(int tick) async {
    try {
      _explorerStore.incrementPendingRequests();
      final response = await _dio.get('$_baseUrl${Config.tickData(tick)}');
      return ExplorerTickDto.fromJson(response.data["tickData"]);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    } finally {
      _explorerStore.decreasePendingRequests();
    }
  }

  Future<List<ExplorerTransactionDto>> getExplorerTickTransactions(
      int tick) async {
    try {
      _explorerStore.incrementPendingRequests();
      final response =
          await _dio.get('$_baseUrl${Config.tickTransactions(tick)}');
      return List<ExplorerTransactionDto>.from(response.data["transactions"]
          .map((e) => ExplorerTransactionDto.fromJson(e)));
    } catch (error) {
      throw ErrorHandler.handleError(error);
    } finally {
      _explorerStore.decreasePendingRequests();
    }
  }
}
