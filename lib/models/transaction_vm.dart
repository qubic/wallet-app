import 'dart:core';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/dtos/transaction_dto.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

enum ComputedTransactionStatus {
  //** Transfer is broadcasted but pending */
  pending,
  //** Transfer is successful (processed by computors) */
  success,
  //** Transfer has failed */
  failure,
  //** Transfer is invalid (may be successful but invalidated) */
  invalid,
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
  String status;

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

  TransactionVm(
      {required this.id,
      required this.sourceId,
      required this.destId,
      required this.amount,
      required this.status,
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
      required this.moneyFlow});

  ComputedTransactionStatus getStatus() {
    if (isPending) {
      return ComputedTransactionStatus.pending;
    }
    if ((status == 'Success')) {
      if (moneyFlow == true) {
        return ComputedTransactionStatus.success;
      } else {
        return ComputedTransactionStatus.failure;
      }
    }
    if ((status == 'Invalid')) {
      return ComputedTransactionStatus.invalid;
    }
    return ComputedTransactionStatus.pending;
  }

  String toReadableString(BuildContext context) {
    final l10n = l10nOf(context);
    return l10n.generalAllTransactionDetails(
        id,
        sourceId,
        destId,
        amount.toString(),
        status,
        created.toString(),
        stored.toString(),
        staged.toString(),
        broadcasted.toString(),
        confirmed.toString(),
        statusUpdate.toString(),
        targetTick.toString(),
        isPending ? l10n.generalLabelYes : l10n.generalLabelNo,
        price.toString(),
        quantity.toString(),
        moneyFlow ? l10n.generalLabelYes : l10n.generalLabelNo);
    //return "ID: $id \nSource: $sourceId \nDestination: $destId \nAmount: $amount \nStatus: $status \nCreated: $created \nStored: $stored \nStaged: $staged \nBroadcasted: $broadcasted \nConfirmed: $confirmed \nStatusUpdate: $statusUpdate \nTarget Tick: $targetTick \nIs Pending: $isPending \nPrice: $price \nQuantity: $quantity \nMoney Flow: $moneyFlow \n";
  }

  updateContentsFromTransactionDto(TransactionDto update) {
    //Will copy all values from a transaction DTO (does not update id)
    if (update.id != id) {
      throw Exception("Cannot update a transaction with a different ID");
    }
    sourceId = update.sourceId;
    destId = update.destId;
    amount = update.amount;
    status = update.status;
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
  }

  @override
  String toString() {
    return "TransactionVm: $id, Source: $sourceId, Dest: $destId, Amount: $amount, Status: $status,Created: $created,Stored: $stored,Staged: $staged,Broadcasted: $broadcasted,Confirmed: $confirmed,StatusUpdate: $statusUpdate,TargetTick: $targetTick,isPending: $isPending,Price: $price, Quantity: $quantity, Moneyflow: $moneyFlow";
  }

  factory TransactionVm.fromTransactionDto(TransactionDto original) {
    return TransactionVm(
        id: original.id,
        sourceId: original.sourceId,
        destId: original.destId,
        amount: original.amount,
        status: original.status,
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
        moneyFlow: original.moneyFlow);
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
        status: reader.readString(),
        targetTick: reader.readInt(),
        isPending: reader.readBool(),
        moneyFlow: reader.readBool());
  }

  @override
  int get typeId => 0;

  @override
  void write(BinaryWriter writer, TransactionVm obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.sourceId);
    writer.writeString(obj.destId);
    writer.writeInt(obj.amount);
    writer.writeString(obj.status);
    writer.writeInt(obj.targetTick);
    writer.writeBool(obj.isPending);
    writer.writeBool(obj.moneyFlow);
  }
}
