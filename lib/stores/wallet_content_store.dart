import 'package:collection/collection.dart';
import 'package:mobx/mobx.dart';
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
/// - Terms of use (future)
/// - Privacy policy (future)
/// - Version metadata (future)
///
/// **vs QubicEcosystemStore:**
/// - WalletContentStore = Wallet-specific content (dapps, terms, privacy)
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
  List<DappDto> get allDapps => dappsResponse?.dapps ?? [];

  @computed
  List<DappDto> get topDapps {
    if (dappsResponse == null) return [];
    return dappsResponse!.dapps
        .where((dapp) => dappsResponse!.topApps.contains(dapp.id))
        .toList();
  }

  @computed
  DappDto? get featuredDapp => dappsResponse?.dapps
      .firstWhereOrNull((e) => e.id == dappsResponse?.featuredApp?.id);

  @computed
  List<DappDto> get popularDapps {
    if (dappsResponse == null) return [];
    return dappsResponse!.dapps
        .where((dapp) =>
            !dappsResponse!.topApps.contains(dapp.id) &&
            dapp.id != dappsResponse!.featuredApp?.id)
        .toList();
  }

  String getCurrentLocale() {
    String currentLocale = l10nWrapper.l10n?.localeName ?? "en";
    if (!["de", "es", "fr", "ru", "tr", "zh"].contains(currentLocale)) {
      currentLocale = "en";
    }
    return currentLocale;
  }

  @action
  Future<void> loadDapps() async {
    try {
      appLogger.d("message");
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
