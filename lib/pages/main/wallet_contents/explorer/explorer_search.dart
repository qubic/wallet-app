import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:qubic_wallet/components/explorer_results/explorer_result_qubic_id.dart';
import 'package:qubic_wallet/components/explorer_results/explorer_result_tick.dart';
import 'package:qubic_wallet/components/explorer_results/explorer_result_transaction.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:collection/collection.dart';

import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/explorer_query_dto.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/stores/explorer_store.dart';
import 'package:qubic_wallet/l10n/l10n.dart';

class ExplorerSearch extends StatefulWidget {
  const ExplorerSearch({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExplorerSearchState createState() => _ExplorerSearchState();
}

class _ExplorerSearchState extends State<ExplorerSearch> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ExplorerStore explorerStore = getIt<ExplorerStore>();
  final QubicLi qubicLi = getIt<QubicLi>();
  final ApplicationStore appStore = getIt<ApplicationStore>();

  late TextEditingController searchController = TextEditingController();
  bool showClearButton = false;
  List<ExplorerQueryDto>? searchResults;
  String lastSearchQuery = "";
  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      //_formKey.currentState!.fields["searchTerm"]!
      //  .didChange(searchController.text);
      if (searchController.text.isEmpty) {
        setState(() => showClearButton = false);
      } else {
        setState(() => showClearButton = true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> getItems() {
    List<Widget> items = [];
    for (var item in searchResults!) {
      String? walletAccountName = appStore.currentQubicIDs
          .firstWhereOrNull((e) => e.publicId == item.id)
          ?.name;
      items.add(Container(
          padding: const EdgeInsets.all(ThemePaddings.miniPadding),
          child: Column(children: [
            item.type == ExplorerResult.publicId
                ? ExplorerResultQubicId(
                    item: item, walletAccountName: walletAccountName)
                : item.type == ExplorerResult.tick
                    ? ExplorerResultTick(item: item)
                    : ExplorerResultTransaction(item: item)
          ])));
    }
    return items;
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
                ThemedControls.pageHeader(headerText: l10n.explorerSearchTitle),
                ThemedControls.spacerVerticalBig(),
                Text(l10n.explorerSearchLabelCriteria,
                    style: TextStyles.labelText),
                ThemedControls.spacerVerticalSmall(),
                FormBuilder(
                    key: _formKey,
                    child: Column(children: [
                      FormBuilderTextField(
                        name: "searchTerm",
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: l10n.generalErrorRequiredField),
                        ]),
                        maxLines: 1,
                        controller: searchController,
                        readOnly: isLoading,
                        decoration: ThemeInputDecorations.bigInputbox.copyWith(
                            suffix: showClearButton
                                ? SizedBox(
                                    height: 24,
                                    width: 14,
                                    child: IconButton(
                                        padding: const EdgeInsets.all(0),
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          _formKey.currentState!
                                              .fields["searchTerm"]!
                                              .didChange(null);
                                        }))
                                : SizedBox(
                                    height: 21, width: 14, child: Container())),
                        autocorrect: false,
                        autofillHints: null,
                      ),
                    ])),
                ThemedControls.spacerVerticalSmall(),
                Builder(builder: (context) {
                  if (searchResults == null) {
                    return Container();
                  }
                  if (searchResults!.isEmpty) {
                    return SizedBox(
                        width: double.infinity,
                        child: Column(children: [
                          ThemedControls.spacerVerticalNormal(),
                          Text(l10n.explorerSearchLabelNoResults,
                              textAlign: TextAlign.center,
                              style: TextStyles.labelText),
                          ThemedControls.spacerVerticalSmall(),
                          Text(lastSearchQuery, textAlign: TextAlign.center)
                        ]));
                  }

                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ThemedControls.spacerVerticalNormal(),
                        Text(
                          l10n.explorerSearchLabelResults(
                              searchResults!.length),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: ThemePaddings.smallPadding),
                        Column(children: getItems())
                      ]);
                })
              ])))
        ]));
  }

  List<Widget> getButtons() {
    final l10n = l10nOf(context);
    return [
      Expanded(
          child: ThemedControls.transparentButtonBigWithChild(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: ThemePaddings.normalPadding),
                  child: Text(l10n.generalButtonCancel,
                      style: TextStyles.transparentButtonText)))),
      ThemedControls.spacerHorizontalNormal(),
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: searchHandler,
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: ThemePaddings.normalPadding),
                  child: isLoading
                      ? SizedBox(
                          height: 23,
                          width: 24,
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary)))
                      : Text(l10n.generalButtonSearch,
                          style: TextStyles.primaryButtonText))))
    ];
  }

  void searchHandler() async {
    _formKey.currentState?.validate();
    if (!_formKey.currentState!.isValid) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      List<ExplorerQueryDto>? result = await qubicLi.getExplorerQuery(
          _formKey.currentState!.fields["searchTerm"]!.value as String);
      setState(() {
        lastSearchQuery =
            _formKey.currentState!.fields["searchTerm"]!.value as String;
        searchResults = result;
        isLoading = false;
        FocusManager.instance.primaryFocus?.unfocus();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  TextEditingController privateSeed = TextEditingController();

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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: getButtons())
                ]))));
  }
}
