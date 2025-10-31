import 'package:qubic_wallet/models/smart_contracts_response.dart';

class QubicSCModel {
  final int contractIndex;
  final String name;
  final String contractId;
  final Map<int, String> procedures;

  QubicSCModel({
    required this.contractIndex,
    required this.name,
    required this.contractId,
    required this.procedures,
  });

  factory QubicSCModel.fromDto(SmartContractDto dto) {
    return QubicSCModel(
      contractIndex: dto.contractIndex,
      name: dto.name,
      contractId: dto.address,
      procedures: {
        for (var proc in dto.procedures) proc.id: proc.name,
      },
    );
  }

  String? getProcedureName(int type) {
    return procedures[type];
  }
}
