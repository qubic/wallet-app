import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/app_version_check_model.dart';
import 'package:qubic_wallet/stores/app_update_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppUpdateScreen extends StatelessWidget {
  const AppUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appUpdateStore = getIt<AppUpdateStore>();
    final settingsStore = getIt<SettingsStore>();
    final l10n = l10nOf(context);

    return Observer(
      builder: (context) {
        final versionInfo = appUpdateStore.currentVersionInfo;

        if (versionInfo == null) {
          // Should not happen, but handle gracefully
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/');
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isForceUpdate = versionInfo.updateType == UpdateType.force;

        return Scaffold(
          backgroundColor: LightThemeColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(ThemePaddings.hugePadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/blue-logo.png',
                      height: 100,
                    ),
                  ),
                  // Title
                  Text(
                    isForceUpdate
                        ? l10n.updateRequiredTitle
                        : l10n.updateAvailableTitle,
                    style: TextStyles.textEnormous.copyWith(
                      fontWeight: FontWeight.bold,
                      color: LightThemeColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  ThemedControls.spacerVerticalBig(),

                  // Message
                  Text(
                    isForceUpdate
                        ? l10n.updateRequiredMessage
                        : l10n.updateAvailableMessage,
                    style: TextStyles.textNormal.copyWith(
                      color: LightThemeColors.textColorSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  ThemedControls.spacerVerticalBig(),
                  ThemedControls.card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          l10n.updateScreenCurrentVersion,
                          settingsStore.versionInfo ?? 'Unknown',
                        ),
                        ThemedControls.spacerVerticalSmall(),
                        _buildInfoRow(
                          l10n.updateScreenNewVersion,
                          versionInfo.version,
                        ),
                        if (versionInfo.releaseNotes != null) ...[
                          ThemedControls.spacerVerticalSmall(),
                          Text(
                            l10n.updateScreenWhatsNew,
                            style: TextStyles.secondaryText,
                          ),
                          ThemedControls.spacerVerticalSmall(),
                          Text(
                            versionInfo.releaseNotes!,
                            style: TextStyles.textNormal.copyWith(
                              color: LightThemeColors.primary,
                            ),
                          ),
                        ],
                        // Update button inside card when all 3 options available
                        if (_hasAllOptions(versionInfo)) ...[
                          ThemedControls.spacerVerticalBig(),
                          SizedBox(
                            width: double.infinity,
                            child: ThemedControls.primaryButtonBig(
                              onPressed: () => _launchUpdateUrl(versionInfo),
                              text: l10n.updateButton,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Buttons
                  _buildButtons(
                    context,
                    l10n,
                    versionInfo,
                    appUpdateStore,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _hasAllOptions(AppVersionCheckModel versionInfo) {
    return versionInfo.showLaterButton && versionInfo.showIgnoreButton;
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.secondaryText,
        ),
        Text(
          value,
          style: TextStyles.textNormal.copyWith(
            fontWeight: FontWeight.w600,
            color: LightThemeColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(
    BuildContext context,
    AppLocalizations l10n,
    AppVersionCheckModel versionInfo,
    AppUpdateStore appUpdateStore,
  ) {
    // Scenario 1: Force update - only Update button at bottom
    if (versionInfo.updateType == UpdateType.force) {
      return ThemedControls.primaryButtonBig(
        onPressed: () => _launchUpdateUrl(versionInfo),
        text: l10n.updateButton,
      );
    }

    final showLater = versionInfo.showLaterButton;
    final showIgnore = versionInfo.showIgnoreButton;

    // Scenario 3: All three options - Update in card, Later & Skip in row
    if (showLater && showIgnore) {
      return Row(
        children: [
          Expanded(
            child: ThemedControls.transparentButtonNormal(
              onPressed: () {
                appUpdateStore.handleLaterAction();
                context.go('/');
              },
              text: l10n.laterButton,
            ),
          ),
          ThemedControls.spacerHorizontalNormal(),
          Expanded(
            child: ThemedControls.dangerButtonBigWithClild(
              onPressed: () {
                appUpdateStore.handleIgnoreAction(versionInfo.version);
                context.go('/');
              },
              child: Text(
                l10n.ignoreVersionButton,
                style: TextStyles.destructiveButtonText,
              ),
            ),
          ),
        ],
      );
    }

    // Scenario 2: Two options - Update first, then the other option
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ThemedControls.primaryButtonBig(
          onPressed: () => _launchUpdateUrl(versionInfo),
          text: l10n.updateButton,
        ),
        if (showLater)
          ThemedControls.transparentButtonNormal(
            onPressed: () {
              appUpdateStore.handleLaterAction();
              context.go('/');
            },
            text: l10n.laterButton,
          ),
        if (showIgnore)
          ThemedControls.dangerButtonBigWithClild(
            onPressed: () {
              appUpdateStore.handleIgnoreAction(versionInfo.version);
              context.go('/');
            },
            child: Text(
              l10n.ignoreVersionButton,
              style: TextStyles.destructiveButtonText,
            ),
          ),
      ],
    );
  }

  Future<void> _launchUpdateUrl(AppVersionCheckModel versionInfo) async {
    final url = versionInfo.getUpdateUrlForPlatform();
    if (url == null) {
      // Handle error - no URL for this platform
      return;
    }

    try {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Handle error - could show snackbar
      // For now, just log it (app_logger is available via imports)
      return;
    }
  }
}
