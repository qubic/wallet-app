import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/components/asset_item.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

class Assets extends StatefulWidget {
  final String publicId;
  const Assets({super.key, required this.publicId});

  @override
  // ignore: library_private_types_in_public_api
  _AssetsState createState() => _AssetsState();
}

class _AssetsState extends State<Assets> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final GlobalSnackBar _globalSnackBar = getIt<GlobalSnackBar>();
  late final QubicListVm accountItem;
  late final reactionDispose;

  String? generatedPublicId;
  @override
  void initState() {
    super.initState();
    reactionDispose = autorun((_) {
      accountItem = appStore.currentQubicIDs
          .firstWhere((element) => element.publicId == widget.publicId);
    });
  }

  @override
  void dispose() {
    reactionDispose();
    super.dispose();
  }

  Widget getAssetLine(QubicAssetDto asset) {
    return Text(asset.issuedAsset.name);
  }

  Widget getQXAssets() {
    final l10n = l10nOf(context);

    List<QubicAssetDto> qxAssets = accountItem.assets.values
        .where((element) => !element.isSmartContractShare)
        .toList();
    if (qxAssets.isEmpty) {
      return Container();
    }

    List<Widget> output = [];
    output.add(
        Text(l10n.assetsLabelQXAssets, style: TextStyles.sliverCardPreLabel));
    qxAssets.forEach((element) => output.add(getAssetEntry(element)));
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: output);
  }

  Widget getSCAssets() {
    final l10n = l10nOf(context);

    List<QubicAssetDto> scAssets = accountItem.assets.values
        .where((element) => element.isSmartContractShare)
        .toList();
    if (scAssets.isEmpty) {
      return Container();
    }

    List<Widget> output = [];

    output.add(Text(l10n.assetsLabelSmartContractShares,
        style: TextStyles.sliverCardPreLabel));
    scAssets.forEach((element) => output.add(getAssetEntry(element)));
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: output);
  }

  Widget getAssetEntry(QubicAssetDto asset) {
    return AssetItem(account: accountItem, asset: asset);
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
                  headerText: l10n.assetsTitle,
                  subheaderText: l10n.assetsHeader(accountItem.name)),
              Column(
                children: [
                  getSCAssets(),
                  ThemedControls.spacerVerticalBig(),
                  getQXAssets(),
                  ThemedControls.spacerVerticalMini(),
                ],
              )
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

  void saveIdHandler() async {
    final l10n = l10nOf(context);

    _formKey.currentState?.validate();
    if (!_formKey.currentState!.isValid) {
      return;
    }

    //Prevent duplicates

    if (appStore.currentQubicIDs
        .where(((element) =>
            element.publicId == generatedPublicId!.replaceAll(",", "_")))
        .isNotEmpty) {
      _globalSnackBar.show(l10n.generalSnackBarMessageAccountAlreadyExist);

      return;
    }

    setState(() {
      isLoading = true;
    });
    appStore.addId(
      _formKey.currentState?.instantValue["accountName"] as String,
      generatedPublicId!,
      _formKey.currentState?.instantValue["privateSeed"] as String,
    );

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  TextEditingController privateSeed = TextEditingController();

  bool showAccountInfoTooltip = false;
  bool showSeedInfoTooltip = false;
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
                minimum: ThemeEdgeInsets.pageInsets,
                child: Column(children: [
                  Expanded(child: getScrollView()),
                ]))));
  }
}
