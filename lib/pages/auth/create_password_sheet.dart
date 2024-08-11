import 'package:flutter/material.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

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
    final l10n = l10nOf(context);
    return Row(children: [
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
            ThemedControls.pageHeader(
                headerText: l10n.createPasswordSheetHeader),
            Text(l10n.createPasswordSheetMessage, style: TextStyles.textLarge),
          ]))
    ]);
  }

//transferNowHandler
  List<Widget> getButtons() {
    final l10n = l10nOf(context);

    return [
      Expanded(
          child: ThemedControls.transparentButtonBigWithChild(
              child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding),
                  child: Text(l10n.generalButtonCancel,
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
                    child: Text(l10n.generalButtonProceed,
                        textAlign: TextAlign.center,
                        style: TextStyles.primaryButtonText),
                  ))
              : ThemedControls.primaryButtonBigDisabledWithChild(
                  child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: Text(l10n.generalButtonProceed,
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 0.0),
                      leading: Checkbox(
                        value: hasAccepted,
                        onChanged: (value) {
                          setState(() {
                            hasAccepted = value!;
                          });
                        },
                      ),
                      title: Text(l10n.createPasswordSheetCheckboxMessage),
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
