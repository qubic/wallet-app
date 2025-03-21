// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ApplicationStore on _ApplicationStore, Store {
  Computed<int>? _$totalAmountsComputed;

  @override
  int get totalAmounts =>
      (_$totalAmountsComputed ??= Computed<int>(() => super.totalAmounts,
              name: '_ApplicationStore.totalAmounts'))
          .value;
  Computed<double>? _$totalAmountsInUSDComputed;

  @override
  double get totalAmountsInUSD => (_$totalAmountsInUSDComputed ??=
          Computed<double>(() => super.totalAmountsInUSD,
              name: '_ApplicationStore.totalAmountsInUSD'))
      .value;
  Computed<List<QubicAssetDto>>? _$totalSharesComputed;

  @override
  List<QubicAssetDto> get totalShares => (_$totalSharesComputed ??=
          Computed<List<QubicAssetDto>>(() => super.totalShares,
              name: '_ApplicationStore.totalShares'))
      .value;

  late final _$hasStoredWalletSettingsAtom =
      Atom(name: '_ApplicationStore.hasStoredWalletSettings', context: context);

  @override
  bool get hasStoredWalletSettings {
    _$hasStoredWalletSettingsAtom.reportRead();
    return super.hasStoredWalletSettings;
  }

  @override
  set hasStoredWalletSettings(bool value) {
    _$hasStoredWalletSettingsAtom
        .reportWrite(value, super.hasStoredWalletSettings, () {
      super.hasStoredWalletSettings = value;
    });
  }

  late final _$globalErrorAtom =
      Atom(name: '_ApplicationStore.globalError', context: context);

  @override
  String get globalError {
    _$globalErrorAtom.reportRead();
    return super.globalError;
  }

  @override
  set globalError(String value) {
    _$globalErrorAtom.reportWrite(value, super.globalError, () {
      super.globalError = value;
    });
  }

  late final _$globalNotificationAtom =
      Atom(name: '_ApplicationStore.globalNotification', context: context);

  @override
  String get globalNotification {
    _$globalNotificationAtom.reportRead();
    return super.globalNotification;
  }

  @override
  set globalNotification(String value) {
    _$globalNotificationAtom.reportWrite(value, super.globalNotification, () {
      super.globalNotification = value;
    });
  }

  late final _$currentTickAtom =
      Atom(name: '_ApplicationStore.currentTick', context: context);

  @override
  int get currentTick {
    _$currentTickAtom.reportRead();
    return super.currentTick;
  }

  @override
  set currentTick(int value) {
    _$currentTickAtom.reportWrite(value, super.currentTick, () {
      super.currentTick = value;
    });
  }

  late final _$isSignedInAtom =
      Atom(name: '_ApplicationStore.isSignedIn', context: context);

  @override
  bool get isSignedIn {
    _$isSignedInAtom.reportRead();
    return super.isSignedIn;
  }

  @override
  set isSignedIn(bool value) {
    _$isSignedInAtom.reportWrite(value, super.isSignedIn, () {
      super.isSignedIn = value;
    });
  }

  late final _$currentTabIndexAtom =
      Atom(name: '_ApplicationStore.currentTabIndex', context: context);

  @override
  int get currentTabIndex {
    _$currentTabIndexAtom.reportRead();
    return super.currentTabIndex;
  }

  @override
  set currentTabIndex(int value) {
    _$currentTabIndexAtom.reportWrite(value, super.currentTabIndex, () {
      super.currentTabIndex = value;
    });
  }

  late final _$currentInboundUriAtom =
      Atom(name: '_ApplicationStore.currentInboundUri', context: context);

  @override
  Uri? get currentInboundUri {
    _$currentInboundUriAtom.reportRead();
    return super.currentInboundUri;
  }

  @override
  set currentInboundUri(Uri? value) {
    _$currentInboundUriAtom.reportWrite(value, super.currentInboundUri, () {
      super.currentInboundUri = value;
    });
  }

  late final _$showAddAccountModalAtom =
      Atom(name: '_ApplicationStore.showAddAccountModal', context: context);

  @override
  bool get showAddAccountModal {
    _$showAddAccountModalAtom.reportRead();
    return super.showAddAccountModal;
  }

  @override
  set showAddAccountModal(bool value) {
    _$showAddAccountModalAtom.reportWrite(value, super.showAddAccountModal, () {
      super.showAddAccountModal = value;
    });
  }

  late final _$currentQubicIDsAtom =
      Atom(name: '_ApplicationStore.currentQubicIDs', context: context);

  @override
  ObservableList<QubicListVm> get currentQubicIDs {
    _$currentQubicIDsAtom.reportRead();
    return super.currentQubicIDs;
  }

  @override
  set currentQubicIDs(ObservableList<QubicListVm> value) {
    _$currentQubicIDsAtom.reportWrite(value, super.currentQubicIDs, () {
      super.currentQubicIDs = value;
    });
  }

  late final _$currentTransactionsAtom =
      Atom(name: '_ApplicationStore.currentTransactions', context: context);

  @override
  ObservableList<TransactionVm> get currentTransactions {
    _$currentTransactionsAtom.reportRead();
    return super.currentTransactions;
  }

  @override
  set currentTransactions(ObservableList<TransactionVm> value) {
    _$currentTransactionsAtom.reportWrite(value, super.currentTransactions, () {
      super.currentTransactions = value;
    });
  }

  late final _$transactionFilterAtom =
      Atom(name: '_ApplicationStore.transactionFilter', context: context);

  @override
  TransactionFilter? get transactionFilter {
    _$transactionFilterAtom.reportRead();
    return super.transactionFilter;
  }

  @override
  set transactionFilter(TransactionFilter? value) {
    _$transactionFilterAtom.reportWrite(value, super.transactionFilter, () {
      super.transactionFilter = value;
    });
  }

  late final _$pendingRequestsAtom =
      Atom(name: '_ApplicationStore.pendingRequests', context: context);

  @override
  int get pendingRequests {
    _$pendingRequestsAtom.reportRead();
    return super.pendingRequests;
  }

  @override
  set pendingRequests(int value) {
    _$pendingRequestsAtom.reportWrite(value, super.pendingRequests, () {
      super.pendingRequests = value;
    });
  }

  late final _$marketInfoAtom =
      Atom(name: '_ApplicationStore.marketInfo', context: context);

  @override
  MarketInfoDto? get marketInfo {
    _$marketInfoAtom.reportRead();
    return super.marketInfo;
  }

  @override
  set marketInfo(MarketInfoDto? value) {
    _$marketInfoAtom.reportWrite(value, super.marketInfo, () {
      super.marketInfo = value;
    });
  }

  late final _$biometricSignInAsyncAction =
      AsyncAction('_ApplicationStore.biometricSignIn', context: context);

  @override
  Future<void> biometricSignIn() {
    return _$biometricSignInAsyncAction.run(() => super.biometricSignIn());
  }

  late final _$checkWalletIsInitializedAsyncAction = AsyncAction(
      '_ApplicationStore.checkWalletIsInitialized',
      context: context);

  @override
  Future<void> checkWalletIsInitialized() {
    return _$checkWalletIsInitializedAsyncAction
        .run(() => super.checkWalletIsInitialized());
  }

  late final _$signInAsyncAction =
      AsyncAction('_ApplicationStore.signIn', context: context);

  @override
  Future<bool> signIn(String password) {
    return _$signInAsyncAction.run(() => super.signIn(password));
  }

  late final _$signUpAsyncAction =
      AsyncAction('_ApplicationStore.signUp', context: context);

  @override
  Future<bool> signUp(String password) {
    return _$signUpAsyncAction.run(() => super.signUp(password));
  }

  late final _$signOutAsyncAction =
      AsyncAction('_ApplicationStore.signOut', context: context);

  @override
  Future signOut() {
    return _$signOutAsyncAction.run(() => super.signOut());
  }

  late final _$addManyIdsAsyncAction =
      AsyncAction('_ApplicationStore.addManyIds', context: context);

  @override
  Future<void> addManyIds(List<QubicId> ids) {
    return _$addManyIdsAsyncAction.run(() => super.addManyIds(ids));
  }

  late final _$addIdAsyncAction =
      AsyncAction('_ApplicationStore.addId', context: context);

  @override
  Future<void> addId(String name, String publicId, String privateSeed) {
    return _$addIdAsyncAction
        .run(() => super.addId(name, publicId, privateSeed));
  }

  late final _$setNameAsyncAction =
      AsyncAction('_ApplicationStore.setName', context: context);

  @override
  Future<void> setName(String publicId, String name) {
    return _$setNameAsyncAction.run(() => super.setName(publicId, name));
  }

  late final _$setBalancesAndAssetsAsyncAction =
      AsyncAction('_ApplicationStore.setBalancesAndAssets', context: context);

  @override
  Future<void> setBalancesAndAssets(
      List<CurrentBalanceDto> balances, List<QubicAssetDto> assets) {
    return _$setBalancesAndAssetsAsyncAction
        .run(() => super.setBalancesAndAssets(balances, assets));
  }

  late final _$removeIDAsyncAction =
      AsyncAction('_ApplicationStore.removeID', context: context);

  @override
  Future<void> removeID(String publicId) {
    return _$removeIDAsyncAction.run(() => super.removeID(publicId));
  }

  late final _$_ApplicationStoreActionController =
      ActionController(name: '_ApplicationStore', context: context);

  @override
  void setCurrentInboundUrl(Uri? uri) {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.setCurrentInboundUrl');
    try {
      return super.setCurrentInboundUrl(uri);
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentTabIndex(int index) {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.setCurrentTabIndex');
    try {
      return super.setCurrentTabIndex(index);
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void triggerAddAccountModal() {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.triggerAddAccountModal');
    try {
      return super.triggerAddAccountModal();
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearAddAccountModal() {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.clearAddAccountModal');
    try {
      return super.clearAddAccountModal();
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reportGlobalError(String error) {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.reportGlobalError');
    try {
      return super.reportGlobalError(error);
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearGlobalError() {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.clearGlobalError');
    try {
      return super.clearGlobalError();
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reportGlobalNotification(String notificationText) {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.reportGlobalNotification');
    try {
      return super.reportGlobalNotification(notificationText);
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void incrementPendingRequests() {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.incrementPendingRequests');
    try {
      return super.incrementPendingRequests();
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void decreasePendingRequests() {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.decreasePendingRequests');
    try {
      return super.decreasePendingRequests();
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetPendingRequests() {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.resetPendingRequests');
    try {
      return super.resetPendingRequests();
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setMarketInfo(MarketInfoDto newInfo) {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.setMarketInfo');
    try {
      return super.setMarketInfo(newInfo);
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setTransactionFilters(String? qubicId,
      ComputedTransactionStatus? status, TransactionDirection? direction) {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.setTransactionFilters');
    try {
      return super.setTransactionFilters(qubicId, status, direction);
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic clearTransactionFilters() {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.clearTransactionFilters');
    try {
      return super.clearTransactionFilters();
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  Map<String, int> setAmounts(List<CurrentBalanceDto> amounts) {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.setAmounts');
    try {
      return super.setAmounts(amounts);
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _addStoredTransactionsToCurrent() {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore._addStoredTransactionsToCurrent');
    try {
      return super._addStoredTransactionsToCurrent();
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic addStoredTransaction(TransactionVm transaction) {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.addStoredTransaction');
    try {
      return super.addStoredTransaction(transaction);
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validatePendingTransactions(int currentTick) {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.validatePendingTransactions');
    try {
      return super.validatePendingTransactions(currentTick);
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic convertPendingToInvalid(TransactionVm transaction) {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.convertPendingToInvalid');
    try {
      return super.convertPendingToInvalid(transaction);
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeStoredTransaction(String transactionId) {
    final _$actionInfo = _$_ApplicationStoreActionController.startAction(
        name: '_ApplicationStore.removeStoredTransaction');
    try {
      return super.removeStoredTransaction(transactionId);
    } finally {
      _$_ApplicationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
hasStoredWalletSettings: ${hasStoredWalletSettings},
globalError: ${globalError},
globalNotification: ${globalNotification},
currentTick: ${currentTick},
isSignedIn: ${isSignedIn},
currentTabIndex: ${currentTabIndex},
currentInboundUri: ${currentInboundUri},
showAddAccountModal: ${showAddAccountModal},
currentQubicIDs: ${currentQubicIDs},
currentTransactions: ${currentTransactions},
transactionFilter: ${transactionFilter},
pendingRequests: ${pendingRequests},
marketInfo: ${marketInfo},
totalAmounts: ${totalAmounts},
totalAmountsInUSD: ${totalAmountsInUSD},
totalShares: ${totalShares}
    ''';
  }
}
