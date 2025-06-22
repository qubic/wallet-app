import 'package:collection/collection.dart';
import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/resources/apis/qubic_helpers_api.dart';

part 'dapp_store.g.dart';

class DappStore = _DappStore with _$DappStore;

abstract class _DappStore with Store {
  final QubicHelpersApi _qubicHelpersApi = getIt<QubicHelpersApi>();

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
      final response = await _qubicHelpersApi.getDapps();
      final dappsLocalized =
          await _qubicHelpersApi.getLocalizedJson(getCurrentLocale());

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
