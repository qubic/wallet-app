// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:qubic_wallet/l10n/app_localizations.dart';
import 'package:qubic_wallet/models/qubic_helper_config.dart';
import 'package:qubic_wallet/stores/root_jailbreak_flag_store.dart';

abstract class Config {
  // ---------------------------------------------------------------------------
  // Base URLs & Environment
  // ---------------------------------------------------------------------------

  static const qubicMainnetRpcDomain = "https://rpc.qubic.org";
  static const networkQubicMainnet = "Qubic Mainnet";
  static const URL_WebExplorer = "https://explorer.qubic.org";

  static bool get useDevEnvironment => kDebugMode;

  static String get qubicStaticApiBaseUrl {
    if (useDevEnvironment) {
      return "https://static.qubic.org/dev/v1";
    }
    return "https://static.qubic.org/v1";
  }

  // ---------------------------------------------------------------------------
  // Static API Endpoints
  // ---------------------------------------------------------------------------

  // Wallet-app specific endpoints
  static const dapps = "/wallet-app/dapps/dapps.json";
  static dappLocale(String locale) => "/wallet-app/dapps/locales/$locale.json";

  // General/ecosystem endpoints (shared across Qubic ecosystem)
  static const smartContracts = "/general/data/smart_contracts.json";
  static const labeledAddresses = "/general/data/address_labels.json";
  static const exchanges = "/general/data/exchanges.json";
  static const protocol = "/general/data/protocol.json";

  // ---------------------------------------------------------------------------
  // RPC API Endpoints — Query
  // ---------------------------------------------------------------------------

  static const queryApiPrefix = "/query/v1";
  static const lastProcessedTick = "$queryApiPrefix/getLastProcessedTick";
  static const transactionByHash = "$queryApiPrefix/getTransactionByHash";
  static const transactionsForIdentity =
      "$queryApiPrefix/getTransactionsForIdentity";

  // ---------------------------------------------------------------------------
  // RPC API Endpoints — Live
  // ---------------------------------------------------------------------------

  static const liveApiPrefix = "/live/v1";
  static const currentTick = "$liveApiPrefix/tick-info";
  static const submitTransaction = "$liveApiPrefix/broadcast-transaction";
  static const querySmartContract = "$liveApiPrefix/querySmartContract";
  static const assets = "$liveApiPrefix/assets/issuances";

  // ---------------------------------------------------------------------------
  // RPC API Endpoints — Aggregation
  // ---------------------------------------------------------------------------

  static const aggregationApiPrefix = "/aggregation/v1";
  static const getIdentitiesAssets =
      "$aggregationApiPrefix/getIdentitiesAssets";

  // ---------------------------------------------------------------------------
  // RPC API Endpoints — Stats
  // ---------------------------------------------------------------------------

  static const latestStatsUrl = "/v1/latest-stats";

  // ---------------------------------------------------------------------------
  // HTTP
  // ---------------------------------------------------------------------------

  static const notFoundStatusCode = 404;

  // ---------------------------------------------------------------------------
  // Polling & Timers
  // ---------------------------------------------------------------------------

  static const fetchEverySeconds = 60;
  static const fetchEverySecondsSlow = 60 * 5;
  static const inactiveSecondsLimit = 120;

  // ---------------------------------------------------------------------------
  // App Settings
  // ---------------------------------------------------------------------------

  static const maxAccountsInWallet = 15;
  static const checkForTamperedUtils = true;
  static const useNativeSnackbar = false;
  static const CustomURLScheme = "qubic-wallet";

  /// Returns a supported language code, falling back to English if not supported
  /// Uses the app's l10n configuration automatically - no manual maintenance needed
  static String getSupportedLocale(String locale) {
    final supportedLocaleCodes =
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
    return supportedLocaleCodes.contains(locale) ? locale : 'en';
  }

  // ---------------------------------------------------------------------------
  // DApp Config
  // ---------------------------------------------------------------------------

  static const dAppDefaultImageName = "assets/images/dapp-default.png";
  static const double dAppIconSize = 45.0;

  // ---------------------------------------------------------------------------
  // Qubic Helper Utilities
  // ---------------------------------------------------------------------------

  static final qubicHelper = QubicHelperConfig(
      win64: QubicHelperConfigEntry(
          filename: "qubic-helper-win-x64-3_1_3.exe",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/v3.1.3/qubic-helper-win-x64-3_1_3.exe",
          checksum: "1ac587676893bd1069cdf0c1d2a4d079"),
      linux64: QubicHelperConfigEntry(
          filename: "qubic-helper-linux-x64-3_1_3",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/v3.1.3/qubic-helper-linux-x64-3_1_3",
          checksum: "f691896a86df0dacea8ac2d35fe18f71"),
      macOs64: QubicHelperConfigEntry(
          filename: "qubic-helper-mac-x64-3_1_3",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/v3.1.3/qubic-helper-mac-x64-3_1_3",
          checksum: "b3038e61c9c04eb00cd5c9672be6acfe"));

  static const qubicJSAssetPath =
      "assets/qubic_js/qubic-helper-html-3_2_0.html";

  // ---------------------------------------------------------------------------
  // WalletConnect
  // ---------------------------------------------------------------------------

  static const walletConnectProjectId = "b2ace378845f0e4806ef23d2732f77a4";
  static const walletConnectName = "Qubic Wallet";
  static const walletConnectDescription = "The official wallet for Qubic chain";
  static const walletConnectURL = "https://www.qubic.org";
  static const walletConnectIcons = [
    "https://wallet.qubic.org/assets/logos/qubic_wallet_dark.svg"
  ];
  static const walletConnectRedirectNative = "qubicwallet://";
  static const walletConnectRedirectUniversal = "https://wallet.qubic.org";
  static const walletConnectChainId = "qubic:mainnet";
  static const wallectConnectUrlLength = 187;
  static const wallectConnectPairingTimeoutSeconds = 4;
  static const walletConnectExistsTimeoutSeconds = 2;

  // ---------------------------------------------------------------------------
  // Debug / Proxy
  // ---------------------------------------------------------------------------

  // This will only be read in Debug mode. In Release mode, proxy setup is ignored.
  static const bool useProxy = false;
  static const String proxyIP = '192.168.1.1';
  static const int proxyPort = 8888;
  static const DeviceIntegrityResponse deviceIntegrityResponse =
      DeviceIntegrityResponse.restrict;
}
