import 'package:flutter/material.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';

class CopyableText extends StatelessWidget {
  final Widget child;
  final String copiedText;

  const CopyableText(
      {super.key, required this.child, required this.copiedText});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          await copyToClipboard(copiedText, context);
        },
        child: Ink(child: child));
  }
}
