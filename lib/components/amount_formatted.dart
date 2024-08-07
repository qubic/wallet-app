import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/currency_label.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:intl/intl.dart';

class AmountFormatted extends StatelessWidget {
  final num? amount;
  final String currencyName;
  final bool isInHeader;
  final NumberFormat numberFormat = NumberFormat.decimalPattern("en_US");
  late final TextStyle? labelStyle;
  late final TextStyle? textStyle;
  late final String? stringOverride;
  late final double labelOffset;
  late final double labelHorizOffset;
  late final bool hideLabel;
  late final String? prefix;
  late final String? suffix;
  AmountFormatted(
      {super.key,
      required this.amount,
      required this.isInHeader,
      required this.currencyName,
      this.stringOverride,
      this.labelOffset = -4,
      this.labelHorizOffset = 0,
      textStyle,
      labelStyle,
      this.hideLabel = false,
      this.prefix,
      this.suffix}) {
    this.textStyle = textStyle ?? TextStyles.sliverBig;
    this.labelStyle = labelStyle ?? TextStyles.sliverCurrencyLabel;
  }

  @override
  Widget build(BuildContext context) {
    if (amount == null) {
      return Container();
    }

    if (isInHeader) {
      return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.ideographic,
          children: [
            Text(
                (prefix ?? "") +
                    (stringOverride == null
                        ? numberFormat.format(
                            amount!,
                          )
                        : stringOverride!) +
                    (suffix ?? ""),
                style: textStyle),
            const SizedBox(width: 6, height: 6),
            hideLabel
                ? Container()
                : Transform.translate(
                    offset: Offset(labelHorizOffset, labelOffset),
                    child: CurrencyLabel(
                        currencyName: currencyName,
                        isInHeader: isInHeader,
                        style: labelStyle))
          ]);
    } else {
      return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.ideographic,
          children: [
            Text(
                (prefix ?? "") +
                    (stringOverride == null
                        ? numberFormat.format(
                            amount!,
                          )
                        : stringOverride!) +
                    (suffix ?? ""),
                style: textStyle),
            const SizedBox(width: 6, height: 6),
            hideLabel
                ? Container()
                : Transform.translate(
                    offset: Offset(labelHorizOffset, labelOffset),
                    child: CurrencyLabel(
                        currencyName: currencyName,
                        isInHeader: isInHeader,
                        style: labelStyle))
          ]);
    }

    //return Text(numberFormat.format(amount!));
  }
}
