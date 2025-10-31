class SmartContractsResponse {
  final List<SmartContractDto> smartContracts;

  SmartContractsResponse({
    required this.smartContracts,
  });

  factory SmartContractsResponse.fromJson(Map<String, dynamic> json) {
    return SmartContractsResponse(
      smartContracts: (json['smart_contracts'] as List)
          .map((e) => SmartContractDto.fromJson(e))
          .toList(),
    );
  }
}

class SmartContractDto {
  final String filename;
  final String name;
  final String label;
  final String githubUrl;
  final int contractIndex;
  final String address;
  final List<ProcedureDto> procedures;

  SmartContractDto({
    required this.filename,
    required this.name,
    required this.label,
    required this.githubUrl,
    required this.contractIndex,
    required this.address,
    required this.procedures,
  });

  factory SmartContractDto.fromJson(Map<String, dynamic> json) {
    return SmartContractDto(
      filename: json['filename'],
      name: json['name'],
      label: json['label'],
      githubUrl: json['githubUrl'],
      contractIndex: json['contractIndex'],
      address: json['address'],
      procedures: (json['procedures'] as List)
          .map((e) => ProcedureDto.fromJson(e))
          .toList(),
    );
  }
}

class ProcedureDto {
  final int id;
  final String name;

  ProcedureDto({
    required this.id,
    required this.name,
  });

  factory ProcedureDto.fromJson(Map<String, dynamic> json) {
    return ProcedureDto(
      id: json['id'],
      name: json['name'],
    );
  }
}
