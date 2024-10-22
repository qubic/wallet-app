// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/models/settings.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';

part 'settings_store.g.dart';

// flutter pub run build_runner watch --delete-conflicting-outputs

class SettingsStore = _SettingsStore with _$SettingsStore;

abstract class _SettingsStore with Store {
  late final SecureStorage secureStorage = getIt<SecureStorage>();

  @observable
  bool cmdUtilsAvailable = false;

  @observable
  Settings settings = Settings();

  @observable
  bool totalBalanceVisible = true;

  @action
  Future<void> loadSettings() async {
    Settings newSettings;
    try {
      newSettings = await secureStorage.getWalletSettings();
      settings = Settings.clone(newSettings);
      totalBalanceVisible = settings.totalBalanceVisible ?? true;
    } catch (e) {
      settings = Settings.clone(Settings());
    }
  }

  @action
  Future<void> setTotalBalanceVisible(bool value) async {
    settings.totalBalanceVisible = value;
    totalBalanceVisible = value;
    settings = Settings.clone(settings);
    await secureStorage.setWalletSettings(settings);
  }

  @action
  Future<void> setBiometrics(bool value) async {
    settings.biometricEnabled = value;
    settings = Settings.clone(settings);
    await secureStorage.setWalletSettings(settings);
  }

  @action
  Future<void> setTOTPKey(String key) async {
    settings.TOTPKey = key;
    settings = Settings.clone(settings);
    await secureStorage.setWalletSettings(settings);
  }

  @action
  Future<void> clearTOTPKey() async {
    settings.TOTPKey = null;
    settings = Settings.clone(settings);
    await secureStorage.setWalletSettings(settings);
  }

  @action
  Future<void> setAutoLockTimeout(int value) async {
    settings.autoLockTimeout = value;
    settings = Settings.clone(settings);
    await secureStorage.setWalletSettings(settings);
  }
}
