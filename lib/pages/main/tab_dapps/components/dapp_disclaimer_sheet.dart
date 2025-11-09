import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/pages/main/tab_dapps/webview_screen.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class DappDisclaimerSheet extends StatefulWidget {
  final Function() onAccept;
  final Function() onReject;

  const DappDisclaimerSheet({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  @override
  DappDisclaimerSheetState createState() => DappDisclaimerSheetState();
}

class DappDisclaimerSheetState extends State<DappDisclaimerSheet> {
  bool hasAccepted = false;

  Widget getDisclaimerText(String text) {
    return Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ThemedControls.spacerHorizontalNormal(),
        Expanded(child: Text(text, style: TextStyles.textLarge))
      ],
    );
  }

  Widget getText() {
    final l10n = l10nOf(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(headerText: l10n.dappDisclaimerTitle),
              ThemedControls.spacerVerticalNormal(),
              getDisclaimerText(l10n.dappDisclaimerMessageLineOne),
              ThemedControls.spacerVerticalNormal(),
              getDisclaimerText(l10n.dappDisclaimerMessageLineTwo),
              ThemedControls.spacerVerticalNormal(),
              getDisclaimerText(l10n.dappDisclaimerMessageLineThree),
            ],
          ),
        )
      ],
    );
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);
    return [
      Expanded(
        child: ThemedControls.transparentButtonBigWithChild(
          child: Padding(
            padding: const EdgeInsets.all(ThemePaddings.smallPadding),
            child: Text(
              l10n.generalButtonCancel,
              textAlign: TextAlign.center,
              style: TextStyles.transparentButtonText,
            ),
          ),
          onPressed: widget.onReject,
        ),
      ),
      ThemedControls.spacerHorizontalSmall(),
      Expanded(
        child: hasAccepted
            ? ThemedControls.primaryButtonBigWithChild(
                onPressed: proceedHandler,
                child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: Text(
                    l10n.generalButtonConfirm,
                    textAlign: TextAlign.center,
                    style: TextStyles.primaryButtonText,
                  ),
                ),
              )
            : ThemedControls.primaryButtonBigDisabledWithChild(
                child: Padding(
                  padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                  child: Text(
                    l10n.generalButtonConfirm,
                    textAlign: TextAlign.center,
                    style: TextStyles.primaryButtonText,
                  ),
                ),
              ),
      ),
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: ThemeEdgeInsets.bottomSheetInsets.copyWith(
        bottom: ThemePaddings.normalPadding + bottomPadding,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            getText(),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ThemedControls.spacerVerticalNormal(),
                const Divider(),
                ThemedControls.spacerVerticalNormal(),
                InkWell(
                  onTap: () {
                    _toggleCheckbox(!hasAccepted);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: hasAccepted,
                        onChanged: _toggleCheckbox,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyles.textNormal,
                              children: [
                                TextSpan(text: l10n.dappDisclaimerCheckboxPrefix),
                                TextSpan(
                                  text: l10n.generalLabelTermsOfService,
                                  style: TextStyles.textNormal.copyWith(
                                    color: LightThemeColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      pushScreen(
                                        context,
                                        screen: SafeArea(
                                          top: false,
                                          child: WebviewScreen(
                                            initialUrl: 'https://static.qubic.org/products/wallet-app/legal/terms-of-service.md',
                                            hideFavorites: true,
                                            customTitle: l10n.generalLabelTermsOfService,
                                          ),
                                        ),
                                        pageTransitionAnimation: PageTransitionAnimation.slideUp,
                                        withNavBar: false,
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ThemePaddings.normalPadding),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: getButtons(),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
