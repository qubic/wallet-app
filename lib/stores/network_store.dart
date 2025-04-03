import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/models/dapp_model.dart';
import 'package:qubic_wallet/models/network_model.dart';
import 'package:qubic_wallet/resources/apis/archive/qubic_archive_api.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:qubic_wallet/resources/apis/stats/qubic_stats_api.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';

part 'network_store.g.dart';

// ignore: library_private_types_in_public_api
class NetworkStore = _NetworkStore with _$NetworkStore;

abstract class _NetworkStore with Store {
  List<NetworkModel> defaultNetworks = const [
    NetworkModel(
        name: Config.networkQubicMainnet,
        rpcUrl: Config.qubicMainnetRpcDomain,
        explorerUrl: Config.URL_WebExplorer),
    NetworkModel(
        name: "Qubic Testnet",
        rpcUrl: "https://testnet-rpc.qubic.org",
        explorerUrl: "https://testnet.explorer.qubic.org"),
  ];

  @observable
  late ObservableList<NetworkModel> networks = defaultNetworks.asObservable();

  @computed
  NetworkModel get currentNetwork => networks.first;

  String get rpcUrl => currentNetwork.rpcUrl;
  String get explorerUrl => currentNetwork.explorerUrl;

  initNetworks() {
    initStoredNetworks();
    initCurrentNetwork();
  }

  @action
  void initStoredNetworks() {
    final List<NetworkModel> storedNetworks =
        getIt<HiveStorage>().getStoredNetworks();
    networks.addAll(storedNetworks);
    networks
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @action
  initCurrentNetwork() {
    final String? savedNetworkName =
        getIt<HiveStorage>().getCurrentNetworkName();
    if (savedNetworkName != null) {
      final networkToSelect = networks.firstWhere(
          (network) => network.name == savedNetworkName,
          orElse: () => defaultNetworks.first);
      setCurrentNetwork(networkToSelect);
    }
  }

  @action
  void setCurrentNetwork(NetworkModel network) {
    networks.remove(network);
    networks.insert(0, network);
    getIt<QubicArchiveApi>().updateDio();
    getIt<QubicLiveApi>().updateDio();
    getIt<QubicStatsApi>().updateDio();
    getIt<HiveStorage>().saveCurrentNetworkName(network.name);
    explorerApp.value = explorerApp.value.copyWith(url: network.explorerUrl);
  }

  @action
  void addNetwork(NetworkModel network) {
    networks.add(network);
    getIt<HiveStorage>().addStoredNetwork(network);
  }

  @action
  void removeNetwork(NetworkModel network) {
    networks.remove(network);
    getIt<HiveStorage>().removeStoredNetwork(network.name);
  }
}
