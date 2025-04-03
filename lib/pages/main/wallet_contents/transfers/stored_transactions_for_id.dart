import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/transaction_item.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/resources/hive_storage.dart';
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
              headerText: (l10n.transfersLabelForAccount(item.name)),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount:
                        getIt<HiveStorage>().storedTransactions.values.length,
                    itemBuilder: (context, index) {
                      final hiveStorage = getIt<HiveStorage>();
                      final item =
                          hiveStorage.storedTransactions.values.toList()[index];
                      return TransactionItem(item: item);
                    }))
          ],
        ),
      ),
    );
  }
}
