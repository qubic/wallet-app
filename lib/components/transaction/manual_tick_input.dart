import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/extensions/as_thousands.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

/// Manual tick input field with "Set Current Tick" button
class ManualTickInput extends StatelessWidget {
  final TextEditingController controller;
  final int currentTick;
  final bool isLoading;
  final VoidCallback onSetCurrentTick;

  const ManualTickInput({
    super.key,
    required this.controller,
    required this.currentTick,
    required this.isLoading,
    required this.onSetCurrentTick,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return Column(
      children: [
        ThemedControls.spacerVerticalSmall(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                l10n.generalLabelTick,
                style: TextStyles.labelTextNormal,
              ),
            ),
            ThemedControls.transparentButtonBigWithChild(
              child: Observer(
                builder: (context) {
                  return Text(
                    l10n.sendItemButtonSetCurrentTick(currentTick.asThousands()),
                    style: TextStyles.transparentButtonTextSmall,
                  );
                },
              ),
              onPressed: onSetCurrentTick,
            ),
          ],
        ),
        FormBuilderTextField(
          decoration: ThemeInputDecorations.normalInputbox,
          name: l10n.generalLabelTick,
          readOnly: isLoading,
          controller: controller,
          enableSuggestions: false,
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: l10n.generalErrorRequiredField,
            ),
            FormBuilderValidators.numeric(),
          ]),
          maxLines: 1,
          autocorrect: false,
          autofillHints: null,
        ),
      ],
    );
  }
}
