// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NetworkStore on _NetworkStore, Store {
  Computed<NetworkModel>? _$selectedNetworkComputed;

  @override
  NetworkModel get selectedNetwork => (_$selectedNetworkComputed ??=
          Computed<NetworkModel>(() => super.selectedNetwork,
              name: '_NetworkStore.selectedNetwork'))
      .value;

  late final _$networksAtom =
      Atom(name: '_NetworkStore.networks', context: context);

  @override
  ObservableList<NetworkModel> get networks {
    _$networksAtom.reportRead();
    return super.networks;
  }

  bool _networksIsInitialized = false;

  @override
  set networks(ObservableList<NetworkModel> value) {
    _$networksAtom
        .reportWrite(value, _networksIsInitialized ? super.networks : null, () {
      super.networks = value;
      _networksIsInitialized = true;
    });
  }

  late final _$_NetworkStoreActionController =
      ActionController(name: '_NetworkStore', context: context);

  @override
  void setSelectedNetwork(NetworkModel network) {
    final _$actionInfo = _$_NetworkStoreActionController.startAction(
        name: '_NetworkStore.setSelectedNetwork');
    try {
      return super.setSelectedNetwork(network);
    } finally {
      _$_NetworkStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addNetwork(NetworkModel network) {
    final _$actionInfo = _$_NetworkStoreActionController.startAction(
        name: '_NetworkStore.addNetwork');
    try {
      return super.addNetwork(network);
    } finally {
      _$_NetworkStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeNetwork(NetworkModel network) {
    final _$actionInfo = _$_NetworkStoreActionController.startAction(
        name: '_NetworkStore.removeNetwork');
    try {
      return super.removeNetwork(network);
    } finally {
      _$_NetworkStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
networks: ${networks},
selectedNetwork: ${selectedNetwork}
    ''';
  }
}
