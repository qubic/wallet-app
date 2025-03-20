import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/intercepted_http.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/auth_login_dto.dart';
import 'package:qubic_wallet/dtos/explorer_id_info_dto.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/custom_proxy.dart';
import 'package:qubic_wallet/resources/http_interceptors.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/explorer_store.dart';
import 'package:qubic_wallet/stores/network_store.dart';

class QubicLi {
  final NetworkStore networkStore = getIt<NetworkStore>();
  ApplicationStore appStore = getIt<ApplicationStore>();
  ExplorerStore explorerStore = getIt<ExplorerStore>();
  String? _authenticationToken;
  // ignore: unused_field
  String? _refreshToken;
  String? get authenticationToken => _authenticationToken;

  bool _gettingNetworkBalances = false;
  bool _gettingNetworkAssets = false;
  bool _gettingNetworkTransactions = false;

  bool get gettingNetworkBalances => _gettingNetworkBalances;
  bool get gettingNetworkAssets => _gettingNetworkAssets;
  bool get gettingNetworkTransactions => _gettingNetworkTransactions;

  final client = InterceptedHttp.build(
    interceptors: [LoggingInterceptor()],
  );

  late String qubicLiDomain = networkStore.selectedNetwork.liUrl;

  void resetGetters() {
    _gettingNetworkBalances = false;
    _gettingNetworkAssets = false;
    _gettingNetworkTransactions = false;
  }

  updateDomain() {
    qubicLiDomain = networkStore.selectedNetwork.liUrl;
  }

  QubicLi() {
    // Initialization code
    // Set global HttpOverrides
    if (!kReleaseMode && Config.useProxy && Config.proxyIP.isNotEmpty) {
      final proxy =
          CustomProxy(ipAddress: Config.proxyIP, port: Config.proxyPort);
      proxy.enable();
    }
  }

  static Map<String, String> getHeaders() {
    return {
      'Accept': 'application/json',
      'Accept-Encoding': 'gzip, deflate',
      //'Accept-Encoding': 'identity',

      'Accept-Language': 'en-US,en;q=0.9',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'Host': 'api.qubic.li',
      'Pragma': 'no-cache',
      'Referer': 'https://wallet.qubic.li',
      'Origin': 'https://wallet.qublic.li',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36',
      'Sec-Ch-Ua':
          '"Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"',
      'Sec-Ch-Ua-Mobile': '?0',
      'Sec-Ch-Ua-Platform': '"Windows"',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'same-site'
    };
  }

  void _assertAuthorized() {
    if (_authenticationToken == null) {
      throw Exception('Failed to contact qubic network. Not authenticated');
    }
  }

  void _assert200Response(int statusCode) {
    if (statusCode != 200) {
      throw Exception(
          'Failed to perform action. Server returned status $statusCode');
    }
  }

  /// Authenticates with Qubic.li and stores authentication cookie in memory
  Future<void> authenticate() async {
    appStore.incrementPendingRequests();
    late http.Response response;
    try {
      var headers = QubicLi.getHeaders();
      headers.addAll({
        'Content-Type': 'application/json',
      });
      response =
          await client.post(Uri.parse('$qubicLiDomain/${Config.URL_Login}'),
              body: json.encode({
                'userName': Config.qubicLiAuthUsername,
                'password': Config.qubicLiAuthPassword,
                'twoFactorCode': ""
              }),
              headers: headers);
      appStore.decreasePendingRequests();
    } catch (e) {
      appLogger.e(e);
      appStore.decreasePendingRequests();
      throw Exception('Failed to contact server.');
    }
    appLogger.d(response);
    if (response.statusCode == 200) {
      late dynamic parsedJson;
      late AuthLoginDto loginDto;
      try {
        appLogger.d(response.body);
        parsedJson = jsonDecode(response.body);
      } catch (e) {
        throw Exception('Failed to authenticate. Could not parse response');
      }
      try {
        loginDto = AuthLoginDto.fromJson(parsedJson);
      } catch (e) {
        throw Exception(
            'Failed to authenticate. Server response is missing required info');
      }
      if (!loginDto.success) {
        throw Exception('Failed to authenticate. Wrong server credentials');
      }
      _authenticationToken = loginDto.token;
      _refreshToken = loginDto.refreshToken;
    } else {
      throw Exception(
          'Failed to authenticate. Got status response ${response.statusCode}');
    }
  }

  Future<ExplorerIdInfoDto> getExplorerIdInfo(String publicId) async {
    try {
      _assertAuthorized();
    } catch (e) {
      rethrow;
    }
    late http.Response response;
    try {
      var headers = QubicLi.getHeaders();
      headers.addAll({'Authorization': 'bearer ${_authenticationToken!}'});
      response = await client.get(
          Uri.parse('$qubicLiDomain/${Config.URL_ExplorerIdInfo}/$publicId'),
          headers: headers);
    } catch (e) {
      throw Exception('Failed to contact server for explorer id info.');
    }
    try {
      _assert200Response(response.statusCode);
    } catch (e) {
      rethrow;
    }
    late dynamic parsedJson;
    late ExplorerIdInfoDto resultDto;
    try {
      parsedJson = jsonDecode(response.body);
    } catch (e) {
      throw Exception(
          'Failed to fetch explorer id info. Could not parse response');
    }
    try {
      resultDto = ExplorerIdInfoDto.fromJson(parsedJson);
    } catch (e) {
      throw Exception(
          'Failed to fetch explorer id info. Server response is missing required info');
    }

    return resultDto;
  }
}
