import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class RevealSeedWarningSheet extends StatefulWidget {
  final Function() onAccept;
  final QubicListVm item;

  final Function() onReject;
  const RevealSeedWarningSheet(
      {super.key,
      required this.onAccept,
      required this.onReject,
      required this.item});

  @override
  _RevealSeedWarningSheetState createState() => _RevealSeedWarningSheetState();
}

class _RevealSeedWarningSheetState extends State<RevealSeedWarningSheet> {
  final ApplicationStore appStore = getIt<ApplicationStore>();

  bool hasAccepted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getWarningText(String text) {
    return Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // GradientForeground(
          //     child: Image.asset(
          //   "assets/images/attention-circle-color-16.png",
          // )),
          ThemedControls.spacerHorizontalNormal(),
          Expanded(child: Text(text, style: TextStyles.textLarge))
        ]);
  }

  Widget getText() {
    final l10n = l10nOf(context);

    return Row(children: [
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
            ThemedControls.pageHeader(
                headerText: l10n.revealSeedWarningSheetHeader),
            ThemedControls.spacerVerticalNormal(),
            getWarningText(l10n.revealSeedWarningSheetLabelOne),
            ThemedControls.spacerVerticalNormal(),
            getWarningText(l10n.revealSeedWarningSheetLabelTwo),
            ThemedControls.spacerVerticalNormal(),
            getWarningText(l10n.revealSeedWarningSheetLabelThree),
          ]))
    ]);
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);
    return [
      Expanded(
          child: ThemedControls.transparentButtonBigPadded(
              onPressed: widget.onReject, text: l10n.generalButtonCancel)),
      ThemedControls.spacerHorizontalSmall(),
      Expanded(
          child: hasAccepted
              ? ThemedControls.primaryButtonBigPadded(
                  onPressed: proceedHandler, text: l10n.generalButtonProceed)
              : ThemedControls.primaryButtonBigDisabledPadded(
                  text: l10n.generalButtonProceed)),
    ];
  }

  void proceedHandler() async {
    if (!hasAccepted) {
      return;
    }
    widget.onAccept();
  }

  void _toggleCheckbox(bool? value) {
    setState(() {
      hasAccepted = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return Container(
        width: double.infinity,
        child: Padding(
            padding: ThemeEdgeInsets.bottomSheetInsets,
            child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(children: [
                  getText(),
                  ThemedControls.spacerVerticalNormal(),
                  const Divider(),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    leading: Checkbox(
                      value: hasAccepted,
                      onChanged: _toggleCheckbox,
                    ),
                    title: Text(l10n.revealSeedWarningSheetCheckboxLabel),
                    onTap: () {
                      _toggleCheckbox(!hasAccepted);
                    },
                  ),
                  ThemedControls.spacerVerticalNormal(),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: getButtons())
                ]))));
  }
}
