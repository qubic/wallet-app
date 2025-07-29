import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class CopyButton extends StatelessWidget {
  final String copiedText;
  final String? snackbarMessage;
  final VoidCallback? onTap;

  const CopyButton(
      {super.key, required this.copiedText, this.snackbarMessage, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          await copyToClipboard(copiedText, context, message: snackbarMessage);
          onTap?.call();
        },
        icon: LightThemeColors.shouldInvertIcon
            ? ThemedControls.invertedColors(
                child: Image.asset("assets/images/Group 2400.png"))
            : Image.asset("assets/images/Group 2400.png"));
  }
}
