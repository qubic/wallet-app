import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class AddAccountWarningSheet extends StatefulWidget {
  final Function() onAccept;
  final Function() onReject;
  const AddAccountWarningSheet(
      {super.key, required this.onAccept, required this.onReject});

  @override
  _AddAccountWarningSheetState createState() => _AddAccountWarningSheetState();
}

class _AddAccountWarningSheetState extends State<AddAccountWarningSheet> {
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
          ThemedControls.spacerHorizontalNormal(),
          Expanded(child: Text(text, style: TextStyles.textLarge))
        ]);
  }

  Widget getText() {
    return Row(children: [
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
            ThemedControls.pageHeader(headerText: "Before you proceed"),
            ThemedControls.spacerVerticalNormal(),
            getWarningText("Keep a safe backup of your private seed"),
            ThemedControls.spacerVerticalNormal(),
            getWarningText("Never share your private seed with anyone"),
            ThemedControls.spacerVerticalNormal(),
            getWarningText(
                "Do not paste your private seed to unknown apps or websites"),
          ]))
    ]);
  }

  List<Widget> getButtons() {
    return [
      Expanded(
          child: ThemedControls.transparentButtonBigWithChild(
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding),
                  child: Text("Cancel",
                      textAlign: TextAlign.center,
                      style: TextStyles.transparentButtonText)),
              onPressed: widget.onReject)),
      ThemedControls.spacerHorizontalSmall(),
      Expanded(
          child: hasAccepted
              ? ThemedControls.primaryButtonBigWithChild(
                  onPressed: transferNowHandler,
                  child: Padding(
                    padding:
                        const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                    child: Text("Proceed",
                        textAlign: TextAlign.center,
                        style: TextStyles.primaryButtonText),
                  ))
              : ThemedControls.primaryButtonBigDisabledWithChild(
                  child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: Text("Proceed",
                      textAlign: TextAlign.center,
                      style: TextStyles.primaryButtonText),
                ))),
    ];
  }

  void transferNowHandler() async {
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
    return Padding(
        padding: ThemeEdgeInsets.bottomSheetInsets,
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(children: [
              getText(),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThemedControls.spacerVerticalNormal(),
                    const Divider(),
                    ThemedControls.spacerVerticalNormal(),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                      leading: Checkbox(
                        value: hasAccepted,
                        onChanged: _toggleCheckbox,
                      ),
                      title: const Text("I understand the above"),
                      onTap: () {
                        _toggleCheckbox(!hasAccepted);
                      },
                    ),
                    const SizedBox(height: ThemePaddings.normalPadding),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: getButtons())
                  ])
            ])));
  }
}
