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
      isLoading = true;
      error = null;
      dappsResponse = await _qubicHelpersApi.getDapps();
      final dappsLocalized =
          await _qubicHelpersApi.getLocalizedJson(getCurrentLocale());
      // Change the description and name of each dapp inside dapps to have the localized value
      dappsResponse!.dapps = dappsResponse!.dapps.map((dapp) {
        return dapp.copyWith(
          description: dappsLocalized[dapp.descriptionId],
          name: dappsLocalized[dapp.nameId],
        );
      }).toList();
    } catch (e) {
      appLogger.e(e);
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

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
  DappDto? get explorerDapp =>
      dappsResponse?.dapps.firstWhereOrNull((e) => e.id == "explorer_app_id");
}
