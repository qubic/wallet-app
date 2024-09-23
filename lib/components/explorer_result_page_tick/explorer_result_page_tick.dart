import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/components/explorer_result_page_tick/explorer_result_page_tick_header.dart';
import 'package:qubic_wallet/components/explorer_results/explorer_result_page_transaction_item.dart';
import 'package:qubic_wallet/dtos/explorer_tick_info_dto.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

enum RequestViewChangeType { tick, publicId }

class ExplorerResultPageTick extends StatelessWidget {
  ExplorerResultPageTick(
      {super.key,
      required this.tickInfo,
      this.onRequestViewChange,
      this.focusedTransactionId});
  final DateFormat formatter = DateFormat('dd MMM yyyy \'at\' HH:mm:ss');
  final ExplorerTickInfoDto tickInfo;
  final String? focusedTransactionId;

  final Function(RequestViewChangeType type, int? tick, String? publicId)?
      onRequestViewChange;

  Widget listTransactions() {
    return SliverList.builder(
      itemBuilder: (context, index) {
        final transaction = tickInfo.transactions![index];
        return focusedTransactionId == null ||
                focusedTransactionId! == transaction.id
            ? Padding(
                padding:
                    const EdgeInsets.only(bottom: ThemePaddings.normalPadding),
                child: ExplorerResultPageTransactionItem(
                  transaction: transaction,
                  isFocused: focusedTransactionId == null
                      ? false
                      : focusedTransactionId! == transaction.id,
                  dataStatus: tickInfo.completed,
                ),
              )
            : const SizedBox.shrink();
      },
      itemCount: tickInfo.transactions!.length,
    );
  }

  Widget getTransactionsHeader(BuildContext context) {
    final l10n = l10nOf(context);

    TextStyle panelTickHeader = TextStyles.textExtraLargeBold;

    if (tickInfo.transactions != null) {
      if (focusedTransactionId == null) {
        return Text(
            l10n.explorerTickResultLabelTransactionsFound(
                tickInfo.transactions!.length),
            style: panelTickHeader);
      } else {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            l10n.explorerTickResultLabelShowingOneTransaction(
                tickInfo.transactions!.length),
            style: panelTickHeader,
            textAlign: TextAlign.center,
          ),
          Padding(
              padding: const EdgeInsets.only(top: ThemePaddings.smallPadding),
              child: tickInfo.transactions!.length > 1
                  ? ThemedControls.primaryButtonSmall(
                      text: l10n.generalButtonShowAll,
                      onPressed: () {
                        onRequestViewChange!(
                            RequestViewChangeType.tick, tickInfo.tick, null);
                      })
                  : Container())
        ]);
      }
    } else {
      return Text(l10n.explorerTickResultLabelNoTransactionsFound,
          style: panelTickHeader);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ExplorerResultPageTickHeader(
              tickInfo: tickInfo,
              onTickChange: onRequestViewChange != null
                  ? (tick) => {
                        onRequestViewChange!(
                            RequestViewChangeType.tick, tick, null)
                      }
                  : null),
        ),
        SliverPadding(
          padding: EdgeInsets.only(
              left: ThemeEdgeInsets.pageInsets.left,
              right: ThemeEdgeInsets.pageInsets.right),
          sliver: SliverToBoxAdapter(
            child: getTransactionsHeader(context),
          ),
        ),
        if (tickInfo.transactions != null && tickInfo.transactions!.isNotEmpty)
          listTransactions(),
      ],
    );
  }
}
