import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:qubic_wallet/config.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/dtos/qubic_asset_dto.dart';
import 'package:qubic_wallet/models/wallet_connect.dart';
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

  /// Event that is triggered when a session proposal event is expired
  StreamController<SessionProposalEvent?> onProposalExpire =
      StreamController<SessionProposalEvent?>.broadcast();

  StreamController<RequestAccountsEvent> onRequestAccounts =
      StreamController<RequestAccountsEvent>.broadcast();
  StreamController<void> onRequestSendQubic =
      StreamController<SessionConnect?>.broadcast();
  StreamController<void> onRequestSendToken =
      StreamController<SessionConnect?>.broadcast();

  void disconnect() {
    web3Wallet!
        .getActiveSessions()
        .forEach(((String session, SessionData sessionData) {
      //web3Wallet!.sessions.delete(session);
      web3Wallet!.disconnectSession(
          reason: WalletConnectError(
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
          .contains(wcEvents.amountChanged)) {
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
                SessionEventParams(name: wcEvents.amountChanged, data: data));
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
          .contains(wcEvents.tokenAmountChanged)) {
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
                name: wcEvents.tokenAmountChanged, data: data));
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
          .contains(wcEvents.accountsChanged)) {
        List<dynamic> data = [];
        for (var id in appStore.currentQubicIDs) {
          dynamic item = {};
          item["publicId"] = id.publicId;
          item["name"] = id.name;
          item["amount"] = id.amount ?? -1;
          data.add(item);
        }

        web3Wallet!.emitSessionEvent(
            topic: sessionData.topic,
            chainId: Config.walletConnectChainId,
            event:
                SessionEventParams(name: wcEvents.accountsChanged, data: data));
      }
    }));
  }

  //tickChanged
  void triggerTickChangedEvent() {
    if (!shouldTriggerEvent()) {
      return;
    }
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
        web3Wallet!.core.relayClient.connect();
      }
    });

    //Event emitter registrations
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId, event: wcEvents.amountChanged);
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId,
        event: wcEvents.tokenAmountChanged);
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId, event: wcEvents.accountsChanged);
    web3Wallet!.registerEventEmitter(
        chainId: Config.walletConnectChainId, event: wcEvents.tickChanged);

    web3Wallet!.registerRequestHandler(
        chainId: Config.walletConnectChainId,
        method: wcMethods.wRequestAccounts,
        handler: (topic, args) {
          onRequestAccounts.add(RequestAccountsEvent(topic: topic));
          List<dynamic> data = [];
          appStore.currentQubicIDs.forEach(((id) {
            dynamic item = {};
            item["address"] = id.publicId;
            item["name"] = id.name;
            item["amount"] = id.amount ?? -1;
            data.add(item);
          }));

          web3Wallet!.emitSessionEvent(
              topic: topic,
              chainId: Config.walletConnectChainId,
              event: SessionEventParams(name: "accountsChanged", data: data));
        });

    web3Wallet!.registerRequestHandler(
        chainId: Config.walletConnectChainId,
        method: wcMethods.wSendQubic,
        handler: (name, args) {});

    web3Wallet!.registerRequestHandler(
        chainId: Config.walletConnectChainId,
        method: wcMethods.wSendAsset,
        handler: (name, args) {});

    web3Wallet!.registerAccount(
        accountAddress:
            "000000000000000000000000000000000000000000000000000000000000",
        chainId: Config.walletConnectChainId);

    appStore.currentQubicIDs.forEach(((id) {
      web3Wallet!.registerAccount(
          accountAddress: id.publicId, chainId: Config.walletConnectChainId);
    }));
  }

  WalletConnectService() {}

  /// Pairs WC with a URL
  Future<PairingInfo> pair(Uri uri) async {
    pairingInfo = await web3Wallet!.pair(uri: uri);
    return pairingInfo!;
  }
}
