import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/dapp_helpers.dart';
import 'package:qubic_wallet/models/favorite_dapp.dart';
import 'package:qubic_wallet/models/network_model.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
import 'package:qubic_wallet/stores/application_store.dart';

enum HiveBoxesNames {
  storedTransactions,
  storedNetworks,
  currentNetworkName,
  accountsSortingMode,
  favoriteDapps,
  externalUrlWarningPreference,
}

class HiveStorage {
  final _secureStorage = getIt<SecureStorage>();
  late Box<TransactionVm> _storedTransactions;
  late Box<NetworkModel> _storedNetworks;
  late Box<String> _currentNetworkBox;
  late Box<FavoriteDappModel> _favoriteDapps;
  late Box<bool> _externalUrlWarningBox;
  final currentNetworkKey = "current_network";
  late Box<String> _accountsSortingMode;
  final accountsSortingKey = "accounts_sorting_mode";
  final externalUrlWarningKey = "external_url_warning_dismissed";
  late HiveAesCipher _encryptionCipher;

  Future<void> initialize() async {
    appLogger.i('[HiveStorage] Initializing Hive...');
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionVmAdapter());
    Hive.registerAdapter(NetworkAdapter());
    Hive.registerAdapter(FavoriteDappAdapter());
    await initEncryptedBoxes();
  }

  Future<void> initEncryptedBoxes() async {
    try {
      await _loadEncryptionKey();
      await openTransactionsBox();
      await openNetworksBox();
      await openCurrentNetworkBox();
      await openAccountsSortingModeBox();
      await openFavoriteDappsBox();
      await openExternalUrlWarningBox();
    } catch (e) {
      appLogger.e("[HiveStorage] Error initializing hive storage: $e");
    }
  }

  /// Loads or generates a new encryption key and stores it securely.
  Future<void> _loadEncryptionKey() async {
    appLogger.d('[HiveStorage] Loading encryption key...');
    String? keyString = await _secureStorage.getHiveEncryptionKey();

    if (keyString == null) {
      appLogger
          .w('[HiveStorage] No encryption key found! Generating new key...');
      final key = Hive.generateSecureKey();
      final encodedKey = base64UrlEncode(key);
      await _secureStorage.storeHiveEncryptionKey(encodedKey);
      _encryptionCipher = HiveAesCipher(key);
      appLogger.w('[HiveStorage] New encryption key generated and stored.');
    } else {
      final key = base64Decode(keyString);
      _encryptionCipher = HiveAesCipher(key);
      appLogger.w('[HiveStorage] Existing encryption key loaded.');
    }
    appLogger.d(
        '[HiveStorage] Encryption key loaded - $_encryptionCipher - ${_encryptionCipher.calculateKeyCrc()}');
  }

  Future<void> openTransactionsBox() async {
    appLogger.d('[HiveStorage] Attempting to open transactions box...');
    try {
      _storedTransactions = await Hive.openBox<TransactionVm>(
        HiveBoxesNames.storedTransactions.name,
        encryptionCipher: _encryptionCipher,
      );
      appLogger.d(
          '[HiveStorage] Transactions box opened with ${_storedTransactions.length} items.');
    } catch (e, stack) {
      appLogger.e('[HiveStorage] Failed to open transactions box: $e');
      appLogger.e('[HiveStorage] Stacktrace: $stack');
    }
  }

  Future<void> openNetworksBox() async {
    _storedNetworks = await Hive.openBox<NetworkModel>(
      HiveBoxesNames.storedNetworks.name,
      encryptionCipher: _encryptionCipher,
    );
    appLogger.d(
        '[HiveStorage] Networks box opened with ${_storedNetworks.length} items.');
  }

  Future<void> openCurrentNetworkBox() async {
    _currentNetworkBox = await Hive.openBox<String>(
        HiveBoxesNames.currentNetworkName.name,
        encryptionCipher: _encryptionCipher);
    appLogger.d('[HiveStorage] Current network box opened.');
  }

  Future<void> openAccountsSortingModeBox() async {
    _accountsSortingMode = await Hive.openBox<String>(
        HiveBoxesNames.accountsSortingMode.name,
        encryptionCipher: _encryptionCipher);
  }

  Future<void> openFavoriteDappsBox() async {
    _favoriteDapps = await Hive.openBox<FavoriteDappModel>(
      HiveBoxesNames.favoriteDapps.name,
      encryptionCipher: _encryptionCipher,
    );
    appLogger.d(
        '[HiveStorage] Favorite dApps box opened with ${_favoriteDapps.length} items.');
  }

  Future<void> openExternalUrlWarningBox() async {
    _externalUrlWarningBox = await Hive.openBox<bool>(
      HiveBoxesNames.externalUrlWarningPreference.name,
      encryptionCipher: _encryptionCipher,
    );
    appLogger.d('[HiveStorage] External URL warning preference box opened.');
  }

  void addStoredTransaction(TransactionVm transactionVm) {
    appLogger.d('[HiveStorage] Adding transaction: ${transactionVm.id}');
    _storedTransactions.put(transactionVm.id, transactionVm);
  }

  void removeStoredTransaction(String transactionId) {
    appLogger.d('[HiveStorage] Removing transaction: $transactionId');
    _storedTransactions.delete(transactionId);
  }

  List<TransactionVm> getStoredTransactions() {
    appLogger.d(
        '[HiveStorage] Getting stored transactions (${_storedTransactions.length})');
    return _storedTransactions.values.toList();
  }

  addStoredNetwork(NetworkModel network) {
    _storedNetworks.put(network.name, network);
  }

  List<NetworkModel> getStoredNetworks() {
    return _storedNetworks.values.toList();
  }

  removeStoredNetwork(String networkName) {
    _storedNetworks.delete(networkName);
  }

  void saveCurrentNetworkName(String networkName) {
    _currentNetworkBox.put(currentNetworkKey, networkName);
  }

  String? getCurrentNetworkName() {
    return _currentNetworkBox.get(currentNetworkKey);
  }

  void setAccountsSortingMode(AccountSortMode mode) {
    _accountsSortingMode.put(accountsSortingKey, mode.name);
  }

  AccountSortMode? getAccountsSortingMode() {
    final mode = _accountsSortingMode.get(accountsSortingKey);
    if (mode != null) {
      return AccountSortMode.values.firstWhereOrNull((e) => e.name == mode);
    }
    return null;
  }

  // External URL warning preference methods
  bool getExternalUrlWarningDismissed() {
    return _externalUrlWarningBox.get(externalUrlWarningKey) ?? false;
  }

  void setExternalUrlWarningDismissed(bool dismissed) {
    appLogger
        .d('[HiveStorage] Setting external URL warning dismissed: $dismissed');
    _externalUrlWarningBox.put(externalUrlWarningKey, dismissed);
  }

  // Favorite dApps methods
  void addFavoriteDapp(FavoriteDappModel favorite) {
    appLogger.d('[HiveStorage] Adding favorite: ${favorite.name}');
    final normalizedUrl = normalizeUrl(favorite.url);
    // Create a new FavoriteDappModel with normalized URL to ensure consistency
    final normalizedFavorite = FavoriteDappModel(
      name: favorite.name,
      url: normalizedUrl,
      createdAt: favorite.createdAt,
      iconUrl: favorite.iconUrl,
    );
    _favoriteDapps.put(normalizedUrl, normalizedFavorite);
  }

  void removeFavoriteDapp(String url) {
    appLogger.d('[HiveStorage] Removing favorite: $url');
    final normalizedUrl = normalizeUrl(url);

    if (_favoriteDapps.containsKey(normalizedUrl)) {
      _favoriteDapps.delete(normalizedUrl);
      appLogger.d('[HiveStorage] Removed favorite by normalized URL');
    } else {
      appLogger.w('[HiveStorage] Favorite not found for removal: $url');
    }
  }

  List<FavoriteDappModel> getFavoriteDapps() {
    appLogger
        .d('[HiveStorage] Getting favorite dApps (${_favoriteDapps.length})');
    final favorites = _favoriteDapps.values.toList();
    // Sort by createdAt to show in the order they were added
    favorites.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return favorites;
  }

  bool isFavorite(String url) {
    final normalizedUrl = normalizeUrl(url);
    appLogger.d(
        '[HiveStorage] Checking if favorite - Original: $url, Normalized: $normalizedUrl');

    final isFav = _favoriteDapps.containsKey(normalizedUrl);
    appLogger.d('[HiveStorage] Is favorite: $isFav');
    return isFav;
  }

  Future<void> clear() async {
    await _storedTransactions.clear();
    _storedTransactions.close();

    await _storedNetworks.clear();
    _storedNetworks.close();

    await _currentNetworkBox.clear();
    _currentNetworkBox.close();

    await _accountsSortingMode.clear();
    _accountsSortingMode.close();
    await _favoriteDapps.clear();
    _favoriteDapps.close();

    await _externalUrlWarningBox.clear();
    _externalUrlWarningBox.close();

    await _secureStorage.deleteHiveEncryptionKey();
    appLogger.w(
        '[HiveStorage] data cleared, boxes closed, and encryption key deleted.');
  }
}
