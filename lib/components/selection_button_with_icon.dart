import 'package:flutter/cupertino.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class SelectionButtonWithIcon extends StatelessWidget {
  final Function? onPressed;
  final String assetPath;
  final String title;
  final String subtitle;
  final bool hasError;

  const SelectionButtonWithIcon(
      {super.key,
      required this.onPressed,
      required this.assetPath,
      required this.title,
      required this.subtitle,
      required this.hasError});

  @override
  Widget build(BuildContext context) {
    return ThemedControls.darkButtonBigWithChild(
        error: hasError,
        onPressed: () async {
          if (onPressed != null) {
            await onPressed!();
          }
        },
        child: Padding(
            padding: const EdgeInsets.all(ThemePaddings.normalPadding),
            child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(assetPath),
                  ThemedControls.spacerHorizontalNormal(),
                  Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: TextStyles.textBold),
                          ThemedControls.spacerVerticalSmall(),
                          Container(
                              child: Text(subtitle,
                                  style: TextStyles.secondaryText))
                        ]),
                  )
                ])));
  }
}
