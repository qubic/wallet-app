// ignore_for_file: library_private_types_in_public_api

// ignore: depend_on_referenced_packages

import 'package:collection/collection.dart';
import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/current_balance_dto.dart';
import 'package:qubic_wallet/dtos/market_info_dto.dart';
import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/models/qubic_id.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/models/transaction_filter.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/resources/apis/archive/qubic_archive_api.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';

part 'application_store.g.dart';

// flutter pub run build_runner watch --delete-conflicting-outputs

class ApplicationStore = _ApplicationStore with _$ApplicationStore;

abstract class _ApplicationStore with Store {
  late final SecureStorage secureStorage = getIt<SecureStorage>();
  late final HiveStorage _hiveStorage = getIt<HiveStorage>();
  late final QubicArchiveApi qubicArchiveApi = getIt<QubicArchiveApi>();

  /// If there are stored wallet settings in the device
  @observable
  bool hasStoredWalletSettings = false;

  /// Holds a global error to be shown in snackbar
  @observable
  String globalError = "";

  /// Holds a global notification to be shown in snackbar
  @observable
  String globalNotification = "";

  /// Current tick
  @observable
  int currentTick = 0;

  /// Is the user signed in
  @observable
  bool isSignedIn = false;

  @observable
  int currentTabIndex = 0;

  @observable
  Uri? currentInboundUri;

  @action
  void setCurrentInboundUrl(Uri? uri) {
    currentInboundUri = uri;
  }

  @observable
  late AccountSortMode accountsSortingMode =
      _hiveStorage.getAccountsSortingMode() ?? AccountSortMode.creationOrder;

  @action
  void setAccountsSortingMode(AccountSortMode mode) {
    if (accountsSortingMode == mode) return;
    accountsSortingMode = mode;
    _hiveStorage.setAccountsSortingMode(mode);
    sortAccounts();
  }

  void initStoredAccountsIfAbsent() {
    if (_hiveStorage.getAccountsSortingMode() == null &&
        currentQubicIDs.isNotEmpty) {
      appLogger.i('Setting accounts by creation order');
      _hiveStorage.setAccounts(currentQubicIDs);
      _hiveStorage.setAccountsSortingMode(AccountSortMode.creationOrder);
    }
  }

  @action
  void sortAccounts() {
    if (accountsSortingMode == AccountSortMode.name) {
      currentQubicIDs.sort((a, b) => a.name.compareTo(b.name));
    } else if (accountsSortingMode == AccountSortMode.balance) {
      currentQubicIDs.sort((b, a) => (a.amount ?? 0).compareTo(b.amount ?? 0));
    } else {
      //Arrange currentQubicIDs based on the accountsSorted
      final accountsSorted = _hiveStorage.getAccounts();
      currentQubicIDs.sort((a, b) {
        final aIndex =
            accountsSorted.indexWhere((acc) => acc.publicId == a.publicId);
        final bIndex =
            accountsSorted.indexWhere((acc) => acc.publicId == b.publicId);
        return aIndex.compareTo(bIndex);
      });
    }
  }

// Add an action to update the tab index
  @action
  void setCurrentTabIndex(int index) {
    currentTabIndex = index;
  }

  // Observable to trigger the Add Account ModalBottomSheet
  @observable
  bool showAddAccountModal = false;

// Action to toggle the Add Account signal
  @action
  void triggerAddAccountModal() {
    showAddAccountModal = true;
  }

// Action to clear the Add Account signal after the modal is shown
  @action
  void clearAddAccountModal() {
    showAddAccountModal = false;
  }

  @observable
  ObservableList<QubicListVm> currentQubicIDs = ObservableList<QubicListVm>();
  @observable
  ObservableList<TransactionVm> currentTransactions =
      ObservableList<TransactionVm>();
  ObservableList<TransactionVm> storedTransactions =
      ObservableList<TransactionVm>();
  @observable
  TransactionFilter? transactionFilter = TransactionFilter();

  List<String> get qubicIDsNames => currentQubicIDs.map((e) => e.name).toList();

  @observable
  int pendingRequests = 0; //The number of pending HTTP requests

  @computed
  int get totalAmounts {
    return currentQubicIDs
        .where((qubic) => !qubic.watchOnly)
        .fold<int>(0, (sum, qubic) => sum + (qubic.amount ?? 0));
  }

  @computed
  double get totalAmountsInUSD {
    if (marketInfo == null) return -1;
    return currentQubicIDs.where((qubic) => !qubic.watchOnly).fold<double>(
        0,
        (sum, qubic) =>
            sum + (qubic.amount ?? 0) * marketInfo!.price!.toDouble());
  }

  //The market info for $QUBIC
  @observable
  MarketInfoDto? marketInfo;

  @computed
  List<QubicAssetDto> get totalShares {
    List<QubicAssetDto> shares = [];
    List<QubicAssetDto> tokens = [];
    currentQubicIDs.where((qubic) => !qubic.watchOnly).forEach((id) {
      id.assets.forEach((key, asset) {
        QubicAssetDto temp = asset;

        if (asset.isSmartContractShare) {
          int index = shares.indexWhere(
              (element) => element.issuedAsset.name == asset.issuedAsset.name);
          if (index != -1) {
            shares[index].numberOfUnits =
                shares[index].numberOfUnits + temp.numberOfUnits;
          } else {
            shares.add(temp);
          }
        } else {
          int index = tokens.indexWhere(
              (element) => element.issuedAsset.name == asset.issuedAsset.name);
          if (index != -1) {
            tokens[index].numberOfUnits =
                tokens[index].numberOfUnits + temp.numberOfUnits;
          } else {
            tokens.add(temp);
          }
        }
      });
    });

    List<QubicAssetDto> result = [];
    result.addAll(shares);
    result.addAll(tokens);

    return result;
    //Get all shares
  }

  @action
  void reportGlobalError(String error) {
    globalError = "$error~${DateTime.now()}";
    //Show a snackbar
  }

  @action
  void clearGlobalError() {
    globalError = "";
  }

  @action
  void reportGlobalNotification(String notificationText) {
    globalNotification = "$notificationText~${DateTime.now()}";
  }

  @action
  void incrementPendingRequests() {
    pendingRequests++;
  }

  @action
  void decreasePendingRequests() {
    pendingRequests--;
  }

  @action
  void resetPendingRequests() {
    pendingRequests = 0;
  }

  @action
  setMarketInfo(MarketInfoDto newInfo) {
    marketInfo = newInfo;
  }

  /// Gets the stored seed by a public Id
  Future<String> getSeedByPublicId(String publicId) async {
    var result = await secureStorage.getIdByPublicKey(publicId);
    return result.getPrivateSeed();
  }

  @action
  setTransactionFilters(String? qubicId, ComputedTransactionStatus? status,
      TransactionDirection? direction) {
    transactionFilter = TransactionFilter(
        qubicId: qubicId, status: status, direction: direction);
  }

  @action
  clearTransactionFilters() {
    transactionFilter = TransactionFilter();
  }

  @action
  Future<void> biometricSignIn() async {
    try {
      isSignedIn = true;
      final results = await secureStorage.getWalletContents();
      currentQubicIDs = ObservableList.of(results);
    } catch (e) {
      isSignedIn = false;
    }
  }

  QubicListVm? findAccountById(String? publicId) {
    return currentQubicIDs
        .firstWhereOrNull((element) => element.publicId == publicId);
  }

  /// Checks if the wallet is initialized (contains password stored in secure storage)
  /// updates hasStoredWalletSettings
  @action
  Future<void> checkWalletIsInitialized() async {
    try {
      final result = await secureStorage.criticalSettingsExist();
      hasStoredWalletSettings = result;
    } catch (e) {
      hasStoredWalletSettings = false;
    }
  }

  @action
  Future<bool> signIn(String password) async {
    try {
      final result = await secureStorage.signInWallet(password);
      isSignedIn = result;

      //Populate the list
      final results = await secureStorage.getWalletContents();
      currentQubicIDs = ObservableList.of(results);
      return result;
    } catch (e) {
      isSignedIn = false;
      return false;
    }
  }

  @action
  Future<bool> signUp(String password) async {
    try {
      final result = await secureStorage.createWallet(password);
      await _hiveStorage.initEncryptedBoxes();
      isSignedIn = result;
      currentQubicIDs = ObservableList<QubicListVm>();
      appLogger.d('[QubicWallet] Signed up');
      return isSignedIn;
    } catch (e) {
      reportGlobalError(e.toString());
      return false;
    }
  }

  @action
  signOut() async {
    isSignedIn = false;
    transactionFilter = TransactionFilter();
    currentQubicIDs = ObservableList<QubicListVm>();
    currentTransactions = ObservableList<TransactionVm>();
  }

  @action
  Future<void> addManyIds(List<QubicId> ids) async {
    await secureStorage.addManyIds(ids);
    for (var element in ids) {
      currentQubicIDs.add(QubicListVm(element.getPublicId(), element.getName(),
          null, null, null, element.getPrivateSeed() == '' ? true : false));
    }
    initStoredAccountsIfAbsent();
  }

  @action
  Future<void> addId(String name, String publicId, String privateSeed) async {
    await secureStorage.addID(QubicId(privateSeed, publicId, name, null));
    currentQubicIDs.add(QubicListVm(
        publicId, name, null, null, null, privateSeed == '' ? true : false));
    // Add to stored by creation order accounts
    _hiveStorage.addAccount(QubicListVm(
        publicId, name, null, null, null, privateSeed == '' ? true : false));
    sortAccounts();
  }

  Future<String> getSeedById(String publicId) async {
    var result = await secureStorage.getIdByPublicKey(publicId);
    return result.getPrivateSeed();
  }

  @action
  Future<void> setName(String publicId, String name) async {
    for (var i = 0; i < currentQubicIDs.length; i++) {
      if (currentQubicIDs[i].publicId == publicId) {
        var item = QubicListVm.clone(currentQubicIDs[i]);
        item.name = name;
        currentQubicIDs[i] = item;
        await secureStorage.renameId(publicId, name);
        return;
      }
    }
    // Rename stored by creation order accounts
    _hiveStorage.renameAccount(publicId, name);
  }

  @action
  Future<void> setBalancesAndAssets(
      List<CurrentBalanceDto> balances, List<QubicAssetDto> assets) async {
    for (var i = 0; i < currentQubicIDs.length; i++) {
      CurrentBalanceDto? balance =
          balances.firstWhereOrNull((e) => e.id == currentQubicIDs[i].publicId);
      List<QubicAssetDto> newAssets = assets
          .where((e) => e.ownerIdentity == currentQubicIDs[i].publicId)
          .toList();

      if ((newAssets.isNotEmpty) || (balance != null)) {
        var item = QubicListVm.clone(currentQubicIDs[i]);

        if (newAssets.isNotEmpty) {
          item.setAssets(newAssets);
        }
        if (balance != null) {
          if ((item.amountTick == null) ||
              (item.amountTick! < balance.validForTick)) {
            item.amountTick = balance.validForTick;
            item.amount = balance.balance;
          }
        }

        currentQubicIDs[i] = item;
      }
    }
    ObservableList<QubicListVm> newList = ObservableList<QubicListVm>();
    newList.addAll(currentQubicIDs);
    currentQubicIDs = newList;
  }

  @action

  /// Sets the $QUBIC amount for an account
  /// Returns the  IDs whose amounts have changed <PublicID, newAmount>
  Map<String, int> setAmounts(List<CurrentBalanceDto> amounts) {
    Map<String, int> changedIds = {};

    for (var i = 0; i < currentQubicIDs.length; i++) {
      List<CurrentBalanceDto> amountsForID =
          amounts.where((e) => e.id == currentQubicIDs[i].publicId).toList();
      for (var j = 0; j < amountsForID.length; j++) {
        if (currentQubicIDs[i].publicId == amountsForID[j].id) {
          var item = QubicListVm.clone(currentQubicIDs[i]);

          //Add the ID that has changed to the list
          if ((item.amount != amountsForID[j].balance) &&
              (changedIds.containsKey(item.publicId) == false)) {
            changedIds[item.publicId] = amountsForID[j].balance;
          }
          item.amount = amountsForID[j].balance;

          currentQubicIDs[i] = item;
        }
      }
      //Update the whole currentQubicIDs array
      ObservableList<QubicListVm> newList = ObservableList<QubicListVm>();
      newList.addAll(currentQubicIDs);
      currentQubicIDs = newList;
    }
    return changedIds;
  }

  /// Sets the Assets for an account
  /// Returns the list of IDs whose assets have changed
  /// as <PublicID, [QubicAssetDto]>
  Map<String, List<QubicAssetDto>> setAssets(
      List<QubicAssetDto> assetsForAllIDs) {
    Map<String, List<QubicAssetDto>> changedIds = {};

    for (var i = 0; i < currentQubicIDs.length; i++) {
      List<QubicAssetDto> assetsForID = assetsForAllIDs
          .where((e) => e.ownerIdentity == currentQubicIDs[i].publicId)
          .toList();
      for (var j = 0; j < assetsForID.length; j++) {
        if (assetsForID[j].ownerIdentity == currentQubicIDs[i].publicId) {
          // Detect changes start
          var assetInfo = currentQubicIDs[i]
              .assets
              .values
              .where((el) =>
                  el.issuedAsset.name == assetsForID[j].issuedAsset.name &&
                  el.managingContractIndex ==
                      assetsForID[j].managingContractIndex &&
                  el.issuedAsset.issuerIdentity ==
                      assetsForID[j].issuedAsset.issuerIdentity)
              .firstOrNull;
          if (assetInfo != null) {
            if (assetInfo.numberOfUnits != assetsForID[j].numberOfUnits) {
              if (changedIds.containsKey(currentQubicIDs[i].publicId) ==
                  false) {
                changedIds[currentQubicIDs[i].publicId] = [];
              }
              changedIds[currentQubicIDs[i].publicId]!.add(assetsForID[j]);
            }
          }
          //Detect changes end

          var item = QubicListVm.clone(currentQubicIDs[i]);
          item.setAssets(assetsForID);
          currentQubicIDs[i] = item;
        }
      }
    }
    ObservableList<QubicListVm> newList = ObservableList<QubicListVm>();
    newList.addAll(currentQubicIDs);
    currentQubicIDs = newList;

    return changedIds;
  }

  @action
  initStoredTransactions() {
    storedTransactions.clear();
    storedTransactions.addAll(_hiveStorage.getStoredTransactions());
  }

  List<TransactionVm> getStoredTransactionsForID(String publicId) {
    return storedTransactions
        .where((element) =>
            element.sourceId == publicId || element.destId == publicId)
        .toList();
  }

  @action
  addStoredTransaction(TransactionVm transaction) {
    storedTransactions.add(transaction);
    _hiveStorage.addStoredTransaction(transaction);
  }

  @action
  Future<void> validatePendingTransactions(int latestTickProcessed) async {
    List<TransactionVm> toBeRemoved = [];
    for (var trx in _hiveStorage.getStoredTransactions()) {
      if (latestTickProcessed >= trx.targetTick) {
        final checkTrx = await qubicArchiveApi.getTransaction(trx.id);
        if (checkTrx == null) {
          convertPendingToInvalid(trx);
        } else {
          toBeRemoved.add(trx);
        }
      }
      for (var trx in toBeRemoved) {
        removeStoredTransaction(trx.id);
      }
    }
  }

  @action
  convertPendingToInvalid(TransactionVm transaction) {
    transaction.isPending = false;
    storedTransactions.removeWhere((element) => element.id == transaction.id);
    storedTransactions.add(transaction);
    _hiveStorage.addStoredTransaction(transaction);
  }

  int getQubicIDsWithPublicId(String publicId) {
    return currentQubicIDs
        .where((element) => element.publicId == publicId.replaceAll(",", "_"))
        .length;
  }

  @action
  void removeStoredTransaction(String transactionId) {
    _hiveStorage.removeStoredTransaction(transactionId);
    storedTransactions.removeWhere((element) => element.id == transactionId);
  }

  @action
  Future<void> removeID(String publicId) async {
    await secureStorage.removeID(publicId);
    currentQubicIDs.removeWhere(
        (element) => element.publicId == publicId.replaceAll(",", "_"));
    //Remove all from transactions which contain this qubicId and no other wallet ids

    currentTransactions.removeWhere((element) =>
        element.destId == publicId.replaceAll(",", "_") &&
        currentQubicIDs.any(
                (el) => el.publicId == element.sourceId.replaceAll(",", "_")) ==
            false);

    currentTransactions.removeWhere((element) =>
        element.sourceId == publicId.replaceAll(",", "_") &&
        currentQubicIDs.any(
                (el) => el.publicId == element.destId.replaceAll(",", "_")) ==
            false);
    // Remove from stored by creation order accounts
    _hiveStorage.deleteAccount(publicId);
  }
}

enum AccountSortMode {
  creationOrder,
  name,
  balance,
}
