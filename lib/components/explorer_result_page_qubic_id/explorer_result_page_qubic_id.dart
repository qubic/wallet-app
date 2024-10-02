import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/components/explorer_result_page_qubic_id/explorer_result_page_qubic_id_header.dart';
import 'package:qubic_wallet/dtos/explorer_id_info_dto.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class ExplorerResultPageQubicId extends StatelessWidget {
  ExplorerResultPageQubicId({
    super.key,
    required this.idInfo,
  });
  final DateFormat formatter = DateFormat('dd MMM yyyy \'at\' HH:mm:ss');
  final ExplorerIdInfoDto idInfo;
  //TODO Show latest transfers ExplorerResultPageTransactionItem for a Public ID here
  Widget listTransactions() {
    return SliverList.builder(
      itemCount: 0,
      itemBuilder: (context, index) => const SizedBox.shrink(),
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
