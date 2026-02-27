import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/models/network_model.dart';
import 'package:qubic_wallet/resources/apis/archive/qubic_archive_api.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:qubic_wallet/resources/apis/stats/qubic_stats_api.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';
import 'package:qubic_wallet/stores/wallet_content_store.dart';

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

  void _refreshServices() {
    getIt<QubicArchiveApi>().updateDio();
    getIt<QubicLiveApi>().updateDio();
    getIt<QubicStatsApi>().updateDio();
    try {
      getIt<WalletContentStore>()
          .allDapps
          .firstWhere((e) => e.id == "explorer_app_id")
          .url = currentNetwork.explorerUrl;
    } catch (_) {
      // Explorer dapp may not be loaded yet
    }
  }

  void _sortNetworksByName() {
    networks
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @action
  void setCurrentNetwork(NetworkModel network) {
    _sortNetworksByName();
    networks.remove(network);
    networks.insert(0, network);
    getIt<HiveStorage>().saveCurrentNetworkName(network.name);
    _refreshServices();
  }

  @action
  void addNetwork(NetworkModel network) {
    networks.add(network);
    _sortNetworksByName();
    getIt<HiveStorage>().addStoredNetwork(network);
  }

  @action
  void removeNetwork(NetworkModel network) {
    networks.remove(network);
    getIt<HiveStorage>().removeStoredNetwork(network.name);
  }

  @action
  void updateNetwork(NetworkModel oldNetwork, NetworkModel updatedNetwork) {
    final index = networks.indexOf(oldNetwork);
    if (index != -1) {
      final wasCurrent = index == 0;
      networks[index] = updatedNetwork;
      _sortNetworksByName();

      // If it was the current network, keep it at position 0 and refresh services
      if (wasCurrent) {
        networks.remove(updatedNetwork);
        networks.insert(0, updatedNetwork);
        getIt<HiveStorage>().saveCurrentNetworkName(updatedNetwork.name);
        _refreshServices();
      }

      getIt<HiveStorage>()
          .updateStoredNetwork(oldNetwork.name, updatedNetwork);
    }
  }
}
