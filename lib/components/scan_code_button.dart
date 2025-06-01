import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class ScanCodeButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ScanCodeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Align(
        alignment: Alignment.topLeft,
        child: ThemedControls.primaryButtonNormal(
            onPressed: onPressed,
            text: l10n.generalButtonUseQRCode,
            icon: !LightThemeColors.shouldInvertIcon
                ? ThemedControls.invertedColors(
                    child: Image.asset("assets/images/Group 2294.png"))
                : Image.asset("assets/images/Group 2294.png")));
  }
}
