import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/models/qubic_asset.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/stores/application_store.dart';

const accountId =
    'OWNERAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
const issuerId = 'ISSUERAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

QubicAsset buildAsset(String name, int units, {int tick = 100}) {
  return QubicAsset(
    ownerIdentity: accountId,
    managingContractIndex: 1,
    numberOfUnits: units,
    issuedAsset: IssuedAsset(issuerIdentity: issuerId, name: name),
    info: AssetInfo(tick: tick),
  );
}

ApplicationStore buildStoreWithAssets(List<QubicAsset> assets) {
  final store = ApplicationStore();
  final account = QubicListVm(accountId, 'Test account', 0, 0, null, false);
  account.setAssets(assets);
  store.currentQubicIDs = ObservableList.of([account]);
  return store;
}

void main() {
  group('ApplicationStore.setAssets change detection', () {
    test(
        'flags an account whose asset vanished while another remains, '
        'reporting the vanished asset with zero units', () {
      final store =
          buildStoreWithAssets([buildAsset('QX', 5), buildAsset('CFB', 3)]);

      // QX was sold entirely; CFB is still held, unchanged.
      final changed = store.setAssets([buildAsset('CFB', 3)]);

      expect(changed, contains(accountId));
      expect(changed[accountId], hasLength(1));
      expect(changed[accountId]!.single.issuedAsset.name, 'QX');
      expect(changed[accountId]!.single.numberOfUnits, 0);

      final remaining = store.currentQubicIDs.first.assets.values;
      expect(remaining, hasLength(1));
      expect(remaining.single.issuedAsset.name, 'CFB');
    });

    test(
        'flags a sold-to-zero account, reporting every vanished asset '
        'with zero units', () {
      final store =
          buildStoreWithAssets([buildAsset('QX', 5), buildAsset('CFB', 3)]);

      final changed = store.setAssets([]);

      expect(changed, contains(accountId));
      final reportedNames =
          changed[accountId]!.map((a) => a.issuedAsset.name).toSet();
      expect(reportedNames, {'QX', 'CFB'});
      expect(changed[accountId]!.every((a) => a.numberOfUnits == 0), isTrue);
      expect(store.currentQubicIDs.first.assets, isEmpty);
    });

    test('reports a unit change with the new amount', () {
      final store = buildStoreWithAssets([buildAsset('QX', 5)]);

      final changed = store.setAssets([buildAsset('QX', 2)]);

      expect(changed, contains(accountId));
      expect(changed[accountId]!.single.issuedAsset.name, 'QX');
      expect(changed[accountId]!.single.numberOfUnits, 2);
    });

    test('flags nothing when the fetched assets are unchanged', () {
      final store =
          buildStoreWithAssets([buildAsset('QX', 5), buildAsset('CFB', 3)]);

      final changed =
          store.setAssets([buildAsset('QX', 5), buildAsset('CFB', 3)]);

      expect(changed, isEmpty);
    });

    test(
        'dedupes duplicate fetched records by highest tick, so a stale '
        'duplicate cannot mask a real change', () {
      final store = buildStoreWithAssets([buildAsset('QX', 5)]);

      // The aggregation endpoint can return the same position twice; the
      // stale record (same units as before) arrives first.
      final changed = store.setAssets([
        buildAsset('QX', 5, tick: 90),
        buildAsset('QX', 2, tick: 100),
      ]);

      expect(changed, contains(accountId));
      expect(changed[accountId]!.single.numberOfUnits, 2);
      expect(store.currentQubicIDs.first.assets.values.single.numberOfUnits, 2);
    });

    test('flags nothing for an account that never had assets', () {
      final store = buildStoreWithAssets([]);

      final changed = store.setAssets([]);

      expect(changed, isEmpty);
    });
  });
}
