import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class CreatePasswordSheet extends StatefulWidget {
  final Function() onAccept;

  final Function() onReject;
  const CreatePasswordSheet({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  @override
  _CreatePasswordSheetState createState() => _CreatePasswordSheetState();
}

class _CreatePasswordSheetState extends State<CreatePasswordSheet> {
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
                headerText: "Please backup your password"),
            Text(
                "There is no way to retrieve your password if you forget it. Please make sure you have a backup of your password before proceeding.",
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
                      title: const Text("Yes, I have backed up my password."),
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
