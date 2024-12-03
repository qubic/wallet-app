import 'package:qubic_wallet/dtos/explorer_transaction_info_dto.dart';

class ExplorerTickInfoDto {
  bool isNonEmpty;
  String tickLeaderId;
  int tickLeaderIndex;
  String? tickLeaderShortCode;
  String? signature;
  bool signatureVerified;
  bool completed;
  int tick;
  DateTime? timestamp;
  List<ExplorerTransactionInfoDto>? transactions;

  ExplorerTickInfoDto(
      this.isNonEmpty,
      this.tickLeaderId,
      this.tickLeaderIndex,
      this.tickLeaderShortCode,
      this.signature,
      this.signatureVerified,
      this.completed,
      this.tick,
      this.timestamp,
      this.transactions);

  factory ExplorerTickInfoDto.fromJson(Map<String, dynamic> data) {
    List<ExplorerTransactionInfoDto>? transactions;
    if (data['transactions'] != null) {
      transactions = data['transactions']
          ?.map<ExplorerTransactionInfoDto>(
              (e) => ExplorerTransactionInfoDto.fromJson(e))
          .toList();
    }

    return ExplorerTickInfoDto(
      data['isNonEmpty'],
      data['tickLeaderId'],
      data['tickLeaderIndex'],
      data['tickLeaderShortCode'],
      // ignore: prefer_if_null_operators
      data['signature'] == null
          ? null
          : data['signature'], //Somehow needs this syntax to work, ?? doesnt!?!
      data['signatureVerified'],
      data['completed'],
      data['tick'],
      data['timestamp'] == null
          ? null
          : DateTime.parse(data[
              'timestamp']), //Somehow needs this syntax to work, ?? doesnt!?!
      transactions,
    );
  }

  factory ExplorerTickInfoDto.clone(ExplorerTickInfoDto source) {
    List<ExplorerTransactionInfoDto>? transactions = source.transactions
        ?.map<ExplorerTransactionInfoDto>(
            (e) => ExplorerTransactionInfoDto.clone(e))
        .toList();

    return ExplorerTickInfoDto(
        source.isNonEmpty,
        source.tickLeaderId,
        source.tickLeaderIndex,
        source.tickLeaderShortCode,
        source.signature,
        source.signatureVerified,
        source.completed,
        source.tick,
        source.timestamp,
        transactions);
  }
}

class ExplorerTickDto {
  final int? computorIndex;
  final int? epoch;
  final int tickNumber;
  final DateTime? timestamp;
  final String? varStruct;
  final String? timeLock;
  final List<String>? transactionIds;
  final List<String>? contractFees;
  final String? signatureHex;
  final bool completed;
  String? tickLeaderId;

  ExplorerTickDto({
    this.computorIndex,
    this.epoch,
    required this.tickNumber,
    this.timestamp,
    this.varStruct,
    this.timeLock,
    this.transactionIds,
    this.contractFees,
    this.signatureHex,
    this.tickLeaderId,
    this.completed = true,
  });

  factory ExplorerTickDto.fromJson(Map<String, dynamic> json) =>
      ExplorerTickDto(
        computorIndex: json["computorIndex"],
        epoch: json["epoch"],
        tickNumber: json["tickNumber"],
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                int.tryParse(json["timestamp"] ?? 0) ?? 0),
        varStruct: json["varStruct"],
        timeLock: json["timeLock"],
        transactionIds: json["transactionIds"] == null
            ? null
            : List<String>.from(json["transactionIds"].map((x) => x)),
        contractFees: json["contractFees"] == null
            ? null
            : List<String>.from(json["contractFees"].map((x) => x)),
        signatureHex: json["signatureHex"],
      );
}
