import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/components/bookmark_icon_button.dart';
import 'package:qubic_wallet/components/qr_scan_icon_button.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class DestinationAddressField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final bool showBookmarkPicker;
  final VoidCallback? onBookmarkPressed;
  final FormFieldValidator<String>? additionalValidator;
  final ValueChanged<String?>? onSubmitted;
  final bool showLabel;

  const DestinationAddressField({
    super.key,
    required this.controller,
    this.isLoading = false,
    this.showBookmarkPicker = false,
    this.onBookmarkPressed,
    this.additionalValidator,
    this.onSubmitted,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.accountSendLabelDestinationAddress,
                  style: TextStyles.labelTextNormal,
                ),
              ),
              ThemedControls.transparentButtonSmall(
                onPressed: () async {
                  final clipboardData =
                      await Clipboard.getData(Clipboard.kTextPlain);
                  if (clipboardData != null && clipboardData.text != null) {
                    controller.text = clipboardData.text!;
                  }
                },
                text: l10n.generalButtonPaste,
              ),
            ],
          ),
          ThemedControls.spacerVerticalMini(),
        ],
        FormBuilderTextField(
          name: "destinationID",
          readOnly: isLoading,
          controller: controller,
          enableSuggestions: false,
          keyboardType: TextInputType.visiblePassword,
          onSubmitted: onSubmitted,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
                errorText: l10n.generalErrorRequiredField),
            CustomFormFieldValidators.isPublicID(context: context),
            if (additionalValidator != null) additionalValidator!,
          ]),
          maxLines: 3,
          style: TextStyles.inputBoxSmallStyle,
          maxLength: 60,
          decoration: ThemeInputDecorations.normalMultiLineInputbox.copyWith(
            hintText: "",
            hintMaxLines: 3,
            suffixIcon: _SuffixIconRow(
              controller: controller,
              showBookmarkPicker: showBookmarkPicker,
              onBookmarkPressed: onBookmarkPressed,
            ),
          ),
          autocorrect: false,
          autofillHints: null,
        ),
      ],
    );
  }
}

class _SuffixIconRow extends StatelessWidget {
  final TextEditingController controller;
  final bool showBookmarkPicker;
  final VoidCallback? onBookmarkPressed;

  const _SuffixIconRow({
    required this.controller,
    required this.showBookmarkPicker,
    this.onBookmarkPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasButtons = isMobile || showBookmarkPicker;
    if (!hasButtons) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMobile) QrScanIconButton(controller: controller),
        if (isMobile && showBookmarkPicker)
          Container(
            height: 24,
            width: 1,
            color: LightThemeColors.inputBorderColor,
          ),
        if (showBookmarkPicker) BookmarkIconButton(onPressed: onBookmarkPressed),
      ],
    );
  }
}
