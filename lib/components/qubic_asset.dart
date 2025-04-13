import 'package:flutter/material.dart';
import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:skeleton_text/skeleton_text.dart';

class QubicAsset extends StatelessWidget {
  final QubicAssetDto? asset;

  final TextStyle? style;
  const QubicAsset({super.key, this.asset, this.style});

  TextStyle getStyle(BuildContext context, bool opaque) {
    TextStyle opaqueStyle = Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(fontFamily: ThemeFonts.primary);
    TextStyle transparentStyle = opaqueStyle.copyWith(
        color:
            Theme.of(context).textTheme.titleMedium?.color!.withValues(alpha: 0.1));
    TextStyle defaultStyle = opaque ? opaqueStyle : transparentStyle;

    TextStyle? transparentOverridenStyle = style?.copyWith(
      color: style!.color!.withValues(alpha: 0.1),
    );

    TextStyle? overridenStyle = style == null
        ? null
        : opaque
            ? style
            : transparentOverridenStyle!;

    return overridenStyle ?? defaultStyle;
  }

  Widget getText(BuildContext context, String text, bool opaque) {
    return Text(text, style: getStyle(context, opaque));
  }

  Widget getDescriptor(BuildContext context) {
    final l10n = l10nOf(context);

    if (asset == null) {
      return Container();
    }

    bool isToken = !asset!.isSmartContractShare;

    String text;
    int amount = asset!.numberOfUnits;

    if (isToken) {
      text = l10n.generalUnitTokens(amount);
    } else {
      text = l10n.generalUnitShares(amount);
    }

    return Text(" $text",
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(fontFamily: ThemeFonts.primary));
  }

  @override
  Widget build(BuildContext context) {
    if (asset == null) {
      return Container();
    }
    if ((asset!.numberOfUnits == 0)) {
      List<Widget> output = [];
      output.add(SkeletonAnimation(
          borderRadius: BorderRadius.circular(2.0),
          shimmerColor:
              Theme.of(context).textTheme.titleMedium!.color!.withValues(alpha: 0.3),
          shimmerDuration: 3000,
          curve: Curves.easeInOutCirc,
          child: Container(
            height: 18,
            width: MediaQuery.of(context).size.width * 0.45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.0),
                color: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.color!
                    .withValues(alpha: 0.1)),
          )));

      return Row(mainAxisAlignment: MainAxisAlignment.center, children: output);
    }
    List<Widget> numbers = [];
    int numberOfShares = asset!.numberOfUnits;
    String? zeros = numberOfShares > 100
        ? null
        : numberOfShares >= 10
            ? "0"
            : numberOfShares > 0
                ? "00"
                : "000";
    if (zeros != null) {
      numbers.add(getText(context, zeros, false));
    }
    numbers.add(getText(context, numberOfShares.toString(), true));
    numbers.add(
        Text(" ${asset!.issuedAsset.name}", style: getStyle(context, true)));
    numbers.add(getDescriptor(context));
    return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.end,
        children: numbers);
  }
}
