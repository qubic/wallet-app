import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/copy_button.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/re_auth_dialog.dart';
import 'package:qubic_wallet/helpers/signature_format_helper.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class SignMessageScreen extends StatefulWidget {
  final QubicListVm item;

  const SignMessageScreen({super.key, required this.item});

  @override
  State<SignMessageScreen> createState() => _SignMessageScreenState();
}

class _SignMessageScreenState extends State<SignMessageScreen> {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final QubicCmd qubicCmd = getIt<QubicCmd>();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();

  final TextEditingController _messageController = TextEditingController();
  String signOutput = '';
  bool isSigning = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onFormChanged);
    _messageController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {
      if (signOutput.isNotEmpty) {
        signOutput = '';
      }
    });
  }

  bool get _canSign => _messageController.text.isNotEmpty && !isSigning;

  Future<void> _onSign() async {
    final l10n = l10nOf(context);
    if (!_canSign) return;

    final authenticated = await reAuthDialog(context);
    if (!authenticated) return;
    if (!mounted) return;

    setState(() {
      isSigning = true;
      signOutput = '';
    });

    try {
      final seed = await appStore.getSeedByPublicId(widget.item.publicId);

      // signUTF8 prepends "Qubic Signed Message:\n" before signing
      // (security measure matching Ethereum's pattern to prevent
      // malicious dApps from tricking users into signing raw transactions)
      final signResult = await qubicCmd.signUTF8(seed, _messageController.text);

      // signResult.signature is base64-encoded 64-byte Schnorrq signature
      final rawSigBytes = base64Decode(signResult.signature);

      final json = SignatureFormatHelper.buildSignedMessageJson(
        identity: widget.item.publicId,
        message: _messageController.text,
        signatureBytes: rawSigBytes,
      );

      if (!mounted) return;
      setState(() => signOutput = json);
    } catch (e) {
      if (!mounted) return;
      _globalSnackBar.show(l10n.signVerifyMessageErrorSign);
    } finally {
      if (mounted) {
        setState(() => isSigning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        minimum: ThemeEdgeInsets.pageInsets
            .copyWith(bottom: ThemePaddings.normalPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header — same pattern as Send screen
              ThemedControls.pageHeader(
                headerText: l10n.signVerifyMessageSignButton,
                subheaderText: l10n.transferAssetSubHeader(widget.item.name),
              ),
              ThemedControls.spacerVerticalSmall(),

              // Message input
              Text(l10n.signVerifyMessageMessageLabel,
                  style: TextStyles.labelTextNormal),
              ThemedControls.spacerVerticalMini(),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: ThemeInputDecorations.bigInputbox.copyWith(
                  hintText: l10n.signVerifyMessageEnterMessage,
                ),
              ),

              // Sign button
              ThemedControls.spacerVerticalNormal(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _canSign
                      ? ThemedControls.primaryButtonBig(
                          text: l10n.signVerifyMessageSignButton,
                          onPressed: _onSign,
                        )
                      : ThemedControls.primaryButtonBigDisabled(
                          text: l10n.signVerifyMessageSignButton,
                        ),
                ],
              ),

              // Loading indicator
              if (isSigning) ...[
                ThemedControls.spacerVerticalSmall(),
                const Center(child: CircularProgressIndicator()),
              ],

              // Output
              if (signOutput.isNotEmpty) ...[
                ThemedControls.spacerVerticalNormal(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.signVerifyMessageOutputLabel,
                        style: TextStyles.labelTextNormal),
                    CopyButton(copiedText: signOutput),
                  ],
                ),
                ThemedControls.spacerVerticalMini(),
                TextFormField(
                  key: ValueKey(signOutput),
                  initialValue: signOutput,
                  readOnly: true,
                  maxLines: null,
                  decoration: ThemeInputDecorations.bigInputbox,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
