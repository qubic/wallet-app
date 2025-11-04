import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/amount_formatted.dart';
import 'package:qubic_wallet/dtos/grouped_asset_dto.dart';
import 'package:qubic_wallet/extensions/as_thousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/smart_contracts/sc_info.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class GroupedAssetItem extends StatelessWidget {
  final QubicListVm account;
  final GroupedAssetDto groupedAsset;

  const GroupedAssetItem({
    super.key,
    required this.account,
    required this.groupedAsset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return Container(
      margin: const EdgeInsets.only(bottom: ThemePaddings.normalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AmountFormatted(
            amount: groupedAsset.totalUnits,
            isInHeader: false,
            labelOffset: -0,
            labelHorizOffset: -6,
            textStyle: TextStyles.accountAmount,
            labelStyle: TextStyles.accountAmountLabel,
            currencyName: groupedAsset.tokenName,
          ),
          ThemedControls.spacerVerticalSmall(),
          ...groupedAsset.contractContributions.map((contribution) {
            String? contractName = QubicSCStore.fromContractIndex(
                contribution.managingContractIndex);
            return Padding(
              padding: const EdgeInsets.only(
                  left: ThemePaddings.normalPadding, top: 4),
              child: Row(
                children: [
                  Text(
                    contribution.numberOfUnits.asThousands(),
                    style: TextStyles.accountAmount.copyWith(fontSize: 16),
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
    );
  }
}
