import 'package:collection/collection.dart';
import 'package:mobx/mobx.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/target_tick.dart';
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

  /// Raw `default_tick_offset` from the wallet-app config — null until loaded or
  /// if absent. Deliberately NOT `@observable`: it is read imperatively in screen
  /// `initState`, so no MobX reactivity (and no build_runner regen) is required.
  int? remoteDefaultTickOffset;

  /// Effective default tick offset for new transactions: the remote value when
  /// present and valid (>= 1), otherwise the historical +5 fallback.
  int get defaultTickOffset =>
      (remoteDefaultTickOffset != null && remoteDefaultTickOffset! >= 1)
          ? remoteDefaultTickOffset!
          : TargetTickTypeEnum.autoCurrentPlus5.value;

  /// Dropdown preset used as the default selection on the send screens.
  ///
  /// Rounds [defaultTickOffset] UP to the nearest preset — never down — so the
  /// lead time is never shorter than what was configured; caps at the largest
  /// preset. (The WalletConnect path has no dropdown and uses [defaultTickOffset]
  /// directly, honoring the exact value.)
  TargetTickTypeEnum get defaultTargetTickType {
    final offset = defaultTickOffset;
    const presets = [
      TargetTickTypeEnum.autoCurrentPlus5,
      TargetTickTypeEnum.autoCurrentPlus10,
      TargetTickTypeEnum.autoCurrentPlus20,
      TargetTickTypeEnum.autoCurrentPlus40,
    ];
    return presets.firstWhere((t) => t.value >= offset,
        orElse: () => TargetTickTypeEnum.autoCurrentPlus40);
  }

  /// Cached app version for version constraint checks
  Version? _appVersion;

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

  /// Checks if a dApp should be shown on the current platform and version
  bool isDappAvailableOnCurrentPlatform(DappDto dapp) {
    final currentPlatform = getCurrentPlatform();
    final versionConstraint = dapp.platformVersions?[currentPlatform];

    // If no version constraint for this platform, dApp is available
    if (versionConstraint == null) return true;

    // Special value "none" means excluded entirely (no version supported)
    if (versionConstraint.toLowerCase() == DappDto.versionNone) return false;

    // If app version not loaded, hide dApps with version constraints (restrictive)
    if (_appVersion == null) return false;

    try {
      final constraint = VersionConstraint.parse(versionConstraint);
      return constraint.allows(_appVersion!);
    } catch (e) {
      appLogger.e('Invalid version constraint: $versionConstraint - $e');
      return false; // On error, hide the dApp (restrictive)
    }
  }

  @action
  Future<void> loadDapps() async {
    try {
      isLoading = true;
      error = null;

      // Load app version for version constraint checks
      if (_appVersion == null) {
        final packageInfo = await PackageInfo.fromPlatform();
        try {
          _appVersion = Version.parse(packageInfo.version);
        } catch (e) {
          appLogger.e('Failed to parse app version: ${packageInfo.version}');
        }
      }

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

  /// Loads wallet-app runtime configuration. Not a MobX `@action`: it only
  /// writes a non-observable field, so no reactivity or codegen is involved.
  /// Failures are swallowed — callers fall back to compiled defaults.
  Future<void> loadConfig() async {
    try {
      final response = await _staticApi.getWalletAppConfig();
      remoteDefaultTickOffset = response.defaultTickOffset;
      appLogger.i(
          "Successfully loaded wallet app config (default_tick_offset: ${response.defaultTickOffset})");
    } catch (e) {
      appLogger.e("Failed to load wallet app config: ${e.toString()}");
    }
  }
}
