import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:qubic_wallet/models/wallet_connect/pairing_metadata_mixin.dart';
import 'package:qubic_wallet/models/wallet_connect/request_event.dart';
import 'package:qubic_wallet/stores/application_store.dart';

/// A model to handle a WC transaction request method from `WcMethods`
/// including `wSendQubic` , `wSendTransaction` and `wSignTransaction`
class RequestHandleTransactionEvent extends RequestEvent
    with PairingMetadataMixin {
  final String fromID; //From which publicID should the funds flow
  final String toID; //To which publicID should the funds flow
  final int amount; //The amount of funds to send
  final int? tick; //The tick to be used for the transaction
  final int? inputType;
  final String? payload;
  String? method;

  //Validates the request to send qubic against the wallet context
  void validateOrThrow() {
    ApplicationStore appStore = getIt<ApplicationStore>();
    var account = appStore.findAccountById(fromID);
    if (account == null) {
      throw ArgumentError(
          "Account not found in wallet", WcRequestParameters.from);
    }
    if ((account.amount == null) || (account.amount! < amount)) {
      throw ArgumentError("Insufficient funds", WcRequestParameters.from);
    }
    if (account.publicId == toID) {
      throw ArgumentError(
          "${WcRequestParameters.from} and ${WcRequestParameters.to} are the same");
    }
    if (tick != null) {
      if (appStore.currentTick > tick!) {
        throw ArgumentError(
            "Value is already in the past", WcRequestParameters.tick);
      }
    }
    fromIDName = account.name;
  }

  RequestHandleTransactionEvent({
    required super.topic,
    required super.requestId,
    required super.redirectUrl,
    required this.fromID,
    required this.toID,
    required this.amount,
    required this.tick,
    required this.inputType,
    required this.payload,
    this.method,
  });

  factory RequestHandleTransactionEvent.fromMap(
      Map<String, dynamic> map, String topic, int requestId,
      {String? method}) {
    WcValidationUtils.validateField(
      map: map,
      fieldName: WcRequestParameters.from,
      validators: [
        FormBuilderValidators.required(),
        CustomFormFieldValidators.isPublicIDNoContext(),
      ],
    );

    WcValidationUtils.validateField(
      map: map,
      fieldName: WcRequestParameters.to,
      validators: [
        FormBuilderValidators.required(),
        CustomFormFieldValidators.isPublicIDNoContext()
      ],
    );

    WcValidationUtils.validateField(
      map: map,
      fieldName: WcRequestParameters.amount,
      validators: [
        FormBuilderValidators.required(),
        (method == WcMethods.wSendQubic)
            ? FormBuilderValidators.positiveNumber()
            : FormBuilderValidators.min(0)
      ],
    );

    WcValidationUtils.validateOptionalField(
      map: map,
      fieldName: WcRequestParameters.tick,
      validators: [FormBuilderValidators.positiveNumber()],
    );

    WcValidationUtils.validateOptionalField(
      map: map,
      fieldName: WcRequestParameters.inputType,
      validators: [FormBuilderValidators.min(0)],
    );
    return RequestHandleTransactionEvent(
      topic: topic.toString(),
      requestId: requestId,
      redirectUrl: map[WcRequestParameters.redirectUrl],
      fromID: map[WcRequestParameters.from],
      toID: map[WcRequestParameters.to],
      amount: map[WcRequestParameters.amount],
      tick: map[WcRequestParameters.tick],
      inputType: map[WcRequestParameters.inputType],
      payload: map[WcRequestParameters.payload],
      method: method,
    );
  }

  get isPublicIDNoContext => null;

  @override
  String toString() {
    return 'RequestSignTransactionEvent(fromID: $fromID, toID: $toID, amount: $amount, tick: $tick, inputType: $inputType, payload: $payload, fromIDName: $fromIDName, pairingMetadata: $pairingMetadata)';
  }
}
