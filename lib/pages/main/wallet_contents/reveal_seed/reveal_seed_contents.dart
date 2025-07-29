import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qubic_wallet/components/copy_button.dart';
import 'package:qubic_wallet/components/toggleable_qr_code.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
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

class RevealSeedContentsState extends State<RevealSeedContents>
    with WidgetsBindingObserver {
  final ApplicationStore appStore = getIt<ApplicationStore>();

  String? seedId;

  Timer? _clipboardTimer;
  DateTime? _clipboardSetTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appStore.getSeedById(widget.item.publicId).then((value) {
      setState(() {
        seedId = value;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clipboardTimer?.cancel();
    _clipboardTimer = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndClearExpiredClipboard();
    }
  }

  void _checkAndClearExpiredClipboard() {
    if (_clipboardSetTime != null &&
        DateTime.now().difference(_clipboardSetTime!).inSeconds >= 60) {
      _clearClipboard();
    }
  }

  void _clearClipboardTimer() {
    _clipboardTimer?.cancel();
    _clipboardTimer = null;
  }

  void _clearClipboard() {
    Clipboard.setData(const ClipboardData(text: ''));
    _clearClipboardTimer();
    _clipboardSetTime = null;
    appLogger.i("[Clipboard] Cleared after timeout");
  }

  void setTimerToClearClipboard() {
    _clipboardSetTime = DateTime.now();
    _clearClipboardTimer();
    _clipboardTimer = Timer(const Duration(minutes: 1), () {
      if (mounted) {
        _clearClipboard();
      }
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
                // Warning Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: LightThemeColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: LightThemeColors.warning40),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.revealSeedWarningTitle,
                          style: TextStyles.alertHeader
                              .copyWith(color: LightThemeColors.warning40)),
                      const SizedBox(height: 4),
                      Text(
                        l10n.revealSeedWarningDescription,
                        style: TextStyles.alertText
                            .copyWith(color: LightThemeColors.warning40),
                      ),
                    ],
                  ),
                ),
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
                                  child: SelectableText(
                                    seedId!,
                                    style: const TextStyle(
                                        fontSize: 16, fontFamily: 'monospace'),
                                  ),
                                ),
                                CopyButton(
                                  copiedText: seedId!,
                                  snackbarMessage:
                                      l10n.revealSeedCopiedToClipboardMessage,
                                  onTap: setTimerToClearClipboard,
                                ),
                              ],
                            )
                          : const Text("-"),
                      ThemedControls.spacerVerticalNormal(),
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
