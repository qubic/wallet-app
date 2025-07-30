import 'package:flutter/material.dart';
import 'package:qubic_wallet/helpers/clipboard_helper.dart';

class CopyableText extends StatelessWidget {
  final Widget child;
  final String copiedText;

  const CopyableText(
      {super.key, required this.child, required this.copiedText});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          await ClipboardHelper.copyToClipboard(copiedText, context);
        },
        child: Ink(child: child));
  }
}
