import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/components/amount_formatted.dart';
import 'package:qubic_wallet/components/qubic_asset.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class AmountValueHeader extends StatefulWidget {
  const AmountValueHeader({super.key, required this.amount, this.suffix});

  final int amount;
  final String? suffix;

  @override
  State<AmountValueHeader> createState() => _CumulativeWalletValueSliverState();
}

class _CumulativeWalletValueSliverState extends State<AmountValueHeader> {
  final NumberFormat numberFormat = NumberFormat.decimalPattern("en_US");

  final ApplicationStore appStore = getIt<ApplicationStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  bool showingTotalBalance = true;

  @override
  void initState() {
    super.initState();
    showingTotalBalance = settingsStore.settings.totalBalanceVisible ?? true;
  }

  Widget getTotalQubics(BuildContext context) {
    return Text(numberFormat.format(widget.amount),
        style: MediaQuery.of(context).size.width < 400
            ? TextStyles.qubicAmount.copyWith(fontSize: 22)
            : TextStyles.qubicAmount);
  }

  Widget getTotalUSD() {
    // Create a NumberFormat object for USD currency with 2 decimal places
    NumberFormat currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    // Format the double value as a USD amount
    String formattedValue = currencyFormat.format(widget.amount);
    return Text(formattedValue, style: TextStyles.sliverSmall);
  }

  Widget getConversion() {
    final l10n = l10nOf(context);
    //return Text(appStore.marketInfo!.price);
    return AmountFormatted(
        amount: 1,
        stringOverride: appStore.marketInfo!.price,
        isInHeader: true,
        currencyName: l10n.generalLabelUSDQubicConversion,
        labelOffset: -2,
        textStyle: TextStyles.sliverSmall);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getTotalQubics(context),
                widget.suffix != null
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: ThemePaddings.miniPadding),
                        child: Text(widget.suffix!,
                            style: MediaQuery.of(context).size.width < 400
                                ? TextStyles.qubicAmount.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: LightThemeColors.inputFieldHint,
                                    fontSize: 22)
                                : TextStyles.qubicAmount.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 26,
                                    color: LightThemeColors.inputFieldHint)))
                    : Container()
              ]),
          getTotalUSD()
        ]);
  }
}
