import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class PrivateSeedWarning extends StatelessWidget {
  final String title;
  final String description;
  const PrivateSeedWarning(
      {super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return ThemedControls.card(
        borderColor: LightThemeColors.warning40,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            SvgPicture.asset(AppIcons.warning, height: 20),
            ThemedControls.spacerHorizontalSmall(),
            Text(
              title,
              style: TextStyles.labelText
                  .copyWith(color: LightThemeColors.warning40),
            )
          ]),
          ThemedControls.spacerVerticalSmall(),
          Text(
            description,
            style: TextStyles.secondaryText,
          )
        ]));
  }
}
