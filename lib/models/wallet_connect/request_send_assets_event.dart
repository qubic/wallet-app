import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/models/wallet_connect/pairing_metadata_mixin.dart';
import 'package:qubic_wallet/models/wallet_connect/request_event.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';

import '../../di.dart';

const wcRequestParamAssetName = "assetName";

class RequestSendAssetEvent extends RequestEvent with PairingMetadataMixin {
  final String from;
  final String to;
  final String assetName;
  final int amount;
  RequestSendAssetEvent({
    required super.topic,
    required super.requestId,
    required this.from,
    required this.to,
    required this.assetName,
    required this.amount,
  });

  void validateOrThrow() {
    ApplicationStore appStore = getIt<ApplicationStore>();
    var account = appStore.findAccountById(from);
    if (account == null) {
      throw ArgumentError("Account not found in wallet", wcRequestParamFrom);
    }
    final asset = account.assets.values
        .firstWhere((element) => element.assetName == assetName);
    if (asset.ownedAmount == null || asset.ownedAmount! < amount) {
      throw ArgumentError("Insufficient assets", wcRequestParamAmount);
    }
    // TODO: Uncomment the following lines after finishing testing
    // if (account.amount! < QxInfo.transferAssetFee) {
    //   throw ArgumentError("Insufficient funds");
    // }
    if (from == to) {
      throw ArgumentError("From and to are the same");
    }
    fromIDName = account.name;
  }

  factory RequestSendAssetEvent.fromMap(
      Map<String, dynamic> map, String topic, int requestId) {
    WcValidationUtils.validateField(
      map: map,
      fieldName: wcRequestParamFrom,
      validators: [
        FormBuilderValidators.required(),
        CustomFormFieldValidators.isPublicIDNoContext(),
      ],
    );

    WcValidationUtils.validateField(
      map: map,
      fieldName: wcRequestParamTo,
      validators: [
        FormBuilderValidators.required(),
        CustomFormFieldValidators.isPublicIDNoContext(),
      ],
    );

    WcValidationUtils.validateField(
      map: map,
      fieldName: wcRequestParamAssetName,
      validators: [FormBuilderValidators.required()],
    );

    WcValidationUtils.validateField(
      map: map,
      fieldName: wcRequestParamAmount,
      validators: [
        FormBuilderValidators.required(),
        FormBuilderValidators.positiveNumber(),
      ],
    );
    return RequestSendAssetEvent(
      topic: topic,
      requestId: requestId,
      from: map[wcRequestParamFrom],
      to: map[wcRequestParamTo],
      assetName: map[wcRequestParamAssetName],
      amount: map[wcRequestParamAmount],
    );
  }
}
