import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:qubic_wallet/components/beta_badge.dart';
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
import 'package:qubic_wallet/pages/main/wallet_contents/settings/wallet_connect/wallet_connect.dart';
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
  String settingsUnlockIconPath = AppIcons.fingerPrint;
  bool isFirstOpen = true;

  final defaultIconHeight = 20.0;

  @override
  void didChangeDependencies() {
    if (isFirstOpen) {
      biometricService.getAvailableBiometric(context).then((result) {
        setState(() {
          settingsUnlockLabel = result['label'];
          settingsUnlockIconPath = result['icon'];
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
                              prefix: SvgPicture.asset(AppIcons.lock,
                                  height: defaultIconHeight),
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
                              prefix: SizedBox(
                                width: 24,
                                child: SvgPicture.asset(AppIcons.autoLock,
                                    height: defaultIconHeight),
                              ),
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
                              prefix: SizedBox(
                                width: 24,
                                child: SvgPicture.asset(AppIcons.changePassword,
                                    height: defaultIconHeight),
                              ),
                              title: l10n.settingsLabelChangePassword,
                              path: const ChangePassword(),
                            ),
                            SettingsListTile(
                              prefix: SvgPicture.asset(
                                settingsUnlockIconPath,
                                height: defaultIconHeight,
                                color: LightThemeColors.textColorSecondary,
                              ),
                              title: settingsUnlockLabel,
                              path: const ManageBiometrics(),
                            ),
                            SettingsListTile(
                                prefix: SvgPicture.asset(AppIcons.walletConnect,
                                    height: defaultIconHeight),
                                title: l10n.settingsLabelWalletConnect,
                                afterText: const BetaBadge(),
                                path: const WalletConnectSettings()),
                            SettingsListTile(
                              prefix: SvgPicture.asset(
                                AppIcons.support,
                                height: defaultIconHeight,
                                color: LightThemeColors.textColorSecondary,
                              ),
                              title: "Support",
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.email_outlined,
                                              size: defaultIconHeight,
                                              color: LightThemeColors
                                                  .textColorSecondary),
                                          title: const Text("Send email"),
                                          onTap: () {
                                            final platform =
                                                Theme.of(context).platform;
                                            String emailTo = "wallet+";
                                            String subject =
                                                "Feedback for Qubic Wallet - ";
                                            if (platform ==
                                                TargetPlatform.iOS) {
                                              emailTo += "ios@qubic.org";
                                              subject += "iOS";
                                            } else if (platform ==
                                                TargetPlatform.android) {
                                              emailTo += "android@qubic.org";
                                              subject += "Android";
                                            } else if (platform ==
                                                TargetPlatform.macOS) {
                                              emailTo += "macos@qubic.org";
                                              subject += "MacOS";
                                            }
                                            final emailUri = Uri(
                                              scheme: 'mailto',
                                              path: emailTo,
                                              query: 'subject=$subject',
                                            );
                                            launchUrlString(
                                                emailUri.toString());
                                          },
                                        ),
                                        ListTile(
                                          leading: SvgPicture.asset(
                                              AppIcons.github,
                                              height: defaultIconHeight),
                                          title: const Text(
                                              "GitHub (File an issue)"),
                                          trailing: SvgPicture.asset(
                                              AppIcons.externalLink,
                                              height: defaultIconHeight),
                                          onTap: () {
                                            launchUrlString(
                                              "https://github.com/qubic/wallet-app/issues/new",
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          },
                                        ),
                                        ListTile(
                                          leading: SvgPicture.asset(
                                              AppIcons.discord,
                                              height: defaultIconHeight),
                                          title: const Text(
                                              "Discord (Support channel)"),
                                          trailing: SvgPicture.asset(
                                              AppIcons.externalLink,
                                              height: defaultIconHeight),
                                          onTap: () {
                                            launchUrlString(
                                              "https://discord.com/channels/768887649540243497/1074609434015322132",
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
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
                                    "https://qubic.org/privacy-policy",
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
