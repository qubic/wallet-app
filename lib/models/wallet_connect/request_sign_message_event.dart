import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:qubic_wallet/models/wallet_connect/pairing_metadata_mixin.dart';
import 'package:qubic_wallet/models/wallet_connect/request_event.dart';
import 'package:qubic_wallet/stores/application_store.dart';

class RequestSignMessageEvent extends RequestEvent with PairingMetadataMixin {
  final String fromID; //From which publicID should the funds flow
  final String message; //To which publicID should the funds flow

  //Validates the request to send qubic against the wallet context
  void validateOrThrow() {
    ApplicationStore appStore = getIt<ApplicationStore>();
    var account = appStore.findAccountById(fromID);
    if (account == null) {
      throw ArgumentError(
          "Account not found in wallet", WcRequestParameters.from);
    }
    fromIDName = account.name;
  }

  RequestSignMessageEvent({
    required super.topic,
    required super.requestId,
    required this.fromID,
    required this.message,
  });

  //Creates a RequestSendQubicEvent from a map validating data types
  factory RequestSignMessageEvent.fromMap(
      Map<String, dynamic> map, String topic, int requestId) {
    WcValidationUtils.validateField(
      map: map,
      fieldName: WcRequestParameters.from,
      validators: [
        FormBuilderValidators.required(),
        CustomFormFieldValidators.isPublicIDNoContext()
      ],
    );

    WcValidationUtils.validateField(
      map: map,
      fieldName: WcRequestParameters.message,
      validators: [FormBuilderValidators.required()],
    );

    return RequestSignMessageEvent(
      topic: topic.toString(),
      requestId: requestId,
      fromID: map[WcRequestParameters.from],
      message: map[WcRequestParameters.message],
    );
  }

  get isPublicIDNoContext => null;
}
