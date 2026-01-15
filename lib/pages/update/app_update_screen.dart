import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/app_version_check_model.dart';
import 'package:qubic_wallet/stores/app_update_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'components/app_update_logo.dart';
part 'components/app_update_header.dart';
part 'components/app_update_info_card.dart';
part 'components/app_update_buttons.dart';

class AppUpdateScreen extends StatelessWidget {
  const AppUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appUpdateStore = getIt<AppUpdateStore>();
    final settingsStore = getIt<SettingsStore>();

    return Observer(
      builder: (context) {
        final versionInfo = appUpdateStore.currentVersionInfo;

        if (versionInfo == null) {
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
                  const _AppUpdateLogo(),
                  _AppUpdateHeader(isForceUpdate: isForceUpdate),
                  ThemedControls.spacerVerticalBig(),
                  _AppUpdateInfoCard(
                    versionInfo: versionInfo,
                    currentVersion: settingsStore.versionInfo,
                    onUpdatePressed: () => _launchUpdateUrl(versionInfo),
                  ),
                  const Spacer(),
                  _AppUpdateButtons(
                    versionInfo: versionInfo,
                    onUpdatePressed: () => _launchUpdateUrl(versionInfo),
                    onLaterPressed: () {
                      appUpdateStore.handleLaterAction();
                      context.go('/');
                    },
                    onIgnorePressed: () {
                      appUpdateStore.handleIgnoreAction(versionInfo.version);
                      context.go('/');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchUpdateUrl(AppVersionCheckModel versionInfo) async {
    final url = versionInfo.getUpdateUrlForPlatform();
    if (url == null) {
      appLogger.e('[AppUpdateScreen] No update URL available for platform');
      return;
    }

    try {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      appLogger.e('[AppUpdateScreen] Failed to launch update URL: $e');
      return;
    }
  }
}
