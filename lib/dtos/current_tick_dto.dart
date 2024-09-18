// class CurrentTickDto {
//   int tick;

//   CurrentTickDto(this.tick);

//   factory CurrentTickDto.fromJson(Map<String, dynamic> data) {
//     if (data
//         case {
//           'tick': int currentTick,
//           //'tickDate': String tickDate,
//         }) {
//       return CurrentTickDto(currentTick);
//     } else {
//       throw FormatException('Invalid Tick JSON: $data');
//     }
//   }
// }

class CurrentTickDto {
  final int tick;

  CurrentTickDto({required this.tick});

  factory CurrentTickDto.fromJson(Map<String, dynamic> data) {
    return CurrentTickDto(tick: data['latestTick']);
  }
}
