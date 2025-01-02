import 'package:collection/collection.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
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

  //Validates the request to send qubic against the wallet context
  void validateOrThrow() {
    ApplicationStore appStore = getIt<ApplicationStore>();
    var account =
        appStore.currentQubicIDs.firstWhereOrNull((e) => e.publicId == fromID);
    if (account == null) {
      throw ArgumentError("Account not found in wallet", wcRequestParamFrom);
    }
    if ((account.amount == null) || (account.amount! < amount)) {
      throw ArgumentError("Insufficient funds", wcRequestParamFrom);
    }
    if (account.publicId == toID) {
      throw ArgumentError(
          "$wcRequestParamFrom and $wcRequestParamTo are the same");
    }
    if (tick != null) {
      if (appStore.currentTick > tick!) {
        throw ArgumentError("Value is already in the past", wcRequestParamTick);
      }
    }
    fromIDName = account.name;
  }

  RequestHandleTransactionEvent(
      {required super.topic,
      required super.requestId,
      required this.fromID,
      required this.toID,
      required this.amount,
      required this.tick,
      required this.inputType,
      required this.payload});

  //Creates a RequestSendQubicEvent from a map validating data types
  factory RequestHandleTransactionEvent.fromMap(
      Map<String, dynamic> map, String topic, int requestId) {
    appLogger.e(map.toString());

    var validFromID = FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      CustomFormFieldValidators.isPublicIDNoContext()
    ])(map[wcRequestParamFrom]);
    if ((map[wcRequestParamFrom] == null) || (validFromID != null)) {
      throw ArgumentError(validFromID, wcRequestParamFrom);
    }

    var validToId = FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      CustomFormFieldValidators.isPublicIDNoContext()
    ])(map[wcRequestParamTo]);
    if ((map[wcRequestParamTo] == null) || (validToId != null)) {
      throw ArgumentError(validToId, wcRequestParamTo);
    }

    var validAmount = FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.positiveNumber()
    ])(map[wcRequestParamAmount]);

    if ((map[wcRequestParamAmount] == null) || (validAmount != null)) {
      throw ArgumentError(validAmount, wcRequestParamAmount);
    }

    if (map[wcRequestParamTick] != null) {
      var validTick = FormBuilderValidators.compose(
          [FormBuilderValidators.positiveNumber()])(map[wcRequestParamTick]);
      if (validTick != null) {
        throw ArgumentError(validTick, wcRequestParamTick);
      }
    }

    if (map[wcRequestParamInputType] != null) {
      var validInputType = FormBuilderValidators.compose([
        FormBuilderValidators.positiveNumber()
      ])(map[wcRequestParamInputType]);
      if (validInputType != null) {
        throw ArgumentError(validInputType, wcRequestParamInputType);
      }
    }
    return RequestHandleTransactionEvent(
      topic: topic.toString(),
      requestId: requestId,
      fromID: map[wcRequestParamFrom],
      toID: map[wcRequestParamTo],
      amount: int.parse(map[wcRequestParamAmount]),
      tick: map[wcRequestParamTick] != null
          ? int.parse(map[wcRequestParamTick])
          : null,
      inputType: map[wcRequestParamInputType] != null
          ? int.tryParse(map[wcRequestParamInputType])
          : null,
      payload: map["payload"],
    );
  }

  get isPublicIDNoContext => null;

  @override
  String toString() {
    return 'RequestSignTransactionEvent(fromID: $fromID, toID: $toID, amount: $amount, tick: $tick, inputType: $inputType, payload: $payload, fromIDName: $fromIDName, pairingMetadata: $pairingMetadata)';
  }
}
