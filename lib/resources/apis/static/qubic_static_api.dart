import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/dtos/app_message_dto.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/services/dio_client.dart';

class QubicStaticApi {
  late Dio _dio;

  QubicStaticApi() {
    _dio = DioClient.getDio(baseUrl: Config.qubicStaticApiUrl);
  }

  Future<AppMessageModel?> getAppMessage() async {
    try {
      final response = await _dio.get(Config.qubicStaticMessages);
      final decodedResponse = json.decode(response.data);
      return decodedResponse["id"] == null
          ? null
          : AppMessageModel.fromJson(decodedResponse);
    } catch (error) {
      throw ErrorHandler.handleError(error);
    }
  }
}
