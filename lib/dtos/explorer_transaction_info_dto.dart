// Holds transaction information for an explorer query
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

  ComputedTransactionStatus getStatus() {
    if (!executed) {
      return ComputedTransactionStatus.failure;
    }
    if (executed && (amount == 0 || moneyFlew)) {
      return ComputedTransactionStatus.success;
    }
    if (executed && !moneyFlew) {
      return ComputedTransactionStatus.failure;
    }
    return ComputedTransactionStatus.invalid;
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
      this.moneyFlew);

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
        data['moneyFlew']);
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
        source.moneyFlew);
  }
}

/// Holds transaction information for an explorer query used in Qubic Archive
class ExplorerTransactionDto {
  final Transaction transaction;
  final String? timestamp;
  final bool moneyFlew;

  ExplorerTransactionDto({
    required this.transaction,
    required this.timestamp,
    required this.moneyFlew,
  });

  factory ExplorerTransactionDto.fromJson(Map<String, dynamic> json) =>
      ExplorerTransactionDto(
        transaction: Transaction.fromJson(json["transaction"]),
        timestamp: json["timestamp"],
        moneyFlew: json["moneyFlew"],
      );

  ComputedTransactionStatus getStatus() {
    if (int.tryParse(transaction.amount ?? "0") == 0 || moneyFlew) {
      return ComputedTransactionStatus.success;
    }
    return ComputedTransactionStatus.failure;
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
