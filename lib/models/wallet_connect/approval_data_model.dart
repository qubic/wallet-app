import 'package:reown_walletkit/reown_walletkit.dart';

class ApprovalDataModel {
  final PairingMetadata? pairingMetadata;
  final String? fromID;
  final String? fromName;

  ApprovalDataModel({
    required this.pairingMetadata,
    required this.fromID,
    required this.fromName,
  });
}

class TransactionApprovalDataModel extends ApprovalDataModel {
  final String toID;
  final int amount;
  final int? tick;
  final int? inputType;
  final String? payload;

  TransactionApprovalDataModel({
    required super.pairingMetadata,
    required super.fromID,
    required super.fromName,
    required this.toID,
    required this.amount,
    this.tick,
    this.inputType,
    this.payload,
  });
}

class MessageApprovalDataModel extends ApprovalDataModel {
  final String? message;

  MessageApprovalDataModel({
    required super.pairingMetadata,
    required super.fromID,
    required super.fromName,
    required this.message,
  });
}
