import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';

class TimedController extends WidgetsBindingObserver {
  Timer? _fetchTimer;
  // ignore: unused_field
  Timer? _fetchTimerSlow;

  DateTime? lastFetch;
  DateTime? lastFetchSlow;
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final QubicLi _apiService = getIt<QubicLi>();
  final WalletConnectService _walletConnectService =
      getIt<WalletConnectService>();

  stopFetchTimers() {
    if (_fetchTimer != null) {
      _fetchTimer!.cancel();
      _fetchTimer = null;
    }
    if (_fetchTimerSlow != null) {
      _fetchTimerSlow!.cancel();
      _fetchTimerSlow = null;
    }
  }

  /// Restart the fetching timer if it's not already running
  restartFetchTimersIfNeeded() {
    if (_fetchTimer == null) {
      setupFetchTimer(true);
    }
    if (_fetchTimerSlow == null) {
      setupSlowTimer(true);
    }
  }

  /// Fetch balances assets and transactions from the network
  /// Makes four calls (balances, network balances, network assets, network transactions
  /// and updates the store with the results)
  /// Will not make a call if there's a pending call
  /// If any of the calls fail, it shows a snackbar with the error message
  _getNetworkBalancesAndAssets() async {
    try {
      List<String> myIds =
          appStore.currentQubicIDs.map((e) => e.publicId).toList();

      //Fetch network balances
      if (!_apiService.gettingNetworkBalances) {
        _apiService.getNetworkBalances(myIds).then((balances) {
          Map<String, int> changedIds = appStore.setAmounts(balances);
          if (changedIds.isNotEmpty) {
            _walletConnectService.triggerAmountChangedEvent(changedIds);
          }
        }, onError: (e) {
          appStore
              .reportGlobalError(e.toString().replaceAll("Exception: ", ""));
        });
      }

      //Fetch network assets
      if (!_apiService.gettingNetworkAssets) {
        _apiService.getCurrentAssets(myIds).then((assets) {
          Map<String, List<QubicAssetDto>> changedIds =
              appStore.setAssets(assets);
          if (changedIds.isNotEmpty) {
            _walletConnectService.triggerTokenAmountChangedEvent(changedIds);
          }
        }, onError: (e) {
          appStore
              .reportGlobalError(e.toString().replaceAll("Exception: ", ""));
        });
      }

      if (!_apiService.gettingNetworkTransactions) {
        _apiService
            .getTransactions(myIds)
            .then((transactions) => appStore.updateTransactions(transactions));
      }
    } on Exception catch (e) {
      appStore.reportGlobalError(e.toString().replaceAll("Exception: ", ""));
    }
  }

  /// Fetch the market info from the backend
  /// If the call fails, it shows a snackbar with the error message
  /// If the call succeeds, it updates the store with the results
  _getMarketInfo() async {
    _apiService.getMarketInfo().then((marketInfo) {
      debugPrint(
          "Got market info: ${marketInfo.capitalization} ${marketInfo.price} ${marketInfo.currency} ${marketInfo.supply}");
      appStore.setMarketInfo(marketInfo);
    }).onError((e, stackTrace) {
      appStore.reportGlobalError(e.toString().replaceAll("Exception: ", ""));
    });
  }

  /// Called by the main timer
  /// Fetches the current tick and the network balances and assets
  /// If the call fails, it shows a snackbar with the error message
  fetchData() async {
    try {
      //Fetch the ticks
      int tick = await _apiService.getCurrentTick();
      appStore.currentTick = tick;
      _getNetworkBalancesAndAssets();
      lastFetch = DateTime.now();
    } on Exception catch (e) {
      appStore.reportGlobalError(e.toString().replaceAll("Exception: ", ""));
      //_globalSnackBar.show(e.toString().replaceAll("Exception: ", ""));
    } catch (e) {
      appStore.reportGlobalError(e.toString().replaceAll("Exception: ", ""));
    }
  }

  /// Called by the slow timer
  /// Fetches the market info
  /// If the call fails, it shows a snackbar with the error message
  /// If the call succeeds, it updates the store with the results

  fetchDataSlow() async {
    try {
      _getMarketInfo();
      lastFetchSlow = DateTime.now();
    } on Exception catch (e) {
      appStore.reportGlobalError(e.toString().replaceAll("Exception: ", ""));
      //_globalSnackBar.show(e.toString().replaceAll("Exception: ", ""));
    }
  }

  /// Restart the fetching timer.
  /// If the timer is already running, it stops it and starts it again
  interruptFetchTimer() async {
    _fetchTimer?.cancel();
    _apiService.resetGetters();

    setupFetchTimer(true);
    if ((lastFetchSlow == null) ||
        (lastFetchSlow!.isBefore(DateTime.now().subtract(
            const Duration(seconds: Config.fetchEverySecondsSlow))))) {
      await fetchDataSlow();
    }
  }

  /// Setup the fetching timer
  setupFetchTimer(bool makeInitialCall) async {
    if (makeInitialCall) {
      await fetchData();
    }
    _fetchTimer = Timer.periodic(
        const Duration(seconds: Config.fetchEverySeconds), (timer) {
      fetchData();
    });
  }

  /// Setup the slow fetching timer
  setupSlowTimer(bool makeInitialCall) async {
    if (makeInitialCall) {
      await fetchDataSlow();
    }
    _fetchTimerSlow = Timer.periodic(
        const Duration(seconds: Config.fetchEverySecondsSlow), (timerSlow) {
      fetchDataSlow();
    });
  }
}
