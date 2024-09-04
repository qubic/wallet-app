import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/dtos/tick_dto.dart';

class NetworkOverviewDto {
  @observable
  int numberOfTicks;
  @observable
  int numberOfEmptyTicks;
  @observable
  int numberOfEntities;
  @observable
  int supply;
  @observable
  double price;
  @observable
  int marketCap;
  List<TickDto> ticks;

  NetworkOverviewDto(
      this.numberOfTicks,
      this.numberOfEmptyTicks,
      this.numberOfEntities,
      this.supply,
      this.ticks,
      this.price,
      this.marketCap);

  String get tickQualityPercentage => numberOfTicks == 0
      ? "0"
      : ((numberOfTicks - numberOfEmptyTicks) / numberOfTicks * 100)
          .toStringAsFixed(2);

  factory NetworkOverviewDto.clone(NetworkOverviewDto other,
      {bool descendingTicks = false}) {
    return NetworkOverviewDto(
        other.numberOfTicks,
        other.numberOfEmptyTicks,
        other.numberOfEntities,
        other.supply,
        List<TickDto>.from(other.ticks),
        other.price,
        other.marketCap);
  }

  factory NetworkOverviewDto.fromJson(Map<String, dynamic> data,
      {bool descendingTicks = false}) {
    List<TickDto> a =
        data['ticks'].map<TickDto>((e) => TickDto.fromJson(e)).toList();

    return NetworkOverviewDto(
        data['numberOfTicks'],
        data['numberOfEmptyTicks'],
        data['numberOfEntities'],
        data['supply'],
        descendingTicks ? a.reversed.toList() : a,
        data['price'],
        data['marketCapitalization']);
  }
}
