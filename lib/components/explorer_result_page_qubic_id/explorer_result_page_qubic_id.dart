import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/components/explorer_result_page_qubic_id/explorer_result_page_qubic_id_header.dart';
import 'package:qubic_wallet/components/explorer_results/explorer_result_page_transaction_item.dart';
import 'package:qubic_wallet/dtos/explorer_id_info_dto.dart';
import 'package:qubic_wallet/dtos/explorer_transaction_info_dto.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class ExplorerResultPageQubicId extends StatelessWidget {
  ExplorerResultPageQubicId({
    super.key,
    required this.idInfo,
  });
  final ExplorerIdInfoDto idInfo;

  final DateFormat formatter = DateFormat('dd MMM yyyy \'at\' HH:mm:ss');
  Widget listTransactions() {
    return SliverList.builder(
      itemCount: idInfo.latestTransfers?.length,
      itemBuilder: (context, index) {
        final transaction = idInfo.latestTransfers![index];
        return ExplorerResultPageTransactionItem(
            transaction: ExplorerTransactionDto(
                transaction: Transaction(
                    sourceId: transaction.sourceId,
                    destId: transaction.destId,
                    amount: transaction.amount.toString(),
                    tickNumber: transaction.tick,
                    inputType: transaction.type,
                    inputSize: null,
                    inputHex: null,
                    signatureHex: null,
                    txId: transaction.id),
                timestamp: null,
                moneyFlew: transaction.moneyFlew),
            isFocused: false,
            showTick: true);
      },
    );
  }

  Widget getTransactionsHeader(BuildContext context) {
    final l10n = l10nOf(context);

    if (idInfo.latestTransfers != null) {
      return Text(l10n.accountExplorerLabelLatestTransactions,
          style: TextStyles.textExtraLargeBold);
    } else {
      return Text(l10n.accountExplorerLabelNoResultsFound);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ExplorerResultPageQubicIdHeader(idInfo: idInfo),
        ),
        SliverToBoxAdapter(child: getTransactionsHeader(context)),
        if (idInfo.latestTransfers != null &&
            idInfo.latestTransfers!.isNotEmpty)
          listTransactions(),
        SliverToBoxAdapter(child: ThemedControls.spacerVerticalSmall()),
      ],
    );
  }
}
