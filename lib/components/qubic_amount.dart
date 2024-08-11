import 'package:flutter/material.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:skeleton_text/skeleton_text.dart';

class QubicAmount extends StatelessWidget {
  final int? amount;
  const QubicAmount({super.key, required this.amount});

  Widget getText(BuildContext context, String text, bool opaque) {
    return Text(text,
        style: opaque ? TextStyles.qubicAmount : TextStyles.qubicAmountLight);
  }

  List<Widget> padAndFormatWithCommas(int number) {
    // Convert the number to a string
    String numberStr = number.toString();
    // Calculate the padding required to reach 15 digits
    int paddingLength = 15 - numberStr.length;

    // Pad the number with zeros on the left to ensure it has at least 15 digits
    String paddedNumber = numberStr.padLeft(15, '0');

    // Create a list of Widgets
    List<Widget> widgets = [];

    for (int i = 0; i < paddedNumber.length; i++) {
      bool isPadding = i < paddingLength;
      bool isComma = (paddedNumber.length - i) % 3 == 0 && i != 0;

      if (isComma) {
        bool commaIsPadding = (i - 1) <
            paddingLength; // comma is padding when previous digit is padding

        widgets.add(Text(',',
            style: commaIsPadding
                ? TextStyles.qubicAmountLight
                : TextStyles.qubicAmount));
      }

      widgets.add(Text(paddedNumber[i],
          style: isPadding
              ? TextStyles.qubicAmountLight
              : TextStyles.qubicAmount));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    if (amount == null) {
      List<Widget> output = [];
      output.add(SkeletonAnimation(
          borderRadius: BorderRadius.circular(2.0),
          shimmerColor:
              Theme.of(context).textTheme.titleMedium!.color!.withOpacity(0.3),
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
                    .withOpacity(0.1)),
          )));

      return Row(mainAxisAlignment: MainAxisAlignment.center, children: output);
    }

    //Leave styling for ultra big
    if (amount! > 1000000000000) {
      List<Widget> numbers = [];

      numbers.add(Text(amount.toString(), style: TextStyles.qubicAmount));
      numbers.add(Text(" ${l10n.generalLabelCurrencyQubic}",
          style: TextStyles.qubicAmount));
      return Row(
          mainAxisAlignment: MainAxisAlignment.center, children: numbers);
    }

    List<Widget> numbers = padAndFormatWithCommas(amount!.floor());
    numbers.add(Text(" ${l10n.generalLabelCurrencyQubic}",
        style: TextStyles.qubicAmountLabel));
    return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.end,
        children: numbers);
  }
}
