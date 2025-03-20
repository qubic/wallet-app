import 'dart:core';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/dtos/transaction_dto.dart';
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

@observable
class TransactionVm {
  @observable
  late String id; //The transaction Id

  @observable
  String sourceId;

  @observable
  String destId;

  @observable
  int amount;

  @observable
  DateTime? created;

  @observable
  DateTime? stored;

  @observable
  DateTime? staged;

  @observable
  DateTime? broadcasted;

  @observable
  DateTime? confirmed;

  @observable
  DateTime? statusUpdate;

  @observable
  int targetTick;

  @observable
  bool isPending;

  @observable
  int? price; //IPO Bids

  @observable
  int? quantity; //IPO Bids

  @observable
  bool moneyFlow;

  int? type;

  String? inputHex;

  TransactionVm({
    required this.id,
    required this.sourceId,
    required this.destId,
    required this.amount,
    this.created,
    this.stored,
    this.staged,
    this.broadcasted,
    this.confirmed,
    this.statusUpdate,
    required this.targetTick,
    required this.isPending,
    this.price,
    this.quantity,
    this.type,
    required this.moneyFlow,
    this.inputHex,
  });

  ComputedTransactionStatus getStatus() {
    return TransactionStatusHelpers.getTransactionStatus(
        isPending,
        type,
        amount,
        moneyFlow,
        confirmed != null && isPending == false); // TODO IMPORTANT
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
        confirmed.toString(),
        targetTick.toString().asThousands());
  }

  updateContentsFromTransactionDto(TransactionDto update) {
    //Will copy all values from a transaction DTO (does not update id)
    if (update.id != id) {
      throw Exception("Cannot update a transaction with a different ID");
    }
    sourceId = update.sourceId;
    destId = update.destId;
    amount = update.amount;
    created = update.created;
    stored = update.stored;
    staged = update.staged;
    broadcasted = update.broadcasted;
    confirmed = update.confirmed;
    statusUpdate = update.statusUpdate;
    targetTick = update.targetTick;
    isPending = update.isPending;
    price = update.price;
    quantity = update.quantity;
    moneyFlow = update.moneyFlow;
    type = update.type;
  }

  @override
  String toString() {
    return "TransactionVm: $id, Source: $sourceId, Dest: $destId, Amount: $amount,Created: $created,Stored: $stored,Staged: $staged,Broadcasted: $broadcasted,Confirmed: $confirmed,StatusUpdate: $statusUpdate,TargetTick: $targetTick,isPending: $isPending,Price: $price, Quantity: $quantity, Moneyflow: $moneyFlow Type: $type";
  }

  factory TransactionVm.fromTransactionDto(TransactionDto original) {
    return TransactionVm(
      id: original.id,
      sourceId: original.sourceId,
      destId: original.destId,
      amount: original.amount,
      created: original.created,
      stored: original.stored,
      staged: original.staged,
      broadcasted: original.broadcasted,
      confirmed: original.confirmed,
      statusUpdate: original.statusUpdate,
      targetTick: original.targetTick,
      isPending: original.isPending,
      price: original.price,
      quantity: original.quantity,
      moneyFlow: original.moneyFlow,
      type: original.type,
      inputHex: original.inputHex,
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
