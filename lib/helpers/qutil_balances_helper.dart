import 'dart:convert';
import 'dart:typed_data';

import 'package:qubic_wallet/dtos/query_smart_contract_request.dart';
import 'package:qubic_wallet/smart_contracts/qutil_info.dart';

/// Helper for the QUTIL `GetBalances16` read-only procedure.
///
/// Mirrors the in-Dart serialization style of [ReleaseTransferRightsHelper]:
/// build the contract input struct with [ByteData] and base64-encode it; decode
/// the response bytes directly. Only the network call (querySmartContract) lives
/// outside this helper.
///
/// GetBalances16_input  (512 bytes): 16 × PublicKey (32 bytes each), zero-padded
/// GetBalances16_output (128 bytes): 16 × sint64 balance (little-endian)
class QutilBalancesHelper {
  /// Converts a 60-char Qubic identity to its 32-byte public key.
  ///
  /// Pure base-26 decode of the 56 payload chars: 4 groups of 14 letters, each a
  /// little-endian uint64. No crypto is required for this direction. The 4-char
  /// K12 checksum (last 4 chars) is not re-validated here — identities come from
  /// the user's own vault and were validated on import, and this is a read-only
  /// query (a malformed id can only yield a wrong/zero balance, never moves QU).
  static Uint8List _identityToPublicKey(String identity) {
    if (identity.length != 60) {
      throw ArgumentError('Identity must be 60 chars, got ${identity.length}');
    }
    final pk = Uint8List(QutilInfo.publicKeySize);
    for (var fragment = 0; fragment < 4; fragment++) {
      var value = BigInt.zero;
      for (var digit = 13; digit >= 0; digit--) {
        final code = identity.codeUnitAt(fragment * 14 + digit);
        value = value * BigInt.from(26) + BigInt.from(code - 65); // 'A' == 65
      }
      for (var b = 0; b < 8; b++) {
        pk[fragment * 8 + b] = (value & BigInt.from(0xff)).toInt();
        value = value >> 8;
      }
    }
    return pk;
  }

  /// Builds the querySmartContract request for up to 16 identities.
  static QuerySmartContractRequest buildGetBalances16Request(
      List<String> identities) {
    if (identities.length > QutilInfo.maxBalancesPerCall) {
      throw ArgumentError(
          'GetBalances16 accepts at most ${QutilInfo.maxBalancesPerCall} identities, '
          'got ${identities.length}');
    }

    final buffer =
        Uint8List(QutilInfo.getBalances16InputSize); // 512, zero-padded
    for (var i = 0; i < identities.length; i++) {
      buffer.setRange(
        i * QutilInfo.publicKeySize,
        (i + 1) * QutilInfo.publicKeySize,
        _identityToPublicKey(identities[i]),
      );
    }

    return QuerySmartContractRequest(
      contractIndex: QutilInfo.contractIndex,
      inputType: QutilInfo.getBalances16InputType,
      inputSize: QutilInfo.getBalances16InputSize,
      requestData: base64Encode(buffer),
    );
  }

  /// Decodes the base64 `responseData` into a list of balances (one per slot,
  /// in the same order as the identities passed to the request).
  static List<BigInt> decodeGetBalances16(String responseDataB64) {
    final bytes = base64Decode(responseDataB64);
    final view = ByteData.sublistView(bytes);
    final count = (bytes.length ~/ QutilInfo.balanceSize)
        .clamp(0, QutilInfo.maxBalancesPerCall);
    return [
      for (var i = 0; i < count; i++)
        BigInt.from(view.getInt64(i * QutilInfo.balanceSize, Endian.little)),
    ];
  }
}
