// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/models/app_version_check_model.dart'
    show UpdateType, AppVersionCheckModel;
import 'package:qubic_wallet/resources/apis/static/qubic_static_api.dart';
import 'package:qubic_wallet/stores/settings_store.dart';

part 'app_update_store.g.dart';

// flutter pub run build_runner watch --delete-conflicting-outputs

class AppUpdateStore = _AppUpdateStore with _$AppUpdateStore;

abstract class _AppUpdateStore with Store {
  static const String _ignoredVersionKey = 'ignored_update_version';

  final QubicStaticApi _staticApi = getIt<QubicStaticApi>();
  final SettingsStore _settingsStore = getIt<SettingsStore>();

  /// Latest version info fetched from the API
  @observable
  AppVersionCheckModel? versionInfo;

  /// Session-based flag to track if user clicked "Later"
  @observable
  bool _dismissedForSession = false;

  /// Cached ignored version loaded from SharedPreferences
  @observable
  String? _ignoredVersion;

  @computed
  bool get shouldShowUpdateScreen {
    if (versionInfo == null) return false;
    if (_dismissedForSession) return false;

    return _shouldShowForVersion(versionInfo!);
  }

  @computed
  AppVersionCheckModel? get currentVersionInfo =>
      shouldShowUpdateScreen ? versionInfo : null;

  bool _shouldShowForVersion(AppVersionCheckModel versionInfo) {
    if (!versionInfo.isApplicableForCurrentPlatform()) {
      return false;
    }

    final currentVersion = _getCurrentAppVersion();
    final requiredVersion = Version.parse(versionInfo.version);

    if (currentVersion < requiredVersion) {
      if (versionInfo.updateType == UpdateType.flexible &&
          _ignoredVersion == versionInfo.version) {
        return false;
      }
      return true;
    }

    return false;
  }

  Version _getCurrentAppVersion() {
    final versionString = _settingsStore.versionInfo ?? '0.0.0';
    try {
      return Version.parse(versionString);
    } catch (e) {
      appLogger.e(
          '[AppUpdateStore] Failed to parse current version: $versionString');
      return Version(0, 0, 0);
    }
  }

  Future<void> _loadIgnoredVersion() async {
    final prefs = await SharedPreferences.getInstance();
    _ignoredVersion = prefs.getString(_ignoredVersionKey);
  }

  @action
  Future<void> checkForUpdate() async {
    try {
      await _loadIgnoredVersion();
      versionInfo = await _staticApi.getAppVersionCheck();
    } catch (e) {
      appLogger.e('[AppUpdateStore] Failed to check for updates: $e');
    }
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
