import 'package:flutter/material.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class AddressBook extends StatelessWidget {
  const AddressBook({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          l10n.settingsLabelAddressBook,
        ),
      ),
    );
  }
}
