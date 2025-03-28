import 'package:app_links/app_links.dart';
import 'package:get_it/get_it.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/models/wallet_connect/wallet_connect_modals_controller.dart';
import 'package:qubic_wallet/resources/apis/archive/qubic_archive_api.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:qubic_wallet/resources/apis/stats/qubic_stats_api.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
import 'package:qubic_wallet/services/biometric_service.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/network_store.dart';
import 'package:qubic_wallet/stores/qubic_hub_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/timed_controller.dart';

final GetIt getIt = GetIt.instance;

/// Setups Dependency injection
void setupDI() {
  getIt.registerSingleton<NetworkStore>(NetworkStore());

  getIt.registerSingleton<QubicArchiveApi>(
      QubicArchiveApi(getIt<NetworkStore>()));
  getIt.registerSingleton<QubicStatsApi>(QubicStatsApi(getIt<NetworkStore>()));

  //Stores
  getIt.registerSingleton<ApplicationStore>(ApplicationStore());
  getIt.registerSingleton<SettingsStore>(SettingsStore());
  getIt.registerSingleton<QubicHubStore>(QubicHubStore());
  getIt.registerSingleton<SecureStorage>(SecureStorage());
  getIt.registerSingleton<HiveStorage>(HiveStorage());

//Providers
  getIt.registerSingleton<GlobalSnackBar>(GlobalSnackBar());

  //getIt.registerSingleton<QubicHub>(QubicHub());

  getIt.registerSingleton<QubicLiveApi>(QubicLiveApi(getIt<NetworkStore>()));

  //Services
  //getIt.registerSingleton<QubicHubService>(QubicHubService());

  //WalletConnect
  getIt.registerSingleton<WalletConnectService>(WalletConnectService());
  getIt.registerSingleton<WalletConnectModalsController>(
      WalletConnectModalsController());

  getIt.registerSingleton<TimedController>(TimedController());
  getIt.registerSingleton<BiometricService>(BiometricService());

  getIt.registerSingleton<QubicCmd>(QubicCmd());

  getIt.registerSingleton<AppLinks>(AppLinks());
}
