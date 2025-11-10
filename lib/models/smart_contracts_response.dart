class SmartContractsResponse {
  final List<SmartContractModel> smartContracts;

  SmartContractsResponse({
    required this.smartContracts,
  });

  factory SmartContractsResponse.fromJson(Map<String, dynamic> json) {
    return SmartContractsResponse(
      smartContracts: (json['smart_contracts'] as List)
          .map((e) => SmartContractModel.fromJson(e))
          .toList(),
    );
  }
}

class SmartContractModel {
  final String filename;
  final String name;
  final String label;
  final String githubUrl;
  final int contractIndex;
  final String address;
  final Map<int, String> procedures;

  SmartContractModel({
    required this.filename,
    required this.name,
    required this.label,
    required this.githubUrl,
    required this.contractIndex,
    required this.address,
    required this.procedures,
  });

  factory SmartContractModel.fromJson(Map<String, dynamic> json) {
    final proceduresList = (json['procedures'] as List)
        .map((e) => _ProcedureData(
              id: e['id'] as int,
              name: e['name'] as String,
              fee: e['fee'] ?? 0,
            ))
        .toList();

    return SmartContractModel(
      filename: json['filename'] as String,
      name: json['name'] as String,
      label: json['label'] as String,
      githubUrl: json['githubUrl'] as String,
      contractIndex: json['contractIndex'] as int,
      address: json['address'] as String,
      procedures: {
        for (var proc in proceduresList) proc.id: proc.name,
      },
    );
  }

  String? getProcedureName(int type) {
    return procedures[type];
  }

  /// Check if this contract supports a specific procedure by name
  bool supportsProcedure(String procedureName) {
    return procedures.values
        .any((name) => name.toLowerCase() == procedureName.toLowerCase());
  }

  /// Get procedure ID by procedure name (case-insensitive)
  int? getProcedureId(String procedureName) {
    for (var entry in procedures.entries) {
      if (entry.value.toLowerCase() == procedureName.toLowerCase()) {
        return entry.key;
      }
    }
    return null;
  }

  /// Check if this contract supports Transfer Share Management Rights
  bool supportsTransferShareManagementRights() {
    return supportsProcedure("Transfer Share Management Rights");
  }
}

class _ProcedureData {
  final int id;
  final String name;
  final int fee;

  _ProcedureData({
    required this.id,
    required this.name,
    this.fee = 0,
  });
}
