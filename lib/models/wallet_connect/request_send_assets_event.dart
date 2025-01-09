import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/models/wallet_connect/pairing_metadata_mixin.dart';
import 'package:qubic_wallet/models/wallet_connect/request_event.dart';
import 'package:qubic_wallet/smart_contracts/qx_info.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:collection/collection.dart';

import '../../di.dart';

class RequestSendAssetEvent extends RequestEvent with PairingMetadataMixin {
  final String from;
  final String to;
  final String issuer;
  final String assetName;
  final int amount;
  RequestSendAssetEvent({
    required super.topic,
    required super.requestId,
    required this.from,
    required this.to,
    required this.issuer,
    required this.assetName,
    required this.amount,
  });

  void validateOrThrow() {
    ApplicationStore appStore = getIt<ApplicationStore>();
    var account = appStore.findAccountById(from);
    if (account == null) {
      throw ArgumentError(
          "Account not found in wallet", WcRequestParameters.from);
    }
    final asset = account.assets.values.firstWhereOrNull((element) =>
        element.assetName == assetName && element.issuerIdentity == issuer);
    if (asset == null) {
      throw ArgumentError("Asset not found in this account $from",
          WcRequestParameters.assetName);
    }
    if (asset.ownedAmount == null || asset.ownedAmount! < amount) {
      throw ArgumentError("Insufficient assets", WcRequestParameters.amount);
    }
    if (account.amount! < QxInfo.transferAssetFee) {
      throw ArgumentError("Insufficient funds");
    }
    if (from == to) {
      throw ArgumentError("From and to are the same");
    }
    fromIDName = account.name;
  }

  factory RequestSendAssetEvent.fromMap(
      Map<String, dynamic> map, String topic, int requestId) {
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
        CustomFormFieldValidators.isPublicIDNoContext(),
      ],
    );

    WcValidationUtils.validateField(
      map: map,
      fieldName: WcRequestParameters.issuer,
      validators: [
        FormBuilderValidators.required(),
        CustomFormFieldValidators.isPublicIDNoContext(),
      ],
    );

    WcValidationUtils.validateField(
      map: map,
      fieldName: WcRequestParameters.assetName,
      validators: [FormBuilderValidators.required()],
    );

    WcValidationUtils.validateField(
      map: map,
      fieldName: WcRequestParameters.amount,
      validators: [
        FormBuilderValidators.required(),
        FormBuilderValidators.positiveNumber(),
      ],
    );
    return RequestSendAssetEvent(
      topic: topic,
      requestId: requestId,
      from: map[WcRequestParameters.from],
      to: map[WcRequestParameters.to],
      assetName: map[WcRequestParameters.assetName],
      amount: map[WcRequestParameters.amount],
      issuer: map[WcRequestParameters.issuer],
    );
  }
}
