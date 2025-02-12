import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/settings/address_book/add_to_address_book_screen.dart';
import 'package:qubic_wallet/stores/address_book_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  final AddressBookStore addressBookStore = getIt<AddressBookStore>();

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.settingsLabelAddressBook,
            style: TextStyles.textExtraLargeBold),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: LightThemeColors.primary),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AddToAddressBookScreen()));
            },
          ),
        ],
      ),
      body: Observer(
        builder: (context) {
          return ListView.separated(
            padding: ThemeEdgeInsets.pageInsets.copyWith(
                bottom: MediaQuery.of(context).padding.bottom +
                    ThemePaddings.normalPadding),
            separatorBuilder: (context, index) =>
                ThemedControls.spacerHorizontalNormal(),
            itemCount: addressBookStore.addressBook.length,
            itemBuilder: (context, index) {
              final account = addressBookStore.addressBook[index];
              return Dismissible(
                key: ValueKey(account.name),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(
                      horizontal: ThemePaddings.bigPadding),
                  color: LightThemeColors.dangerColor,
                  child:
                      const Icon(Icons.delete, color: LightThemeColors.primary),
                ),
                onDismissed: (direction) {
                  addressBookStore.removeAddressBook(account);
                },
                child: ThemedControls.card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: TextStyles.accountName,
                      ),
                      ThemedControls.spacerVerticalMini(),
                      Text(
                        account.publicId,
                        style: TextStyles.accountPublicId,
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
