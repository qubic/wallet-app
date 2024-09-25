import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qubic_wallet/components/explorer_result_page_qubic_id/explorer_result_page_qubic_id.dart';
import 'package:qubic_wallet/components/explorer_result_page_tick/explorer_result_page_tick.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/explorer_id_info_dto.dart';
import 'package:qubic_wallet/dtos/explorer_tick_info_dto.dart';
import 'package:qubic_wallet/dtos/explorer_transaction_info_dto.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/models/app_error.dart';
import 'package:qubic_wallet/resources/apis/archive/qubic_archive_api.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';
import 'package:qubic_wallet/stores/explorer_store.dart';
import 'package:qubic_wallet/styles/edge_insets.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum ExplorerResultType { publicId, tick, transaction }

class ExplorerResultPage extends StatefulWidget {
  final ExplorerResultType resultType;
  final int? tick;
  final String? qubicId;
  final String? focusedTransactionHash;
  final String? walletAccountName;
  const ExplorerResultPage(
      {super.key,
      required this.resultType,
      this.tick,
      this.qubicId,
      this.focusedTransactionHash,
      this.walletAccountName});

  @override
  // ignore: library_private_types_in_public_api
  _ExplorerResultPageState createState() => _ExplorerResultPageState();
}

class _ExplorerResultPageState extends State<ExplorerResultPage> {
  final ExplorerStore explorerStore = getIt<ExplorerStore>();
  final QubicLi qubicLi = getIt<QubicLi>();
  final QubicArchiveApi qubicArchiveApi = getIt<QubicArchiveApi>();

  late int? tick;
  late String? qubicId;
  late ExplorerResultType resultType;
  late String? focusedTransactionHash;

  final DateFormat formatter = DateFormat('dd MMM yyyy \'at\' HH:mm:ss');

  ExplorerIdInfoDto? idInfo;
  List<ExplorerTransactionDto>? transactions;
  ExplorerTickDto? tickData;

  bool isLoading = true;
  String? error = "An error";
  @override
  void initState() {
    super.initState();

    focusedTransactionHash = widget.focusedTransactionHash;

    tick = widget.tick;
    qubicId = widget.qubicId;
    resultType = widget.resultType;
    validateNonMissingQueryData();
    getInfo();
  }

  // Validates that query data is not missing for this widget
  void validateNonMissingQueryData() {
    if (((resultType == ExplorerResultType.tick) ||
            (resultType == ExplorerResultType.transaction)) &&
        (tick == null)) {
      throw Exception("Tick cannot be null");
    }
    if ((resultType == ExplorerResultType.publicId) && (qubicId == null)) {
      throw Exception("PublicId cannot be null");
    }
  }

  //Gets info from the backend and stores it in the store
  void getInfo() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    if (resultType == ExplorerResultType.tick) {
      try {
        final futures = await Future.wait([
          qubicArchiveApi.getExplorerTick(tick!),
          qubicArchiveApi.getExplorerTickTransactions(tick!),
        ]);
        tickData = futures[0] as ExplorerTickDto;
        transactions = futures[1] as List<ExplorerTransactionDto>;
        final computers = await qubicArchiveApi.getComputors(tickData!.epoch);
        tickData?.tickLeaderId = computers.identities[tickData!.computorIndex];
        isLoading = false;
        setState(() {});
      } catch (err) {
        setState(() {
          error = err is AppError ? err.message : err.toString();
        });
      }

      // qubicLi.getExplorerTickInfo(tick!).then((value) {
      //   setState(() {
      //     tickInfo = value;
      //     isLoading = false;
      //   });
      // },
      //     onError: (err) => setState(() {
      //           error = err.toString().replaceAll("Exception: ", "");
      //         }));
    } else if (resultType == ExplorerResultType.publicId) {
      //PUBLIC ID
      qubicLi.getExplorerIdInfo(qubicId!).then((value) {
        setState(() {
          idInfo = value;
          isLoading = false;
        });
      },
          onError: (err) => setState(() {
                error = err.toString().replaceAll("Exception: ", "");
              }));
    } else if (resultType == ExplorerResultType.transaction) {
      qubicLi.getExplorerTickInfo(tick!).then((value) {
        explorerStore.setExplorerTickInfo(value);
        setState(() {
          //  tickInfo = value;
          isLoading = false;
        });
      },
          onError: (err) => setState(() {
                error = err.toString().replaceAll("Exception: ", "");
              }));
    }
  }

  Widget getErrorView() {
    final l10n = l10nOf(context);
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: ThemePaddings.normalPadding),
          Text(l10n.generalLabelError,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium!
                  .copyWith(fontFamily: ThemeFonts.primary)),
          Text(
            error ?? "-",
            textAlign: TextAlign.center,
          ),
          FilledButton(
              child: Text(l10n.generalButtonTryAgain),
              onPressed: () {
                getInfo();
              })
        ]));
  }

  Widget getLoadingView() {
    final l10n = l10nOf(context);
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(height: ThemePaddings.normalPadding),
          Text(l10n.generalLabelLoading,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontFamily: ThemeFonts.primary))
        ]));
  }

  Widget getHeader() {
    if (resultType == ExplorerResultType.publicId) {
      return Column(children: [
        Text(qubicId!.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(fontFamily: ThemeFonts.primary))
      ]);
    }
    return Container();
  }

  Widget getScrollView() {
    return resultType == ExplorerResultType.tick ||
            resultType == ExplorerResultType.transaction
        ? ExplorerResultPageTick(
            tickInfo: tickData!,
            transactions: transactions,
            focusedTransactionId: focusedTransactionHash,
            onRequestViewChange: (type, tick, publicId) {
              if (type == RequestViewChangeType.tick) {
                setState(() {
                  focusedTransactionHash = null;
                  tickData = null;
                  this.tick = tick;
                  getInfo();
                });
              } else if (type == RequestViewChangeType.publicId) {
                setState(() {
                  focusedTransactionHash = null;
                  tickData = null;
                  qubicId = publicId;
                  getInfo();
                });
              }
            })
        : ExplorerResultPageQubicId(idInfo: idInfo!);
  }

  List<Widget>? getActions() {
    return <Widget>[
      IconButton(
        icon: const ImageIcon(AssetImage('assets/images/explorer.png'),
            color: LightThemeColors
                .primary // Optional: color to apply to the image
            ),
        onPressed: () async {
          String explorerUrl = Config.URL_WebExplorer;

          if (widget.resultType == ExplorerResultType.publicId) {
            explorerUrl += "/network/address/$qubicId";
          } else if (focusedTransactionHash != null) {
            // if showing only one transaction
            explorerUrl += "/network/tx/$focusedTransactionHash";
          } else {
            // it's displaying all the transactions in the tick
            explorerUrl += "/network/tick/$tick";
          }

          if (await canLaunchUrlString(explorerUrl)) {
            await launchUrlString(explorerUrl,
                mode: LaunchMode.externalApplication);
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: resultType == ExplorerResultType.tick ||
                    resultType == ExplorerResultType.transaction
                ? LightThemeColors.cardBackground
                : Colors.transparent,
            actions: getActions()),
        body: SafeArea(
            minimum: resultType == ExplorerResultType.tick ||
                    resultType == ExplorerResultType.transaction
                ? EdgeInsets.fromLTRB(
                    0, 0, 0, ThemeEdgeInsets.pageInsets.bottom)
                : ThemeEdgeInsets.pageInsets,
            child: error != null
                ? getErrorView()
                : isLoading
                    ? getLoadingView()
                    : getScrollView()));
  }
}
