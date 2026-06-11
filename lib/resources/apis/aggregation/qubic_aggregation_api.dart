import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/dtos/identities_assets_response.dart';
import 'package:qubic_wallet/models/qubic_asset.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/services/dio_client.dart';
import 'package:qubic_wallet/stores/network_store.dart';

/// Client for the `/aggregation/v1` endpoints. Mirrors the web wallet's
/// `ApiAggregationService`. Currently exposes owned-asset data via
/// [getIdentitiesAssets] — one batched call for all identities, replacing the
/// previous per-address `GET /live/v1/assets/{id}/owned`.
class QubicAggregationApi {
  late Dio _dio;
  final NetworkStore _networkStore;

  QubicAggregationApi(this._networkStore) {
    _dio = DioClient.getDio(baseUrl: _networkStore.currentNetwork.rpcUrl);
  }

  void updateDio() {
    _dio = DioClient.getDio(baseUrl: _networkStore.currentNetwork.rpcUrl);
  }

  Future<List<QubicAsset>> getIdentitiesAssets(List<String> publicIds) async {
    if (publicIds.isEmpty) return [];
    try {
      final response = await _dio.post(
        '${_networkStore.currentNetwork.rpcUrl}${Config.getIdentitiesAssets}',
        data: {'identities': publicIds},
      );
      return IdentitiesAssetsResponse.fromJson(
              response.data as Map<String, dynamic>)
          .toOwnedAssets();
    } catch (e) {
      throw await ErrorHandler.handleError(e);
    }
  }
}
