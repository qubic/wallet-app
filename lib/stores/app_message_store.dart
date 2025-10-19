import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/app_message_dto.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/resources/apis/static/qubic_static_api.dart';
import 'package:universal_platform/universal_platform.dart';

part 'app_message_store.g.dart';

// ignore: library_private_types_in_public_api
class AppMessageStore = _AppMessageStore with _$AppMessageStore;

abstract class _AppMessageStore with Store {
  @observable
  bool isLoading = false;

  @action
  Future<AppMessageModel?> getAppMessage() async {
    isLoading = true;
    try {
      final message = await getIt<QubicStaticApi>().getAppMessage();
      if (message != null &&
          message.isValid(UniversalPlatform.operatingSystem)) {
        return message;
      }
      return null;
    } catch (e) {
      appLogger.e(e);
      return null;
    } finally {
      isLoading = false;
    }
  }
}
