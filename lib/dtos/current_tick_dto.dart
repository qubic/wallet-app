class CurrentTickDto {
  final int tick;

  CurrentTickDto({required this.tick});

  factory CurrentTickDto.fromJson(Map<String, dynamic> data) {
    return CurrentTickDto(tick: data['latestTick']);
  }
}
