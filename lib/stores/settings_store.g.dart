// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SettingsStore on _SettingsStore, Store {
  late final _$cmdUtilsAvailableAtom =
      Atom(name: '_SettingsStore.cmdUtilsAvailable', context: context);

  @override
  bool get cmdUtilsAvailable {
    _$cmdUtilsAvailableAtom.reportRead();
    return super.cmdUtilsAvailable;
  }

  @override
  set cmdUtilsAvailable(bool value) {
    _$cmdUtilsAvailableAtom.reportWrite(value, super.cmdUtilsAvailable, () {
      super.cmdUtilsAvailable = value;
    });
  }

  late final _$settingsAtom =
      Atom(name: '_SettingsStore.settings', context: context);

  @override
  Settings get settings {
    _$settingsAtom.reportRead();
    return super.settings;
  }

  @override
  set settings(Settings value) {
    _$settingsAtom.reportWrite(value, super.settings, () {
      super.settings = value;
    });
  }

  late final _$totalBalanceVisibleAtom =
      Atom(name: '_SettingsStore.totalBalanceVisible', context: context);

  @override
  bool get totalBalanceVisible {
    _$totalBalanceVisibleAtom.reportRead();
    return super.totalBalanceVisible;
  }

  @override
  set totalBalanceVisible(bool value) {
    _$totalBalanceVisibleAtom.reportWrite(value, super.totalBalanceVisible, () {
      super.totalBalanceVisible = value;
    });
  }

  late final _$loadSettingsAsyncAction =
      AsyncAction('_SettingsStore.loadSettings', context: context);

  @override
  Future<void> loadSettings() {
    return _$loadSettingsAsyncAction.run(() => super.loadSettings());
  }

  late final _$setTotalBalanceVisibleAsyncAction =
      AsyncAction('_SettingsStore.setTotalBalanceVisible', context: context);

  @override
  Future<void> setTotalBalanceVisible(bool value) {
    return _$setTotalBalanceVisibleAsyncAction
        .run(() => super.setTotalBalanceVisible(value));
  }

  late final _$setBiometricsAsyncAction =
      AsyncAction('_SettingsStore.setBiometrics', context: context);

  @override
  Future<void> setBiometrics(bool value) {
    return _$setBiometricsAsyncAction.run(() => super.setBiometrics(value));
  }

  late final _$setTOTPKeyAsyncAction =
      AsyncAction('_SettingsStore.setTOTPKey', context: context);

  @override
  Future<void> setTOTPKey(String key) {
    return _$setTOTPKeyAsyncAction.run(() => super.setTOTPKey(key));
  }

  late final _$clearTOTPKeyAsyncAction =
      AsyncAction('_SettingsStore.clearTOTPKey', context: context);

  @override
  Future<void> clearTOTPKey() {
    return _$clearTOTPKeyAsyncAction.run(() => super.clearTOTPKey());
  }

  late final _$setAutoLockTimeoutAsyncAction =
      AsyncAction('_SettingsStore.setAutoLockTimeout', context: context);

  @override
  Future<void> setAutoLockTimeout(int value) {
    return _$setAutoLockTimeoutAsyncAction
        .run(() => super.setAutoLockTimeout(value));
  }

  @override
  String toString() {
    return '''
cmdUtilsAvailable: ${cmdUtilsAvailable},
settings: ${settings},
totalBalanceVisible: ${totalBalanceVisible}
    ''';
  }
}
