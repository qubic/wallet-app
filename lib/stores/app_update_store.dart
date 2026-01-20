// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/models/app_version_check_model.dart'
    show UpdateType, AppVersionCheckModel;
import 'package:qubic_wallet/resources/apis/static/qubic_static_api.dart';
import 'package:qubic_wallet/stores/settings_store.dart';

part 'app_update_store.g.dart';

class AppUpdateStore = _AppUpdateStore with _$AppUpdateStore;

abstract class _AppUpdateStore with Store {
  static const String _ignoredVersionKey = 'ignored_update_version';

  final QubicStaticApi _staticApi = getIt<QubicStaticApi>();
  final SettingsStore _settingsStore = getIt<SettingsStore>();

  /// Latest version info fetched from the API
  @observable
  AppVersionCheckModel? _versionInfo;

  bool _dismissedForSession = false;
  String? _ignoredVersion;

  bool get shouldShowUpdateScreen {
    if (_versionInfo == null || _dismissedForSession) return false;
    return _shouldShowForVersion(_versionInfo!);
  }

  @computed
  AppVersionCheckModel? get currentVersionInfo =>
      shouldShowUpdateScreen ? _versionInfo : null;

  bool _shouldShowForVersion(AppVersionCheckModel info) {
    if (!info.isApplicableForCurrentPlatform()) return false;

    final currentVersion = _parseVersion(_settingsStore.versionInfo);
    final requiredVersion = _parseVersion(info.version);
    final isOutdated = currentVersion < requiredVersion;
    final isIgnored =
        info.updateType == UpdateType.flexible && _ignoredVersion == info.version;

    return isOutdated && !isIgnored;
  }

  Version _parseVersion(String? versionString) {
    try {
      return Version.parse(versionString ?? '0.0.0');
    } catch (_) {
      return Version(0, 0, 0);
    }
  }

  @action
  Future<void> checkForUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    _ignoredVersion = prefs.getString(_ignoredVersionKey);
    _versionInfo = await _staticApi.getAppVersionCheck();
  }

  @action
  void handleLaterAction() {
    _dismissedForSession = true;
  }

  @action
  Future<void> handleIgnoreAction(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ignoredVersionKey, version);
    _ignoredVersion = version;
  }
}
