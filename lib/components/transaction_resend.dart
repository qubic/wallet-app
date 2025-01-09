import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/components/amount_formatted.dart';
import 'package:qubic_wallet/components/currency_label.dart';
import 'package:qubic_wallet/components/transaction_details.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/stores/application_store.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/styles/text_styles.dart';

import 'package:intl/intl.dart';

enum CardItem { explorer, clipboardCopy }

class TransactionResend extends StatelessWidget {
  final TransactionVm item;
  final NumberFormat numberFormat = NumberFormat.decimalPattern("en_US");

  TransactionResend({super.key, required this.item});

  final ApplicationStore appStore = getIt<ApplicationStore>();

  //Gets the labels for Source and Destination in transcations. Also copies to clipboard
  Widget getFromTo(BuildContext context, String prepend, String accountId) {
    final l10n = l10nOf(context);
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Observer(builder: (context) {
        QubicListVm? source = appStore.findAccountById(accountId);
        if (source != null) {
          return Container(
              width: double.infinity,
              child: Text(l10n.generalLabelToFromAccount(prepend, source.name),
                  style: TextStyles.labelText));
        }
        return Container(
            width: double.infinity,
            child: Text(l10n.generalLabelToFromAddress(prepend),
                style: TextStyles.labelText));
      }),
      Text(id,
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(fontFamily: ThemeFonts.secondary)),
    ]);
  }

  void showDetails(BuildContext context) {
    showModalBottomSheet<void>(
        useRootNavigator: true,
        showDragHandle: false,
        useSafeArea: true,
        context: context,
        builder: (BuildContext context) {
          return SafeArea(child: TransactionDetails(item: item));
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Container(
        constraints: const BoxConstraints(minWidth: 400, maxWidth: 500),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AmountFormatted(
              labelOffset: -0,
              labelHorizOffset: -6,
              textStyle: MediaQuery.of(context).size.width < 400
                  ? TextStyles.accountAmount.copyWith(fontSize: 22)
                  : TextStyles.accountAmount,
              labelStyle: TextStyles.accountAmountLabel,
              amount: item.amount,
              isInHeader: false,
              currencyName: l10n.generalLabelCurrencyQubic),
          const SizedBox(height: ThemePaddings.normalPadding),
          getFromTo(context, l10n.generalLabelFrom, item.sourceId),
          const SizedBox(height: ThemePaddings.normalPadding),
          getFromTo(context, l10n.generalLabelTo, item.destId)
        ]));
  }
}
