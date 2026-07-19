import 'package:flutter_test/flutter_test.dart';
import 'package:qubic_wallet/models/wallet_app_config_model.dart';

void main() {
  group('WalletAppConfigResponse.fromJson', () {
    test('parses an integer default_tick_offset', () {
      expect(
          WalletAppConfigResponse.fromJson({'default_tick_offset': 10})
              .defaultTickOffset,
          10);
    });

    test('is null when the field is absent', () {
      expect(WalletAppConfigResponse.fromJson({}).defaultTickOffset, isNull);
    });

    test('throws on a non-integer value (the caller catches it and falls back)', () {
      // Bare `json[...]` assignment to int? does an implicit downcast, so a
      // wrong-typed value throws here; getWalletAppConfig/loadConfig swallow it.
      expect(() => WalletAppConfigResponse.fromJson({'default_tick_offset': 'ten'}),
          throwsA(isA<TypeError>()));
      expect(() => WalletAppConfigResponse.fromJson({'default_tick_offset': 10.5}),
          throwsA(isA<TypeError>()));
    });

    test('ignores unknown fields so the config can grow', () {
      final config = WalletAppConfigResponse.fromJson(
          {'default_tick_offset': 20, 'some_future_key': 'x'});
      expect(config.defaultTickOffset, 20);
    });
  });
}
