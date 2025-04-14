// ignore_for_file: constant_identifier_names

import 'package:qubic_wallet/models/qubic_helper_config.dart';

abstract class Config {
  // Qubic RPC backend related config
  static const qubicMainnetRpcDomain = "https://rpc.qubic.org";

  static tickData(int tick) => "/v1/ticks/$tick/tick-data";
  static tickTransactions(int tick) => "/v2/ticks/$tick/transactions";
  static computors(int epoch) => "/v1/epochs/$epoch/computors";
  static transaction(String transaction) => "/v2/transactions/$transaction";
  static networkTicks(int epoch) => "/v2/epochs/$epoch/ticks";

  static const latestStatsUrl = "/v1/latest-stats";

  static const submitTransaction = "/v1/broadcast-transaction";
  static const currentTick = "/v1/tick-info";

  static addressQubicBalance(String address) => "/v1/balances/$address";
  static addressAssetsBalance(String address) => "/v1/assets/$address/owned";
  static addressTransfers(String address) =>
      "/v2/identities/$address/transfers";

  static const notFoundStatusCode = 404;

  static const fetchEverySeconds = 60;
  static const fetchEverySecondsSlow = 60 * 5;
  static const inactiveSecondsLimit = 120;

  static const checkForTamperedUtils = true;

  static const useNativeSnackbar = false;

  // The qubic-hub.com backend
  static const servicesDomain = "wallet.qubic-hub.com";
  static const URL_VersionInfo = "/versionInfo.php";

  static const URL_WebExplorer = "https://explorer.qubic.org";

  static const networkQubicMainnet = "Qubic Mainnet";

  //Qubic Helper Utilities
  static final qubicHelper = QubicHelperConfig(
      win64: QubicHelperConfigEntry(
          filename: "qubic-helper-win-x64-3_1_1.exe",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/v3.1.1/qubic-helper-win-x64-3_1_1.exe",
          checksum: "a32e17ba2b92158ee9a63f7d666cbf8a"),
      linux64: QubicHelperConfigEntry(
          filename: "qubic-helper-linux-x64-3_1_1",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/v3.1.1/qubic-helper-linux-x64-3_1_1",
          checksum: "b1f7c658ff81bdf9408f3bcaba3403fe"),
      macOs64: QubicHelperConfigEntry(
          filename: "qubic-helper-mac-x64-3_1_1",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/v3.1.1/qubic-helper-mac-x64-3_1_1",
          checksum: "3a855b800fb2eb64035d83a1b48a2969"));

  static const qubicJSAssetPath =
      "assets/qubic_js/qubic-helper-html-3_1_2.html";

  // This will only be read in Debug mode. In Release mode, proxy setup is ignored.
  static const bool useProxy = false; // Can be set to `true` to use a proxy
  static const String proxyIP = '192.168.1.1'; // Replace with actual proxy IP
  static const int proxyPort = 8888; // Replace with actual proxy port

  // Configuration for Wallet Connect
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

  static const CustomURLScheme = "qubic-wallet";

  static const averageTickDurationInSeconds = 2.0;
  static const secondsToFlagTrxAsInvalid = 20;
  static const ticksToFlagTrxAsInvalid =
      secondsToFlagTrxAsInvalid / averageTickDurationInSeconds;

  static const dAppDefaultImageName = "assets/images/dapp-default.png";

  static const zeroAddress =
      "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFXIB";
}
