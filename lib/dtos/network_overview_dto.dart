import 'package:qubic_wallet/dtos/tick_dto.dart';
import 'package:qubic_wallet/models/pagination_response_model.dart';

class NetworkTicksDto {
  final PaginationResponseModel pagination;
  final List<TickDto> ticks;

  NetworkTicksDto({
    required this.ticks,
    required this.pagination,
  });

  factory NetworkTicksDto.fromJson(Map<String, dynamic> json) {
    return NetworkTicksDto(
      pagination: PaginationResponseModel.fromJson(json['pagination']),
      ticks: List<TickDto>.from(json['ticks'].map((x) => TickDto.fromJson(x))),
    );
  }
}
