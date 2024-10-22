import 'dart:async';

import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
import 'package:qubic_wallet/models/wallet_connect/approve_sign_generic_result.dart';
import 'package:qubic_wallet/models/wallet_connect/approve_sign_transaction_result.dart';
import 'package:qubic_wallet/models/wallet_connect/approve_token_transfer_result.dart';
import 'package:qubic_wallet/models/wallet_connect/request_send_qubic_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_generic_event.dart';
import 'package:qubic_wallet/models/wallet_connect/request_sign_transaction_event.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

class WalletConnectService {
  final ApplicationStore appStore = getIt<ApplicationStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();
  bool isReady = false;

  PairingInfo? pairingInfo;

  ReownWalletKit? web3Wallet;

  //------------------------------------ HANDLERS ------------------------------------
  //A callback that is called when a request to send qubic is received
  Future<ApproveTokenTransferResult> Function(RequestSendQubicEvent event)?
      sendQubicHandler;

  //A callback that is called when a request to sign a generic message is received
  Future<ApproveSignGenericResult> Function(RequestSignGenericEvent event)?
      signGenericHandler;

  //A callback that is called when a request to sign a transaction is received
  Future<ApproveSignTransactionResult> Function(
      RequestSignTransactionEvent event)? signTransactionHandler;

  //------------------------------------ EVENTS ------------------------------------
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

  /// Event that is triggered when a session proposal event has an error
  StreamController<SessionProposalErrorEvent?> onSessionProposalError =
      StreamController<SessionProposalErrorEvent?>.broadcast();

  /// Sets the handler for the requestSendQubic event
  void setRequestSendQubicHandler(
      {required ApproveTokenTransferResult Function(RequestSendQubicEvent event)
          handler}) {}

  WalletConnectService();

  void disconnect() {
    web3Wallet!
        .getActiveSessions()
        .forEach(((String session, SessionData sessionData) {
      //web3Wallet!.sessions.delete(session);
      web3Wallet!.disconnectSession(
          reason: const ReownSignError(
              code: -1, message: "User forcefully disconnected"),
          topic: sessionData.topic);
    }));

    web3Wallet!.core.relayClient.disconnect();
  }

  /// Checks that walletconnect is initialized before trying to trigger an event
  bool shouldTriggerEvent() {
    if (web3Wallet == null) {
      return false;
    }
    if (web3Wallet!.getActiveSessions().isEmpty) {
      return false;
    }
    return true;
  }

  bool sessionPairingTopicAlreadyExists(String sessionPairingTopic) {
    if (web3Wallet!
        .getActiveSessions()
        .values
        .where((e) => e.pairingTopic == sessionPairingTopic)
        .isNotEmpty) return true;

    if (web3Wallet!.pairings.get(sessionPairingTopic) != null) return true;

    return false;
  }

  //---------------------------------- Triggers ----------------------------------

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

  initialize() async {
    if (web3Wallet != null) {
      return;
    }

    web3Wallet = await ReownWalletKit.createInstance(
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

    web3Wallet!.onSessionProposalError
        .subscribe((SessionProposalErrorEvent? args) {
      onSessionProposalError.add(args);
    });

    web3Wallet!.core.relayClient.onRelayClientDisconnect.subscribe((args) {
      web3Wallet!.onSessionConnect.unsubscribeAll();
      web3Wallet!.onSessionDelete.unsubscribeAll();
      web3Wallet!.onSessionExpire.unsubscribeAll();
      web3Wallet!.onProposalExpire.unsubscribeAll();
      web3Wallet!.onSessionProposal.unsubscribeAll();
      web3Wallet!.onSessionProposalError.unsubscribeAll();
      web3Wallet!.onSessionAuthRequest.unsubscribeAll();
      web3Wallet!.onSessionPing.unsubscribeAll();
      web3Wallet!.onSessionRequest.unsubscribeAll();
      web3Wallet!.core.relayClient.onRelayClientDisconnect.unsubscribeAll();

      web3Wallet = null;
      initialize();
    });

    //Event emitter registrations
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId, event: WcEvents.amountChanged);
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId,
        event: WcEvents.tokenAmountChanged);
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId, event: WcEvents.accountsChanged);

    // -------------------------------------------------------- METHODS --------------------------------------------------------
    // requestAccounts (responds automatically to clients)
    web3Wallet!.registerRequestHandler(
        chainId: Config.walletConnectChainId,
        method: WcMethods.wRequestAccounts,
        handler: (topic, args) async {
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
          return data;
        });

    // qubic_sendQubic uses the sendQubicHandler callback if the request is valid
    // otherwise returns a validation error
    web3Wallet!.registerRequestHandler(
        chainId: Config.walletConnectChainId,
        method: WcMethods.wSendQubic,
        handler: (topic, args) async {
          final sessionRequest = web3Wallet!.pendingRequests.getAll().first;
          late RequestSendQubicEvent event;

          if (sendQubicHandler == null) {
            throw "sendQubicHandler is not set";
          }
          try {
            event =
                RequestSendQubicEvent.fromMap(args, topic, sessionRequest.id);
            event.validateOrThrow();

            if (web3Wallet!.getActiveSessions().containsKey(topic)) {
              event.setPairingMetadata(
                  web3Wallet!.getActiveSessions()[topic]!.peer.metadata);
            } else {
              throw "Session not found";
            }
            return await sendQubicHandler!(event);
          } catch (e) {
            if (e is JsonRpcError) {
              rethrow;
            }
            throw JsonRpcError(code: -2, message: e.toString());
          }
        });

    // qubic_sign
    web3Wallet!.registerRequestHandler(
        chainId: Config.walletConnectChainId,
        method: WcMethods.wSign,
        handler: (topic, args) async {
          final sessionRequest = web3Wallet!.pendingRequests.getAll().first;
          late RequestSignGenericEvent event;

          if (signGenericHandler == null) {
            throw "signGenericHandler is not set";
          }
          try {
            event =
                RequestSignGenericEvent.fromMap(args, topic, sessionRequest.id);
            event.validateOrThrow();

            if (web3Wallet!.getActiveSessions().containsKey(topic)) {
              event.setPairingMetadata(
                  web3Wallet!.getActiveSessions()[topic]!.peer.metadata);
            } else {
              throw "Session not found";
            }
            return await signGenericHandler!(event);
          } catch (e) {
            if (e is JsonRpcError) {
              rethrow;
            }
            throw JsonRpcError(code: -2, message: e.toString());
          }
        });

    // qubic_signTransaction
    web3Wallet!.registerRequestHandler(
        chainId: Config.walletConnectChainId,
        method: WcMethods.wSignTransaction,
        handler: (topic, args) async {
          final sessionRequest = web3Wallet!.pendingRequests.getAll().first;
          late RequestSignTransactionEvent event;

          if (signTransactionHandler == null) {
            throw "signTransactionHandler is not set";
          }
          try {
            event = RequestSignTransactionEvent.fromMap(
                args, topic, sessionRequest.id);
            event.validateOrThrow();

            if (web3Wallet!.getActiveSessions().containsKey(topic)) {
              event.setPairingMetadata(
                  web3Wallet!.getActiveSessions()[topic]!.peer.metadata);
            } else {
              throw "Session not found";
            }
            return await signTransactionHandler!(event);
          } catch (e) {
            if (e is JsonRpcError) {
              rethrow;
            }
            throw JsonRpcError(code: -2, message: e.toString());
          }
        });

    web3Wallet!.registerRequestHandler(
        chainId: Config.walletConnectChainId,
        method: WcMethods.wSendAsset,
        handler: (name, args) {});

    // -------------------------------------------------------- END OF METHODS ---------------------------------------------------------
    web3Wallet!.registerAccount(
        accountAddress:
            "000000000000000000000000000000000000000000000000000000000000", //Hardcoded in order to use wallet_ methods
        chainId: Config.walletConnectChainId);

    appStore.currentQubicIDs.forEach(((id) {
      if (id.watchOnly == false) {
        web3Wallet!.registerAccount(
            accountAddress: id.publicId, chainId: Config.walletConnectChainId);
      }
    }));
  }

  /// Pairs WC with a URL
  Future<PairingInfo> pair(Uri uri) async {
    try {
      pairingInfo = await web3Wallet!.pair(uri: uri);
      return pairingInfo!;
    } catch (e) {
      rethrow;
    }
  }
}
