import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/resources/apis/qubic_helpers_api.dart';
import 'package:qubic_wallet/smart_contracts/sc_info.dart';

part 'smart_contract_store.g.dart';

class SmartContractStore = SmartContractStoreBase with _$SmartContractStore;

abstract class SmartContractStoreBase with Store {
  final QubicHelpersApi _qubicHelpersApi = getIt<QubicHelpersApi>();

  @observable
  List<QubicSCModel> contracts = [];

  @observable
  String? error;

  @observable
  bool isLoading = false;

  @computed
  Map<String, QubicSCModel> get _byId => {
        for (var sc in contracts) sc.contractId: sc,
      };

  @computed
  bool get hasData => contracts.isNotEmpty;

  String? fromContractId(String id) => _byId[id]?.name;

  bool isSC(String id) => _byId.containsKey(id);

  String? getProcedureName(String contractId, int type) {
    return _byId[contractId]?.getProcedureName(type);
  }

  @action
  Future<void> loadSmartContracts() async {
    try {
      isLoading = true;
      error = null;

      final response = await _qubicHelpersApi.getSmartContracts();

      contracts = response.smartContracts
          .map((dto) => QubicSCModel.fromDto(dto))
          .toList();

      appLogger.d("Successfully loaded ${contracts.length} smart contracts");
    } catch (e) {
      appLogger.e("Failed to load smart contracts from API: $e");
      error = e.toString();
      appLogger.d("Falling back to static smart contracts data");
      contracts = QubicSCStore.contracts;
    } finally {
      isLoading = false;
    }
  }
}
