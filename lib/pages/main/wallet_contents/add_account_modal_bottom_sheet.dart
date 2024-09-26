import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_account.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// Show the ModalBottomSheet when the trigger is set in the store
void showAddAccountModal(BuildContext context) {
  final l10n = l10nOf(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            // 44px padding from bottom
            padding: const EdgeInsets.symmetric(
                    horizontal: ThemePaddings.normalPadding)
                .copyWith(bottom: 44, top: 5),
            decoration: BoxDecoration(
              color: LightThemeColors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border.all(color: LightThemeColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grabber indicator
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LightThemeColors.navBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: ThemePaddings.smallPadding),
                AddAccountTile(
                  title: l10n.addAccountCreateNewAccountModalBottomSheet,
                  iconPath: AppIcons.plusCircular,
                  type: AddAccountType.createAccount,
                ),
                const SizedBox(height: ThemePaddings.smallPadding),
                AddAccountTile(
                    title: l10n.addAccountWatchOnlyAddressModalBottomSheet,
                    iconPath: AppIcons.eye,
                    type: AddAccountType.watchOnly),
                const SizedBox(height: ThemePaddings.smallPadding),
                AddAccountTile(
                    title: l10n.importWalletLabelFromPrivateSeed,
                    iconPath: AppIcons.import,
                    type: AddAccountType.importPrivateSeed),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class AddAccountTile extends StatelessWidget {
  AddAccountTile({
    super.key,
    required this.type,
    required this.title,
    required this.iconPath,
  });

  final AddAccountType type;
  final String title;
  final String iconPath;
  final applicationStore = getIt<ApplicationStore>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        color: LightThemeColors.inputFieldBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: LightThemeColors.border),
        ),
        child: ListTile(
          leading: SvgPicture.asset(iconPath),
          title: Text(
            title,
            style: TextStyles.labelText.copyWith(
                color: LightThemeColors.primary,
                letterSpacing: ThemeFontSizes.letterSpacing,
                fontSize: ThemeFontSizes.normal),
          ),
          onTap: () {
            Navigator.pop(context);
            pushScreen(
              context,
              screen: AddAccount(type: type),
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
            // Clear the modal trigger
            applicationStore.clearAddAccountModal();
          },
        ),
      ),
    );
  }
}
