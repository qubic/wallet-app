import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class SettingsListTile extends StatelessWidget {
  final String title;
  final Widget prefix;
  final Widget? suffix;
  final Widget? afterText;
  final Function()? onPressed;
  final Widget? path;
  const SettingsListTile(
      {super.key,
      required this.title,
      required this.prefix,
      this.afterText,
      this.onPressed,
      this.path,
      this.suffix});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              vertical: ThemePaddings.normalPadding, horizontal: 0),
          shape: const RoundedRectangleBorder()),
      onPressed: path != null
          ? () {
              pushScreen(context,
                  screen: path!,
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino);
            }
          : onPressed,
      child: Row(
        children: [
          SizedBox(width: 24, child: prefix),
          const SizedBox(width: ThemePaddings.normalPadding),
          if (afterText == null)
            Expanded(
              child: Text(
                title,
                style: TextStyles.labelText,
              ),
            ),
          if (afterText != null) ...[
            Text(
              title,
              style: TextStyles.labelText,
            ),
            const SizedBox(width: ThemePaddings.smallPadding),
            afterText!,
            const Spacer(),
          ],
          suffix == null
              ? ThemedControls.chevronIcon
              : suffix!
        ],
      ),
    );
  }
}
