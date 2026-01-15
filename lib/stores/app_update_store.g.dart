// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AppUpdateStore on _AppUpdateStore, Store {
  Computed<AppVersionCheckModel?>? _$currentVersionInfoComputed;

  @override
  AppVersionCheckModel? get currentVersionInfo =>
      (_$currentVersionInfoComputed ??= Computed<AppVersionCheckModel?>(
              () => super.currentVersionInfo,
              name: '_AppUpdateStore.currentVersionInfo'))
          .value;

  late final _$_versionInfoAtom =
      Atom(name: '_AppUpdateStore._versionInfo', context: context);

  @override
  AppVersionCheckModel? get _versionInfo {
    _$_versionInfoAtom.reportRead();
    return super._versionInfo;
  }

  @override
  set _versionInfo(AppVersionCheckModel? value) {
    _$_versionInfoAtom.reportWrite(value, super._versionInfo, () {
      super._versionInfo = value;
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
currentVersionInfo: ${currentVersionInfo}
    ''';
  }
}
