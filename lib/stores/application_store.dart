// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/current_balance_dto.dart';
import 'package:qubic_wallet/dtos/market_info_dto.dart';
import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';
import 'package:qubic_wallet/dtos/transaction_dto.dart';
import 'package:qubic_wallet/models/qubic_id.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/models/transaction_filter.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
part 'application_store.g.dart';

// flutter pub run build_runner watch --delete-conflicting-outputs

class ApplicationStore = _ApplicationStore with _$ApplicationStore;

abstract class _ApplicationStore with Store {
  late final SecureStorage secureStorage = getIt<SecureStorage>();

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

  @observable
  TransactionFilter? transactionFilter = TransactionFilter();

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
    return currentQubicIDs.where((qubic) => !qubic.watchOnly).fold<double>(0,
        (sum, qubic) => sum + (qubic.amount ?? 0) * marketInfo!.price!.toDouble());
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
        QubicAssetDto temp = asset.clone();
        temp.ownedAmount ??= 0;

        if (QubicAssetDto.isSmartContractShare(asset)) {
          int index = shares
              .indexWhere((element) => element.assetName == asset.assetName);
          if (index != -1) {
            shares[index].ownedAmount =
                shares[index].ownedAmount! + temp.ownedAmount!;
          } else {
            shares.add(temp);
          }
        } else {
          int index = tokens
              .indexWhere((element) => element.assetName == asset.assetName);
          if (index != -1) {
            tokens[index].ownedAmount =
                tokens[index].ownedAmount! + (asset.ownedAmount ?? 0);
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
    await secureStorage.deleteWallet();
    final result = await secureStorage.createWallet(password);
    isSignedIn = result;
    currentQubicIDs = ObservableList<QubicListVm>();
    return isSignedIn;
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
  }

  @action
  Future<void> addId(String name, String publicId, String privateSeed) async {
    //Todo store in wallet

    await secureStorage.addID(QubicId(privateSeed, publicId, name, null));
    currentQubicIDs.add(QubicListVm(
        publicId, name, null, null, null, privateSeed == '' ? true : false));
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
    } //);
  }

  @action
  Future<void> setBalancesAndAssets(
      List<CurrentBalanceDto> balances, List<QubicAssetDto> assets) async {
    for (var i = 0; i < currentQubicIDs.length; i++) {
      CurrentBalanceDto? balance = balances
          .firstWhereOrNull((e) => e.publicId == currentQubicIDs[i].publicId);
      List<QubicAssetDto> newAssets = assets
          .where((e) => e.publicId == currentQubicIDs[i].publicId)
          .toList();

      if ((newAssets.isNotEmpty) || (balance != null)) {
        var item = QubicListVm.clone(currentQubicIDs[i]);

        if (newAssets.isNotEmpty) {
          item.setAssets(newAssets);
        }
        if (balance != null) {
          if ((item.amountTick == null) || (item.amountTick! < balance.tick)) {
            item.amountTick = balance.tick;
            item.amount = balance.amount;
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
  void setAmounts(List<CurrentBalanceDto> amounts) {
    for (var i = 0; i < currentQubicIDs.length; i++) {
      List<CurrentBalanceDto> amountsForID = amounts
          .where((e) => e.publicId == currentQubicIDs[i].publicId)
          .toList();
      for (var j = 0; j < amountsForID.length; j++) {
        if (currentQubicIDs[i].publicId == amountsForID[j].publicId) {
          var item = QubicListVm.clone(currentQubicIDs[i]);
          item.amount = amountsForID[j].amount;
          currentQubicIDs[i] = item;
        }
      }
      //Update the whole currentQubicIDs array
      ObservableList<QubicListVm> newList = ObservableList<QubicListVm>();
      newList.addAll(currentQubicIDs);
      currentQubicIDs = newList;
    }
  }

  /// Sets the Assets for an account
  void setAssets(List<QubicAssetDto> assetsForAllIDs) {
    for (var i = 0; i < currentQubicIDs.length; i++) {
      List<QubicAssetDto> assetsForID = assetsForAllIDs
          .where((e) => e.publicId == currentQubicIDs[i].publicId)
          .toList();
      for (var j = 0; j < assetsForID.length; j++) {
        if (assetsForID[j].publicId == currentQubicIDs[i].publicId) {
          var item = QubicListVm.clone(currentQubicIDs[i]);
          item.setAssets(assetsForID);
          currentQubicIDs[i] = item;
        }
      }
    }
    ObservableList<QubicListVm> newList = ObservableList<QubicListVm>();
    newList.addAll(currentQubicIDs);
    currentQubicIDs = newList;
  }

  @action
  Future<void> updateTransactions(List<TransactionDto> transactions) async {
    for (var i = 0; i < transactions.length; i++) {
      var currentIndex = currentTransactions
          .indexWhere((element) => element.id == transactions[i].id);
      if (currentIndex == -1) {
        currentTransactions
            .add(TransactionVm.fromTransactionDto(transactions[i]));
      } else {
        currentTransactions[currentIndex] =
            TransactionVm.fromTransactionDto(transactions[i]);
      }
    }
  }

  int getQubicIDsWithPublicId(String publicId) {
    return currentQubicIDs
        .where((element) => element.publicId == publicId.replaceAll(",", "_"))
        .length;
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
  }
}
