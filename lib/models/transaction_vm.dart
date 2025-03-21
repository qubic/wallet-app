import 'dart:core';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:qubic_wallet/dtos/transactions_dto.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/helpers/transaction_ui_helpers.dart';
import 'package:qubic_wallet/helpers/transaction_status_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

enum ComputedTransactionStatus {
  //** Transaction is broadcasted but pending */
  pending,
  //** Transfer is successful (processed by computors) */
  success,
  //** Transfer has failed */
  failure,
  //** Transaction is invalid (ignored by network) */
  invalid,
  // amount is 0 or SC was executed, can not determine success or failure
  executed
}

class TransactionVmStatus {
  static const String invalid = "Invalid";
  static const String success = "Success";
}

class TransactionVm {
  final String id;
  final String sourceId;
  final String destId;
  final int amount;
  final int targetTick;
  bool isPending;
  final bool moneyFlow;
  final DateTime? timestamp;
  final int? type;
  final String? inputHex;

  TransactionVm({
    required this.id,
    required this.sourceId,
    required this.destId,
    required this.amount,
    required this.targetTick,
    required this.isPending,
    required this.moneyFlow,
    this.timestamp,
    this.type,
    this.inputHex,
  });

  bool get isInvalid => timestamp != null && isPending == false;

  ComputedTransactionStatus getStatus() {
    return TransactionStatusHelpers.getTransactionStatus(
        isPending, type, amount, moneyFlow, isInvalid);
  }

  String toReadableString(BuildContext context) {
    final l10n = l10nOf(context);
    return l10n.generalAllTransactionDetails(
        id,
        sourceId,
        destId,
        amount.asThousands(),
        TransactionUIHelpers.getTransactionType(type ?? 0, destId),
        TransactionStatusHelpers.getTransactionStatusText(getStatus(), context),
        timestamp.toString(),
        targetTick.toString().asThousands());
  }

  @override
  String toString() {
    return "TransactionVm: $id, Source: $sourceId, Dest: $destId, Amount: $amount, Moneyflow: $moneyFlow Type: $type, Timestamp: $timestamp";
  }

  factory TransactionVm.fromTransactionDto(TransactionDto original) {
    int? millisecondsSinceEpoch = int.tryParse(original.timestamp);
    DateTime? dateTime = millisecondsSinceEpoch == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

    return TransactionVm(
      id: original.transaction.txId,
      sourceId: original.transaction.sourceId,
      destId: original.transaction.destId,
      amount: int.parse(original.transaction.amount),
      targetTick: original.transaction.tickNumber,
      isPending: false,
      moneyFlow: original.moneyFlew,
      type: original.transaction.inputType,
      inputHex: original.transaction.inputHex,
      timestamp: dateTime,
    );
  }
}

class TransactionVmAdapter extends TypeAdapter<TransactionVm> {
  @override
  TransactionVm read(BinaryReader reader) {
    return TransactionVm(
      id: reader.readString(),
      sourceId: reader.readString(),
      destId: reader.readString(),
      amount: reader.readInt(),
      targetTick: reader.readInt(),
      isPending: reader.readBool(),
      moneyFlow: reader.readBool(),
      type: reader.availableBytes > 0 ? reader.read() : null,
    );
  }

  @override
  int get typeId => 0;

  @override
  void write(BinaryWriter writer, TransactionVm obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.sourceId);
    writer.writeString(obj.destId);
    writer.writeInt(obj.amount);
    writer.writeInt(obj.targetTick);
    writer.writeBool(obj.isPending);
    writer.writeBool(obj.moneyFlow);
    writer.write(obj.type ?? 0);
  }
}
