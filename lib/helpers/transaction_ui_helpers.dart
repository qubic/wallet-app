import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/smart_contracts/special_addresses.dart';
import 'package:qubic_wallet/stores/qubic_ecosystem_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class TransactionUIHelpers {
  static final QubicEcosystemStore _ecosystemStore =
      getIt<QubicEcosystemStore>();

  static Widget getEmptyTransactions(
      {required BuildContext context,
      required bool hasFiltered,
      int? numberOfFilters,
      required void Function()? onTap}) {
    final l10n = l10nOf(context);
    String message = hasFiltered
        ? l10n.transfersLabelNoTransactionsFoundInWalletMatchingFilters
        : l10n.transfersLabelNoTransactionsFoundInWallet;

    return getEmptyTransactionsWidget(
        context: context,
        hasFiltered: hasFiltered,
        numberOfFilters: numberOfFilters,
        message: message,
        onTap: onTap);
  }

  static Widget getEmptyTransactionsForSingleID(
      {required BuildContext context,
      required bool hasFiltered,
      int? numberOfFilters,
      required void Function()? onTap}) {
    final l10n = l10nOf(context);
    String message = hasFiltered
        ? l10n.transfersLabelNoTransactionsFoundInAccountMatchingFilters
        : l10n.transfersLabelNoTransactionsFoundInAccount;

    return getEmptyTransactionsWidget(
        context: context,
        hasFiltered: hasFiltered,
        numberOfFilters: numberOfFilters,
        message: message,
        onTap: onTap);
  }

  static Widget getEmptyTransactionsWidget(
      {required BuildContext context,
      required bool hasFiltered,
      int? numberOfFilters,
      required String message,
      required void Function()? onTap}) {
    final l10n = l10nOf(context);
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyles.secondaryText
            .copyWith(fontSize: ThemeFontSizes.extraLarge),
      ),
      const SizedBox(height: ThemePaddings.hugePadding * 3),
      if ((hasFiltered) && (numberOfFilters != null))
        ThemedControls.primaryButtonNormal(
            onPressed: onTap,
            text: l10n.filterTransfersClearFilters(numberOfFilters))
    ]);
  }

  static String getTransactionType(int type, String destination) {
    return _ecosystemStore.getProcedureName(destination, type) ??
        "$type ${(type == 0 || SpecialAddresses.empty == destination) ? "Standard" : "SC"}";
  }

  static getTransactionFiltersInfo(BuildContext context,
      {required int numberOfFilters,
      required int numberOfResults,
      required VoidCallback onTap}) {
    final l10n = l10nOf(context);

    return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemePaddings.smallPadding,
        ),
        child: Flex(
            direction: MediaQuery.of(context).size.width < 400
                ? Axis.vertical
                : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.transfersLabelShowingTransactionsFound(numberOfResults),
                  style: TextStyles.secondaryText),
              numberOfFilters == 0
                  ? Container()
                  : clearFiltersButton(context,
                      numberOfFilters: numberOfFilters, onTap: onTap)
            ]));
  }

  static Widget clearFiltersButton(BuildContext context,
      {required VoidCallback? onTap, required int numberOfFilters}) {
    final l10n = l10nOf(context);

    return TextButton(
        onPressed: onTap,
        child: Text(l10n.filterTransfersClearFilters(numberOfFilters),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontFamily: ThemeFonts.secondary)));
  }
}
