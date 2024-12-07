import 'package:get_it/get_it.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/models/wallet_connect/wallet_connect_modals_controller.dart';
import 'package:qubic_wallet/resources/apis/archive/qubic_archive_api.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/resources/qubic_hub.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
import 'package:qubic_wallet/services/biometric_service.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/resources/apis/stats/qubic_stats_api.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/explorer_store.dart';
import 'package:qubic_wallet/stores/qubic_hub_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';

import 'package:qubic_wallet/timed_controller.dart';

import 'services/qubic_hub_service.dart';

final GetIt getIt = GetIt.instance;

/// Setups Dependency injection
void setupDI() {
  getIt.registerSingleton<QubicArchiveApi>(QubicArchiveApi());
  getIt.registerSingleton<QubicStatsApi>(QubicStatsApi());

  //Stores
  getIt.registerSingleton<ApplicationStore>(ApplicationStore());
  getIt.registerSingleton<SettingsStore>(SettingsStore());
  getIt.registerSingleton<ExplorerStore>(ExplorerStore());
  getIt.registerSingleton<QubicHubStore>(QubicHubStore());
  getIt.registerSingleton<SecureStorage>(SecureStorage());

//Providers
  getIt.registerSingleton<GlobalSnackBar>(GlobalSnackBar());

  getIt.registerSingleton<QubicLi>(QubicLi());
  getIt.registerSingleton<QubicHub>(QubicHub());

  getIt.registerSingleton<QubicLiveApi>(QubicLiveApi());

  //Services
  getIt.registerSingleton<QubicHubService>(QubicHubService());

  //WalletConnect
  getIt.registerSingleton<WalletConnectService>(WalletConnectService());
  getIt.registerSingleton<WalletConnectModalsController>(
      WalletConnectModalsController());

  getIt.registerSingleton<TimedController>(TimedController());
  getIt.registerSingleton<BiometricService>(BiometricService());

  getIt.registerSingleton<QubicCmd>(QubicCmd());
}
