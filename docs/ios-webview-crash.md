# iOS WebView Callback Crash

## Summary

Native crash on iOS during a WalletConnect transaction approval. Reported on **iPhone 7 Plus running iOS 15.8.7**. Could not reproduce locally — but see "Affected scope" below: this is a **known upstream bug** that only manifests in release/TestFlight builds, not in Xcode-attached debug runs.

## Stack trace (top frames)

```
0  0x0
1  WebViewChannelDelegate.handle(_:result:)
2  implicit closure #2 in implicit closure #1 in ChannelDelegate.init(channel:)
3  thunk for @escaping @callee_guaranteed (FlutterMethodCall, ...)
4  __45-[FlutterMethodChannel setMethodCallHandler:]_block_invoke
5  invocation function for block in flutter::PlatformMessageHandlerIos::HandlePlatformMessage
```

Frame 0 at `0x0` indicates a null-pointer dereference inside `flutter_inappwebview_ios` (currently 1.1.2, parent `flutter_inappwebview ^6.1.5`).

## Reproduction steps

1. dApp running on desktop sends a WalletConnect request to the wallet
2. Wallet shows the re-authentication dialog
3. User enters password and approves
4. App crashes during/after signing

## Root cause

The wallet uses a hidden `HeadlessInAppWebView` (`lib/resources/qubic_js.dart`) to run the qubic-helper JS for crypto operations such as transaction signing.

Suspected sequence:

1. `controller.callAsyncJavaScript(...)` is invoked to sign the transaction.
2. iOS pauses or reclaims the WebView while it is in the background or under memory pressure (very likely on iPhone 7 Plus, which has 3 GB RAM).
3. When the JS result eventually fires, the native `WebViewChannelDelegate.handle(_:result:)` tries to deliver it through a `FlutterResult` callback whose context has been deallocated → null deref.

The crash is at the native (Swift) layer. Dart-side `try/catch` cannot intercept it.

## Affected scope

This is **not just our reporter's old phone**. The upstream `flutter_inappwebview` issue [#2619](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2619) (open since May 2025) collects user reports with the same `EXC_BAD_ACCESS` at `0x0` signature in `callAsyncJavaScript` across:

- iOS 15.x (our case)
- iOS 17.5, 17.6, 17.6.1
- iOS 18.1, 18.3, 18.4, 18.5
- macOS Intel

**Crucial detail from the upstream thread:** the crash only happens in **release / TestFlight** builds, not when the app is launched from Xcode in debug mode. That is why we could not reproduce locally.

We've likely had more affected users than the one report suggests — the rest may have just retried, blamed the network, or churned silently.

## What we already do

- Try/catch around `controller.callAsyncJavaScript` in `lib/resources/qubic_js.dart:125-132`
- App lifecycle handler calls `qubicCmd.reinitialize()` on resume (`lib/main.dart:80-86`)
- `reInitialize()` short-circuits if the controller is still valid (`lib/resources/qubic_js.dart:62-69`)

None of these prevent an iOS-initiated kill of the WebView during an in-flight call.

## Options to solve

### 1. Replace `callAsyncJavaScript` with `evaluateJavascript` (recommended)
This is the **confirmed workaround from the upstream issue thread**. Multiple users have validated that switching avoids the crash entirely. The trade-off is that we have to write the async JS function manually instead of letting the plugin wrap it for us.

The change is local to `lib/resources/qubic_js.dart`. The `runFunction` helper is the only caller of `callAsyncJavaScript`. Replace it with an `evaluateJavascript` call that wraps the existing JS in an async IIFE and resolves a JSON string result.

- **Effort:** small (~half-day to convert + test all signing paths)
- **Risk:** low — single-file change, all crypto paths funnel through `runFunction`. Must regression-test signing, asset transfers, vault create/import on real iOS devices in **release mode** (the crash doesn't appear in debug).
- **Coverage:** **fixes the reported crash directly** for all affected iOS versions. Same workaround used in production by other apps facing this issue.

### 2. Upgrade `flutter_inappwebview` to 6.2.0-beta and verify
Beta may have addressed the underlying issue. Worth checking before committing to Option 1.

- **Effort:** small (dependency bump + regression test on a real iPhone in release/TestFlight build)
- **Risk:** medium — beta in a wallet app
- **Coverage:** unconfirmed. As of late 2025 the upstream issue is still open, suggesting the fix is not in stable. Need to verify beta status before relying on this.

### 3. Replace WebView crypto with a native implementation
Use Dart-native or platform-channel-based crypto for signing, bypassing the WebView entirely. WebView would remain only for the in-app dApp browser, not for crypto operations.

- **Effort:** large (weeks); requires a vetted Dart port of the qubic-helper crypto (SchnorrQ signatures, etc.)
- **Risk:** high — touches the most security-sensitive code, must be reviewed and tested exhaustively
- **Coverage:** **eliminates the entire class of bug**. WebView lifecycle stops mattering for signing.

### 4. Patch `flutter_inappwebview` directly
Fork the plugin and add a null-check guard inside `WebViewChannelDelegate.handle(_:result:)`. Less attractive than Option 1 because it requires maintaining a fork — but Option 1 is essentially the same fix at a layer we already control.

- **Effort:** medium
- **Risk:** medium — adds a forked dependency to maintain
- **Coverage:** complete for this crash

### 5. Defensive Dart-side hardening (complementary)
Track in-flight operations in `QubicJs`. Refuse our own `reInitialize` while operations are pending.

- **Effort:** small (~1 day)
- **Risk:** low
- **Coverage:** does not address the upstream bug. Worth doing alongside Option 1 or 3 as defense-in-depth, not standalone.

## Recommendation

Ship **Option 1** as the hotfix. It's the documented workaround from the plugin maintainers' own issue thread, scoped to a single file we own, and confirmed by other apps in production.

Plan **Option 3** for a future release as the durable fix — it removes our dependency on `flutter_inappwebview` for the signing-critical path entirely.
