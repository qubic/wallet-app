import 'package:collection/collection.dart';
import 'package:qubic_wallet/smart_contracts/release_transfer_rights_info.dart';

class SmartContractsResponse {
  final List<SmartContractModel> smartContracts;

  SmartContractsResponse({
    required this.smartContracts,
  });

  factory SmartContractsResponse.fromJson(Map<String, dynamic> json) =>
      SmartContractsResponse(
        smartContracts: List<SmartContractModel>.from(
            json["smart_contracts"].map((x) => SmartContractModel.fromJson(x))),
      );
}

class SmartContractModel {
  final String filename;
  final String name;
  final String? label;
  final String? githubUrl;
  final int contractIndex;
  final String address;
  final List<Procedure> procedures;
  final String? website;
  final String? proposalUrl;
  final bool allowTransferShares;

  SmartContractModel({
    required this.filename,
    required this.name,
    required this.label,
    required this.githubUrl,
    required this.contractIndex,
    required this.address,
    required this.procedures,
    required this.website,
    required this.proposalUrl,
    required this.allowTransferShares,
  });

  factory SmartContractModel.fromJson(Map<String, dynamic> json) =>
      SmartContractModel(
        filename: json["filename"],
        name: json["name"],
        label: json["label"],
        githubUrl: json["githubUrl"],
        contractIndex: json["contractIndex"],
        address: json["address"],
        procedures: List<Procedure>.from(
            json["procedures"].map((x) => Procedure.fromJson(x))),
        website: json["website"],
        proposalUrl: json["proposalUrl"],
        allowTransferShares: json["allowTransferShares"] ?? false,
      );

  /// Get procedure name by procedure ID
  String? getProcedureName(int type) =>
      procedures.firstWhereOrNull((p) => p.id == type)?.name;

  /// Get procedure fee by procedure ID
  int? getProcedureFee(int type) =>
      procedures.firstWhereOrNull((p) => p.id == type)?.fee;

  /// Check if this contract supports a specific procedure by name (case-insensitive)
  bool supportsProcedure(String procedureName) {
    final name = procedureName.toLowerCase();
    return procedures.any((p) => p.name.toLowerCase() == name);
  }

  /// Get procedure ID by procedure name (case-insensitive)
  int? getProcedureId(String procedureName) {
    final name = procedureName.toLowerCase();
    return procedures.firstWhereOrNull((p) => p.name.toLowerCase() == name)?.id;
  }

  Procedure? get _managementRightsProcedure =>
      procedures.firstWhereOrNull((p) => p.managementRightsType != null);

  bool hasManagementRightsProcedure() => _managementRightsProcedure != null;

  ManagementRightsProcedureType? getManagementRightsProcedureType() =>
      _managementRightsProcedure?.managementRightsType;

  int? getManagementRightsProcedureId() => _managementRightsProcedure?.id;
}

class Procedure {
  final int id;
  final String name;
  final int? fee;
  final String? sourceIdentifier;

  Procedure({
    required this.id,
    required this.name,
    required this.fee,
    this.sourceIdentifier,
  });

  ManagementRightsProcedureType? get managementRightsType {
    final id = sourceIdentifier?.toLowerCase();
    if (id == ReleaseTransferRightsInfo.transferSourceIdentifier) {
      return ManagementRightsProcedureType.transfer;
    }
    if (id == ReleaseTransferRightsInfo.revokeSourceIdentifier) {
      return ManagementRightsProcedureType.revoke;
    }
    return null;
  }

  factory Procedure.fromJson(Map<String, dynamic> json) => Procedure(
        id: json["id"],
        name: json["name"],
        fee: json["fee"],
        sourceIdentifier: json["sourceIdentifier"],
      );
}
