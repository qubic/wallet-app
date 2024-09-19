import 'dart:async';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:mobx/mobx.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/change_foreground.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/pages/main/download_cmd_utils.dart';
import 'package:qubic_wallet/pages/main/tab_explorer.dart';
import 'package:qubic_wallet/pages/main/tab_settings.dart';
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
import 'package:privacy_screen/privacy_screen.dart';

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

  Timer? _lockTimer;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Lock the app immediately if the timeout is 0 (Immediately)
      if (settingsStore.settings.autoLockTimeout == 0) {
        applicationStore.signOut();
      } else {
        // Start the auto-lock timer when the app goes to background
        _lockTimer = Timer(
          Duration(minutes: settingsStore.settings.autoLockTimeout),
          () {
            // Lock the app
            applicationStore.signOut();
          },
        );
      }
    }
    if (state == AppLifecycleState.resumed) {
      // Cancel the timer when the app is resumed
      _lockTimer?.cancel();
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

    walletConnectService.onRequestSendQubic.stream.listen((event) {
      //TODO Show dialog (with timeout)
    });

    PrivacyScreen.instance.enable(
      iosOptions: const PrivacyIosOptions(
        enablePrivacy: true,
        autoLockAfterSeconds: 0,
        lockTrigger: IosLockTrigger.didEnterBackground,
      ),
      androidOptions: const PrivacyAndroidOptions(
        enableSecure: true,
        autoLockAfterSeconds: 0,
      ),
      blurEffect: PrivacyBlurEffect.dark,
      backgroundColor: Colors.transparent,
    );

    _timedController.setupFetchTimer(true);
    _timedController.setupSlowTimer(true);
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
    _timedController.stopFetchTimer();
    _disposeSnackbarAuto();

    WidgetsBinding.instance.removeObserver(this);
    _lockTimer?.cancel();

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
      if (UniversalPlatform.isDesktop && !settingsStore.cmdUtilsAvailable) {
        return const Scaffold(body: DownloadCmdUtils());
      }

      return getMain();
    });
  }
}
