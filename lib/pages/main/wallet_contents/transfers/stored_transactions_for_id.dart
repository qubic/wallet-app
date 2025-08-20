import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/components/transaction_item.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/transaction_ui_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class StoredTransactionsForId extends StatelessWidget {
  final QubicListVm item;
  const StoredTransactionsForId({super.key, required this.item});

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
        child: Column(
          children: [
            ThemedControls.pageHeader(
              headerText: (l10n.storedTransfersLabelForAccount(item.name)),
            ),
            Observer(builder: (context) {
              final storedTransactions = getIt<ApplicationStore>()
                  .getStoredTransactionsForID(item.publicId);
              final isEmpty = storedTransactions.isEmpty;
              return Expanded(
                  child: isEmpty
                      ? TransactionUIHelpers.getEmptyTransactionsForSingleID(
                          context: context,
                          hasFiltered: false,
                          numberOfFilters: 0,
                          onTap: null)
                      : ListView.builder(
                          itemCount: storedTransactions.length,
                          itemBuilder: (context, index) {
                            return TransactionItem(
                                item: storedTransactions[index]);
                          }));
            })
          ],
        ),
      ),
    );
  }
}
