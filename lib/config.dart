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

  static const checkForTamperedUtils = true;

  static const useNativeSnackbar = false;

  // The qubic-hub.com backend
  static const servicesDomain = "wallet.qubic-hub.com";
  static const URL_VersionInfo = "/versionInfo.php";

  //Qubic Helper Utilities
  static final qubicHelper = QubicHelperConfig(
      win64: QubicHelperConfigEntry(
          filename: "qubic-helper-win-x64-3_0_6.exe",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/3.0.6/qubic-helper-win-x64-3_0_6.exe",
          checksum: "55236d3b6d5d7c795807cbf89f77423d"),
      linux64: QubicHelperConfigEntry(
          filename: "qubic-helper-linux-x64-3_0_6",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/3.0.6/qubic-helper-linux-x64-3_0_6",
          checksum: "503a87fadc425692b7d0d0579f56683e"),
      macOs64: QubicHelperConfigEntry(
          filename: "qubic-helper-mac-x64-3_0_6",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/3.0.6/qubic-helper-mac-x64-3_0_6",
          checksum: "45588af4b72234858dca3e1094f2aaeb"));

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
}
