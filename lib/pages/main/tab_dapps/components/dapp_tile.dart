import 'package:flutter/material.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/dtos/dapp_dto.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/dapp_helpers.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/components/dapp_icon.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DAppTile extends StatelessWidget {
  final DappDto dApp;
  final bool openFullScreen;
  final VoidCallback? onReturn;
  const DAppTile({
    required this.dApp,
    this.openFullScreen = false,
    this.onReturn,
    super.key,
  });

  onTap(BuildContext context) async {
    if (dApp.url == null) return;
    if (openFullScreen) {
      launchUrlString(dApp.url!, mode: LaunchMode.inAppBrowserView);
      return;
    }
    await openDappUrl(
      context,
      dApp.url!,
      withNavBar: true,
    );
    // Call the callback when returning from webview
    onReturn?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            0,
            ThemePaddings.smallPadding,
            ThemePaddings.normalPadding,
            ThemePaddings.smallPadding),
        child: Row(
          children: [
            DappIcon(
              iconUrl: dApp.icon,
              size: Config.dAppIconSize,
            ),
            ThemedControls.spacerHorizontalNormal(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dApp.name ?? "-",
                    style: TextStyles.labelTextTight,
                  ),
                  ThemedControls.spacerVerticalTiny(),
                  Text(
                    dApp.description ?? "-",
                    style: TextStyles.smallInfoTextTight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
