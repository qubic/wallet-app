import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/explorer_transaction_info_dto.dart';
import 'package:qubic_wallet/helpers/transaction_status_helpers.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';

enum CardItem { delete, rename }

class ExplorerTransactionStatusItem extends StatelessWidget {
  final ExplorerTransactionDto item;

  ExplorerTransactionStatusItem({super.key, required this.item});

  final ApplicationStore appStore = getIt<ApplicationStore>();

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Icon(TransactionStatusHelpers.getTransactionStatusIcon(item.getStatus()),
          color: TransactionStatusHelpers.getTransactionStatusColor(
              item.getStatus()),
          size: 18),
      Text(
          " ${TransactionStatusHelpers.getTransactionStatusText(item.getStatus(), context)}",
          style: TextStyles.labelTextSmall)
    ]);
  }
}
