import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/resources/apis/query/qubic_query_api.dart';
import 'package:qubic_wallet/resources/apis/live/qubic_live_api.dart';
import 'package:qubic_wallet/resources/apis/stats/qubic_stats_api.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';

class TimedController extends WidgetsBindingObserver {
  Timer? _fetchTimer;
  // ignore: unused_field
  Timer? _fetchTimerSlow;

  DateTime? lastFetch;
  DateTime? lastFetchSlow;
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final WalletConnectService _walletConnectService =
      getIt<WalletConnectService>();
  final _liveApi = getIt<QubicLiveApi>();
  final QubicStatsApi _statsApi = getIt<QubicStatsApi>();
  final QubicQueryApi _queryApi = getIt<QubicQueryApi>();

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

  /// Fetches network balances and assets in parallel.
  /// Each fetch handles its own errors so one failing does not affect the other.
  Future<void> _getNetworkBalancesAndAssets() async {
    final List<String> myIds =
        appStore.currentQubicIDs.map((e) => e.publicId).toList();

    await Future.wait([
      _fetchAndProcessBalances(myIds),
      _fetchAndProcessAssets(myIds),
    ]);
  }

  Future<void> _fetchAndProcessBalances(List<String> myIds) async {
    try {
      final balances = await _liveApi.getQubicBalances(myIds);
      final Map<String, int> changedIds = appStore.setAmounts(balances);
      if (changedIds.isNotEmpty) {
        final Map<String, int> changedIdsWithSeed = {};

        //Filter out only non WatchOnly accounts
        for (final element in changedIds.entries) {
          final account = appStore.findAccountById(element.key);
          if (account != null && !account.watchOnly) {
            changedIdsWithSeed[element.key] = element.value;
          }
        }
        if (changedIdsWithSeed.isNotEmpty) {
          _walletConnectService.triggerAmountChangedEvent(changedIdsWithSeed);
        }
        // Only sort if in balance mode since balance changes don't affect other sort orders
        if (appStore.accountsSortingMode == AccountSortMode.balance) {
          appStore.sortAccounts();
        }
      }
    } catch (e) {
      final error = await ErrorHandler.handleError(e);
      appStore.reportGlobalError(error.toString());
    }
  }

  Future<void> _fetchAndProcessAssets(List<String> myIds) async {
    try {
      final assets = await _liveApi.getCurrentAssets(myIds);
      final Map<String, List<QubicAssetDto>> changedIds =
          appStore.setAssets(assets);

      final Map<String, List<QubicAssetDto>> changedIdsWithSeed = {};

      //Filter out only non WatchOnly accounts
      for (final element in changedIds.entries) {
        final account = appStore.findAccountById(element.key);
        if (account != null && !account.watchOnly) {
          changedIdsWithSeed[element.key] = element.value;
        }
      }

      if (changedIdsWithSeed.isNotEmpty) {
        _walletConnectService
            .triggerAssetAmountChangedEvent(changedIdsWithSeed);
      }
    } catch (e) {
      final error = await ErrorHandler.handleError(e);
      appStore.reportGlobalError(error.toString());
    }
  }

  /// Fetch the market info from the backend
  /// If the call fails, it shows a snackbar with the error message
  /// If the call succeeds, it updates the appStore with the results
  Future<void> _getMarketInfo() async {
    try {
      final marketInfo = await _statsApi.getMarketInfo();
      appStore.setMarketInfo(marketInfo);
      lastFetchSlow = DateTime.now();
    } on AppError catch (e) {
      appStore.reportGlobalError(e.toString());
    }
  }

  /// Called by the main timer
  /// Fetches the current tick and the network balances and assets
  /// If the call fails, it shows a snackbar with the error message
  Future<void> fetchData() async {
    if (appStore.isLoading) return;
    appStore.setLoading(true);
    try {
      //Fetch the ticks
      int tick = (await _liveApi.getCurrentTick()).tick;
      appStore.currentTick = tick;
      int latestTickProcessed = (await _queryApi.getLastProcessedTick());
      appStore.validatePendingTransactions(latestTickProcessed);
      await _getNetworkBalancesAndAssets();
      lastFetch = DateTime.now();
    } on AppError catch (e) {
      appStore.reportGlobalError(e.toString());
    } catch (e) {
      final error = await ErrorHandler.handleError(e);
      appStore.reportGlobalError(error.toString());
    } finally {
      appStore.setLoading(false);
    }
  }

  /// Called by the slow timer
  /// Fetches the market info
  /// If the call fails, it shows a snackbar with the error message
  /// If the call succeeds, it updates the store with the results

  Future<void> fetchDataSlow() async {
    await _getMarketInfo();
  }

  /// Restart the fetching timer.
  /// If the timer is already running, it stops it and starts it again
  Future<void> interruptFetchTimer() async {
    _fetchTimer?.cancel();

    setupFetchTimer(true);
    if ((lastFetchSlow == null) ||
        (lastFetchSlow!.isBefore(DateTime.now().subtract(
            const Duration(seconds: Config.fetchEverySecondsSlow))))) {
      await fetchDataSlow();
    }
  }

  /// Setup the fetching timer
  Future<void> setupFetchTimer(bool makeInitialCall) async {
    if (makeInitialCall) {
      await fetchData();
    }
    _fetchTimer = Timer.periodic(
        const Duration(seconds: Config.fetchEverySeconds), (timer) {
      fetchData();
    });
  }

  /// Setup the slow fetching timer
  Future<void> setupSlowTimer(bool makeInitialCall) async {
    if (makeInitialCall) {
      await fetchDataSlow();
    }
    _fetchTimerSlow = Timer.periodic(
        const Duration(seconds: Config.fetchEverySecondsSlow), (timerSlow) {
      fetchDataSlow();
    });
  }
}
