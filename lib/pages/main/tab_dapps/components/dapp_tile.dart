import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/dapp_model.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/webview_screen.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DAppTile extends StatelessWidget {
  final DAppModel dApp;
  final bool openFullScreen;
  const DAppTile({
    required this.dApp,
    this.openFullScreen = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemePaddings.smallPadding),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(dApp.icon, height: 40),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dApp.name,
                  style: TextStyles.labelText,
                ),
                ThemedControls.spacerVerticalMini(),
                Text(
                  dApp.description,
                  style: TextStyles.smallInfoText,
                ),
              ],
            ),
          ),
          ThemedControls.transparentButtonSmall(
            onPressed: () {
              if (openFullScreen) {
                launchUrlString(dApp.url, mode: LaunchMode.inAppBrowserView);
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return WebviewScreen(initialUrl: dApp.url);
                }),
              );
            },
            text: l10n.dAppOpenButton,
          )
        ],
      ),
    );
  }
}
