import 'package:collection/collection.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/components/wallet_connect/approve_wc_method_screen.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:qubic_wallet/models/wallet_connect/pairing_metadata_mixin.dart';
import 'package:qubic_wallet/models/wallet_connect/request_event.dart';
import 'package:qubic_wallet/stores/application_store.dart';

const String wcRequestParamInputType = "inputType";
const String wcRequestParamPayload = "payload";

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

  RequestHandleTransactionEvent({
    required super.topic,
    required super.requestId,
    required this.fromID,
    required this.toID,
    required this.amount,
    required this.tick,
    required this.inputType,
    required this.payload,
    this.method,
  });

  //Creates a RequestSendQubicEvent from a map validating data types
  factory RequestHandleTransactionEvent.fromMap(
      Map<String, dynamic> map, String topic, int requestId,
      {String? method}) {
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
      (method == WcMethods.wSendQubic)
          ? FormBuilderValidators.positiveNumber()
          : FormBuilderValidators.min(0)
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
      var validInputType = FormBuilderValidators.compose(
          [FormBuilderValidators.min(0)])(map[wcRequestParamInputType]);
      if (validInputType != null) {
        throw ArgumentError(validInputType, wcRequestParamInputType);
      }
    }
    return RequestHandleTransactionEvent(
      topic: topic.toString(),
      requestId: requestId,
      fromID: map[wcRequestParamFrom],
      toID: map[wcRequestParamTo],
      amount: map[wcRequestParamAmount],
      tick: map[wcRequestParamTick],
      inputType: map[wcRequestParamInputType],
      payload: map[wcRequestParamPayload],
      method: method,
    );
  }

  get isPublicIDNoContext => null;

  @override
  String toString() {
    return 'RequestSignTransactionEvent(fromID: $fromID, toID: $toID, amount: $amount, tick: $tick, inputType: $inputType, payload: $payload, fromIDName: $fromIDName, pairingMetadata: $pairingMetadata)';
  }
}
