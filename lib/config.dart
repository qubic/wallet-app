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
          filename: "qubic-helper-win-x64-3_0_9.exe",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/3.0.9/qubic-helper-win-x64-3_0_9.exe",
          checksum: "edbf36cd76ca8d1ff030e5600246cc0d"),
      linux64: QubicHelperConfigEntry(
          filename: "qubic-helper-linux-x64-3_0_9",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/3.0.9/qubic-helper-linux-x64-3_0_9",
          checksum: "2f903d0f37361cb8c6beb13385fbc407"),
      macOs64: QubicHelperConfigEntry(
          filename: "qubic-helper-mac-x64-3_0_9",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/3.0.9/qubic-helper-mac-x64-3_0_9",
          checksum: "20f729d82643f02df2e1f49dfad96951"));

  // This will only be read in Debug mode. In Release mode, proxy setup is ignored.
  static const bool useProxy = false; // Can be set to `true` to use a proxy
  static const String proxyIP = '192.168.1.1'; // Replace with actual proxy IP
  static const int proxyPort = 8888; // Replace with actual proxy port
}
