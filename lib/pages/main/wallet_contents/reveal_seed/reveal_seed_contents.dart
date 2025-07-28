import 'package:flutter/material.dart';
import 'package:qubic_wallet/components/toggleable_qr_code.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';
import 'package:flutter/services.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'dart:async';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class RevealSeedContents extends StatefulWidget {
  final QubicListVm item;

  const RevealSeedContents({super.key, required this.item});

  @override
  RevealSeedContentsState createState() => RevealSeedContentsState();
}

class RevealSeedContentsState extends State<RevealSeedContents>
    with WidgetsBindingObserver {
  final ApplicationStore appStore = getIt<ApplicationStore>();

  String? generatedPublicId;
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // If more than 1 minute has passed since copying, clear clipboard
      if (_clipboardSetTime != null &&
          DateTime.now().difference(_clipboardSetTime!).inSeconds >= 60) {
        Clipboard.setData(const ClipboardData(text: ''));
        _clipboardSetTime = null;
      }
    }
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
                      Text('Do not share your Private Seed!',
                          style: TextStyles.alertHeader
                              .copyWith(color: LightThemeColors.warning40)),
                      const SizedBox(height: 4),
                      Text(
                        'If someone has your private seed, they will have full control of your account.',
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
                                    style: TextStyle(
                                        fontSize: 16, fontFamily: 'monospace'),
                                  ),
                                ),
                                IconButton(
                                  icon: ThemedControls.invertedColors(
                                      child: Image.asset(
                                          "assets/images/Group 2400.png")),
                                  tooltip: l10n.revealSeedButtonCopy,
                                  onPressed: () =>
                                      _copySeedToClipboard(seedId!),
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

  void _copySeedToClipboard(String seed) async {
    await Clipboard.setData(ClipboardData(text: seed));
    _clipboardSetTime = DateTime.now();
    _clipboardTimer?.cancel();
    _clipboardTimer = Timer(const Duration(minutes: 1), () async {
      await Clipboard.setData(const ClipboardData(text: ''));
      _clipboardSetTime = null;
    });
    final l10n = l10nOf(context);
    final _globalSnackBar = getIt<GlobalSnackBar>();
    _globalSnackBar.show(
        'Private seed temporarily copied to clipboard (stored for 1 minute)');
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
