import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class EraseWalletSheet extends StatefulWidget {
  final Function() onAccept;

  final Function() onReject;
  const EraseWalletSheet({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  @override
  _EraseWalletSheetState createState() => _EraseWalletSheetState();
}

class _EraseWalletSheetState extends State<EraseWalletSheet> {
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
    return Row(children: [
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
            ThemedControls.pageHeader(
                headerText:
                    "Are you sure you want to erase existing wallet data?"),
            Text(
                "This action cannot be undone. All your accounts will be removed from your device.",
                style: TextStyles.textLarge),
            ThemedControls.spacerVerticalSmall(),
            Text(
                "You will only be able to recover your accounts if you have a backup of your private seeds.",
                style: TextStyles.textLarge),
          ]))
    ]);
  }

//transferNowHandler
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
                  onPressed: acceptedHandler,
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

  void acceptedHandler() async {
    if (!hasAccepted) {
      return;
    }
    widget.onAccept();
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
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                      leading: Checkbox(
                        value: hasAccepted,
                        onChanged: (value) {
                          setState(() {
                            hasAccepted = value!;
                          });
                        },
                      ),
                      title: const Text("Yes, erase my wallet data."),
                      onTap: () {
                        setState(() {
                          hasAccepted = !hasAccepted;
                        });
                      },
                    ),
                    ThemedControls.spacerVerticalNormal(),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: getButtons())
                  ])
            ])));
  }
}
