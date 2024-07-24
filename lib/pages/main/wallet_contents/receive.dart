import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qubic_wallet/components/toggleable_qr_code.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:share_plus/share_plus.dart';

class Receive extends StatefulWidget {
  final QubicListVm item;
  const Receive({super.key, required this.item});

  @override
  // ignore: library_private_types_in_public_api
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  final ApplicationStore appStore = getIt<ApplicationStore>();

  String? generatedPublicId;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getQRCode() {
    return Container(
        color: Colors.white,
        child: QrImageView(
            data: widget.item.publicId,
            version: QrVersions.auto,
            backgroundColor: Colors.white,
            errorCorrectionLevel: QrErrorCorrectLevel.H,
            embeddedImage: const AssetImage('assets/images/logo.png'),
            embeddedImageStyle: const QrEmbeddedImageStyle(
              size: Size(80, 80),
            ),
            padding: const EdgeInsets.all(ThemePaddings.normalPadding)));
  }

  List<Widget> getActions() {
    final l10n = l10nOf(context);
    return [
      ThemedControls.primaryButtonNormal(
          onPressed: () {
            copyToClipboard(widget.item.publicId, context);
          },
          text: l10n.generalButtonCopyAddress,
          icon: !LightThemeColors.shouldInvertIcon
              ? ThemedControls.invertedColors(
                  child: Image.asset("assets/images/Group 2400.png"))
              : Image.asset("assets/images/Group 2400.png")),
      MediaQuery.of(context).size.width < 400
          ? ThemedControls.spacerVerticalSmall()
          : ThemedControls.spacerHorizontalSmall(),
      ThemedControls.transparentButtonNormal(
          onPressed: () {
            Share.share(widget.item.publicId);
          },
          text: l10n.generalButtonShare,
          icon: LightThemeColors.shouldInvertIcon
              ? ThemedControls.invertedColors(
                  child: Image.asset("assets/images/Group 2389.png"))
              : Image.asset("assets/images/Group 2389.png"))
    ];
  }

  Widget getScrollView() {
    final l10n = l10nOf(context);

    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Container(
              child: Expanded(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(
                  headerText: l10n.receiveTitle,
                  subheaderText: l10n.receiveHeader(widget.item.name)),
              ThemedControls.card(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    Text(l10n.receiveLabelAddress,
                        style: TextStyles.lightGreyTextSmall),
                    ThemedControls.spacerVerticalMini(),
                    Text(widget.item.publicId),
                    ThemedControls.spacerVerticalNormal(),
                    MediaQuery.of(context).size.width < 400
                        ? Column(children: getActions())
                        : Row(children: getActions())
                  ])),
              ThemedControls.spacerVerticalSmall(),
              ToggleableQRCode(
                  qRCodeData: widget.item.publicId, expanded: true),
            ],
          )))
        ]));
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);

    return [
      FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(l10n.generalButtonClose))
    ];
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return Future.value(!isLoading);
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: SafeArea(
                minimum: ThemeEdgeInsets.pageInsets,
                child: Column(children: [
                  Expanded(child: getScrollView()),
                ]))));
  }
}
