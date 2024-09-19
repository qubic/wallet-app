import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/tab_settings/components/erase_wallet_data_button.dart';
import 'package:qubic_wallet/pages/main/tab_settings/components/settings_list_tile.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/auto_lock_settings.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/change_password.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/export_wallet_vault.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/join_community/join_community.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/manage_biometics.dart';
import 'package:qubic_wallet/services/biometric_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/qubic_hub_store.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TabSettings extends StatefulWidget {
  const TabSettings({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TabSettingsState createState() => _TabSettingsState();
}

class _TabSettingsState extends State<TabSettings> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final QubicHubStore qubicHubStore = getIt<QubicHubStore>();
  final BiometricService biometricService = getIt<BiometricService>();
  final TimedController timedController = getIt<TimedController>();

  String settingsUnlockLabel = "";
  Widget settingsUnlockIcon = const Icon(Icons.fingerprint);
  bool isFirstOpen = true;

  final defaultIconHeight = 20.0;

  @override
  void didChangeDependencies() {
    if (isFirstOpen) {
      biometricService.getAvailableBiometric(context).then((result) {
        setState(() {
          settingsUnlockLabel = result['label'];
          settingsUnlockIcon = result['icon'];
        });
      });
      isFirstOpen = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTabSettings, style: TextStyles.textExtraLargeBold),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: ThemeEdgeInsets.pageInsets,
                        child: Column(
                          children: [
                            SettingsListTile(
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
                            SettingsListTile(
                              prefix: SvgPicture.asset(AppIcons.autoLock,
                                  height: defaultIconHeight),
                              title: l10n.settingsLabelAutlock,
                              path: AutoLockSettings(),
                            ),
                            SettingsListTile(
                              prefix: SvgPicture.asset(AppIcons.export,
                                  height: defaultIconHeight),
                              title: l10n.settingsLabelExportWalletVaultFile,
                              path: const ExportWalletVault(),
                            ),
                            SettingsListTile(
                              prefix: SvgPicture.asset(AppIcons.changePassword,
                                  height: defaultIconHeight),
                              title: l10n.settingsLabelChangePassword,
                              path: const ChangePassword(),
                            ),
                            SettingsListTile(
                              prefix: settingsUnlockIcon,
                              title: settingsUnlockLabel,
                              path: const ManageBiometrics(),
                            ),
                            // SettingsListTile(
                            //   prefix:
                            //       SvgPicture.asset(AppIcons.walletConnect, height: defaultIconHeight),
                            //   title: l10n.settingsLabelWalletConnect,
                            //   onPressed: () {},
                            // ),
                            SettingsListTile(
                              prefix: SvgPicture.asset(AppIcons.community,
                                  height: defaultIconHeight),
                              title: l10n.settingsLabelJoinCommunity,
                              path: const JoinCommunity(),
                            ),
                            SettingsListTile(
                              prefix: SvgPicture.asset(AppIcons.privacyPolicy,
                                  height: defaultIconHeight),
                              title: l10n.settingsLabelPrivacyPolicy,
                              onPressed: () {
                                launchUrlString(
                                    "https://qubic.org/Privacy-policy",
                                    mode: LaunchMode.externalApplication);
                              },
                              suffix: SvgPicture.asset(AppIcons.externalLink,
                                  height: defaultIconHeight),
                            ),
                            EraseWalletDataButton(),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: ThemePaddings.bigPadding),
                      child: Text(
                        "Qubic Wallet v.${qubicHubStore.versionInfo!}${qubicHubStore.buildNumber!.isNotEmpty ? " (${qubicHubStore.buildNumber!})" : ""}",
                        textAlign: TextAlign.center,
                        style: TextStyles.secondaryTextSmall,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
