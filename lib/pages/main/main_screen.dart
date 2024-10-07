import 'dart:async';
import 'dart:developer';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:mobx/mobx.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/change_foreground.dart';
import 'package:qubic_wallet/components/wallet_connect/approve_token_transfer.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/models/wallet_connect/approve_token_transfer_result.dart';
import 'package:qubic_wallet/pages/main/download_cmd_utils.dart';
import 'package:qubic_wallet/pages/main/tab_explorer.dart';
import 'package:qubic_wallet/pages/main/tab_settings/tab_settings.dart';
import 'package:qubic_wallet/pages/main/tab_transfers.dart';
import 'package:qubic_wallet/pages/main/tab_wallet_contents.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/qubic_hub_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_account_modal_bottom_sheet.dart';

class MainScreen extends StatefulWidget {
  final int initialTabIndex;
  const MainScreen({super.key, this.initialTabIndex = 0});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  late final PersistentTabController _controller;
  final _timedController = getIt<TimedController>();
  final QubicHubStore qubicHubStore = getIt<QubicHubStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  final ApplicationStore applicationStore = getIt<ApplicationStore>();
  final QubicCmd qubicCmd = getIt<QubicCmd>();
  late final ReactionDisposer _disposeSnackbarAuto;
  final WalletConnectService walletConnectService =
      getIt<WalletConnectService>();

  late AnimatedSnackBar? errorBar;
  late AnimatedSnackBar? notificationBar;

  Timer? _autoLockTimer;
  Timer? _backgroundTimer;

  bool WCDialogOpen = false; //Wallet Connect Dialog Open

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        (UniversalPlatform.isDesktop && state == AppLifecycleState.hidden)) {
      // Lock the app immediately if the timeout is 0 (Immediately)
      if (settingsStore.settings.autoLockTimeout == 0) {
        applicationStore.signOut();
      } else {
        // Start the auto-lock timer when the app goes to background
        _autoLockTimer = Timer(
          Duration(minutes: settingsStore.settings.autoLockTimeout),
          () {
            // Lock the app
            applicationStore.signOut();
          },
        );
        // Start the background timer
        _backgroundTimer =
            Timer(const Duration(seconds: Config.inactiveSecondsLimit), () {
          _timedController.stopFetchTimers();
        });
      }
    }
    // When the app is resumed
    if (state == AppLifecycleState.resumed ||
        (UniversalPlatform.isDesktop && state == AppLifecycleState.inactive)) {
      _backgroundTimer?.cancel();
      _timedController.restartFetchTimersIfNeeded();
      _autoLockTimer?.cancel();
      if (!applicationStore.isSignedIn) {
        context.go('/signIn');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (settingsStore.settings != null &&
        settingsStore.settings.walletConnectEnabled) {
      walletConnectService.initialize();
    }

    //Wallet Connect Modals

    //Modal for sending qubic
    walletConnectService.onRequestSendQubic.stream.listen((event) async {
      //Do not allow multiple modals
      if (WCDialogOpen) {
        walletConnectService.emitErrorSessionEvent(
            event.topic, "user unavailable", event.nonce);
        return;
      }

      if (mounted) {
        WCDialogOpen = true;

//  bool? hasAuthenticated =
//       await Navigator.of(context).push(MaterialPageRoute<bool>(
//           builder: (BuildContext context) {
//             return const Reauthenticate();
//           },
//           fullscreenDialog: true));

        var result = await Navigator.of(context)
            .push(MaterialPageRoute<ApproveTokenTransferResult?>(
                builder: (BuildContext context) {
                  return ApproveTokenTransfer(
                      pairingMetadata: event.pairingMetadata!,
                      nonce: event.nonce,
                      fromID: event.fromID,
                      fromName: event.fromIDName,
                      amount: event.amount,
                      toID: event.toID);
                },
                fullscreenDialog: true));

        //Notify WC on the result
        if ((result == null)) {
          walletConnectService.emitErrorSessionEvent(
              event.topic, "user rejected", event.nonce);
        } else if (result.success == false) {
          walletConnectService.emitErrorSessionEvent(
              event.topic, "user could not authorize transaction", event.nonce);
        } else {
          dynamic responseInfo = {};
          responseInfo['tick'] = result.tick;
          walletConnectService.emitSuccessSessionEvent(event.topic, event.nonce,
              params: responseInfo);
        }
        WCDialogOpen = false;
      }
    });

    if (settingsStore.settings != null &&
        settingsStore.settings.walletConnectEnabled) {
      walletConnectService.initialize();
    }

    //Wallet Connect Modals

    //Modal for sending qubic
    walletConnectService.onRequestSendQubic.stream.listen((event) async {
      //Do not allow multiple modals
      if (WCDialogOpen) {
        walletConnectService.emitErrorSessionEvent(
            event.topic, "user unavailable", event.nonce);
        return;
      }

      WCDialogOpen = true;
      ApproveTokenTransferResult? result =
          await showDialog<ApproveTokenTransferResult?>(
              context: context,
              builder: (context) {
                return ApproveTokenTransfer(
                    pairingMetadata: event.pairingMetadata!,
                    nonce: event.nonce,
                    fromID: event.fromID,
                    fromName: event.fromIDName,
                    amount: event.amount,
                    toID: event.toID);
              });
      //Notify WC on the result
      if ((result == null)) {
        walletConnectService.emitErrorSessionEvent(
            event.topic, "user rejected", event.nonce);
      } else if (result.success == false) {
        walletConnectService.emitErrorSessionEvent(
            event.topic, "user could not authorize transaction", event.nonce);
      } else {
        dynamic responseInfo = {};
        responseInfo['tick'] = result.tick;
        walletConnectService.emitSuccessSessionEvent(event.topic, event.nonce,
            params: responseInfo);
      }
      WCDialogOpen = false;
    });
    _timedController.restartFetchTimersIfNeeded();
    _controller = PersistentTabController(initialIndex: widget.initialTabIndex);
    // _controller.jumpToTab(value);
    _controller.addListener(() {
      applicationStore.setCurrentTabIndex(_controller.index);
    });

    if (!getIt.isRegistered<PersistentTabController>()) {
      getIt.registerSingleton<PersistentTabController>(_controller);
    }

    _disposeSnackbarAuto = autorun((_) {
      if (applicationStore.globalError != "") {
        var errorPos = applicationStore.globalError.indexOf("~");
        var error = (errorPos == -1)
            ? applicationStore.globalError
            : applicationStore.globalError.substring(0, errorPos);

        if (error != "") {
          //Error overriding for more than 15 accounts in wallet
          if (error == "Failed to perform action. Server returned status 400") {
            if (applicationStore.currentQubicIDs.length > 15) {
              return;
            }
          }

          errorBar = AnimatedSnackBar(
              builder: ((context) {
                return Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: LightThemeColors.cardBackground.withRed(100),
                    ),
                    child: InkWell(
                        onTap: (() {
                          AnimatedSnackBar.removeAll();
                        }),
                        child: Container(
                          padding:
                              const EdgeInsets.all(ThemePaddings.normalPadding),
                          child: Text(
                            error,
                            style: TextStyles.labelTextSmall,
                          ),
                        )));
              }),
              snackBarStrategy: RemoveSnackBarStrategy())
            ..show(context);

          applicationStore.clearGlobalError();
        }
      }

      if (applicationStore.globalNotification != "") {
        var notificationPos = applicationStore.globalNotification.indexOf("~");
        var notification = (notificationPos == -1)
            ? applicationStore.globalNotification
            : applicationStore.globalNotification.substring(0, notificationPos);

        if (notification != "") {
          notificationBar = AnimatedSnackBar(
              builder: ((context) {
                return Ink(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: LightThemeColors.cardBackground),
                    child: InkWell(
                        onTap: (() {
                          AnimatedSnackBar.removeAll();
                        }),
                        child: Container(
                          padding:
                              const EdgeInsets.all(ThemePaddings.normalPadding),
                          child: Text(
                            notification,
                            style: TextStyles.labelTextSmall,
                          ),
                        )));
              }),
              snackBarStrategy: RemoveSnackBarStrategy())
            ..show(context);
        }
      }
    });
  }

  @override
  void dispose() {
    _timedController.stopFetchTimers();
    _disposeSnackbarAuto();

    WidgetsBinding.instance.removeObserver(this);
    _autoLockTimer?.cancel();

    super.dispose();
  }

  List<PersistentTabConfig> _tabs() {
    final l10n = l10nOf(context);

    return [
      PersistentTabConfig(
          screen: Container(
              color: LightThemeColors.background,
              child: const SafeArea(child: TabWalletContents())),
          item: ItemConfig(
            icon: ChangeForeground(
                color: LightThemeColors.buttonBackground,
                child: Image.asset("assets/images/tab-home.png")),
            inactiveIcon: Image.asset("assets/images/tab-home.png"),
            title: (l10n.appTabHome),
            textStyle: TextStyles.menuActive,
            activeForegroundColor: LightThemeColors.menuActive,
            inactiveForegroundColor: LightThemeColors.menuInactive,
          )),
      PersistentTabConfig(
          screen: Container(
              color: LightThemeColors.background,
              child: const SafeArea(child: TabTransfers())),
          item: ItemConfig(
            icon: ChangeForeground(
                color: LightThemeColors.buttonBackground,
                child: Image.asset("assets/images/tab-transfers.png")),
            inactiveIcon: Image.asset("assets/images/tab-transfers.png"),
            title: (l10n.appTabTransfers),
            textStyle: TextStyles.menuActive,
            activeForegroundColor: LightThemeColors.menuActive,
            inactiveForegroundColor: LightThemeColors.menuInactive,
          )),
      PersistentTabConfig(
          screen: Container(
              color: LightThemeColors.background,
              child: const SafeArea(child: TabExplorer())),
          item: ItemConfig(
            icon: ChangeForeground(
                color: LightThemeColors.buttonBackground,
                child: Image.asset("assets/images/tab-explorer.png")),
            inactiveIcon: Image.asset("assets/images/tab-explorer.png"),
            title: (l10n.appTabExplorer),
            textStyle: TextStyles.menuActive,
            activeForegroundColor: LightThemeColors.menuActive,
            inactiveForegroundColor: LightThemeColors.menuInactive,
          )),
      PersistentTabConfig(
          screen: Container(
              color: LightThemeColors.background,
              child: const SafeArea(child: TabSettings())),
          item: ItemConfig(
            icon: ChangeForeground(
                color: LightThemeColors.buttonBackground,
                child: Image.asset("assets/images/tab-settings.png")),
            inactiveIcon: Image.asset("assets/images/tab-settings.png"),
            title: (l10n.appTabSettings),
            textStyle: TextStyles.menuActive,
            activeForegroundColor: LightThemeColors.menuActive,
            inactiveForegroundColor: LightThemeColors.menuInactive,
          ))
    ];
  }

  Widget getMain() {
    if (applicationStore.hasStoredWalletSettings) {
      _controller.jumpToTab(applicationStore.currentTabIndex);
    } else {
      _controller.jumpToTab(0);
    }
    // _controller.jumpToPreviousTab();
    return PersistentTabView(
      controller: _controller,
      navBarHeight: 60,
      navBarBuilder: (navBarConfig) => Style1BottomNavBar(
          navBarConfig: navBarConfig,
          navBarDecoration: const NavBarDecoration(
              border: Border(
                top: BorderSide(width: 1, color: LightThemeColors.navBorder),
              ),
              color: LightThemeColors.navBg)),

      tabs: _tabs(),

      backgroundColor: LightThemeColors.navBg,

      // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      navBarOverlap: const NavBarOverlap.none(),
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
    );
  }

  @override
  Widget build(BuildContext context) {
    // if (UniversalPlatform.isDesktop && !settingsStore.cmdUtilsAvailable) {
    //   return DownloadCmdUtils();
    // }
    // return getMain();
    return Observer(builder: (context) {
      if (applicationStore.showAddAccountModal) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAddAccountModal(context);
          // Reset the trigger to avoid showing the modal again unintentionally
          applicationStore.clearAddAccountModal();
        });
      }

      if (UniversalPlatform.isDesktop && !settingsStore.cmdUtilsAvailable) {
        return const Scaffold(body: DownloadCmdUtils());
      }

      return getMain();
    });
  }
}
