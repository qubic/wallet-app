// Holds transaction information for an explorer query
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:qubic_wallet/helpers/transaction_status_helpers.dart';
import 'package:qubic_wallet/models/transaction_vm.dart';

//TODO Remove this after complete explorer
class ExplorerTransactionInfoDto {
  String id;
  bool executed;
  int tick;
  bool includedByTickLeader;
  String sourceId;
  String destId;
  int amount;
  int type;
  String digest;
  bool moneyFlew;
  bool isPending;

  ComputedTransactionStatus getStatus() {
    return TransactionStatusHelpers.getTransactionStatus(
        isPending, type, amount, moneyFlew, executed == false);
  }

  ExplorerTransactionInfoDto(
      this.id,
      this.executed,
      this.tick,
      this.includedByTickLeader,
      this.sourceId,
      this.destId,
      this.amount,
      this.type,
      this.digest,
      this.moneyFlew,
      this.isPending);

  factory ExplorerTransactionInfoDto.fromJson(Map<String, dynamic> data) {
    return ExplorerTransactionInfoDto(
        data['id'],
        data['executed'],
        data['tick'],
        data['includedByTickLeader'],
        data['sourceId'],
        data['destId'],
        data['amount'],
        data['type'],
        data['digest'],
        data['moneyFlew'],
        data['isPending']);
  }

  factory ExplorerTransactionInfoDto.clone(ExplorerTransactionInfoDto source) {
    return ExplorerTransactionInfoDto(
        source.id,
        source.executed,
        source.tick,
        source.includedByTickLeader,
        source.sourceId,
        source.destId,
        source.amount,
        source.type,
        source.digest,
        source.moneyFlew,
        source.isPending);
  }
}

/// Holds transaction information for an explorer query used in Qubic Archive
class ExplorerTransactionDto {
  final Transaction data;
  final String? timestamp;
  final bool moneyFlew;

  ExplorerTransactionDto({
    required this.data,
    required this.timestamp,
    required this.moneyFlew,
  });

  factory ExplorerTransactionDto.fromJson(Map<String, dynamic> json) =>
      ExplorerTransactionDto(
        data: Transaction.fromJson(json["transaction"]),
        timestamp: json["timestamp"],
        moneyFlew: json["moneyFlew"],
      );

  ComputedTransactionStatus getStatus() {
    // archive only returns transactions that were added to the blockchain, meaning is not pending and it's not invalid
    return TransactionStatusHelpers.getTransactionStatus(false, data.inputType!,
        int.tryParse(data.amount ?? "0")!, moneyFlew, false);
  }
}

class Transaction {
  final String? sourceId;
  final String? destId;
  final String? amount;
  final int? tickNumber;
  final int? inputType;
  final int? inputSize;
  final String? inputHex;
  final String? signatureHex;
  final String? txId;

  Transaction({
    required this.sourceId,
    required this.destId,
    required this.amount,
    required this.tickNumber,
    required this.inputType,
    required this.inputSize,
    required this.inputHex,
    required this.signatureHex,
    required this.txId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        sourceId: json["sourceId"],
        destId: json["destId"],
        amount: json["amount"],
        tickNumber: json["tickNumber"],
        inputType: json["inputType"],
        inputSize: json["inputSize"],
        inputHex: json["inputHex"],
        signatureHex: json["signatureHex"],
        txId: json["txId"],
      );
}
