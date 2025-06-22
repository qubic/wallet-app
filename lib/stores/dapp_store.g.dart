// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dapp_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DappStore on _DappStore, Store {
  Computed<List<DappDto>>? _$allDappsComputed;

  @override
  List<DappDto> get allDapps =>
      (_$allDappsComputed ??= Computed<List<DappDto>>(() => super.allDapps,
              name: '_DappStore.allDapps'))
          .value;
  Computed<List<DappDto>>? _$topDappsComputed;

  @override
  List<DappDto> get topDapps =>
      (_$topDappsComputed ??= Computed<List<DappDto>>(() => super.topDapps,
              name: '_DappStore.topDapps'))
          .value;
  Computed<DappDto?>? _$featuredDappComputed;

  @override
  DappDto? get featuredDapp =>
      (_$featuredDappComputed ??= Computed<DappDto?>(() => super.featuredDapp,
              name: '_DappStore.featuredDapp'))
          .value;
  Computed<List<DappDto>>? _$popularDappsComputed;

  @override
  List<DappDto> get popularDapps => (_$popularDappsComputed ??=
          Computed<List<DappDto>>(() => super.popularDapps,
              name: '_DappStore.popularDapps'))
      .value;

  late final _$dappsResponseAtom =
      Atom(name: '_DappStore.dappsResponse', context: context);

  @override
  DappsResponse? get dappsResponse {
    _$dappsResponseAtom.reportRead();
    return super.dappsResponse;
  }

  @override
  set dappsResponse(DappsResponse? value) {
    _$dappsResponseAtom.reportWrite(value, super.dappsResponse, () {
      super.dappsResponse = value;
    });
  }

  late final _$errorAtom = Atom(name: '_DappStore.error', context: context);

  @override
  String? get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(String? value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_DappStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$loadDappsAsyncAction =
      AsyncAction('_DappStore.loadDapps', context: context);

  @override
  Future<void> loadDapps() {
    return _$loadDappsAsyncAction.run(() => super.loadDapps());
  }

  @override
  String toString() {
    return '''
dappsResponse: ${dappsResponse},
error: ${error},
isLoading: ${isLoading},
allDapps: ${allDapps},
topDapps: ${topDapps},
featuredDapp: ${featuredDapp},
popularDapps: ${popularDapps}
    ''';
  }
}
