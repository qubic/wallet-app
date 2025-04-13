import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/components/amount_formatted.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/helpers/currency_helpers.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class CumulativeWalletValueSliver extends StatefulWidget {
  const CumulativeWalletValueSliver({super.key});

  @override
  State<CumulativeWalletValueSliver> createState() =>
      _CumulativeWalletValueSliverState();
}

class _CumulativeWalletValueSliverState
    extends State<CumulativeWalletValueSliver> {
  final NumberFormat numberFormat = NumberFormat.decimalPattern("en_US");

  final ApplicationStore appStore = getIt<ApplicationStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  bool showingTotalBalance = true;
  bool isQubicsPrimaryBalance = true;

  togglePrimaryBalance() {
    setState(() {
      isQubicsPrimaryBalance = !isQubicsPrimaryBalance;
    });
    settingsStore.setQubicsPrimaryBalance(isQubicsPrimaryBalance);
  }

  @override
  void initState() {
    super.initState();
    showingTotalBalance = settingsStore.settings.totalBalanceVisible ?? true;
    isQubicsPrimaryBalance =
        settingsStore.settings.isQubicsPrimaryBalance ?? true;
  }

  TextStyle primaryBalanceStyle() => MediaQuery.of(context).size.width < 400
      ? TextStyles.sliverBig.copyWith(fontSize: 26)
      : TextStyles.sliverBig;

  TextStyle secondaryBalanceStyle() => TextStyles.sliverSmall;

  String getTotalQubics(BuildContext context) {
    return numberFormat.format(appStore.totalAmounts);
  }

  Widget getConversion() {
    final l10n = l10nOf(context);
    //return Text(appStore.marketInfo!.price);
    return AmountFormatted(
        amount: 1,
        stringOverride: appStore.marketInfo!.price.toString(),
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
                ThemedControls.transparentButtonWithChild(
                    onPressed: () async {
                      setState(() {
                        showingTotalBalance = !showingTotalBalance;
                      });
                      settingsStore.setTotalBalanceVisible(showingTotalBalance);
                    },
                    child: Row(children: [
                      Text("${l10n.homeLabelTotalBalance} ",
                          style: TextStyles.secondaryText),
                      ThemedControls.spacerHorizontalSmall(),
                      showingTotalBalance
                          ? Image.asset("assets/images/eye-closed.png")
                          : Image.asset("assets/images/eye-open.png")
                    ]))
              ]),
          GestureDetector(
            onTap: togglePrimaryBalance,
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  Observer(builder: (context) {
                    if (appStore.totalAmountsInUSD == -1) {
                      return Container();
                    }
                    return AnimatedCrossFade(
                      firstChild: Text(
                        isQubicsPrimaryBalance
                            ? getTotalQubics(context)
                            : CurrencyHelpers.formatToUsdCurrency(
                                appStore.totalAmountsInUSD),
                        style: primaryBalanceStyle(),
                      ),
                      secondChild: Text(l10n.generalLabelHiddenLong,
                          style: TextStyles.sliverBig),
                      crossFadeState: showingTotalBalance
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: 300.ms,
                    );
                  }),
                  Observer(builder: (context) {
                    if (appStore.totalAmountsInUSD == -1) {
                      return Container();
                    }
                    return AnimatedOpacity(
                        opacity: showingTotalBalance ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          isQubicsPrimaryBalance
                              ? CurrencyHelpers.formatToUsdCurrency(
                                  appStore.totalAmountsInUSD)
                              : getTotalQubics(context),
                          style: secondaryBalanceStyle(),
                        ));
                  }),
                ],
              ),
            ),
          )
        ]);
  }
}
