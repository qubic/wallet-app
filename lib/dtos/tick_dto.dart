class TickDto {
  int tick;
  bool arbitrated;

  TickDto(
    this.tick,
    this.arbitrated,
  );

  factory TickDto.fromJson(Map<String, dynamic> data) {
    return TickDto(
      data['tickNumber'],
      data['isEmpty'],
    );
  }
}
