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
      'KAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXIUO');

  //TODO Complete this map
  static final Map<String, Map<int, String>> procedureNames = {
    qEarn.contractId: {1: 'Lock', 2: 'Unlock'},
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
