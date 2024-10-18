// ignore_for_file: constant_identifier_names

import 'package:qubic_wallet/models/qubic_helper_config.dart';

abstract class Config {
  /// General backend via qubic.li
  static const walletDomain = "api.qubic.li";

  static const URL_Login = "Auth/Login";
  static const URL_Tick = "Public/CurrentTick";
  static const URL_Balance = "Wallet/CurrentBalance";
  static const URL_NetworkBalances = "Wallet/NetworkBalances";
  static const URL_NetworkTransactions = "Wallet/Transactions";
  static const URL_Assets = "Wallet/Assets";
  static const URL_Transaction = "Public/SubmitTransaction";
  static const URL_TickOverview = "Network/TickOverview";
  static const URL_ExplorerQuery = "Search/Query";
  static const URL_ExplorerTickInfo = "Network/Block";
  static const URL_ExplorerIdInfo = "Network/Id";

  static const URL_MarketInfo = "Public/MarketInformation";

  static const archiveDomain = "https://rpc.qubic.org";
  static tickData(int tick) => "/v1/ticks/$tick/tick-data";
  static tickTransactions(int tick) => "/v2/ticks/$tick/transactions";
  static computors(int epoch) => "/v1/epochs/$epoch/computors";
  static transaction(String transaction) => "/v2/transactions/$transaction";

  static const statsDomain = "https://rpc.qubic.org";
  static const latestStatsUrl = "/v1/latest-stats";

  static const liveDomain = "https://rpc.qubic.org";
  static const submitTransaction = "/v1/broadcast-transaction";
  static const currentTick = "/v1/tick-info";

  static const authUser = "guest@qubic.li";
  static const authPass = "guest13@Qubic.li";

  static const fetchEverySeconds = 60;
  static const fetchEverySecondsSlow = 60 * 5;
  static const inactiveSecondsLimit = 120;

  static const checkForTamperedUtils = true;

  static const useNativeSnackbar = false;

  // The qubic-hub.com backend
  static const servicesDomain = "wallet.qubic-hub.com";
  static const URL_VersionInfo = "/versionInfo.php";

  static const URL_WebExplorer = "https://explorer.qubic.org";

  //Qubic Helper Utilities
  static final qubicHelper = QubicHelperConfig(
      win64: QubicHelperConfigEntry(
          filename: "qubic-helper-win-x64-3_0_8.exe",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/3.0.8/qubic-helper-win-x64-3_0_8.exe",
          checksum: "25a673010749a2c1cbbf97d023b02b1b"),
      linux64: QubicHelperConfigEntry(
          filename: "qubic-helper-linux-x64-3_0_8",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/3.0.8/qubic-helper-linux-x64-3_0_8",
          checksum: "43a6f19eea3289ed53b45987305e06f0"),
      macOs64: QubicHelperConfigEntry(
          filename: "qubic-helper-mac-x64-3_0_8",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/3.0.8/qubic-helper-mac-x64-3_0_8",
          checksum: "8166782f742251d486309f0007d96a59"));

  // This will only be read in Debug mode. In Release mode, proxy setup is ignored.
  static const bool useProxy = false; // Can be set to `true` to use a proxy
  static const String proxyIP = '192.168.1.1'; // Replace with actual proxy IP
  static const int proxyPort = 8888; // Replace with actual proxy port

  //Configuration for Wallet Connect
  static const walletConnectProjectId = "b2ace378845f0e4806ef23d2732f77a4";
  static const walletConnectName = "Qubic Wallet";
  static const walletConnectDescription = "The official wallet for Qubic chain";
  static const walletConnectURL = "https://www.qubic.org";
  static const walletConnectIcons = [
    "https://wallet.qubic.org/assets/logos/qubic_wallet_dark.svg"
  ];
  static const walletConnectRedirectNative = "qubicwallet://";
  static const walletConnectRedirectUniversal = "https://wallet.qubic.org";

  static const walletConnectChainId = "qubic:main";
  static const wallectConnectUrlLength = 187;
}
