import 'package:reown_walletkit/reown_walletkit.dart';

class ApprovalDataModel {
  final String? toID;
  final int? amount;
  final int? tick;
  final int? inputType;
  final String? payload;
  final PairingMetadata? pairingMetadata;
  final String fromID;
  final String? fromName;
  final String? message;

  ApprovalDataModel({
    required this.pairingMetadata,
    required this.fromID,
    required this.fromName,
    this.toID,
    this.amount,
    this.tick,
    this.inputType,
    this.payload,
    this.message,
  });
}
