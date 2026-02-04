import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class BookmarkIconButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const BookmarkIconButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: onPressed,
      icon: LightThemeColors.shouldInvertIcon
          ? ThemedControls.invertedColors(
              child: Image.asset("assets/images/bookmark-24.png"))
          : Image.asset("assets/images/bookmark-24.png"),
    );
  }
}
