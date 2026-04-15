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
      if (verifyResult != _VerifyResult.none || verifyError.isNotEmpty) {
        verifyResult = _VerifyResult.none;
        verifyError = '';
      }
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

    // 2. Validate identity format
    if (!SignatureFormatHelper.isValidIdentityFormat(parsed.identity)) {
      setState(() => verifyError = l10n.signVerifyMessageErrorIdentity);
      return;
    }

    // 3. Verify identity with qubic helper
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

    // 5. Validate checksum
    if (!SignatureFormatHelper.validateSignatureChecksum(parsed.signature)) {
      if (!mounted) return;
      setState(() => verifyError = l10n.signVerifyMessageErrorChecksum);
      return;
    }

    // 6. Cryptographic verification
    try {
      // Decode shifted-hex to 65 bytes, take first 64 (signature without checksum)
      final decoded = SignatureFormatHelper.decodeShiftedHex(parsed.signature);
      final sigBytes = decoded.sublist(0, 64);
      final signatureB64 = base64Encode(sigBytes);

      final isValid = await qubicCmd.verifySignedUTF8(
          parsed.identity, parsed.message, signatureB64);

      if (!mounted) return;
      setState(() => verifyResult =
          isValid ? _VerifyResult.valid : _VerifyResult.invalid);
    } catch (_) {
      if (!mounted) return;
      setState(() => verifyError = l10n.signVerifyMessageErrorSignature);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
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
                      if (clipboardData != null && clipboardData.text != null) {
                        _verifyInputController.text = clipboardData.text!;
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
                  suffixIcon: _verifyInputController.text.isNotEmpty
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
                  _verifyInputController.text.isNotEmpty
                      ? ThemedControls.primaryButtonBig(
                          text: l10n.signVerifyMessageVerifyButton,
                          onPressed: _onVerify,
                        )
                      : ThemedControls.primaryButtonBigDisabled(
                          text: l10n.signVerifyMessageVerifyButton,
                        ),
                ],
              ),

              // Result banner — Valid
              if (verifyResult == _VerifyResult.valid) ...[
                ThemedControls.spacerVerticalNormal(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(ThemePaddings.normalPadding),
                  decoration: BoxDecoration(
                    color: LightThemeColors.successIncoming.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.signVerifyMessageResultValid,
                    style: TextStyles.labelTextNormal
                        .copyWith(color: LightThemeColors.successIncoming),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              // Result banner — Invalid
              if (verifyResult == _VerifyResult.invalid) ...[
                ThemedControls.spacerVerticalNormal(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(ThemePaddings.normalPadding),
                  decoration: BoxDecoration(
                    color: LightThemeColors.error.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.signVerifyMessageResultInvalid,
                    style: TextStyles.labelTextNormal
                        .copyWith(color: LightThemeColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              // Error message
              if (verifyError.isNotEmpty) ...[
                ThemedControls.spacerVerticalNormal(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(ThemePaddings.normalPadding),
                  decoration: BoxDecoration(
                    color: LightThemeColors.error.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    verifyError,
                    style: TextStyles.labelTextNormal
                        .copyWith(color: LightThemeColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
