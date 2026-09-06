import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/styles/app_icons.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class SmartContractTransferWarningSheet extends StatelessWidget {
  final String contractName;
  final bool isDappRequest;
  final Function() onContinue;
  final Function() onCancel;

  const SmartContractTransferWarningSheet(
      {super.key,
      required this.contractName,
      required this.isDappRequest,
      required this.onContinue,
      required this.onCancel});

  List<Widget> getButtons(BuildContext context) {
    final l10n = l10nOf(context);
    return [
      Expanded(
          child: ThemedControls.transparentButtonBigWithChild(
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding),
                  child: Text(l10n.generalButtonCancel,
                      textAlign: TextAlign.center,
                      style: TextStyles.transparentButtonText)),
              onPressed: onCancel)),
      ThemedControls.spacerHorizontalSmall(),
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: onContinue,
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: Text(l10n.generalButtonContinue,
                      textAlign: TextAlign.center,
                      style: TextStyles.primaryButtonText)))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final warningText = isDappRequest
        ? l10n.smartContractTransferWarningTextDApp(contractName)
        : l10n.smartContractTransferWarningText(contractName);

    return Padding(
        padding: ThemeEdgeInsets.bottomSheetInsets,
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ThemedControls.pageHeader(
                  headerText: l10n.smartContractTransferWarningTitle),
              ThemedControls.spacerVerticalNormal(),
              ThemedControls.card(
                  borderColor: LightThemeColors.warning40,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(AppIcons.warning, height: 20),
                        ThemedControls.spacerHorizontalSmall(),
                        Expanded(
                            child:
                                Text(warningText, style: TextStyles.textLarge))
                      ])),
              ThemedControls.spacerVerticalBig(),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: getButtons(context))
            ])));
  }
}

/// Returns true only when the user explicitly taps Continue.
Future<bool> showSmartContractTransferWarning(BuildContext context,
    {required String contractName, required bool isDappRequest}) async {
  final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: LightThemeColors.background,
      builder: (BuildContext context) {
        return SafeArea(
            child: SmartContractTransferWarningSheet(
                contractName: contractName,
                isDappRequest: isDappRequest,
                onContinue: () => Navigator.pop(context, true),
                onCancel: () => Navigator.pop(context, false)));
      });
  return result == true;
}
