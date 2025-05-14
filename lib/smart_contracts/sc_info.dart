import 'package:qubic_wallet/smart_contracts/qutil_info.dart';
import 'package:qubic_wallet/smart_contracts/qx_info.dart';

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

  String? getProcedureName(int type) {
    return procedures[type];
  }
}

class QubicSCStore {
  static final List<QubicSCModel> contracts = [
    QubicSCModel(
      contractIndex: 1,
      name: 'QX',
      contractId: QxInfo.address,
      procedures: {
        1: 'Qx Issue Asset',
        2: 'Qx Transfer Shares',
        5: 'Qx Add to Ask Orders',
        6: 'Qx Add to Bid Orders',
        7: 'Qx Remove from Ask Orders',
        8: 'Qx Remove from Bid Orders',
      },
    ),
    QubicSCModel(
      contractIndex: 2,
      name: 'Quottery',
      contractId:
          'CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACNKL',
      procedures: {
        1: 'Quottery Issue Bet',
        2: 'Quottery Join Bet',
        3: 'Quottery Cancel Bet',
        4: 'Quottery Publish Result',
      },
    ),
    QubicSCModel(
      contractIndex: 3,
      name: 'Random',
      contractId:
          'DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANMIG',
      procedures: {1: 'Random Reveal and Commit'},
    ),
    QubicSCModel(
      contractIndex: 4,
      name: 'QUtil',
      contractId: QutilInfo.address,
      procedures: {
        1: 'Send to Many',
        2: 'Burn Qubic',
        3: 'Send to Many Benchmark'
      },
    ),
    QubicSCModel(
      contractIndex: 6,
      name: 'General Quorum Proposal',
      contractId:
          'GAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQGNM',
      procedures: {1: 'GQMPROP Create Proposal', 2: 'GQMPROP Vote'},
    ),
    QubicSCModel(
      contractIndex: 8,
      name: 'Computer Controller Fund',
      contractId:
          'IAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABXSH',
      procedures: {1: 'CCF Create Proposal', 2: 'CCF Vote'},
    ),
    QubicSCModel(
      contractIndex: 9,
      name: 'QEarn',
      contractId:
          'JAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAVKHO',
      procedures: {1: 'QEarn Lock', 2: 'QEarn Unlock'},
    ),
    QubicSCModel(
      contractIndex: 10,
      name: 'QVault',
      contractId:
          'KAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXIUO',
      procedures: {
        1: 'QVault Submit Auth Address',
        2: 'QVault Change Auth Address',
        3: 'QVault Submit Distribution Permille',
        4: 'QVault Change Distribution Permille',
        5: 'QVault Submit Reinvesting Address',
        6: 'QVault Change Reinvesting Address',
        7: 'QVault Submit Admin Address',
        8: 'QVault Change Admin Address',
        9: 'QVault Submit Banned Address',
        10: 'QVault Save Banned Address',
        11: 'QVault Submit Unbanned Address',
        12: 'QVault Unblock Banned Address',
      },
    ),
    QubicSCModel(
      contractIndex: 11,
      name: 'MSVault',
      contractId:
          'LAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKPTJ',
      procedures: {
        1: 'MSVault Register Vault',
        2: 'MSVault Deposit',
        3: 'MSVault Release',
        4: 'MSVault Reset Release',
        13: 'MSVault Vote Fee Change',
      },
    ),
    QubicSCModel(
        contractIndex: 12,
        name: "Qbay",
        contractId:
            "MAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWLWD",
        procedures: {
          1: 'Qbay setting CFB and Qubic Price',
          2: 'Qbay create collection',
          3: 'Qbay mint',
          4: 'Qbay mint of drop',
          5: 'Qbay transfer',
          6: 'Qbay list in market',
          7: 'Qbay buy',
          8: 'Qbay cancel sale',
          9: 'Qbay list in exchange',
          10: 'Qbay cancel exchange',
          11: 'Qbay make offer',
          12: 'Qbay accept offer',
          13: 'Qbay cancel offer',
          14: 'Qbay create traditional auction',
          15: 'Qbay bid on traditional auction',
          16: 'Qbay transfer share management rights',
          17: 'Qbay change status of marketplace'
        })
  ];

  static final Map<String, QubicSCModel> _byId = {
    for (var sc in contracts) sc.contractId: sc,
  };

  static String? fromContractId(String id) => _byId[id]?.name;

  static bool isSC(String id) => _byId.containsKey(id);

  static String? getProcedureName(String contractId, int type) {
    return _byId[contractId]?.getProcedureName(type);
  }
}
