class QutilInfo {
  static const address =
      "EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAVWRF";

  static const sendToManyType = 1;

  static bool isSendToManyTransfer(String? destId, int? inputType) =>
      destId == address && inputType == sendToManyType;
}
