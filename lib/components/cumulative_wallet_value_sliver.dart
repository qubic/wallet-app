import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/components/currency_amount.dart';
import 'package:qubic_wallet/components/currency_label.dart';
import 'package:qubic_wallet/components/qubic_amount.dart';
import 'package:qubic_wallet/components/amount_formatted.dart';
import 'package:qubic_wallet/components/qubic_asset.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class CumulativeWalletValueSliver extends StatefulWidget {
  const CumulativeWalletValueSliver({super.key});

  @override
  State<CumulativeWalletValueSliver> createState() =>
      _CumulativeWalletValueSliverState();
}

class _CumulativeWalletValueSliverState
    extends State<CumulativeWalletValueSliver> {
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
    return AmountFormatted(
      amount: appStore.totalAmounts,
      isInHeader: true,
      currencyName: 'QUBIC',
      hideLabel: true,
      textStyle: MediaQuery.of(context).size.width < 400
          ? TextStyles.sliverBig.copyWith(fontSize: 26)
          : TextStyles.sliverBig,
    );
  }

  Widget getTotalUSD() {
    return AmountFormatted(
      amount: appStore.totalAmountsInUSD.toInt(),
      prefix: "\$",
      isInHeader: true,
      hideLabel: true,
      currencyName: 'USD',
      labelOffset: -2,
      textStyle: TextStyles.sliverSmall,
    );
  }

  Widget getConversion() {
    //return Text(appStore.marketInfo!.price);
    return AmountFormatted(
        amount: 1,
        stringOverride: appStore.marketInfo!.price,
        isInHeader: true,
        currencyName: 'USD / QUBIC',
        labelOffset: -2,
        textStyle: TextStyles.sliverSmall);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Total balance ", style: TextStyles.secondaryText),
                IconButton(
                    onPressed: () async {
                      setState(() {
                        showingTotalBalance = !showingTotalBalance;
                      });
                      settingsStore.setTotalBalanceVisible(showingTotalBalance);
                    },
                    icon: showingTotalBalance
                        ? Image.asset("assets/images/eye-closed-small.png")
                        : Image.asset("assets/images/eye-open-small.png"))
              ]),
          Observer(builder: (context) {
            if (appStore.totalAmountsInUSD == -1) {
              return Container();
            }
            return getTotalQubics(context)
                .animate(target: showingTotalBalance ? 0 : 1)
                .fadeOut();
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
          SizedBox(
                  height: MediaQuery.of(context).size.width < 400 ? 25 : 35,
                  width: MediaQuery.of(context).size.width < 400 ? 240 : 300,
                  child: Container(
                      color: Colors.white, alignment: Alignment.center))
              .animate(target: showingTotalBalance ? 0 : 1)
              .scaleX(
                  duration: const Duration(milliseconds: 300),
                  begin: 0,
                  end: 1,
                  curve: Curves.easeInOut)
              .scaleY(
                  duration: const Duration(milliseconds: 600),
                  begin: 0,
                  end: 1,
                  curve: Curves.easeInOut)
              .moveY(
                  duration: const Duration(milliseconds: 300),
                  begin: MediaQuery.of(context).size.width < 400 ? -50 : -65,
                  end: MediaQuery.of(context).size.width < 400 ? -50 : -65,
                  curve: Curves.easeInOut)
              .fadeIn(duration: const Duration(milliseconds: 200))
              .blurXY(
                  duration: const Duration(milliseconds: 300),
                  begin: 7,
                  end: 10,
                  curve: Curves.easeInOut),
        ]);
  }
}
