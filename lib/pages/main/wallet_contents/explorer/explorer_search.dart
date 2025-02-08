import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/explorer_query_dto.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/explorer/explorer_result_page.dart';
import 'package:qubic_wallet/resources/apis/archive/qubic_archive_api.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/explorer_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/styles/input_decorations.dart';
import 'package:qubic_wallet/styles/text_styles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';

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
  final qubicArchive = getIt<QubicArchiveApi>();
  final ApplicationStore appStore = getIt<ApplicationStore>();

  final TextEditingController searchController = TextEditingController();
  bool showClearButton = false;
  bool? foundResults;
  String lastSearchTerm = "";
  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
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
                  if (foundResults == false) {
                    return SizedBox(
                        width: double.infinity,
                        child: Column(children: [
                          ThemedControls.spacerVerticalNormal(),
                          Text(l10n.explorerSearchLabelNoResults,
                              textAlign: TextAlign.center,
                              style: TextStyles.labelText),
                          ThemedControls.spacerVerticalSmall(),
                          Text(lastSearchTerm, textAlign: TextAlign.center)
                        ]));
                  } else {
                    return const SizedBox.shrink();
                  }
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
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary)))
                      : Text(l10n.generalButtonSearch,
                          style: TextStyles.primaryButtonText))))
    ];
  }

  ExplorerResult? checkKeyword(String keyword) {
    String trimmedKeyword = keyword.trim();

    if (trimmedKeyword.length == 60) {
      if (RegExp(r'^[A-Z\s]+$').hasMatch(trimmedKeyword)) {
        return ExplorerResult.publicId;
      }
      if (RegExp(r'^[a-z]+$').hasMatch(trimmedKeyword)) {
        return ExplorerResult.transaction;
      }
    } else if (int.tryParse(keyword.replaceAll(',', ''))?.toString().length ==
        8) {
      return ExplorerResult.tick;
    }

    return null;
  }

  void searchHandler() async {
    _formKey.currentState?.validate();
    if (!_formKey.currentState!.isValid) {
      return;
    }
    final term = _formKey.currentState!.fields["searchTerm"]!.value as String;
    if (checkKeyword(term) == null) {
      setNotFoundError(term);
      return;
    } else {
      setState(() {
        foundResults = true;
      });
      if (checkKeyword(term) == ExplorerResult.tick) {
        pushScreen(context,
            screen: ExplorerResultPage(
                resultType: ExplorerResultType.tick,
                tick: int.tryParse(term.replaceAll(',', ''))));
      } else if (checkKeyword(term) == ExplorerResult.publicId) {
        pushScreen(context,
            screen: ExplorerResultPage(
                resultType: ExplorerResultType.publicId, qubicId: term));
      } else {
        setState(() {
          isLoading = true;
        });
        try {
          final transaction = await qubicArchive.getTransaction(term);
          pushScreen(context,
              screen: ExplorerResultPage(
                  resultType: ExplorerResultType.transaction,
                  focusedTransactionHash: term,
                  tick: transaction.transaction.tickNumber));
        } catch (e) {
          if (e is AppError && e.statusCode == 404) {
            setNotFoundError(term);
          } else {
            appStore.reportGlobalError(e.toString());
          }
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  void setNotFoundError(String usedTerm) {
    setState(() {
      foundResults = false;
      lastSearchTerm = usedTerm;
    });
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
                minimum: ThemeEdgeInsets.pageInsets,
                child: Column(children: [
                  Expanded(child: getScrollView()),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: getButtons())
                ]))));
  }
}
