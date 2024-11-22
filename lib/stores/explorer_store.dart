// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/market_info_dto.dart';
import 'package:qubic_wallet/dtos/network_overview_dto.dart';
import 'package:qubic_wallet/helpers/epoch_helpers.dart';
import 'package:qubic_wallet/models/pagination_request_model.dart';
import 'package:qubic_wallet/resources/apis/archive/qubic_archive_api.dart';

part 'explorer_store.g.dart';

// flutter pub run build_runner watch --delete-conflicting-outputs

class ExplorerStore = _ExplorerStore with _$ExplorerStore;

abstract class _ExplorerStore with Store {
  final qubicArchive = getIt<QubicArchiveApi>();
  @observable
  MarketInfoDto? networkOverview;

  @observable
  NetworkTicksDto? networkTicks;

  @observable
  int pageNumber = 1;

  @observable
  bool isTicksLoading = true;

  Future<void> getTicks() async {
    try {
      final respose = await qubicArchive.getNetworkTicks(getCurrentEpoch(),
          PaginationRequestModel(page: pageNumber, pageSize: 33));
      setTicks(respose);
    } catch (e) {}
  }

  @action
  void setLoading(bool value) {
    isTicksLoading = value;
  }

  @action
  void setTicks(NetworkTicksDto newTicks) {
    networkTicks = newTicks;
  }

  @action
  setPageNumber(int newPageNumber) {
    pageNumber = newPageNumber;
    getTicks();
  }

  @action
  void setNetworkOverview(MarketInfoDto newOverview) {
    networkOverview = newOverview;
  }

  @action
  void clearNetworkOverview() {
    networkOverview = null;
  }
}
