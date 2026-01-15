// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AppUpdateStore on _AppUpdateStore, Store {
  Computed<bool>? _$shouldShowUpdateScreenComputed;

  @override
  bool get shouldShowUpdateScreen => (_$shouldShowUpdateScreenComputed ??=
          Computed<bool>(() => super.shouldShowUpdateScreen,
              name: '_AppUpdateStore.shouldShowUpdateScreen'))
      .value;
  Computed<AppVersionCheckModel?>? _$currentVersionInfoComputed;

  @override
  AppVersionCheckModel? get currentVersionInfo =>
      (_$currentVersionInfoComputed ??= Computed<AppVersionCheckModel?>(
              () => super.currentVersionInfo,
              name: '_AppUpdateStore.currentVersionInfo'))
          .value;

  late final _$versionInfoAtom =
      Atom(name: '_AppUpdateStore.versionInfo', context: context);

  @override
  AppVersionCheckModel? get versionInfo {
    _$versionInfoAtom.reportRead();
    return super.versionInfo;
  }

  @override
  set versionInfo(AppVersionCheckModel? value) {
    _$versionInfoAtom.reportWrite(value, super.versionInfo, () {
      super.versionInfo = value;
    });
  }

  late final _$_dismissedForSessionAtom =
      Atom(name: '_AppUpdateStore._dismissedForSession', context: context);

  @override
  bool get _dismissedForSession {
    _$_dismissedForSessionAtom.reportRead();
    return super._dismissedForSession;
  }

  @override
  set _dismissedForSession(bool value) {
    _$_dismissedForSessionAtom.reportWrite(value, super._dismissedForSession,
        () {
      super._dismissedForSession = value;
    });
  }

  late final _$_ignoredVersionAtom =
      Atom(name: '_AppUpdateStore._ignoredVersion', context: context);

  @override
  String? get _ignoredVersion {
    _$_ignoredVersionAtom.reportRead();
    return super._ignoredVersion;
  }

  @override
  set _ignoredVersion(String? value) {
    _$_ignoredVersionAtom.reportWrite(value, super._ignoredVersion, () {
      super._ignoredVersion = value;
    });
  }

  late final _$checkForUpdateAsyncAction =
      AsyncAction('_AppUpdateStore.checkForUpdate', context: context);

  @override
  Future<void> checkForUpdate() {
    return _$checkForUpdateAsyncAction.run(() => super.checkForUpdate());
  }

  late final _$handleIgnoreActionAsyncAction =
      AsyncAction('_AppUpdateStore.handleIgnoreAction', context: context);

  @override
  Future<void> handleIgnoreAction(String version) {
    return _$handleIgnoreActionAsyncAction
        .run(() => super.handleIgnoreAction(version));
  }

  late final _$_AppUpdateStoreActionController =
      ActionController(name: '_AppUpdateStore', context: context);

  @override
  void handleLaterAction() {
    final _$actionInfo = _$_AppUpdateStoreActionController.startAction(
        name: '_AppUpdateStore.handleLaterAction');
    try {
      return super.handleLaterAction();
    } finally {
      _$_AppUpdateStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
versionInfo: ${versionInfo},
shouldShowUpdateScreen: ${shouldShowUpdateScreen},
currentVersionInfo: ${currentVersionInfo}
    ''';
  }
}
