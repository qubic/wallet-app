class MarketInfoDto {
  final String? timestamp;
  final String? circulatingSupply;
  final int? activeAddresses;
  final num? price;
  final String? marketCap;
  final int? epoch;
  final int? currentTick;
  final int? ticksInCurrentEpoch;
  final int? emptyTicksInCurrentEpoch;
  final num? epochTickQuality;
  final String? burnedQus;

  MarketInfoDto({
    required this.timestamp,
    required this.circulatingSupply,
    required this.activeAddresses,
    required this.price,
    required this.marketCap,
    required this.epoch,
    required this.currentTick,
    required this.ticksInCurrentEpoch,
    required this.emptyTicksInCurrentEpoch,
    required this.epochTickQuality,
    required this.burnedQus,
  });

  factory MarketInfoDto.fromJson(Map<String, dynamic> json) => MarketInfoDto(
        timestamp: json["timestamp"],
        circulatingSupply: json["circulatingSupply"],
        activeAddresses: json["activeAddresses"],
        price: json["price"]?.toDouble(),
        marketCap: json["marketCap"],
        epoch: json["epoch"],
        currentTick: json["currentTick"],
        ticksInCurrentEpoch: json["ticksInCurrentEpoch"],
        emptyTicksInCurrentEpoch: json["emptyTicksInCurrentEpoch"],
        epochTickQuality: json["epochTickQuality"]?.toDouble(),
        burnedQus: json["burnedQus"],
      );

  @override
  String toString() {
    return 'MarketInfoDtoo(timestamp: $timestamp, circulatingSupply: $circulatingSupply, activeAddresses: $activeAddresses, price: $price, marketCap: $marketCap, epoch: $epoch, currentTick: $currentTick, ticksInCurrentEpoch: $ticksInCurrentEpoch, emptyTicksInCurrentEpoch: $emptyTicksInCurrentEpoch, epochTickQuality: $epochTickQuality, burnedQus: $burnedQus)';
  }

  MarketInfoDto copyWith({
    String? timestamp,
    String? circulatingSupply,
    int? activeAddresses,
    num? price,
    String? marketCap,
    int? epoch,
    int? currentTick,
    int? ticksInCurrentEpoch,
    int? emptyTicksInCurrentEpoch,
    num? epochTickQuality,
    String? burnedQus,
  }) {
    return MarketInfoDto(
      timestamp: timestamp ?? this.timestamp,
      circulatingSupply: circulatingSupply ?? this.circulatingSupply,
      activeAddresses: activeAddresses ?? this.activeAddresses,
      price: price ?? this.price,
      marketCap: marketCap ?? this.marketCap,
      epoch: epoch ?? this.epoch,
      currentTick: currentTick ?? this.currentTick,
      ticksInCurrentEpoch: ticksInCurrentEpoch ?? this.ticksInCurrentEpoch,
      emptyTicksInCurrentEpoch:
          emptyTicksInCurrentEpoch ?? this.emptyTicksInCurrentEpoch,
      epochTickQuality: epochTickQuality ?? this.epochTickQuality,
      burnedQus: burnedQus ?? this.burnedQus,
    );
  }
}
