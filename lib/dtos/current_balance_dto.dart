class CurrentBalanceDto {
  final String id;
  final int balance;
  final int validForTick;
  final int latestIncomingTransferTick;
  final int latestOutgoingTransferTick;
  final String incomingAmount;
  final String outgoingAmount;
  final int numberOfIncomingTransfers;
  final int numberOfOutgoingTransfers;

  CurrentBalanceDto({
    required this.id,
    required this.balance,
    required this.validForTick,
    required this.latestIncomingTransferTick,
    required this.latestOutgoingTransferTick,
    required this.incomingAmount,
    required this.outgoingAmount,
    required this.numberOfIncomingTransfers,
    required this.numberOfOutgoingTransfers,
  });

  factory CurrentBalanceDto.fromJson(Map<String, dynamic> map) {
    return CurrentBalanceDto(
      id: map['id'],
      balance: int.tryParse(map['balance']) ?? 0,
      validForTick: map['validForTick'],
      latestIncomingTransferTick: map['latestIncomingTransferTick'],
      latestOutgoingTransferTick: map['latestOutgoingTransferTick'],
      incomingAmount: map['incomingAmount'],
      outgoingAmount: map['outgoingAmount'],
      numberOfIncomingTransfers: map['numberOfIncomingTransfers'],
      numberOfOutgoingTransfers: map['numberOfOutgoingTransfers'],
    );
  }

  @override
  String toString() {
    return 'CurrentBalanceDto(id: $id, balance: $balance, validForTick: $validForTick, latestIncomingTransferTick: $latestIncomingTransferTick, latestOutgoingTransferTick: $latestOutgoingTransferTick, incomingAmount: $incomingAmount, outgoingAmount: $outgoingAmount, numberOfIncomingTransfers: $numberOfIncomingTransfers, numberOfOutgoingTransfers: $numberOfOutgoingTransfers)';
  }

  @override
  bool operator ==(covariant CurrentBalanceDto other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.balance == balance &&
        other.validForTick == validForTick &&
        other.latestIncomingTransferTick == latestIncomingTransferTick &&
        other.latestOutgoingTransferTick == latestOutgoingTransferTick &&
        other.incomingAmount == incomingAmount &&
        other.outgoingAmount == outgoingAmount &&
        other.numberOfIncomingTransfers == numberOfIncomingTransfers &&
        other.numberOfOutgoingTransfers == numberOfOutgoingTransfers;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        balance.hashCode ^
        validForTick.hashCode ^
        latestIncomingTransferTick.hashCode ^
        latestOutgoingTransferTick.hashCode ^
        incomingAmount.hashCode ^
        outgoingAmount.hashCode ^
        numberOfIncomingTransfers.hashCode ^
        numberOfOutgoingTransfers.hashCode;
  }
}
