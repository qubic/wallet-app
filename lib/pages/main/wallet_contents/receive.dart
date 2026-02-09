import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qubic_wallet/components/copy_button.dart';
import 'package:qubic_wallet/components/toggleable_qr_code.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
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

  Widget getShareAction() {
    final l10n = l10nOf(context);
    return ThemedControls.primaryButtonNormal(
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final RenderBox box = context.findRenderObject() as RenderBox;

            // Calculate the global position of the Receive button
            final Offset position = box.localToGlobal(Offset.zero);
            final Size size = box.size;

            // Create a Rect based on the Recieve button's position and size
            final Rect sharePositionOrigin = Rect.fromLTWH(
              position.dx,
              position.dy,
              size.width,
              size.height,
            );

            // Now use this Rect for the sharePositionOrigin
            Share.share(
              widget.item.publicId,
              sharePositionOrigin: sharePositionOrigin,
            );
          });
        },
        text: l10n.generalButtonShare,
        icon: !LightThemeColors.shouldInvertIcon
            ? ThemedControls.invertedColors(
                child: Image.asset("assets/images/Group 2389.png"))
            : Image.asset("assets/images/Group 2389.png"));
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
                  headerText: l10n.receiveTitle,
                  subheaderText: l10n.receiveHeader(widget.item.name)),
              ThemedControls.card(
                  padding: const EdgeInsets.fromLTRB(
                      ThemePaddings.mediumPadding,
                      ThemePaddings.normalPadding,
                      ThemePaddings.miniPadding,
                      ThemePaddings.normalPadding),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.receiveLabelAddress,
                            style: TextStyles.lightGreyTextSmall),
                        ThemedControls.spacerVerticalSmall(),
                        Flex(direction: Axis.horizontal, children: [
                          Expanded(child: Text(widget.item.publicId)),
                          CopyButton(copiedText: widget.item.publicId),
                        ]),
                        ThemedControls.spacerVerticalSmall(),
                        MediaQuery.of(context).size.width < 400
                            ? Column(children: [getShareAction()])
                            : Row(children: [getShareAction()]),
                        ThemedControls.spacerVerticalNormal(),
                        ToggleableQRCode(
                            qRCodeData: widget.item.publicId, expanded: true)
                      ])),
              ThemedControls.spacerVerticalMini()
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
          child: Text(l10n.generalButtonClose))
    ];
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !isLoading,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: SafeArea(
                minimum: const EdgeInsets.fromLTRB(
                    ThemePaddings.smallPadding,
                    ThemePaddings.normalPadding,
                    ThemePaddings.smallPadding,
                    ThemePaddings.bigPadding),
                child: Column(children: [
                  Expanded(child: getScrollView()),
                ]))));
  }
}
