import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/services/dio_client.dart';
import 'package:qubic_wallet/stores/application_store.dart';

class QubicLiveApi {
  final Dio _dio = DioClient.getDio(baseUrl: _baseUrl);
  static const String _baseUrl = Config.liveDomain;
  final ApplicationStore appStore = getIt.get<ApplicationStore>();
  Future<void> submitTransaction(String transaction) async {
    try {
      appStore.incrementPendingRequests();
      await _dio.post('$_baseUrl${Config.submitTransaction}',
          data: {"encodedTransaction": transaction});
      return;
    } catch (error) {
      throw ErrorHandler.handleError(error);
    } finally {
      appStore.decreasePendingRequests();
    }
  }
}
