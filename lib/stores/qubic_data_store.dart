import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/models/labeled_address_model.dart';
import 'package:qubic_wallet/models/token_response.dart';
import 'package:qubic_wallet/resources/apis/archive/qubic_archive_api.dart';
import 'package:qubic_wallet/resources/apis/qubic_helpers_api.dart';
import 'package:qubic_wallet/smart_contracts/sc_info.dart';

part 'qubic_data_store.g.dart';

class QubicDataStore = QubicDataStoreBase with _$QubicDataStore;

abstract class QubicDataStoreBase with Store {
  final QubicHelpersApi _qubicHelpersApi = getIt<QubicHelpersApi>();
  final QubicArchiveApi _qubicArchiveApi = getIt<QubicArchiveApi>();

  @observable
  List<QubicSCModel> smartContracts = [];

  @observable
  List<TokenModel> tokens = [];

  @observable
  List<LabeledAddressModel> labeledAddresses = [];

  @computed
  Map<String, QubicSCModel> get _byId => {
        for (var sc in smartContracts) sc.contractId: sc,
      };

  @computed
  Map<String, TokenModel> get _tokensById => {
        for (var token in tokens) token.issuerIdentity: token,
      };

  @computed
  Map<String, LabeledAddressModel> get _labeledAddressesById => {
        for (var addr in labeledAddresses) addr.address: addr,
      };

  String? fromContractId(String id) => _byId[id]?.name;

  bool isSC(String id) => _byId.containsKey(id);

  String? getProcedureName(String contractId, int type) {
    return _byId[contractId]?.getProcedureName(type);
  }

  String? fromTokenId(String id) => _tokensById[id]?.name;

  bool isToken(String id) => _tokensById.containsKey(id);

  String? fromLabeledAddressId(String id) => _labeledAddressesById[id]?.label;

  bool isLabeledAddress(String id) => _labeledAddressesById.containsKey(id);

  /// Returns the label/name for an address if it's a known entity (smart contract, token, or labeled address).
  /// Returns null if the address is not recognized.
  /// Priority: Smart Contract > Token > Labeled Address
  String? getLabel(String id) {
    return fromContractId(id) ?? fromTokenId(id) ?? fromLabeledAddressId(id);
  }

  bool isKnownEntity(String id) {
    return isSC(id) || isToken(id) || isLabeledAddress(id);
  }

  @action
  Future<void> loadSmartContracts() async {
    try {
      final response = await _qubicHelpersApi.getSmartContracts();

      smartContracts = response.smartContracts
          .map((dto) => QubicSCModel.fromDto(dto))
          .toList();
      appLogger
          .i("Successfully loaded ${smartContracts.length} smart contracts");
    } catch (e) {
      appLogger.e("Failed to load smart contracts from API: ${e.toString()}");
      getIt<GlobalSnackBar>().showError(e.toString());
    }
  }

  @action
  Future<void> loadTokens() async {
    try {
      final response = await _qubicArchiveApi.getTokens();

      tokens = response.assets;
      appLogger.i("Successfully loaded ${tokens.length} tokens");
    } catch (e) {
      appLogger.e("Failed to load tokens from API: ${e.toString()}");
      getIt<GlobalSnackBar>().showError(e.toString());
    }
  }

  @action
  Future<void> loadLabeledAddresses() async {
    try {
      final response = await _qubicHelpersApi.getLabeledAddresses();

      labeledAddresses = response.addressLabels;
      appLogger.i(
          "Successfully loaded ${labeledAddresses.length} labeled addresses");
    } catch (e) {
      appLogger.e("Failed to load labeled addresses from API: ${e.toString()}");
      getIt<GlobalSnackBar>().showError(e.toString());
    }
  }

  Future<void> refreshIfAbsent() async {
    if (smartContracts.isEmpty) {
      await loadSmartContracts();
    }
    if (tokens.isEmpty) {
      await loadTokens();
    }
    if (labeledAddresses.isEmpty) {
      await loadLabeledAddresses();
    }
  }
}
