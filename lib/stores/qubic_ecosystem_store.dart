import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/models/labeled_address_model.dart';
import 'package:qubic_wallet/models/smart_contracts_response.dart';
import 'package:qubic_wallet/models/token_response.dart';
import 'package:qubic_wallet/resources/apis/archive/qubic_archive_api.dart';
import 'package:qubic_wallet/resources/apis/static/qubic_static_api.dart';

part 'qubic_ecosystem_store.g.dart';

/// MobX store for Qubic ecosystem-wide reference data.
///
/// **Data Scope:**
/// Manages shared, ecosystem-wide data from `/general/data/` APIs that is
/// common across all Qubic applications (wallets, explorers, tools):
/// - Smart contracts and their procedures
/// - Tokens (Qubic assets)
/// - Labeled addresses (known entities)
///
/// **vs WalletContentStore:**
/// - QubicEcosystemStore = Ecosystem reference data (used by any Qubic app)
/// - WalletContentStore = Wallet-specific content (dapps, terms, privacy)
///
/// **Architecture:**
/// This store combines state management and data fetching. For simple static
/// reference data, extracting a repository layer is unnecessary. If future
/// requirements demand caching, retry logic, or offline support, consider
/// separating data fetching into repository classes.
class QubicEcosystemStore = QubicEcosystemStoreBase with _$QubicEcosystemStore;

abstract class QubicEcosystemStoreBase with Store {
  final QubicStaticApi _staticApi = getIt<QubicStaticApi>();
  final QubicArchiveApi _archiveApi = getIt<QubicArchiveApi>();

  @observable
  List<SmartContractModel> smartContracts = [];

  @observable
  List<TokenModel> tokens = [];

  @observable
  List<LabeledAddressModel> labeledAddresses = [];

  @computed
  Map<String, SmartContractModel> get _byId => {
        for (var sc in smartContracts) sc.address: sc,
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

  String? getProcedureName(String contractId, int type) {
    return _byId[contractId]?.getProcedureName(type);
  }

  String? fromTokenId(String id) => _tokensById[id]?.name;

  String? fromLabeledAddressId(String id) => _labeledAddressesById[id]?.label;

  /// Returns the label/name for an address if it's a known entity (smart contract, token, or labeled address).
  /// Returns null if the address is not recognized.
  /// Priority: Smart Contract > Token > Labeled Address
  String? getLabel(String id) {
    return fromContractId(id) ?? fromTokenId(id) ?? fromLabeledAddressId(id);
  }

  @action
  Future<void> loadSmartContracts() async {
    try {
      final response = await _staticApi.getSmartContracts();

      smartContracts = response.smartContracts;
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
      final response = await _archiveApi.getTokens();

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
      final response = await _staticApi.getLabeledAddresses();

      labeledAddresses = response.addressLabels;
      appLogger.i(
          "Successfully loaded ${labeledAddresses.length} labeled addresses");
    } catch (e) {
      appLogger.e("Failed to load labeled addresses from API: ${e.toString()}");
      getIt<GlobalSnackBar>().showError(e.toString());
    }
  }

  Future<void> loadAllData() async {
    loadSmartContracts();
    loadTokens();
    loadLabeledAddresses();
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
