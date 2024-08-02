import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/components/toggleable_qr_code.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/pages/auth/create_password_sheet.dart';
import 'package:qubic_wallet/pages/auth/import_private_seed.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/inputDecorations.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_platform/universal_platform.dart';

class ImportSelector extends StatefulWidget {
  const ImportSelector({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ImportSelectorState createState() => _ImportSelectorState();
}

class _ImportSelectorState extends State<ImportSelector> {
  bool isLoading = false; //Is the form loading

  final ApplicationStore appStore = getIt<ApplicationStore>();
  bool obscuringTextPass = true; //Hide password text
  bool obscuringTextPassRepeat = true; //Hide password repeat text
  final _formKey = GlobalKey<FormBuilderState>();
  final GlobalSnackBar _globalSnackbar = getIt<GlobalSnackBar>();

  int? selectedImportType =
      0; //0 = no option, 1 vault file, 2 seed, null = no option

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getSelectionButton(Function? onPressed, String assetPath, String title,
      String subtitle, bool hasError) {
    return ThemedControls.darkButtonBigWithChild(
        error: hasError,
        onPressed: () async {
          if (onPressed != null) {
            await onPressed();
          }
        },
        child: Padding(
            padding: const EdgeInsets.all(ThemePaddings.normalPadding),
            child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(assetPath),
                  ThemedControls.spacerHorizontalNormal(),
                  Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: TextStyles.textBold),
                          ThemedControls.spacerVerticalSmall(),
                          Container(
                              child: Text(subtitle,
                                  style: TextStyles.secondaryText))
                        ]),
                  )
                ])));
  }

  //Gets the container scroll view
  Widget getScrollView() {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(
                  headerText: "Import wallet", subheaderText: ""),
              Text("Choose how you want to import your existing wallet",
                  style: TextStyles.secondaryText),
              ThemedControls.spacerVerticalHuge(),
              getSelectionButton(
                  () {},
                  "assets/images/import-vault-file.png",
                  "Import vault file",
                  "Import an existing wallet with multiple accounts through a vault file.",
                  false),
              ThemedControls.spacerVerticalNormal(),
              getSelectionButton(() {
                pushScreen(
                  context,
                  screen: const ImportPrivateSeed(),
                  withNavBar: false, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
                  "assets/images/import-private-seed.png",
                  "Enter private seed",
                  "Import an existing account by entering 55 character seed phraze.",
                  false),
            ],
          ))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !isLoading,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: Padding(
              padding: ThemeEdgeInsets.pageInsets,
              child: Column(children: [
                Expanded(child: getScrollView()),
              ]),
            )));
  }
}
