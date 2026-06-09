import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qubic_wallet/helpers/qutil_balances_helper.dart';
import 'package:qubic_wallet/smart_contracts/qutil_info.dart';

void main() {
  group('QutilBalancesHelper.buildGetBalances16Request', () {
    test('encodes an all-A identity to a zero pubkey, zero-padded to 512 bytes',
        () {
      // Every payload char 'A' is base-26 digit 0, so the whole 32-byte key is
      // zero; the remaining 15 slots are zero-padding -> the entire buffer is 0.
      final request = QutilBalancesHelper.buildGetBalances16Request(['A' * 60]);
      final buffer = base64Decode(request.requestData);

      expect(buffer.length, QutilInfo.getBalances16InputSize); // 512
      expect(buffer.every((b) => b == 0), isTrue);
      expect(request.contractIndex, QutilInfo.contractIndex);
      expect(request.inputType, QutilInfo.getBalances16InputType);
      expect(request.inputSize, QutilInfo.getBalances16InputSize);
    });

    test('rejects more than 16 identities', () {
      expect(
        () => QutilBalancesHelper.buildGetBalances16Request(
            List.filled(17, 'A' * 60)),
        throwsArgumentError,
      );
    });

    test('rejects an identity that is not 60 chars', () {
      expect(
        () => QutilBalancesHelper.buildGetBalances16Request(['A' * 59]),
        throwsArgumentError,
      );
    });
  });

  group('QutilBalancesHelper.decodeGetBalances16', () {
    test('decodes little-endian sint64 balances, including negatives', () {
      final out = ByteData(QutilInfo.balanceSize * 2);
      out.setInt64(0, 123, Endian.little);
      out.setInt64(QutilInfo.balanceSize, -1, Endian.little);

      final balances = QutilBalancesHelper.decodeGetBalances16(
          base64Encode(out.buffer.asUint8List()));

      expect(balances, [BigInt.from(123), BigInt.from(-1)]);
    });

    test('decodes an empty response to an empty list without throwing', () {
      expect(QutilBalancesHelper.decodeGetBalances16(''), isEmpty);
    });

    test('never returns more than maxBalancesPerCall balances', () {
      final out =
          ByteData(QutilInfo.balanceSize * (QutilInfo.maxBalancesPerCall + 4));
      final balances = QutilBalancesHelper.decodeGetBalances16(
          base64Encode(out.buffer.asUint8List()));

      expect(balances.length, QutilInfo.maxBalancesPerCall);
    });
  });
}
