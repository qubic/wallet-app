class CurrentTickDto {
  final int tick;
  final int duration;
  final int epoch;
  final int initialTick;

  CurrentTickDto(
      {required this.tick,
      required this.duration,
      required this.epoch,
      required this.initialTick});

  factory CurrentTickDto.fromJson(Map<String, dynamic> json) {
    return CurrentTickDto(
      tick: json['tick'],
      duration: json['duration'],
      epoch: json['epoch'],
      initialTick: json['initialTick'],
    );
  }
}
