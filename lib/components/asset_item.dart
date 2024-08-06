import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/transfer_asset.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class AssetItem extends StatefulWidget {
  final QubicListVm account;
  final QubicAssetDto asset;
  const AssetItem({super.key, required this.account, required this.asset});

  @override
  // ignore: library_private_types_in_public_api
  _AssetItemState createState() => _AssetItemState();
}

class _AssetItemState extends State<AssetItem> {
  final ApplicationStore appStore = getIt<ApplicationStore>();

  String? generatedPublicId;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final NumberFormat formatter = NumberFormat.decimalPatternDigits(
    locale: 'en_us',
    decimalDigits: 0,
  );

  Widget getAssetButtonBar(QubicAssetDto asset) {
    final l10n = l10nOf(context);

    return Container(
      child: ButtonBar(
          alignment: MainAxisAlignment.start,
          buttonPadding:
              const EdgeInsets.fromLTRB(ThemePaddings.hugePadding, 0, 0, 0),
          children: [
            ThemedControls.primaryButtonBig(
                onPressed: () {
                  // Perform some action
                  pushScreen(
                    context,
                    screen: TransferAsset(
                        item: widget.account, asset: widget.asset),
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                text: l10n.assetsButtonSend,
                icon: LightThemeColors.shouldInvertIcon
                    ? ThemedControls.invertedColors(
                        child: Image.asset("assets/images/send.png"))
                    : Image.asset("assets/images/send.png")),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Container(
        constraints: const BoxConstraints(minWidth: 400, maxWidth: 500),
        child: Card(
            color: LightThemeColors.cardBackground,
            elevation: 0,
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(
                      ThemePaddings.normalPadding,
                      ThemePaddings.normalPadding,
                      ThemePaddings.normalPadding,
                      0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          Expanded(
                              child: Text(widget.asset.assetName,
                                  style: TextStyles.accountName)),
                        ]),
                        Text(
                            l10n.assetsLabelTick(
                                widget.asset.tick.asThousands()),
                            style: TextStyles.assetSecondaryTextLabel),
                        const SizedBox(height: ThemePaddings.normalPadding),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.assetsLabelOwned,
                                  style: TextStyles.assetSecondaryTextLabel),
                              Text(
                                  "${formatter.format(widget.asset.ownedAmount) ?? "-"}",
                                  style:
                                      TextStyles.assetSecondaryTextLabelValue),
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.assetsLabelPossessed,
                                  style: TextStyles.assetSecondaryTextLabel),
                              Text(
                                  "${formatter.format(widget.asset.possessedAmount) ?? "-"}",
                                  style:
                                      TextStyles.assetSecondaryTextLabelValue),
                            ]),
                        const SizedBox(height: ThemePaddings.miniPadding),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.assetsLabelContractName,
                                  style: TextStyles.assetSecondaryTextLabel),
                              Text(widget.asset.contractName,
                                  style:
                                      TextStyles.assetSecondaryTextLabelValue),
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.assetsLabelContractIndex,
                                  style: TextStyles.assetSecondaryTextLabel),
                              Text("${widget.asset.contractIndex}",
                                  style:
                                      TextStyles.assetSecondaryTextLabelValue),
                            ]),
                      ])),
              getAssetButtonBar(widget.asset),
            ])));
  }
}
