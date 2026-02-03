import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/amount_formatted.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/grouped_asset_dto.dart';
import 'package:qubic_wallet/extensions/as_thousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/explorer_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/release_transfer_rights.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/transfer_asset.dart';
import 'package:qubic_wallet/stores/qubic_ecosystem_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

enum CardItem { issuerIdentity }

class GroupedAssetItem extends StatelessWidget {
  final QubicListVm account;
  final GroupedAssetDto groupedAsset;

  const GroupedAssetItem({
    super.key,
    required this.account,
    required this.groupedAsset,
  });

  Widget getCardMenu(BuildContext context) {
    final l10n = l10nOf(context);

    // Only show menu for non-smart-contract shares (Issuer Identity option)
    if (groupedAsset.isSmartContractShare) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<CardItem>(
        tooltip: "",
        icon: Icon(Icons.more_horiz,
            color: LightThemeColors.primary.withAlpha(140)),
        onSelected: (CardItem menuItem) async {
          if (menuItem == CardItem.issuerIdentity) {
            viewAddressInExplorer(
                context, groupedAsset.issuedAsset.issuerIdentity);
          }
        },
        itemBuilder: (BuildContext context) => [
              PopupMenuItem<CardItem>(
                value: CardItem.issuerIdentity,
                child: Text(l10n.assetButtonIssuerIdentity),
              ),
            ]);
  }

  Widget getAssetButtonBar(BuildContext context) {
    final l10n = l10nOf(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ThemePaddings.normalPadding,
        ThemePaddings.smallPadding,
        ThemePaddings.normalPadding,
        ThemePaddings.normalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ThemedControls.iconButtonSquare(
            onPressed: () {
              pushScreen(
                context,
                screen:
                    TransferAsset(item: account, groupedAsset: groupedAsset),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
            semanticLabel: l10n.assetsButtonSend,
            icon: SvgPicture.asset("assets/images/send-arrow.svg"),
          ),
          const SizedBox(width: ThemePaddings.smallPadding),
          ThemedControls.iconButtonSquare(
            onPressed: () {
              pushScreen(
                context,
                screen: ReleaseTransferRights(
                  item: account,
                  groupedAsset: groupedAsset,
                ),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
            semanticLabel: l10n.releaseTransferRightsMenuOption,
            icon: SvgPicture.asset("assets/images/swap-arrows.svg"),
          ),
        ],
      ),
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
              ThemePaddings.mediumPadding,
              ThemePaddings.normalPadding,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AmountFormatted(
                        key: ValueKey<String>(
                            "qubicAsset${account.publicId}-${groupedAsset.tokenName}-${groupedAsset.totalUnits}"),
                        amount: groupedAsset.totalUnits,
                        isInHeader: false,
                        labelOffset: -0,
                        labelHorizOffset: -6,
                        textStyle: MediaQuery.of(context).size.width < 400
                            ? TextStyles.accountAmount.copyWith(fontSize: 20)
                            : TextStyles.accountAmount,
                        labelStyle: TextStyles.accountAmountLabel,
                        currencyName: groupedAsset.tokenName,
                      ),
                    ),
                    getCardMenu(context),
                  ],
                ),
                ThemedControls.spacerVerticalSmall(),
                ...groupedAsset.contractContributions
                    .where((contribution) => contribution.numberOfUnits > 0)
                    .map((contribution) {
                  String? contractName = getIt<QubicEcosystemStore>()
                      .getContractNameByIndex(
                          contribution.managingContractIndex);
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: ThemePaddings.normalPadding, top: 4),
                    child: Row(
                      children: [
                        Text(
                          contribution.numberOfUnits.asThousands(),
                          style:
                              TextStyles.accountAmount.copyWith(fontSize: 16),
                        ),
                        ThemedControls.spacerHorizontalMini(),
                        Text(
                          l10n.assetsManagedBy,
                          style: TextStyles.secondaryTextNormal,
                        ),
                        ThemedControls.spacerHorizontalMini(),
                        Expanded(
                          child: Text(
                              contractName ??
                                  'Contract ${contribution.managingContractIndex}',
                              style: TextStyles.accountAmountLabel),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          account.watchOnly
              ? ThemedControls.spacerVerticalNormal()
              : getAssetButtonBar(context),
        ]),
      ),
    );
  }
}
