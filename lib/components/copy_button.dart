import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/clipboard_helper.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class CopyButton extends StatelessWidget {
  final String copiedText;
  final String? snackbarMessage;
  final VoidCallback? onTap;
  final bool isSensitive;

  const CopyButton({
    super.key,
    required this.copiedText,
    this.snackbarMessage,
    this.onTap,
    this.isSensitive = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await ClipboardHelper.copyToClipboard(
          copiedText,
          context,
          message: snackbarMessage,
          isSensitive: isSensitive,
        );
        onTap?.call();
      },
      icon: LightThemeColors.shouldInvertIcon
          ? ThemedControls.invertedColors(
              child: Image.asset("assets/images/Group 2400.png"))
          : Image.asset("assets/images/Group 2400.png"),
    );
  }
}
