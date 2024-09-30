import 'dart:async';

import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:qubic_wallet/models/wallet_connect/helpers.dart';
import 'package:qubic_wallet/models/wallet_connect/request_accounts_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_qubic_event.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectService {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  bool isReady = false;

  PairingInfo? pairingInfo;

  Web3Wallet? web3Wallet;

  /// Event that is triggered when a session is connected
  StreamController<SessionConnect?> onSessionConnect =
      StreamController<SessionConnect?>.broadcast();

  /// Event that is triggered when a session proposal is received
  StreamController<SessionProposalEvent?> onSessionProposal =
      StreamController<SessionProposalEvent?>.broadcast();

  /// Event that is triggered when a session is disconnected
  StreamController<SessionDelete?> onSessionDisconnect =
      StreamController<SessionDelete?>.broadcast();

  /// Event that is triggered when a session is disconnected
  StreamController<SessionExpire?> onSessionExpire =
      StreamController<SessionExpire?>.broadcast();

  /// Event that is triggered when a session is disconnected
  StreamController<SessionDelete?> onSessionDelete =
      StreamController<SessionDelete?>.broadcast();

  /// Event that is triggered when a session proposal event is expired
  StreamController<SessionProposalEvent?> onProposalExpire =
      StreamController<SessionProposalEvent?>.broadcast();

  StreamController<RequestAccountsEvent> onRequestAccounts =
      StreamController<RequestAccountsEvent>.broadcast();

  //Event that is triggered whan a request to send qubic is received
  StreamController<RequestSendQubicEvent> onRequestSendQubic =
      StreamController<RequestSendQubicEvent>.broadcast();

  StreamController<void> onRequestSendToken =
      StreamController<SessionConnect?>.broadcast();

  void disconnect() {
    web3Wallet!
        .getActiveSessions()
        .forEach(((String session, SessionData sessionData) {
      //web3Wallet!.sessions.delete(session);
      web3Wallet!.disconnectSession(
          reason: const WalletConnectError(
              code: -1, message: "User forcefully disconnected"),
          topic: sessionData.topic);
    }));
    web3Wallet!.core.relayClient.disconnect();
  }

  /// Checks that walletconnect is initialized before trying to trigger an event
  bool shouldTriggerEvent() {
    if (!settingsStore.settings.walletConnectEnabled) {
      return false;
    }
    if (web3Wallet == null) {
      return false;
    }
    if (web3Wallet!.getActiveSessions().isEmpty) {
      return false;
    }
    return true;
  }

  //Trigger of events to be received in a dapp

  //Triggers an amountChanged event for all the wallet connect clients who have subscribed to it
  //@param changedIDs Map<String, int> with the publicId (key) and number of $Qubic (int)
  void triggerAmountChangedEvent(Map<String, int> changedIDs) {
    if (!shouldTriggerEvent()) {
      return;
    }
    web3Wallet!
        .getActiveSessions()
        .forEach(((String session, SessionData sessionData) {
      if (sessionData.namespaces.entries.first.value.events
          .contains(WcEvents.amountChanged)) {
        List<dynamic> data = [];
        for (var id in changedIDs.entries) {
          dynamic item = {};
          item["publicId"] = id.key;
          item["amount"] = id.value;
          data.add(item);
        }

        web3Wallet!.emitSessionEvent(
            topic: sessionData.topic,
            chainId: Config.walletConnectChainId,
            event:
                SessionEventParams(name: WcEvents.amountChanged, data: data));
      }
    }));
  }

//Triggers an token amount change event for the wallet connect clients
//@param changedIDs Map<String, List<QubicAssetDto>> (key = publicId) , List ,containes changed token amounts
  void triggerTokenAmountChangedEvent(
      Map<String, List<QubicAssetDto>> changedIDs) {
    if (!shouldTriggerEvent()) {
      return;
    }

    web3Wallet!
        .getActiveSessions()
        .forEach(((String session, SessionData sessionData) {
      if (sessionData.namespaces.entries.first.value.events
          .contains(WcEvents.tokenAmountChanged)) {
        List<dynamic> data = [];
        for (var id in changedIDs.entries) {
          dynamic item = {};

          List<dynamic> tokens = [];
          tokens.addAll(
              id.value.map((e) => QubicAssetWC.fromQubicAssetDto(e)).toList());

          item["publicId"] = id.key;
          item["tokens"] = tokens;
          data.add(item);
        }

        web3Wallet!.emitSessionEvent(
            topic: sessionData.topic,
            chainId: Config.walletConnectChainId,
            event: SessionEventParams(
                name: WcEvents.tokenAmountChanged, data: data));
      }
    }));
  }

  //Triggers an accountsChanged event for all the wallet connect clients who have subscribed to it
  void triggerAccountsChangedEvent() {
    if (!shouldTriggerEvent()) {
      return;
    }
    web3Wallet!
        .getActiveSessions()
        .forEach(((String session, SessionData sessionData) {
      if (sessionData.namespaces.entries.first.value.events
          .contains(WcEvents.accountsChanged)) {
        List<dynamic> data = [];
        for (var id in appStore.currentQubicIDs) {
          if (id.watchOnly == false) {
            dynamic item = {};
            item["publicId"] = id.publicId;
            item["name"] = id.name;
            item["amount"] = id.amount ?? -1;
            data.add(item);
          }
        }

        web3Wallet!.emitSessionEvent(
            topic: sessionData.topic,
            chainId: Config.walletConnectChainId,
            event:
                SessionEventParams(name: WcEvents.accountsChanged, data: data));
      }
    }));
  }

  //tickChanged
  void triggerTickChangedEvent() {
    if (!shouldTriggerEvent()) {
      return;
    }
  }

  // Triggers a method result event for a specific topic (and with a specific nonce)
  void triggerMethodResultEvent(String topic, String? nonce, dynamic result) {
    if (!shouldTriggerEvent()) {
      return;
    }
    web3Wallet!.emitSessionEvent(
        topic: topic,
        chainId: Config.walletConnectChainId,
        event: SessionEventParams(
            name: WcEvents.methodResult,
            data: getSessionEventParamsResult(
                params: result, nonce: nonce, error: null)));
  }

  initialize() async {
    if (web3Wallet != null) {
      return;
    }

    web3Wallet = await Web3Wallet.createInstance(
        projectId: Config.walletConnectProjectId,
        metadata: const PairingMetadata(
          name: Config.walletConnectName,
          description: Config.walletConnectDescription,
          url: Config.walletConnectURL,
          icons: [...Config.walletConnectIcons],
          redirect: Redirect(
            native: Config.walletConnectRedirectNative,
            universal: Config.walletConnectRedirectUniversal,
          ),
        ));

    //Event bubbling
    web3Wallet!.onSessionConnect.subscribe((args) {
      onSessionConnect.add(args);
    });

    web3Wallet!.onSessionDelete.subscribe((SessionDelete? args) {
      onSessionDisconnect.add(args);
    });

    web3Wallet!.onSessionExpire.subscribe((SessionExpire? args) {
      onSessionExpire.add(args);
    });

    web3Wallet!.onProposalExpire.subscribe((SessionProposalEvent? args) {
      onProposalExpire.add(args);
    });

    web3Wallet!.onSessionProposal.subscribe((SessionProposalEvent? args) {
      onSessionProposal.add(args);
    });

    web3Wallet!.onProposalExpire.subscribe((SessionProposalEvent? args) {
      onSessionProposal.add(args);
    });

    web3Wallet!.core.relayClient.onRelayClientDisconnect.subscribe((args) {
      if (settingsStore.settings.walletConnectEnabled) {
        web3Wallet = null;
        initialize();
      }
    });

    //Event emitter registrations
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId, event: WcEvents.amountChanged);
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId,
        event: WcEvents.tokenAmountChanged);
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId, event: WcEvents.accountsChanged);
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId, event: WcEvents.methodResult);

    // -------------------------------------------------------- METHODS --------------------------------------------------------
    // requestAccounts (responds automatically to clients)
    web3Wallet!.registerRequestHandler(
        chainId: Config.walletConnectChainId,
        method: WcMethods.wRequestAccounts,
        handler: (topic, args) {
          List<dynamic> data = [];
          appStore.currentQubicIDs.forEach(((id) {
            if (id.watchOnly == false) {
              dynamic item = {};
              item["address"] = id.publicId;
              item["name"] = id.name;
              item["amount"] = id.amount ?? -1;
              data.add(item);
            }
          }));
          web3Wallet!.emitSessionEvent(
              topic: topic,
              chainId: Config.walletConnectChainId,
              event: SessionEventParams(
                  name: WcEvents.accountsChanged, data: data));
        });

    // sendQubic emits an onRequestSendQubic event if the request is valid
    // otherwise returns a validation error
    web3Wallet!.registerRequestHandler(
        chainId: Config.walletConnectChainId,
        method: WcMethods.wSendQubic,
        handler: (topic, args) {
          late RequestSendQubicEvent result;
          try {
            result = RequestSendQubicEvent.fromMap(
                args, topic, args["nonce"].toString());
            result.validateOrThrow();

            //Enhance the result with the pairing metadata
            if (web3Wallet!.getActiveSessions().containsKey(topic)) {
              result.setPairingMetadata(
                  web3Wallet!.getActiveSessions()[topic]!.peer.metadata);
              onRequestSendQubic.add(result);
            }
          } catch (e) {
            emitErrorSessionEvent(
                topic, e.toString(), args["nonce"].toString());
          }
        });

    web3Wallet!.registerRequestHandler(
        chainId: Config.walletConnectChainId,
        method: WcMethods.wSendAsset,
        handler: (name, args) {});

    // -------------------------------------------------------- END OF METHODS ---------------------------------------------------------
    web3Wallet!.registerAccount(
        accountAddress:
            "000000000000000000000000000000000000000000000000000000000000",
        chainId: Config.walletConnectChainId);

    appStore.currentQubicIDs.forEach(((id) {
      if (id.watchOnly == false) {
        web3Wallet!.registerAccount(
            accountAddress: id.publicId, chainId: Config.walletConnectChainId);
      }
    }));
  }

  /// Emits an error event to a specific topic
  emitErrorSessionEvent(String topic, String error, String? nonce) {
    web3Wallet!.emitSessionEvent(
        topic: topic,
        chainId: Config.walletConnectChainId,
        event: SessionEventParams(
            name: WcEvents.methodResult,
            data: getSessionEventParamsResult(
                params: {}, nonce: nonce, error: error)));
  }

  emitSuccessSessionEvent(String topic, String? nonce,
      {dynamic params = const {}}) {
    web3Wallet!.emitSessionEvent(
        topic: topic,
        chainId: Config.walletConnectChainId,
        event: SessionEventParams(
            name: WcEvents.methodResult,
            data: getSessionEventParamsResult(params: params, nonce: nonce)));
  }

  WalletConnectService();

  /// Pairs WC with a URL
  Future<PairingInfo> pair(Uri uri) async {
    pairingInfo = await web3Wallet!.pair(uri: uri);
    return pairingInfo!;
  }
}
