import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/change_foreground.dart';
import 'package:qubic_wallet/components/gradient_container.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/pages/auth/erase_wallet_sheet.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/about_wallet.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/change_password.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/join_community.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/manage_biometics.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/explorer_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/stores/qubic_hub_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:universal_platform/universal_platform.dart';

class TabSettings extends StatefulWidget {
  const TabSettings({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TabSettingsState createState() => _TabSettingsState();
}

class _TabSettingsState extends State<TabSettings> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final ExplorerStore explorerStore = getIt<ExplorerStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  final QubicHubStore qubicHubStore = getIt<QubicHubStore>();
  final SecureStorage secureStorage = getIt<SecureStorage>();
  final LocalAuthentication auth = LocalAuthentication();

  final QubicLi li = getIt<QubicLi>();
  final _globalSnackBar = getIt<GlobalSnackBar>();
  final TimedController timedController = getIt<TimedController>();

  //Pagination Related
  int numberOfPages = 0;
  int currentPage = 1;
  int itemsPerPage = 1000;

  BiometricType? biometricType; //The type of biometric available
  String unlockLabel = "Unlock with Biometrics";
  PackageInfo? packageInfo; // = await PackageInfo.fromPlatform();
  Widget icon = const Icon(Icons.fingerprint);

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) => setState(() {
          packageInfo = value;
        }));
    auth.canCheckBiometrics.then((value) {
      auth.getAvailableBiometrics().then((value) {
        if ((value.contains(BiometricType.face)) && (biometricType == null)) {
          setState(() {
            biometricType = BiometricType.face;
            unlockLabel = "Unlock with Face ID";
            icon = Image.asset("assets/images/faceid.png");
          });
        }
        if ((value.contains(BiometricType.fingerprint)) &&
            (biometricType == null)) {
          setState(() {
            biometricType = BiometricType.fingerprint;
            unlockLabel = "Unlock with Touch ID";
            icon = const Icon(Icons.fingerprint);
          });
        }
        if ((value.contains(BiometricType.iris)) && (biometricType == null)) {
          setState(() {
            biometricType = BiometricType.iris;
            unlockLabel = "Unlock with Iris";
            icon = const Icon(Icons.remove_red_eye_outlined);
          });
        }
        if ((value.contains(BiometricType.strong)) && (biometricType == null)) {
          setState(() {
            biometricType = BiometricType.strong;
            if (UniversalPlatform.isWindows) {
              unlockLabel = "Unlock with OS";
              icon = const Icon(Icons.security);
            } else {
              unlockLabel = "Unlock with Biometrics";
              icon = const Icon(Icons.fingerprint);
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getHeader() {
    return Padding(
        padding: const EdgeInsets.only(
            left: ThemePaddings.normalPadding,
            right: ThemePaddings.normalPadding,
            top: ThemePaddings.hugePadding,
            bottom: ThemePaddings.smallPadding),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text("Settings", style: TextStyles.pageTitle)]));
  }

  Widget getBody() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [getHeader(), getSettings()]);
  }

  Widget getSettingsHeader(String text, bool isFirst) {
    return Padding(
        padding: isFirst
            ? const EdgeInsets.fromLTRB(0, 0, 0, ThemePaddings.smallPadding)
            : const EdgeInsets.fromLTRB(
                0, ThemePaddings.bigPadding, 0, ThemePaddings.smallPadding),
        child: Transform.translate(
            offset: const Offset(-16, 0),
            child: Text(text, style: TextStyles.textBold)));
  }

  Widget getSettings() {
    var theme = SettingsThemeData(
      settingsSectionBackground: LightThemeColors.cardBackground,
      //Theme.of(context).cardTheme.color,
      settingsListBackground: LightThemeColors.background,
      dividerColor: Colors.transparent,
      titleTextColor: Theme.of(context).colorScheme.onBackground,
    );

    Widget getTrailingArrow() {
      return Container();
//      return Icon(Icons.arrow_forward_ios_outlined,
      //        color:
      //          Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.2));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: SettingsList(
        shrinkWrap: true,
        applicationType: ApplicationType.material,
        contentPadding: const EdgeInsets.all(0),
        darkTheme: theme,
        lightTheme: theme,
        sections: [
          SettingsSection(
            title: getSettingsHeader("Accounts and Data", true),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: ChangeForeground(
                    child: const Icon(Icons.lock),
                    color: LightThemeColors.gradient1),
                title: Text('Lock Wallet', style: TextStyles.textNormal),
                trailing: Container(),
                onPressed: (BuildContext context) {
                  appStore.reportGlobalError("");
                  appStore.reportGlobalNotification("");
                  appStore.signOut();
                  appStore.checkWalletIsInitialized();
                  timedController.stopFetchTimer();
                  context.go('/signInNoAuth');
                },
              ),
              SettingsTile.navigation(
                leading: ChangeForeground(
                    child: const Icon(Icons.cleaning_services_outlined),
                    color: LightThemeColors.gradient1),
                title: Text('Erase Wallet Data', style: TextStyles.textNormal),
                trailing: Container(),
                onPressed: (BuildContext context) async {
                  //MODAL TO CHECK IF USER AGREES
                  showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      useSafeArea: true,
                      backgroundColor: LightThemeColors.background,
                      builder: (BuildContext context) {
                        return SafeArea(
                            child: EraseWalletSheet(onAccept: () async {
                          if (!context.mounted) return;
                          await secureStorage.deleteWallet();
                          await settingsStore.loadSettings();
                          appStore.checkWalletIsInitialized();
                          appStore.signOut();
                          timedController.stopFetchTimer();
                          Navigator.pop(context);
                          context.go("/signInNoAuth");
                          _globalSnackBar
                              .show("Wallet data erased from device");
                        }, onReject: () async {
                          Navigator.pop(context);
                        }));
                      });
                },
              ),
            ],
          ),
          SettingsSection(
            title: getSettingsHeader("Security", true),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                  leading: ChangeForeground(
                      child: const Icon(Icons.password),
                      color: LightThemeColors.gradient1),
                  trailing: getTrailingArrow(),
                  title: Text('Change Password', style: TextStyles.textNormal),
                  onPressed: (BuildContext? context) async {
                    pushScreen(
                      context!,
                      screen: const ChangePassword(),
                      withNavBar: false, // OPTIONAL VALUE. True by default.
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  }),
              SettingsTile.navigation(
                leading: ChangeForeground(
                    color: LightThemeColors.gradient1, child: icon),
                trailing: getTrailingArrow(),
                title: Text(unlockLabel, style: TextStyles.textNormal),
                value: Observer(builder: (context) {
                  return settingsStore.settings.biometricEnabled
                      ? Text("Enabled",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontFamily: ThemeFonts.secondary))
                      : const Text("Disabled");
                }),
                onPressed: (BuildContext? context) {
                  pushScreen(
                    context!,
                    screen: const ManageBiometrics(),
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
            ],
          ),
          SettingsSection(
              title: getSettingsHeader("About", true),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: ChangeForeground(
                      child: const Icon(Icons.people),
                      color: LightThemeColors.gradient1),
                  title: Text('Join Community', style: TextStyles.textNormal),
                  trailing: Container(),
                  onPressed: (BuildContext? context) async {
                    pushScreen(
                      context!,
                      screen: const JoinCommunity(),
                      withNavBar: false, // OPTIONAL VALUE. True by default.
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                ),
                SettingsTile.navigation(
                  leading: ChangeForeground(
                      child: const Icon(Icons.account_balance_wallet_outlined),
                      color: LightThemeColors.gradient1),
                  trailing: Observer(builder: (BuildContext context) {
                    if (qubicHubStore.updateAvailable) {
                      return const Icon(Icons.info, color: Colors.red);
                    }
                    return getTrailingArrow();
                  }),
                  title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Wallet Info', style: TextStyles.textNormal),
                        Observer(builder: (BuildContext context) {
                          if (qubicHubStore.versionInfo == null) {
                            return const Text("Loading...");
                          }
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "Version ${qubicHubStore.versionInfo!}${qubicHubStore.buildNumber!.isNotEmpty ? " (${qubicHubStore.buildNumber!})" : ""}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontFamily: ThemeFonts.secondary)),
                                qubicHubStore.updateAvailable
                                    ? Text("Update available",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(
                                                color: Colors.red,
                                                fontFamily:
                                                    ThemeFonts.secondary))
                                    : Container(),
                              ]);
                        })
                      ]),
                  // onPressed: (BuildContext? context) async {
                  //   pushNewScreen(
                  //     context!,
                  //     screen: const AboutWallet(),
                  //     withNavBar: false, // OPTIONAL VALUE. True by default.
                  //     pageTransitionAnimation:
                  //         PageTransitionAnimation.cupertino,
                  //   );
                  // }),
                ),
              ])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          minimum: ThemeEdgeInsets.pageInsets
              .copyWith(left: 0, right: 0, top: 0, bottom: 0),
          child: Column(children: [
            Expanded(
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: getBody()))
          ])),
    );
  }
}
