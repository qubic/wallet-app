import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/transaction_status_helpers.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';

enum CardItem { delete, rename }

class TransactionStatusItem extends StatelessWidget {
  final TransactionVm item;

  TransactionStatusItem({super.key, required this.item});

  final ApplicationStore appStore = getIt<ApplicationStore>();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(children: [
      Icon(TransactionStatusHelpers.getTransactionStatusIcon(item.getStatus()),
          color: TransactionStatusHelpers.getTransactionStatusColor(
              item.getStatus())),
      Text(
          " ${TransactionStatusHelpers.getTransactionStatusText(item.getStatus(), context)}",
          style: TextStyles.labelText)
    ]));
  }
}
