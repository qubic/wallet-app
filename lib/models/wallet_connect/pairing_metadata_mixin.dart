import 'package:reown_walletkit/reown_walletkit.dart';

mixin PairingMetadataMixin {
  late final String fromIDName;
  late final PairingMetadata? pairingMetadata;

  void setPairingMetadata(PairingMetadata pairingMetadata) {
    this.pairingMetadata = pairingMetadata;
  }
}
