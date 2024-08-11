import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/toggleable_qr_code.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class RevealSeedContents extends StatefulWidget {
  final QubicListVm item;

  const RevealSeedContents({super.key, required this.item});

  @override
  _RevealSeedContentsState createState() => _RevealSeedContentsState();
}

class _RevealSeedContentsState extends State<RevealSeedContents> {
  final ApplicationStore appStore = getIt<ApplicationStore>();

  String? generatedPublicId;
  String? seedId;
  @override
  void initState() {
    super.initState();
    appStore.getSeedById(widget.item.publicId).then((value) {
      setState(() {
        seedId = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getScrollView() {
    final l10n = l10nOf(context);
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(
                  headerText: l10n.revealSeedTitle,
                  subheaderText: l10n.revealSeedHeader(widget.item.name)),
              ThemedControls.card(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    Text(l10n.revealSeedLabelPrivateSeed,
                        style: TextStyles.lightGreyTextSmall),
                    ThemedControls.spacerVerticalMini(),
                    seedId != null ? Text(seedId!) : const Text("-"),
                    ThemedControls.spacerVerticalNormal(),
                    seedId == null
                        ? Row(children: [
                            ThemedControls.primaryButtonNormal(
                                onPressed: () {
                                  copyToClipboard(seedId!, context);
                                },
                                text: l10n.revealSeedButtonCopy,
                                icon: ThemedControls.invertedColors(
                                    child: LightThemeColors.shouldInvertIcon
                                        ? ThemedControls.invertedColors(
                                            child: Image.asset(
                                                "assets/images/Group 2400.png"))
                                        : Image.asset(
                                            "assets/images/Group 2400.png"))),
                          ])
                        : Container()
                  ])),
              ThemedControls.spacerVerticalSmall(),
              seedId != null
                  ? ToggleableQRCode(qRCodeData: seedId!, expanded: true)
                  : Container(),
            ],
          ))
        ]));
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);
    return [
      FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            l10n.generalButtonClose,
          ))
    ];
  }

  TextEditingController privateSeed = TextEditingController();

  bool showAccountInfoTooltip = false;
  bool showSeedInfoTooltip = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: getScrollView()),
    ]);
  }
}
