import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/app_icons.dart';

class BookmarkIconButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const BookmarkIconButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return IconButton(
      tooltip: l10n.favoritesTitle,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: onPressed,
      icon: SvgPicture.asset(
        AppIcons.bookmark,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(
          LightThemeColors.primary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
