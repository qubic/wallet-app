import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/copy_button.dart';
import 'package:qubic_wallet/components/private_seed_warning.dart';
import 'package:qubic_wallet/components/toggleable_qr_code.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class RevealSeedContents extends StatefulWidget {
  final QubicListVm item;

  const RevealSeedContents({super.key, required this.item});

  @override
  RevealSeedContentsState createState() => RevealSeedContentsState();
}

class RevealSeedContentsState extends State<RevealSeedContents> {
  final ApplicationStore appStore = getIt<ApplicationStore>();

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

  Widget getScrollView() {
    final l10n = l10nOf(context);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ThemedControls.pageHeader(
                  headerText: l10n.revealSeedTitle,
                  subheaderText: l10n.revealSeedHeader(widget.item.name),
                ),
                PrivateSeedWarning(
                  title: l10n.revealSeedWarningTitle,
                  description: l10n.revealSeedWarningDescription,
                ),
                ThemedControls.spacerVerticalSmall(),
                ThemedControls.card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.revealSeedLabelPrivateSeed,
                          style: TextStyles.lightGreyTextSmall),
                      ThemedControls.spacerVerticalMini(),
                      seedId != null
                          ? Row(
                              children: [
                                Expanded(
                                  child: Text(seedId!),
                                ),
                                CopyButton(
                                  copiedText: seedId!,
                                  snackbarMessage:
                                      l10n.revealSeedCopiedToClipboardMessage,
                                  isSensitive: true,
                                ),
                              ],
                            )
                          : const Text("-"),
                    ],
                  ),
                ),
                ThemedControls.spacerVerticalSmall(),
                seedId != null
                    ? ToggleableQRCode(qRCodeData: seedId!, expanded: true)
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: getScrollView()),
    ]);
  }
}
