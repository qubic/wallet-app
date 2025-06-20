import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/webview_screen.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DAppTile extends StatelessWidget {
  final DappDto dApp;
  final bool openFullScreen;
  const DAppTile({
    required this.dApp,
    this.openFullScreen = false,
    super.key,
  });

  onTap(BuildContext context) {
    if (dApp.url == null) return;
    if (openFullScreen) {
      launchUrlString(dApp.url!, mode: LaunchMode.inAppBrowserView);
      return;
    }
    pushScreen(
      context,
      screen: WebviewScreen(initialUrl: dApp.url!),
      pageTransitionAnimation: PageTransitionAnimation.slideUp,
      withNavBar: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(context),
      child: Padding(
        padding: const EdgeInsets.only(bottom: ThemePaddings.smallPadding),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: dApp.icon?.isNotEmpty == true
                  ? Image.network(dApp.icon!, height: 40)
                  : Image.asset(Config.dAppDefaultImageName, height: 40),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dApp.name ?? "-",
                    style: TextStyles.labelText,
                  ),
                  ThemedControls.spacerVerticalMini(),
                  Text(
                    dApp.description ?? "-",
                    style: TextStyles.smallInfoText,
                  ),
                ],
              ),
            ),
            ThemedControls.secondaryButtonWithChild(
              onPressed: () => onTap(context),
              child: Text(
                dApp.openButtonTitle ?? l10n.dAppOpenButton,
                style: TextStyles.primaryButtonTextSmall
                    .copyWith(color: LightThemeColors.primary40),
              ),
            )
          ],
        ),
      ),
    );
  }
}
