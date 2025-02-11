import 'package:flutter/material.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

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
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: LightThemeColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: ThemeEdgeInsets.pageInsets.copyWith(
            bottom: MediaQuery.of(context).padding.bottom +
                ThemePaddings.normalPadding),
        separatorBuilder: (context, index) =>
            ThemedControls.spacerHorizontalNormal(),
        itemCount: 10,
        itemBuilder: (context, index) {
          return ThemedControls.card(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Account 1",
                style: TextStyles.accountName,
              ),
              ThemedControls.spacerVerticalMini(),
              Text(
                "RBMXEFMDFABRTBJIYIBOQZMAWKWCPMJIQVEQDKONOFPEFWLMXQECDGEBIRBM",
                style: TextStyles.accountPublicId,
              )
            ],
          ));
        },
      ),
    );
  }
}
