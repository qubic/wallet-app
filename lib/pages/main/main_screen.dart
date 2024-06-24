import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/change_foreground.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/models/settings.dart';
import 'package:qubic_wallet/pages/main/downloadCmdUtils.dart';
import 'package:qubic_wallet/pages/main/tab_explorer.dart';
import 'package:qubic_wallet/pages/main/tab_settings.dart';
import 'package:qubic_wallet/pages/main/tab_transfers.dart';
import 'package:qubic_wallet/pages/main/tab_wallet_contents.dart';
import 'package:qubic_wallet/resources/qubic_cmd_utils.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/qubic_hub_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../helpers/global_snack_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final PersistentTabController _controller;
  final _timedController = getIt<TimedController>();
  final QubicHubStore qubicHubStore = getIt<QubicHubStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  final ApplicationStore applicationStore = getIt<ApplicationStore>();

  late final ReactionDisposer _disposeSnackbarAuto;
  final _globalSnackBar = getIt<GlobalSnackBar>();

  late AnimatedSnackBar? errorBar;
  late AnimatedSnackBar? notificationBar;

  @override
  void initState() {
    super.initState();
    _timedController.setupFetchTimer(true);
    _timedController.setupSlowTimer(true);
    _controller = PersistentTabController(initialIndex: 0);

    if (!getIt.isRegistered<PersistentTabController>()) {
      getIt.registerSingleton<PersistentTabController>(_controller);
    }

    _disposeSnackbarAuto = autorun((_) {
      if (applicationStore.globalError != "") {
        var errorPos = applicationStore.globalError.indexOf("~");
        var error = (errorPos == -1)
            ? applicationStore.globalError
            : applicationStore.globalError.substring(0, errorPos);

        // AnimatedSnackBar.material(error,
        //         type: AnimatedSnackBarType.error,
        //         snackBarStrategy: StackSnackBarStrategy())
        //     .show(context);
        if (error != "") {
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
    super.dispose();
  }

  List<PersistentTabConfig> _tabs() {
    return [
      PersistentTabConfig(
          screen: const TabWalletContents(),
          item: ItemConfig(
            icon: ChangeForeground(
                color: LightThemeColors.buttonBackground,
                child: Image.asset("assets/images/tab-home.png")),
            inactiveIcon: Image.asset("assets/images/tab-home.png"),
            title: ("Home"),
            textStyle: TextStyles.menuActive,
            activeForegroundColor: LightThemeColors.menuActive,
            inactiveForegroundColor: LightThemeColors.menuInactive,
          )),
      PersistentTabConfig(
          screen: const TabTransfers(),
          item: ItemConfig(
            icon: ChangeForeground(
                color: LightThemeColors.buttonBackground,
                child: Image.asset("assets/images/tab-transfers.png")),
            inactiveIcon: Image.asset("assets/images/tab-transfers.png"),
            title: ("Transfers"),
            textStyle: TextStyles.menuActive,
            activeForegroundColor: LightThemeColors.menuActive,
            inactiveForegroundColor: LightThemeColors.menuInactive,
          )),
      PersistentTabConfig(
          screen: const TabExplorer(),
          item: ItemConfig(
            icon: ChangeForeground(
                color: LightThemeColors.buttonBackground,
                child: Image.asset("assets/images/tab-explorer.png")),
            inactiveIcon: Image.asset("assets/images/tab-explorer.png"),
            title: ("Explorer"),
            textStyle: TextStyles.menuActive,
            activeForegroundColor: LightThemeColors.menuActive,
            inactiveForegroundColor: LightThemeColors.menuInactive,
          )),
      PersistentTabConfig(
          screen: const TabSettings(),
          item: ItemConfig(
            icon: ChangeForeground(
                color: LightThemeColors.buttonBackground,
                child: Image.asset("assets/images/tab-settings.png")),
            inactiveIcon: Image.asset("assets/images/tab-settings.png"),
            title: ("Settings"),
            textStyle: TextStyles.menuActive,
            activeForegroundColor: LightThemeColors.menuActive,
            inactiveForegroundColor: LightThemeColors.menuInactive,
          ))
    ];
  }

  Widget getMain() {
    return PersistentTabView(
      controller: _controller,
      navBarHeight: 56,
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
    // return SafeArea(
    //     child: Column(children: [
    //   Observer(builder: (context) {
    //     if (qubicHubStore.updateNeeded) {
    //       return Container(
    //           width: double.infinity,
    //           color: Colors.red,
    //           child: Column(children: [
    //             TextButton(
    //                 onPressed: () {},
    //                 child: const Text(
    //                     "This is an outdated version. Please update"))
    //           ]));
    //     }
    //     return Container();
    //   }),
    //   Observer(builder: (context) {
    //     if ((qubicHubStore.notice != null) && (qubicHubStore.notice != "")) {
    //       return Container(
    //           width: double.infinity,
    //           color: Theme.of(context).cardColor,
    //           child: Column(children: [
    //             Flex(direction: Axis.horizontal, children: [
    //               Expanded(
    //                   child: Padding(
    //                       padding:
    //                           const EdgeInsets.all(ThemePaddings.smallPadding),
    //                       child: Text(qubicHubStore.notice!,
    //                           softWrap: true,
    //                           maxLines: 3,
    //                           style: Theme.of(context)
    //                               .textTheme
    //                               .labelSmall!
    //                               .copyWith(
    //                                   fontStyle: FontStyle.italic,
    //                                   color: Theme.of(context)
    //                                       .colorScheme
    //                                       .secondary)))),
    //               IconButton(
    //                   onPressed: () {
    //                     qubicHubStore.setNotice(null);
    //                   },
    //                   icon: Icon(Icons.close))
    //             ])
    //           ]));
    //     }
    //     return Container();
    //   }),
    //   Expanded(
    //       child: PersistentTabView(
    //     controller: _controller,
    //     navBarBuilder: (navBarConfig) => Style1BottomNavBar(
    //         navBarConfig: navBarConfig,
    //         navBarDecoration: NavBarDecoration(
    //             borderRadius: BorderRadius.circular(10.0),
    //             color: LightThemeColors.navBg)),

    //     tabs: _tabs(),

    //     backgroundColor: LightThemeColors.navBg,

    //     // Default is Colors.white.
    //     handleAndroidBackButtonPress: true, // Default is true.
    //     resizeToAvoidBottomInset:
    //         true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
    //     stateManagement: true, // Default is true.
    //   )),
    //]));
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
