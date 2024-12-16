import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/models/wallet_connect/request_event.dart';
import 'package:qubic_wallet/stores/application_store.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

class RequestSignGenericEvent extends RequestEvent {
  final String fromID; //From which publicID should the funds flow
  final String message; //To which publicID should the funds flow

  late final String fromIDName; //The name of the fromID
  late final PairingMetadata?
      pairingMetadata; //The pairing metadata to send the request

  //Validates the request to send qubic against the wallet context
  void validateOrThrow() {
    ApplicationStore appStore = getIt<ApplicationStore>();
    var account =
        appStore.currentQubicIDs.firstWhereOrNull((e) => e.publicId == fromID);
    if (account == null) {
      throw ArgumentError("fromID is unknown");
    }
    fromIDName = account.name;
  }

  void setPairingMetadata(PairingMetadata pairingMetadata) {
    this.pairingMetadata = pairingMetadata;
  }

  //Gets only the data stored here (in a dynamic format)
  dynamic getData() {
    return {fromID: fromID, message: message};
  }

  RequestSignGenericEvent({
    required super.topic,
    required super.requestId,
    required this.fromID,
    required this.message,
  });

  //Creates a RequestSendQubicEvent from a map validating data types
  factory RequestSignGenericEvent.fromMap(
      Map<String, dynamic> map, String topic, int requestId) {
    var validFromID = FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: "fromID is required"),
      CustomFormFieldValidators.isPublicIDNoContext(
          errorText: "fromID is not a valid publicID")
    ])(map["fromID"]);
    if ((map["fromID"] == null) || (validFromID != null)) {
      throw ArgumentError(validFromID);
    }

    var validMessage = FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: "message is required"),
    ])(map["message"]);
    if ((map["message"] == null) || (validMessage != null)) {
      throw ArgumentError(validMessage);
    }

    return RequestSignGenericEvent(
      topic: topic.toString(),
      requestId: requestId,
      fromID: map["fromID"],
      message: map["message"],
    );
  }

  get isPublicIDNoContext => null;
}
