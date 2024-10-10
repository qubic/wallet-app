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

  @override
  void initState() {
    super.initState();
    showingTotalBalance = settingsStore.settings.totalBalanceVisible ?? true;
  }

  List<Widget> getShares(BuildContext context) {
    List<Widget> assets = [];
    for (var asset in appStore.totalShares) {
      assets.add(QubicAsset(
          asset: asset,
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
              fontWeight: FontWeight.normal, fontFamily: ThemeFonts.primary)));
    }
    return assets;
  }

  Widget getTotalQubics(BuildContext context) {
    return Text(numberFormat.format(appStore.totalAmounts),
        style: MediaQuery.of(context).size.width < 400
            ? TextStyles.sliverBig.copyWith(fontSize: 26)
            : TextStyles.sliverBig);
  }

  Widget getTotalUSD() {
    // Create a NumberFormat object for USD currency with 2 decimal places
    NumberFormat currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    // Format the double value as a USD amount
    String formattedValue = currencyFormat.format(appStore.totalAmountsInUSD);
    return Text(formattedValue, style: TextStyles.sliverSmall);
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
          Observer(builder: (context) {
            if (appStore.totalAmountsInUSD == -1) {
              return Container();
            }
            return AnimatedCrossFade(
              firstChild: getTotalQubics(context),
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
                child: getTotalUSD());
          }),
          // SizedBox(
          //         height: MediaQuery.of(context).size.width < 400 ? 15 : 20,
          //         width: MediaQuery.of(context).size.width < 400 ? 200 : 240,
          //         child: Container(
          //             color: Color.fromARGB(145, 255, 255, 255),
          //             alignment: Alignment.center))
          //     .animate(target: showingTotalBalance ? 0 : 1)
          //     .scaleX(
          //         duration: const Duration(milliseconds: 300),
          //         begin: 0,
          //         end: 1,
          //         curve: Curves.easeInOut)
          //     .scaleY(
          //         duration: const Duration(milliseconds: 300),
          //         begin: 0,
          //         end: 1,
          //         curve: Curves.easeInOut)
          //     .moveY(
          //         duration: const Duration(milliseconds: 300),
          //         begin: MediaQuery.of(context).size.width < 400 ? -45 : -55,
          //         end: MediaQuery.of(context).size.width < 400 ? -45 : -55,
          //         curve: Curves.easeInOut)
          //     .fadeIn(duration: const Duration(milliseconds: 200))
          //     .blurXY(
          //         duration: const Duration(milliseconds: 300),
          //         begin: 7,
          //         end: 10,
          //         curve: Curves.easeInOut),
        ]);
  }
}
