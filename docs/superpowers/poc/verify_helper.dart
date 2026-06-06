// Verifies the REAL integrated helper (lib/helpers/qutil_balances_helper.dart)
// against values captured from the live device run. Run:
//   fvm dart run docs/superpowers/poc/verify_helper.dart
import 'dart:convert';

import 'package:qubic_wallet/helpers/qutil_balances_helper.dart';

void check(bool ok, String msg) {
  if (!ok) throw StateError('FAIL: $msg');
  print('PASS: $msg');
}

void main() {
  const qx = 'BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARMID';
  const acc2 = 'RBMXEFMDFABRTBJIYIBOQZMAWKWCPMJIQVEQDKONOFPEFWLMXQECDGEBIRBM';

  final req = QutilBalancesHelper.buildGetBalances16Request([qx, acc2]);
  check(req.contractIndex == 4, 'contractIndex == 4');
  check(req.inputType == 9, 'inputType == 9');
  check(req.inputSize == 512, 'inputSize == 512');
  check(base64Decode(req.requestData).length == 512, 'requestData is 512 bytes');
  check(req.requestData.startsWith('AQAA'),
      'requestData starts "AQAA" (QX key = [1,0,...]) — matches the bridge output');

  const realResponse =
      'VtQK2ScAAABEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
  final balances = QutilBalancesHelper.decodeGetBalances16(realResponse);
  print('     decoded (first 3): ${balances.take(3).map((b) => b.toString()).toList()}');
  check(balances[0] == BigInt.parse('171145090134'),
      'balance[0] == 171145090134 (matches the library/bridge)');
  check(balances[1] == BigInt.from(68),
      'balance[1] == 68 (matches the library/bridge)');

  print('\nIntegrated helper matches the library/bridge output. ✅');
}
