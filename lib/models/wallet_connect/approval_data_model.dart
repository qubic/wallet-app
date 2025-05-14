import 'package:reown_walletkit/reown_walletkit.dart';

class ApprovalDataModel {
  final String? toID;
  final String? redirectUrl;
  final int? amount;
  final int? tick;
  final int? inputType;
  final String? payload;
  final String? assetName;
  final PairingMetadata? pairingMetadata;
  final String fromID;
  final String? fromName;
  final String? message;
  final String? issuer;
  ApprovalDataModel({
    required this.pairingMetadata,
    required this.fromID,
    required this.fromName,
    required this.redirectUrl,
    this.toID,
    this.amount,
    this.tick,
    this.inputType,
    this.payload,
    this.message,
    this.assetName,
    this.issuer,
  });
}
