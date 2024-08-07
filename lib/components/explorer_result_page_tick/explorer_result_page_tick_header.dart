import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/components/copy_button.dart';
import 'package:qubic_wallet/dtos/explorer_tick_info_dto.dart';
import 'package:qubic_wallet/extensions/asThousands.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class ExplorerResultPageTickHeader extends StatelessWidget {
  final ExplorerTickInfoDto tickInfo;
  final DateFormat formatter = DateFormat('dd MMM yyyy \'at\' HH:mm:ss');

  final Function(int tick)? onTickChange;

  ExplorerResultPageTickHeader(
      {super.key, required this.tickInfo, this.onTickChange});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    TextStyle panelHeaderStyle = TextStyles.secondaryText;
    TextStyle panelHeaderValue = TextStyles.textNormal;

    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        decoration: BoxDecoration(
            color: LightThemeColors.cardBackground,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0)),
            boxShadow: [
              BoxShadow(
                color: !LightThemeColors.shouldInvertIcon
                    ? Colors.grey.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ]),
        child: Padding(
            padding: EdgeInsets.only(
                left: ThemeEdgeInsets.pageInsets.left,
                right: ThemeEdgeInsets.pageInsets.right,
                bottom: ThemePaddings.normalPadding),
            child: Column(children: [
              Text(l10n.generalLabelTick, style: TextStyles.textSmall),
              Container(
                  width: double.infinity,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        onTickChange != null
                            ? IconButton(
                                color: Theme.of(context).colorScheme.secondary,
                                onPressed: () {
                                  onTickChange!(tickInfo.tick - 1);
                                },
                                icon:
                                    const Icon(Icons.keyboard_arrow_left_sharp))
                            : Container(),
                        Text(tickInfo.tick.asThousands(),
                            style: TextStyles.textHugeBold),
                        onTickChange != null
                            ? IconButton(
                                color: Theme.of(context).colorScheme.secondary,
                                onPressed: () {
                                  onTickChange!(tickInfo.tick + 1);
                                },
                                icon: const Icon(
                                    Icons.keyboard_arrow_right_sharp))
                            : Container()
                      ])),
              tickInfo.timestamp != null
                  ? Text(formatter.format(tickInfo.timestamp!.toLocal()),
                      style: TextStyles.secondaryTextNormal)
                  : Container(),
            ])),
      ),
      Padding(
          padding: EdgeInsets.only(
              left: ThemeEdgeInsets.pageInsets.left,
              right: ThemeEdgeInsets.pageInsets.right),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: ThemePaddings.normalPadding),
            Flex(direction: Axis.horizontal, children: [
              Flexible(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.explorerTickResultLabelBlockStatus,
                          style: panelHeaderStyle),
                      Row(children: [
                        tickInfo.completed
                            ? tickInfo.isNonEmpty
                                ? const Icon(Icons.check,
                                    color: LightThemeColors.successIncoming)
                                : const Icon(Icons.error,
                                    color: LightThemeColors.error)
                            : const Icon(Icons.question_mark,
                                color: Colors.grey),
                        Text(
                          " ${tickInfo.completed ? tickInfo.isNonEmpty ? l10n.explorerTickResultLabelBlockStatusNonEmpty : l10n.explorerTickResultLabelBlockStatusEmpty : l10n.explorerTickResultLabelBlockStatusUnknown}",
                          style: panelHeaderValue,
                        )
                      ]),
                    ],
                  )),
              Flexible(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.explorerTickResultLabelDataStatus,
                          style: panelHeaderStyle),
                      Row(children: [
                        tickInfo.completed
                            ? const Icon(Icons.check,
                                color: LightThemeColors.successIncoming)
                            : const Icon(Icons.hourglass_empty,
                                color: LightThemeColors.error),
                        Text(
                          " ${tickInfo.completed ? l10n.explorerTickResultLabelInfoCompleted : l10n.explorerTickResultLabelInfoNotValidated}",
                          style: tickInfo.completed
                              ? panelHeaderValue
                              : panelHeaderValue.copyWith(
                                  color: LightThemeColors.error),
                        )
                      ]),
                    ],
                  )),
            ]),
            ThemedControls.spacerVerticalNormal(),
            Text(
              l10n.explorerTickResultLabelTickLeader,
              style: panelHeaderStyle,
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                  child: Text(
                "${tickInfo.tickLeaderId} - (${tickInfo.tickLeaderShortCode} / ${tickInfo.tickLeaderIndex})",
                style: panelHeaderValue,
              )),
              ThemedControls.spacerHorizontalSmall(),
              CopyButton(
                copiedText: tickInfo.tickLeaderId,
              )
            ]),
            ThemedControls.spacerVerticalBig(),
          ]))
    ]);
  }
}
