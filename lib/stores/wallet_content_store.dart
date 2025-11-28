import 'package:collection/collection.dart';
import 'package:mobx/mobx.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/resources/apis/static/qubic_static_api.dart';

part 'wallet_content_store.g.dart';

/// MobX store for wallet-app-specific content and configuration.
///
/// **Data Scope:**
/// Manages wallet-specific content from `/wallet-app/` APIs that is unique
/// to this wallet application:
/// - Dapps directory (featured, top, popular apps)
///
/// **vs QubicEcosystemStore:**
/// - WalletContentStore = Wallet-specific content (dapps)
/// - QubicEcosystemStore = Ecosystem reference data (used by any Qubic app)
///
/// **Architecture:**
/// This store combines state management and data fetching. For simple static
/// reference data, extracting a repository layer is unnecessary. If future
/// requirements demand caching, retry logic, or offline support, consider
/// separating data fetching into repository classes.
class WalletContentStore = WalletContentStoreBase with _$WalletContentStore;

abstract class WalletContentStoreBase with Store {
  final QubicStaticApi _staticApi = getIt<QubicStaticApi>();

  @observable
  DappsResponse? dappsResponse;

  @observable
  String? error;

  @observable
  bool isLoading = false;

  @computed
  List<DappDto> get allDapps => (dappsResponse?.dapps ?? [])
      .where((dapp) => isDappAvailableOnCurrentPlatform(dapp))
      .toList();

  @computed
  List<DappDto> get topDapps {
    if (dappsResponse == null) return [];
    return allDapps
        .where((dapp) => dappsResponse!.topApps.contains(dapp.id))
        .toList();
  }

  @computed
  DappDto? get featuredDapp {
    return allDapps
        .firstWhereOrNull((e) => e.id == dappsResponse?.featuredApp?.id);
  }

  @computed
  List<DappDto> get popularDapps {
    if (dappsResponse == null) return [];
    return allDapps
        .where((dapp) =>
            !dappsResponse!.topApps.contains(dapp.id) &&
            dapp.id != dappsResponse!.featuredApp?.id)
        .toList();
  }

  String getCurrentLocale() {
    final currentLocale = l10nWrapper.l10n?.localeName ?? "en";
    return Config.getSupportedLocale(currentLocale);
  }

  /// Returns the current platform identifier
  /// Platform identifiers: 'ios', 'android', 'macos', 'windows', 'linux', 'web'
  String getCurrentPlatform() {
    return UniversalPlatform.operatingSystem;
  }

  /// Checks if a dApp should be shown on the current platform
  bool isDappAvailableOnCurrentPlatform(DappDto dapp) {
    if (dapp.excludedPlatforms == null || dapp.excludedPlatforms!.isEmpty) {
      return true;
    }
    final currentPlatform = getCurrentPlatform();
    return !dapp.excludedPlatforms!
        .any((platform) => platform.toLowerCase() == currentPlatform);
  }

  @action
  Future<void> loadDapps() async {
    try {
      isLoading = true;
      error = null;
      final response = await _staticApi.getDapps();
      final dappsLocalized =
          await _staticApi.getLocalizedDappData(getCurrentLocale());

      // Create the localized dapps list
      final localizedDapps = response.dapps.map((dapp) {
        return dapp.copyWith(
          description: dappsLocalized[dapp.descriptionId],
          name: dappsLocalized[dapp.nameId],
          openButtonTitle: (dapp.openButtonTitleId != null)
              ? dappsLocalized[dapp.openButtonTitleId]
              : null,
        );
      }).toList();

      // Assign the new response with localized dapps
      dappsResponse = response.copyWith(dapps: localizedDapps);
    } catch (e) {
      appLogger.e(e);
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }
}
