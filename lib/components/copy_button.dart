import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/clipboard_helper.dart';
import 'package:qubic_wallet/styles/app_icons.dart';

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
      icon: SvgPicture.asset(
        AppIcons.copy,
        width: 18,
        height: 18,
        colorFilter: const ColorFilter.mode(
          LightThemeColors.primary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
