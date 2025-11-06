import '../di.dart';
import '../services/qubic_label_service.dart';

class AddressUIHelper {
  static String? getLabel(String accountId) {
    final service = getIt<QubicLabelService>();
    return service.isKnownEntity(accountId)
        ? service.getLabel(accountId)
        : null;
  }
}
