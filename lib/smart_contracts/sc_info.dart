enum QubicSCID {
  qX(1, 'QX', 'BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARMID'),
  quottery(2, 'Quottery',
      'CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACNKL'),
  qRnd(3, 'Random',
      'DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANMIG'),
  qutil(4, 'QUtil',
      'EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAVWRF'),
  mlm(5, 'My Last Match',
      'FAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAYWJB'),
  gqmProp(6, 'General Quorum Proposal',
      'GAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQGNM'),
  swatch(7, 'Supply Watcher',
      'HAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHYCM'),
  ccf(8, 'Computer Controller Fund',
      'IAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABXSH'),
  qEarn(9, 'QEarn',
      'JAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAVKHO'),
  qVault(10, 'QVault',
      'KAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXIUO'),
  msVault(11, 'MSVault',
      'LAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKPTJ');

  static final Map<String, Map<int, String>> procedureNames = {
    qX.contractId: {
      1: 'Qx Issue Asset',
      2: 'Qx Transfer Shares',
      5: 'Qx Add to Ask Orders',
      6: 'Qx Add to Bid Orders',
      7: 'Qx Remove from Ask Orders',
      8: 'Qx Remove from Bid Orders'
    },
    quottery.contractId: {
      1: 'Quottery Issue Bet',
      2: 'Quottery Join Bet',
      3: 'Quottery Cancel Bet',
      4: 'Quottery Publish Result'
    },
    qRnd.contractId: {1: 'Random Reveal and Commit'},
    qutil.contractId: {1: 'Send to Many', 2: 'Burn Qubic'},
    gqmProp.contractId: {1: 'GQMPROP Create Proposal', 2: 'GQMPROP Vote'},
    ccf.contractId: {1: 'CCF Create  Proposal', 2: 'CCF Vote'},
    qEarn.contractId: {1: 'QEarn Lock', 2: 'QEarn Unlock'},
    qVault.contractId: {
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
      12: 'QVault Unblock Banned Address'
    },
    msVault.contractId: {
      1: 'MSVault Register Vault',
      2: 'MSVault Deposit',
      3: 'MSVault Release',
      4: 'MSVault Reset Release',
      13: 'MSVault Vote Fee Change'
    }
  };

  const QubicSCID(this.contractIndex, this.name, this.contractId);

  final int contractIndex;
  final String name;
  final String contractId;

  // Static map for quick lookup by contract ID
  static final Map<String, QubicSCID> _byId = {
    for (var scid in QubicSCID.values) scid.contractId: scid,
  };

  /// Get SC name by contract ID
  static String? fromContractId(String id) => _byId[id]?.name;

  static bool isSC(String id) => _byId[id] != null;

  static String? getProcedureName(String contractId, int type) {
    if (procedureNames[contractId]?[type] == null) {
      return null;
    }
    return "$type ${procedureNames[contractId]![type]}";
  }
}
