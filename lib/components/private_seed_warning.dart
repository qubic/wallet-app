import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/text_styles.dart';

class PrivateSeedWarning extends StatelessWidget {
  final String title;
  final String description;
  const PrivateSeedWarning(
      {super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LightThemeColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LightThemeColors.warning40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyles.alertHeader
                  .copyWith(color: LightThemeColors.warning40)),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyles.alertText
                .copyWith(color: LightThemeColors.warning40),
          ),
        ],
      ),
    );
  }
}
