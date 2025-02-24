import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/models/dapp_model.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/webview_screen.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class DAppTile extends StatelessWidget {
  final DAppModel dApp;
  const DAppTile({
    required this.dApp,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemePaddings.smallPadding),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(dApp.icon, height: 40),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dApp.name,
                  style: TextStyles.labelText,
                ),
                Text(
                  dApp.description,
                  style: TextStyles.smallInfoText,
                ),
              ],
            ),
          ),
          ThemedControls.transparentButtonSmall(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return WebviewScreen(initialUrl: dApp.url);
                }));
              },
              text: "Open"),
        ],
      ),
    );
  }
}
