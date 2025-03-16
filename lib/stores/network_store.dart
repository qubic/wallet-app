import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/models/network_model.dart';
import 'package:qubic_wallet/resources/apis/archive/qubic_archive_api.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:qubic_wallet/resources/apis/stats/qubic_stats_api.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';

part 'network_store.g.dart';

// ignore: library_private_types_in_public_api
class NetworkStore = _NetworkStore with _$NetworkStore;

abstract class _NetworkStore with Store {
  List<NetworkModel> defaultNetworks = const [
    NetworkModel(
      "Qubic Mainnet",
      Config.qubicMainnetRpcDomain,
      Config.qubicLiDomain,
      //"https://api.qubic.li",
    ),
    //TODO Replace with Testnet domains
    NetworkModel(
      "Qubic Testnet",
      "https://rpc.testnet.qubic.org",
      "https://api.testnet.qubic.li",
    ),
  ];

  @observable
  late ObservableList<NetworkModel> networks = defaultNetworks.asObservable();

  @computed
  NetworkModel get selectedNetwork => networks.first;

  String get rpcUrl => selectedNetwork.rpcUrl;
  String get liUrl => selectedNetwork.liUrl;

  @action
  void setSelectedNetwork(NetworkModel network) {
    networks.remove(network);
    networks.insert(0, network);
    getIt<QubicArchiveApi>().updateDio();
    getIt<QubicLiveApi>().updateDio();
    getIt<QubicStatsApi>().updateDio();
    getIt<QubicLi>().updateDomain();
  }

  @action
  void addNetwork(NetworkModel network) {
    networks.add(network);
  }

  @action
  void removeNetwork(NetworkModel network) {
    networks.remove(network);
  }
}
