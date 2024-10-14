import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/models/wallet_connect/request_event.dart';
import 'package:qubic_wallet/stores/application_store.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class RequestSignTransactionEvent extends RequestEvent {
  final String fromID; //From which publicID should the funds flow
  final String toID; //To which publicID should the funds flow
  final int amount; //The amount of funds to send
  final int tick; //The tick to be used for the transaction

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
    if ((account.amount == null) || (account.amount! < amount)) {
      throw ArgumentError("insufficient funds in fromID");
    }
    if (account.publicId == toID) {
      throw ArgumentError("fromID and toID are the same");
    }
    if (appStore.currentTick < tick) {
      throw ArgumentError("Tick is already in the past");
    }
    fromIDName = account.name;
  }

  void setPairingMetadata(PairingMetadata pairingMetadata) {
    this.pairingMetadata = pairingMetadata;
  }

  //Gets only the data stored here (in a dynamic format)
  dynamic getData() {
    return {fromID: fromID, toID: toID, amount: amount, tick: tick};
  }

  RequestSignTransactionEvent({
    required super.topic,
    required super.requestId,
    required this.fromID,
    required this.toID,
    required this.amount,
    required this.tick,
  });

  //Creates a RequestSendQubicEvent from a map validating data types
  factory RequestSignTransactionEvent.fromMap(
      Map<String, dynamic> map, String topic, int requestId) {
    var validFromID = FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: "fromID is required"),
      CustomFormFieldValidators.isPublicIDNoContext(
          errorText: "fromID is not a valid publicID")
    ])(map["fromID"]);
    if ((map["fromID"] == null) || (validFromID != null)) {
      throw ArgumentError(validFromID);
    }

    var validToId = FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: "toID is required"),
      CustomFormFieldValidators.isPublicIDNoContext(
          errorText: "toID is not a valid publicID")
    ])(map["toID"]);
    if ((map["toID"] == null) || (validToId != null)) {
      throw ArgumentError(validToId);
    }

    var validAmount = FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: "amount is required"),
      FormBuilderValidators.positiveNumber(
          errorText: "amount must be a positive number")
    ])(map["amount"]);

    if ((map["amount"] == null) || (validAmount != null)) {
      throw ArgumentError(validAmount);
    }

    var validTick = FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: "tick is required"),
      FormBuilderValidators.positiveNumber(
          errorText: "tick must be a positive number")
    ])(map["tick"]);

    if ((map["tick"] == null) || (validTick != null)) {
      throw ArgumentError(validTick);
    }

    return RequestSignTransactionEvent(
      topic: topic.toString(),
      requestId: requestId,
      fromID: map["fromID"],
      toID: map["toID"],
      amount: int.parse(map["amount"]),
      tick: int.parse(map["tick"]),
    );
  }

  get isPublicIDNoContext => null;
}
