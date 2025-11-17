import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/terms_of_use_screen.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class ExternalUrlWarningDialog extends StatefulWidget {
  final Function(bool doNotRemindAgain) onContinue;
  final Function() onCancel;

  const ExternalUrlWarningDialog({
    super.key,
    required this.onContinue,
    required this.onCancel,
  });

  @override
  State<ExternalUrlWarningDialog> createState() =>
      _ExternalUrlWarningDialogState();
}

class _ExternalUrlWarningDialogState extends State<ExternalUrlWarningDialog> {
  bool doNotRemindAgain = false;

  void _toggleCheckbox() {
    setState(() {
      doNotRemindAgain = !doNotRemindAgain;
    });
  }

  void _navigateToTerms(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TermsOfUseScreen(),
      ),
    );
  }

  Widget _buildWarningTextWithLink(BuildContext context) {
    final l10n = l10nOf(context);
    final message = l10n.dAppExternalUrlWarningMessage;
    final termsText = l10n.generalLabelTermsOfService;

    // Find the position of "Terms of Service" in the message
    final termsIndex = message.indexOf(termsText);

    if (termsIndex == -1) {
      // If we can't find the terms text, just return the plain message
      return Text(
        message,
        style: TextStyles.secondaryText,
        textAlign: TextAlign.center,
      );
    }

    // Split the message into parts: before, terms, and after
    final beforeTerms = message.substring(0, termsIndex);
    final afterTerms = message.substring(termsIndex + termsText.length);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyles.secondaryText,
        children: [
          TextSpan(text: beforeTerms),
          TextSpan(
            text: termsText,
            style: TextStyles.secondaryText.copyWith(
              color: LightThemeColors.primary,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _navigateToTerms(context),
          ),
          TextSpan(text: afterTerms),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppIcons.warning,
            height: 20,
            colorFilter: const ColorFilter.mode(
              LightThemeColors.warning40,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: ThemePaddings.smallPadding),
          Flexible(
            child: Text(
              l10n.dAppExternalUrlWarningTitle,
              style: TextStyles.alertHeader.copyWith(
                color: LightThemeColors.warning40,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildWarningTextWithLink(context),
            const SizedBox(height: ThemePaddings.hugePadding),
            // Do not remind again checkbox
            InkWell(
              onTap: _toggleCheckbox,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: doNotRemindAgain,
                        onChanged: (value) => _toggleCheckbox(),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: ThemePaddings.smallPadding),
                    Flexible(
                      child: Text(
                        l10n.dAppExternalUrlWarningDoNotRemind,
                        style: TextStyles.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text(
            l10n.generalButtonCancel,
            style: TextStyles.labelText.copyWith(
              color: LightThemeColors.textColorSecondary,
            ),
          ),
        ),
        ThemedControls.primaryButtonNormal(
          onPressed: () => widget.onContinue(doNotRemindAgain),
          text: l10n.generalButtonContinue,
        ),
      ],
    );
  }
}
