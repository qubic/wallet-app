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
          filename: "qubic-helper-win-x64-3_0_4.exe",
          downloadPath:
              "https://github.com/Qubic-Hub/qubic-helper-utils/releases/download/3.0.4/qubic-helper-win-x64-3_0_4.exe",
          checksum:
              "74336b445a048bfd272e2af6c7668608"), // was 4dcab1001193a7ed3abf3485cd99eff0 for 2_0_1
      linux64: QubicHelperConfigEntry(
          filename: "qubic-helper-linux-x64-3_0_4",
          downloadPath:
              "https://github.com/Qubic-Hub/qubic-helper-utils/releases/download/3.0.4/qubic-helper-linux-x64-3_0_4",
          checksum: "8f65ab5bf42a5fe193ec841417930267"),
      macOs64: QubicHelperConfigEntry(
          filename: "qubic-helper-mac-x64-3_0_4",
          downloadPath:
              "https://github.com/Qubic-Hub/qubic-helper-utils/releases/download/3.0.4/qubic-helper-mac-x64-3_0_4",
          checksum: "7ae70dcedf83599a53877f15b1023b05"));
}
