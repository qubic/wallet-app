import 'package:get_it/get_it.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/resources/qubic_hub.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
import 'package:qubic_wallet/services/biometric_service.dart';
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

  getIt.registerSingleton<QubicStatsApi>(QubicStatsApi());

  //Services
  getIt.registerSingleton<QubicHubService>(QubicHubService());
  getIt.registerSingleton<TimedController>(TimedController());
  getIt.registerSingleton<BiometricService>(BiometricService());

  getIt.registerSingleton<QubicCmd>(QubicCmd());
}
