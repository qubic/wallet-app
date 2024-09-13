import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/change_foreground.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/pages/auth/erase_wallet_sheet.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/change_password.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/export_wallet_vault.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/join_community.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/manage_biometics.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/auto_lock_settings.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/resources/secure_storage.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/explorer_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/stores/qubic_hub_store.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

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
  String settingsUnlockLabel = "";
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
      final l10n = l10nOf(context);

      // setting a default fallback value
      settingsUnlockLabel =
          l10n.settingsLabelManageBiometrics(l10n.generalBiometricTypeGeneric);

      auth.getAvailableBiometrics().then((value) {
        if ((value.contains(BiometricType.face)) && (biometricType == null)) {
          setState(() {
            biometricType = BiometricType.face;
            settingsUnlockLabel = l10n
                .settingsLabelManageBiometrics(l10n.generalBiometricTypeFaceID);
            icon = Image.asset("assets/images/faceid.png");
          });
        }
        if ((value.contains(BiometricType.fingerprint)) &&
            (biometricType == null)) {
          setState(() {
            biometricType = BiometricType.fingerprint;
            settingsUnlockLabel = l10n.settingsLabelManageBiometrics(
                l10n.generalBiometricTypeTouchID);
            icon = const Icon(Icons.fingerprint);
          });
        }
        if ((value.contains(BiometricType.iris)) && (biometricType == null)) {
          setState(() {
            biometricType = BiometricType.iris;
            settingsUnlockLabel = l10n
                .settingsLabelManageBiometrics(l10n.generalBiometricTypeIris);
            icon = const Icon(Icons.remove_red_eye_outlined);
          });
        }
        if ((value.contains(BiometricType.strong)) && (biometricType == null)) {
          setState(() {
            biometricType = BiometricType.strong;
            if (UniversalPlatform.isWindows) {
              settingsUnlockLabel = l10n
                  .settingsLabelManageBiometrics(l10n.generalBiometricTypeOS);
              icon = const Icon(Icons.security);
            } else {
              settingsUnlockLabel = l10n.settingsLabelManageBiometrics(
                  l10n.generalBiometricTypeGeneric);
              icon = const Icon(Icons.fingerprint);
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTabSettings, style: TextStyles.textExtraLargeBold),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: ThemeEdgeInsets.pageInsets,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _SettingsListTile(
                      prefix: const Icon(
                        Icons.lock,
                        color: LightThemeColors.textColorSecondary,
                      ),
                      title: l10n.settingsLockWallet,
                      suffix: const SizedBox.shrink(),
                      onPressed: () {
                        appStore.reportGlobalError("");
                        appStore.reportGlobalNotification("");
                        appStore.setCurrentTabIndex(
                            0); // so after unlock, it goes to Home
                        appStore.signOut();
                        appStore.checkWalletIsInitialized();
                        timedController.stopFetchTimers();
                        context.go('/signInNoAuth');
                      },
                    ),
                    _SettingsListTile(
                      prefix: SvgPicture.asset(AppIcons.autoLock, height: 20),
                      title: l10n.settingsLabelAutlock,
                      onPressed: () {
                        pushScreen(context,
                            screen: AutoLockSettings(),
                            withNavBar: false,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino);
                      },
                    ),
                    _SettingsListTile(
                      prefix: SvgPicture.asset(AppIcons.export, height: 20),
                      title: l10n.settingsLabelExportWalletVaultFile,
                      onPressed: () async {
                        pushScreen(context,
                            screen: const ExportWalletVault(),
                            withNavBar: false,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino);
                      },
                    ),
                    _SettingsListTile(
                      prefix:
                          SvgPicture.asset(AppIcons.changePassword, height: 20),
                      title: l10n.settingsLabelChangePassword,
                      onPressed: () {
                        pushScreen(
                          context,
                          screen: const ChangePassword(),
                          withNavBar: false, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                    _SettingsListTile(
                      prefix: SvgPicture.asset(AppIcons.faceId, height: 20),
                      title: settingsUnlockLabel,
                      onPressed: () {
                        pushScreen(
                          context,
                          screen: const ManageBiometrics(),
                          withNavBar: false, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                    _SettingsListTile(
                      prefix:
                          SvgPicture.asset(AppIcons.walletConnect, height: 20),
                      title: l10n.settingsLabelWalletConnect,
                      onPressed: () {},
                    ),
                    _SettingsListTile(
                      prefix: SvgPicture.asset(AppIcons.community, height: 20),
                      title: l10n.settingsLabelJoinCommunity,
                      onPressed: () {
                        pushScreen(
                          context,
                          screen: const JoinCommunity(),
                          withNavBar: false, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                    _SettingsListTile(
                      prefix:
                          SvgPicture.asset(AppIcons.privacyPolicy, height: 20),
                      title: l10n.settingsLabelPrivacyPolicy,
                      onPressed: () {},
                      suffix:
                          SvgPicture.asset(AppIcons.externalLink, height: 20),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ThemedControls.dangerButtonBigWithClild(
                        child: Text(l10n.generalButtonEraseWalletData,
                            style: TextStyles.destructiveButtonText),
                        onPressed: () {
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
                                  timedController.stopFetchTimers();
                                  Navigator.pop(context);
                                  context.go("/signInNoAuth");
                                  _globalSnackBar.show(l10n
                                      .generalSnackBarMessageWalletDataErased);
                                }, onReject: () async {
                                  Navigator.pop(context);
                                }));
                              });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              "Qubic Wallet v.${qubicHubStore.versionInfo!}${qubicHubStore.buildNumber!.isNotEmpty ? " (${qubicHubStore.buildNumber!})" : ""}",
            )
          ],
        ),
      ),
    );
  }
}

class _SettingsListTile extends StatelessWidget {
  final String title;
  final Widget prefix;
  final Widget? suffix;
  final Function()? onPressed;
  const _SettingsListTile(
      {required this.title,
      required this.prefix,
      required this.onPressed,
      this.suffix});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              vertical: ThemePaddings.normalPadding, horizontal: 0),
          shape: const RoundedRectangleBorder()),
      onPressed: onPressed,
      child: Row(
        children: [
          prefix,
          const SizedBox(width: ThemePaddings.normalPadding),
          Expanded(
            child: Text(
              title,
              style: TextStyles.labelText,
            ),
          ),
          suffix == null
              ? const Icon(Icons.arrow_forward_ios_outlined,
                  size: 14, color: LightThemeColors.textColorSecondary)
              : suffix!
        ],
      ),
    );
  }
}
