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
      );

  /// Get procedure name by procedure ID
  String? getProcedureName(int type) {
    try {
      return procedures.firstWhere((p) => p.id == type).name;
    } catch (e) {
      return null;
    }
  }

  /// Get procedure fee by procedure ID
  int? getProcedureFee(int type) {
    try {
      return procedures.firstWhere((p) => p.id == type).fee;
    } catch (e) {
      return null;
    }
  }

  /// Check if this contract supports a specific procedure by name (case-insensitive)
  bool supportsProcedure(String procedureName) {
    return procedures
        .any((p) => p.name.toLowerCase() == procedureName.toLowerCase());
  }

  /// Check if this contract supports Transfer Share Management Rights
  bool supportsTransferShareManagementRights() {
    return supportsProcedure(ReleaseTransferRightsInfo.procedureName);
  }

  /// Get procedure ID by procedure name (case-insensitive)
  int? getProcedureId(String procedureName) {
    try {
      return procedures
          .firstWhere(
              (p) => p.name.toLowerCase() == procedureName.toLowerCase())
          .id;
    } catch (e) {
      return null;
    }
  }
}

class Procedure {
  final int id;
  final String name;
  final int? fee;

  Procedure({
    required this.id,
    required this.name,
    required this.fee,
  });

  factory Procedure.fromJson(Map<String, dynamic> json) => Procedure(
        id: json["id"],
        name: json["name"],
        fee: json["fee"],
      );
}
