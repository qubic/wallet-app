import 'package:flutter/material.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String continueText;
  final Function() continueFunction;
  final String? cancelText;
  final Function()? cancelFunction;
  const ConfirmationDialog(
      {super.key,
      required this.title,
      required this.content,
      required this.continueText,
      required this.continueFunction,
      this.cancelText,
      this.cancelFunction});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return AlertDialog(
      title: Text(title, style: TextStyles.alertHeader),
      content: Text(content, style: TextStyles.alertText),
      actions: [
        ThemedControls.transparentButtonNormal(
          text: cancelText ?? l10n.generalButtonCancel,
          onPressed: () {
            cancelFunction?.call();
            Navigator.pop(context);
          },
        ),
        ThemedControls.dangerButtonBigWithClild(
          onPressed: () {
            continueFunction();
            Navigator.pop(context);
          },
          child: Text(continueText, style: TextStyles.destructiveButtonText),
        ),
      ],
    );
  }
}
