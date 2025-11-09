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
}

class _ProcedureData {
  final int id;
  final String name;

  _ProcedureData({
    required this.id,
    required this.name,
  });
}
