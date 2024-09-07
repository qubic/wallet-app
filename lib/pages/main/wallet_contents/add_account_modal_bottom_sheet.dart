import 'package:flutter/material.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/add_account.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// Show the ModalBottomSheet when the trigger is set in the store
void showAddAccountModal(BuildContext context) {
  final applicationStore = getIt<ApplicationStore>();
  final l10n = l10nOf(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    // Keeps the grabber indicator area transparent
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grabber indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 60,
            height: 4.5,
            decoration: BoxDecoration(
              color: LightThemeColors.color2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // The actual modal content, anchored to the bottom
          Container(
            // 44px padding from bottom
            padding: const EdgeInsets.only(bottom: 44),
            decoration: BoxDecoration(
              color: LightThemeColors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border.all(
                color: LightThemeColors.navBorder,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                ThemePaddings.normalPadding,
                ThemePaddings.normalPadding,
                ThemePaddings.normalPadding,
                0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Create New Account
                  Container(
                    constraints:
                        const BoxConstraints(minWidth: 400, maxWidth: 500),
                    child: Card(
                      color: LightThemeColors.inputFieldBg,
                      // Card background color
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side:
                            const BorderSide(color: LightThemeColors.navBorder),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.add_circle,
                            color: LightThemeColors.buttonPrimary),
                        title: Text(
                          l10n.addAccountCreateNewAccountModalBottomSheet,
                          style: TextStyles.labelText.copyWith(
                              color: LightThemeColors.primary,
                              fontSize: ThemeFontSizes.normal),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          // Action for adding normal account
                          pushScreen(
                            context,
                            screen: const AddAccount(isWatchOnly: false),
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                          // Clear the modal trigger
                          applicationStore.clearAddAccountModal();
                        },
                      ),
                    ),
                  ),
                  // Space between the two buttons
                  const SizedBox(height: ThemePaddings.smallPadding),
                  // Watch Only Account
                  Container(
                    constraints:
                        const BoxConstraints(minWidth: 400, maxWidth: 500),
                    child: Card(
                      color: LightThemeColors.inputFieldBg,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side:
                            const BorderSide(color: LightThemeColors.navBorder),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.remove_red_eye,
                          color: LightThemeColors.buttonPrimary,
                        ),
                        title: Text(
                          l10n.addAccountWatchOnlyAddressModalBottomSheet,
                          style: TextStyles.labelText.copyWith(
                              color: LightThemeColors.primary,
                              fontSize: ThemeFontSizes.normal),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          // Action for adding watch-only account
                          pushScreen(
                            context,
                            screen: const AddAccount(isWatchOnly: true),
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                          // Clear the modal trigger
                          applicationStore.clearAddAccountModal();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
