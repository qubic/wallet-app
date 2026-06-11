import 'package:flutter_test/flutter_test.dart';
import 'package:qubic_wallet/dtos/identities_assets_response.dart';
import 'package:qubic_wallet/smart_contracts/qx_info.dart';

void main() {
  group('IdentitiesAssetsResponse.fromJson', () {
    test('coerces a numeric numberOfShares to a string', () {
      // The live endpoint returns numberOfShares as a JSON number, not a string;
      // the mapping relies on it being a String, so it must be coerced.
      final entry = IdentitiesAssetsResponse.fromJson({
        'identityAssets': [
          {
            'identity': 'X',
            'ownerships': [
              {
                'assetIssuer': 'I',
                'assetName': 'N',
                'managingContractIndex': 0,
                'numberOfShares': 1610000000,
                'tickNumber': 0,
              },
            ],
            'possessions': [],
          },
        ],
      }).identityAssets.first;
      expect(entry.ownerships.first.numberOfShares, '1610000000');
    });

    test('tolerates missing identityAssets / ownerships / possessions', () {
      expect(IdentitiesAssetsResponse.fromJson({}).identityAssets, isEmpty);

      final entry = IdentitiesAssetsResponse.fromJson({
        'identityAssets': [
          {'identity': 'X'},
        ],
      }).identityAssets.first;
      expect(entry.ownerships, isEmpty);
      expect(entry.possessions, isEmpty);
    });
  });

  group('IdentitiesAssetsResponse.toOwnedAssets', () {
    test(
        'maps ownerships to owned assets; ignores possessions and drops zero shares',
        () {
      final assets = IdentitiesAssetsResponse.fromJson({
        'identityAssets': [
          {
            'identity': 'IDENTITY_ONE',
            'ownerships': [
              {
                'assetIssuer': 'ISSUER_A',
                'assetName': 'ASSETA',
                'managingContractIndex': 1,
                'numberOfShares': '100',
                'tickNumber': 5,
              },
              {
                'assetIssuer': QxInfo.mainAssetIssuer,
                'assetName': 'SHARE',
                'managingContractIndex': 1,
                'numberOfShares': '7',
                'tickNumber': 6,
              },
              {
                'assetIssuer': 'ISSUER_C',
                'assetName': 'ZERO',
                'managingContractIndex': 1,
                'numberOfShares': '0',
                'tickNumber': 4,
              },
            ],
            'possessions': [
              {
                'assetIssuer': 'ISSUER_A',
                'assetName': 'ASSETA',
                'managingContractIndex': 1,
                'numberOfShares': '999',
                'tickNumber': 9,
              },
            ],
          },
          {
            'identity': 'IDENTITY_TWO',
            'ownerships': [
              {
                'assetIssuer': 'ISSUER_D',
                'assetName': 'ASSETD',
                'managingContractIndex': 2,
                'numberOfShares': '50',
                'tickNumber': 3,
              },
            ],
            'possessions': [],
          },
        ],
      }).toOwnedAssets();

      // ownership rows with shares > 0: 100, 7, 50 -> 3 assets (0-share dropped)
      expect(assets.length, 3);
      // a possession amount must never leak into the result
      expect(assets.any((a) => a.numberOfUnits == 999), isFalse);
      // the zero-share ownership is filtered out
      expect(assets.any((a) => a.issuedAsset.name == 'ZERO'), isFalse);

      final assetA = assets.firstWhere((a) => a.issuedAsset.name == 'ASSETA');
      expect(assetA.ownerIdentity, 'IDENTITY_ONE');
      expect(assetA.numberOfUnits, 100); // owned, not possessed (999)
      expect(assetA.issuedAsset.issuerIdentity, 'ISSUER_A');
      expect(assetA.managingContractIndex, 1);
      expect(assetA.info.tick, 5);
      expect(assetA.isSmartContractShare, isFalse);

      final share = assets.firstWhere((a) => a.issuedAsset.name == 'SHARE');
      expect(share.numberOfUnits, 7);
      expect(share.isSmartContractShare, isTrue);

      final assetD = assets.firstWhere((a) => a.issuedAsset.name == 'ASSETD');
      expect(assetD.ownerIdentity, 'IDENTITY_TWO');
      expect(assetD.numberOfUnits, 50);
      expect(assetD.managingContractIndex, 2);
      expect(assetD.info.tick, 3);
    });
  });
}
