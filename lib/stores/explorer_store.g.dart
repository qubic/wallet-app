// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explorer_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ExplorerStore on _ExplorerStore, Store {
  late final _$networkOverviewAtom =
      Atom(name: '_ExplorerStore.networkOverview', context: context);

  @override
  MarketInfoDto? get networkOverview {
    _$networkOverviewAtom.reportRead();
    return super.networkOverview;
  }

  @override
  set networkOverview(MarketInfoDto? value) {
    _$networkOverviewAtom.reportWrite(value, super.networkOverview, () {
      super.networkOverview = value;
    });
  }

  late final _$networkTicksAtom =
      Atom(name: '_ExplorerStore.networkTicks', context: context);

  @override
  NetworkTicksDto? get networkTicks {
    _$networkTicksAtom.reportRead();
    return super.networkTicks;
  }

  @override
  set networkTicks(NetworkTicksDto? value) {
    _$networkTicksAtom.reportWrite(value, super.networkTicks, () {
      super.networkTicks = value;
    });
  }

  late final _$pageNumberAtom =
      Atom(name: '_ExplorerStore.pageNumber', context: context);

  @override
  int get pageNumber {
    _$pageNumberAtom.reportRead();
    return super.pageNumber;
  }

  @override
  set pageNumber(int value) {
    _$pageNumberAtom.reportWrite(value, super.pageNumber, () {
      super.pageNumber = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ExplorerStore.isLoading', context: context);

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

  late final _$_ExplorerStoreActionController =
      ActionController(name: '_ExplorerStore', context: context);

  @override
  void setLoading(bool value) {
    final _$actionInfo = _$_ExplorerStoreActionController.startAction(
        name: '_ExplorerStore.setLoading');
    try {
      return super.setLoading(value);
    } finally {
      _$_ExplorerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTicks(NetworkTicksDto newTicks) {
    final _$actionInfo = _$_ExplorerStoreActionController.startAction(
        name: '_ExplorerStore.setTicks');
    try {
      return super.setTicks(newTicks);
    } finally {
      _$_ExplorerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setPageNumber(int newPageNumber) {
    final _$actionInfo = _$_ExplorerStoreActionController.startAction(
        name: '_ExplorerStore.setPageNumber');
    try {
      return super.setPageNumber(newPageNumber);
    } finally {
      _$_ExplorerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNetworkOverview(MarketInfoDto newOverview) {
    final _$actionInfo = _$_ExplorerStoreActionController.startAction(
        name: '_ExplorerStore.setNetworkOverview');
    try {
      return super.setNetworkOverview(newOverview);
    } finally {
      _$_ExplorerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearNetworkOverview() {
    final _$actionInfo = _$_ExplorerStoreActionController.startAction(
        name: '_ExplorerStore.clearNetworkOverview');
    try {
      return super.clearNetworkOverview();
    } finally {
      _$_ExplorerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
networkOverview: ${networkOverview},
networkTicks: ${networkTicks},
pageNumber: ${pageNumber},
isLoading: ${isLoading}
    ''';
  }
}
