import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/signature_format_helper.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

enum _VerifyResult { none, valid, invalid }

class VerifyMessageScreen extends StatefulWidget {
  const VerifyMessageScreen({super.key});

  @override
  State<VerifyMessageScreen> createState() => _VerifyMessageScreenState();
}

class _VerifyMessageScreenState extends State<VerifyMessageScreen> {
  final QubicCmd qubicCmd = getIt<QubicCmd>();

  final TextEditingController _verifyInputController = TextEditingController();
  _VerifyResult verifyResult = _VerifyResult.none;
  String verifyError = '';

  @override
  void initState() {
    super.initState();
    _verifyInputController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _verifyInputController.removeListener(_onInputChanged);
    _verifyInputController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {
      verifyResult = _VerifyResult.none;
      verifyError = '';
    });
  }

  Future<void> _onVerify() async {
    final l10n = l10nOf(context);

    setState(() {
      verifyResult = _VerifyResult.none;
      verifyError = '';
    });

    final input = _verifyInputController.text;
    if (input.isEmpty) return;

    // 1. Parse JSON
    final parsed = SignatureFormatHelper.parseSignedMessage(input);
    if (parsed == null) {
      setState(() => verifyError = l10n.signVerifyMessageErrorParse);
      return;
    }

    // 2. Validate identity format (fast regex pre-check)
    if (!SignatureFormatHelper.isValidIdentityFormat(parsed.identity)) {
      setState(() => verifyError = l10n.signVerifyMessageErrorIdentity);
      return;
    }

    // 3. Verify identity with qubic helper (full checksum validation)
    try {
      final isValidId = await qubicCmd.verifyIdentity(parsed.identity);
      if (!isValidId) {
        if (!mounted) return;
        setState(() => verifyError = l10n.signVerifyMessageErrorIdentity);
        return;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => verifyError = l10n.signVerifyMessageErrorIdentity);
      return;
    }

    // 4. Validate signature format
    if (!SignatureFormatHelper.isValidSignatureFormat(parsed.signature)) {
      if (!mounted) return;
      setState(() => verifyError = l10n.signVerifyMessageErrorSignature);
      return;
    }

    // 5. Cryptographic verification
    try {
      final sigBytes = SignatureFormatHelper.decodeShiftedHex(parsed.signature);
      final signatureB64 = base64Encode(sigBytes);

      final isValid = await qubicCmd.verifyMessage(
          parsed.identity, parsed.message, signatureB64);

      if (!mounted) return;
      setState(() => verifyResult =
          isValid ? _VerifyResult.valid : _VerifyResult.invalid);
    } catch (_) {
      if (!mounted) return;
      setState(() => verifyError = l10n.signVerifyMessageErrorSignature);
    }
  }

  Widget _buildResultBanner(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemePaddings.normalPadding),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyles.labelTextNormal.copyWith(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final hasInput = _verifyInputController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.signVerifyMessageVerifyTitle,
            style: TextStyles.textExtraLargeBold),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: ThemeEdgeInsets.pageInsets
            .copyWith(bottom: ThemePaddings.normalPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label + Paste button
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.signVerifyMessageVerifyInputLabel,
                        style: TextStyles.labelTextNormal),
                  ),
                  ThemedControls.transparentButtonSmall(
                    onPressed: () async {
                      final clipboardData =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (clipboardData?.text != null) {
                        _verifyInputController.text = clipboardData!.text!;
                      }
                    },
                    text: l10n.generalButtonPaste,
                  ),
                ],
              ),
              ThemedControls.spacerVerticalMini(),
              TextFormField(
                controller: _verifyInputController,
                maxLines: null,
                minLines: 6,
                decoration: ThemeInputDecorations.bigInputbox.copyWith(
                  hintText: l10n.signVerifyMessageVerifyInputPlaceholder,
                  suffixIcon: hasInput
                      ? IconButton(
                          icon: const Icon(Icons.cancel, size: 20),
                          color: LightThemeColors.grey50,
                          onPressed: () {
                            _verifyInputController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),

              // Verify button
              ThemedControls.spacerVerticalNormal(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  hasInput
                      ? ThemedControls.primaryButtonBig(
                          text: l10n.signVerifyMessageVerifyButton,
                          onPressed: _onVerify,
                        )
                      : ThemedControls.primaryButtonBigDisabled(
                          text: l10n.signVerifyMessageVerifyButton,
                        ),
                ],
              ),

              // Result banner
              if (verifyResult == _VerifyResult.valid) ...[
                ThemedControls.spacerVerticalNormal(),
                _buildResultBanner(l10n.signVerifyMessageResultValid,
                    LightThemeColors.successIncoming),
              ],
              if (verifyResult == _VerifyResult.invalid) ...[
                ThemedControls.spacerVerticalNormal(),
                _buildResultBanner(l10n.signVerifyMessageResultInvalid,
                    LightThemeColors.error),
              ],
              if (verifyError.isNotEmpty) ...[
                ThemedControls.spacerVerticalNormal(),
                _buildResultBanner(verifyError, LightThemeColors.error),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
