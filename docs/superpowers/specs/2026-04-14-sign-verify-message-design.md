# Sign / Verify Message — Design Spec

## Purpose

Add a screen to the Flutter wallet-app that lets users cryptographically sign a plaintext message with a Qubic account and verify signatures produced by any Qubic wallet. The output format must be cross-compatible with the Angular wallet (`wallet/`) which already ships this feature on `feat/sign-verify-message`.

## Cross-Compatibility Contract

Both wallets produce and accept this JSON:

```json
{
  "identity": "AABB...ZZ",
  "message": "hello world",
  "signature": "AABB...PP"
}
```

- `identity`: 60 uppercase A-Z characters (Qubic public ID)
- `message`: the original plaintext (UTF-8)
- `signature`: 130 characters using the shifted-hex alphabet (A-P), encoding 65 bytes: 64-byte Schnorrq signature + 1-byte K12 checksum

### Shifted-Hex Encoding (A-P Alphabet)

Each byte is encoded as two characters where `A` = 0x0, `B` = 0x1, ..., `P` = 0xF.

```
encode(byte) -> char(A + highNibble), char(A + lowNibble)
decode(c1, c2) -> (c1 - A) << 4 | (c2 - A)
```

### K12 Checksum

The 65th byte is a 1-byte K12 hash of the 64-byte signature. On verify, recompute K12 of the first 64 bytes and compare to byte 65 before checking the Schnorrq signature.

## Architecture

### New Files

| File | Purpose |
|------|---------|
| `lib/pages/main/wallet_contents/sign_verify_message.dart` | Main screen widget (StatefulWidget) |
| `lib/helpers/signature_format_helper.dart` | Shifted-hex encode/decode, K12 checksum, format conversion |

### Modified Files

| File | Change |
|------|--------|
| `lib/components/account_list_item.dart` | Add `signMessage` to `CardItem` enum, menu item, and handler |
| `lib/pages/main/tab_settings/tab_settings.dart` | Add "Sign / Verify Message" list tile |
| `lib/l10n/app_en.arb` | New i18n strings |

## Entry Points

### 1. Account Card Menu

In `account_list_item.dart`, add a new `CardItem.signMessage` entry to the popup menu, visible only for non-watch-only accounts (same guard as `CardItem.reveal`). On tap, navigate to `SignVerifyMessageScreen` with the account's `publicId` passed as a parameter.

### 2. Settings Tab

In `tab_settings.dart`, add a list tile between the existing items. On tap, navigate to `SignVerifyMessageScreen` with no pre-selected account.

## Screen: SignVerifyMessageScreen

### Layout

- `Scaffold` with transparent `AppBar` and centered title
- Mode toggle at the top switching between **Sign** and **Verify** (use `ToggleButtons` or segmented control matching the app's visual style)
- Body content changes based on selected mode

### Sign Mode

**Widgets:**
1. Account selector — tappable field that opens a `DraggableScrollableSheet` bottom sheet (same pattern as `send.dart` `showPickerBottomSheet`). Shows only non-watch-only accounts via `appStore.nonWatchOnlyAccounts`. Pre-selects account if passed via constructor.
2. Message input — `TextFormField` with multiline, 3 rows
3. "Sign Message" button — primary, disabled when form is incomplete or signing is in progress
4. Output area (visible after signing) — read-only `TextFormField` showing the JSON, with a `CopyButton`

**Flow:**
1. Validate form (account selected, message non-empty)
2. Call `reAuthDialog(context)` — if user cancels, abort
3. Get seed: `appStore.getSeedByPublicId(publicId)`
4. Sign: `qubicCmd.signUTF8(seed, message)` returning `QubicSignResult`
5. Convert `QubicSignResult.signature` to Angular-compatible format via `SignatureFormatHelper`:
   - Decode the hex signature string to raw bytes
   - Compute 1-byte K12 checksum of the 64-byte signature
   - Append checksum byte (total 65 bytes)
   - Encode as shifted-hex (130 chars A-P)
6. Build output JSON: `{ "identity": publicId, "message": message, "signature": shiftedHex }`
7. Display in read-only field with copy button
8. Clear form value changes reset the output

**Error handling:** Wrap in try/catch, show error via `GlobalSnackBar`. Loading state disables the button and shows a spinner.

### Verify Mode

**Widgets:**
1. Input field — `TextFormField` with multiline, 6 rows, placeholder text explaining expected JSON format
2. "Verify Signature" button — primary, disabled when input is empty
3. Result banner — green for valid, red for invalid, styled consistently with the app's success/error colors

**Flow:**
1. Parse input as JSON — on failure, show "Invalid JSON format" error
2. Extract `identity`, `message`, `signature` — if any missing, show parse error
3. Validate identity: regex `/^[A-Z]{60}$/` then `qubicCmd.verifyIdentity(identity)`
4. Validate signature: regex `/^[A-Pa-p]{130}$/`
5. Decode shifted-hex to 65 bytes via `SignatureFormatHelper`
6. Verify K12 checksum: compute K12 of first 64 bytes, compare to byte 65
7. Verify Schnorrq signature (see "Verify Crypto Strategy" below)
8. Display result: "Valid Signature" (green) or "Invalid Signature" (red)

**Error handling:** Each validation step shows a specific error message. Changing the input clears the previous result.

### Verify Crypto Strategy

The existing `qubicCmd` has `signUTF8` but no `verifySignature` method. During implementation, check the qubic helper binary/JS for a verify command:

- **If available:** Add a `verifySignature` constant to `QubicJSFunctions` and a corresponding method to `qubicCmd`/`qubicCmdUtils`/`qubicJs`, following the same `Process.run` / `runFunction` pattern as `signUTF8`. Pass the identity (public key), message, and raw signature bytes. Return a boolean.
- **If not available:** Implement verification using `qubicCmd.publicKeyStringToBytes(identity)` to get the public key bytes, then use a Dart-native Schnorrq verify via FFI or a Dart crypto package. If no suitable Dart-side Schnorrq verify exists, ship the verify tab with a "Verification not yet supported on this platform" message and file an issue to add verify support to the helper binary.

## SignatureFormatHelper

A pure utility class in `lib/helpers/signature_format_helper.dart`.

**K12 dependency:** The K12 hash function is needed for checksum computation. During implementation, check if it's available via the qubic helper binary (call a hash command), an existing Dart package, or the qubic-lib FFI bindings. If unavailable in Dart, the K12 checksum step can be delegated to the helper binary as part of a `formatSignature` command.

**QubicSignResult.signature format:** The `signUTF8` method returns `QubicSignResult.signature` as a string. During implementation, inspect the actual value (likely hex-encoded 64 bytes) and confirm the byte-level mapping to the Angular wallet's raw Schnorrq output before building the adapter.

```dart
class SignatureFormatHelper {
  /// Encode bytes to shifted-hex (A-P alphabet)
  static String encodeShiftedHex(Uint8List bytes)

  /// Decode shifted-hex string to bytes
  static Uint8List decodeShiftedHex(String encoded)

  /// Build the cross-compatible JSON output from sign result
  static String buildSignedMessageJson({
    required String identity,
    required String message,
    required String rawSignatureHex,
  })
  // Decodes rawSignatureHex to bytes, computes K12 checksum,
  // appends checksum, encodes as shifted-hex, returns JSON string

  /// Parse and validate a signed message JSON string
  static SignedMessageData? parseSignedMessage(String jsonString)
  // Returns null on invalid JSON/missing fields

  /// Validate shifted-hex signature format and checksum
  static bool validateSignatureFormat(String signature)
  // Checks regex, length, K12 checksum
}

class SignedMessageData {
  final String identity;
  final String message;
  final String signature;
}
```

## Localization Keys

Add to `app_en.arb`:

```
signVerifyMessageTitle: "Sign / Verify Message"
signVerifyMessageTabSign: "Sign"
signVerifyMessageTabVerify: "Verify"
signVerifyMessageSelectAccount: "Select account"
signVerifyMessageEnterMessage: "Enter message to sign"
signVerifyMessageMessageLabel: "Message"
signVerifyMessageSignButton: "Sign Message"
signVerifyMessageVerifyButton: "Verify Signature"
signVerifyMessageOutputLabel: "Signed output (JSON)"
signVerifyMessageVerifyInputLabel: "Signed message (JSON)"
signVerifyMessageVerifyInputPlaceholder: "Paste JSON with identity, message, and signature fields"
signVerifyMessageResultValid: "Valid Signature"
signVerifyMessageResultInvalid: "Invalid Signature"
signVerifyMessageErrorParse: "Invalid JSON format. Expected: { identity, message, signature }"
signVerifyMessageErrorIdentity: "Invalid identity format. Expected 60 uppercase A-Z characters."
signVerifyMessageErrorSignature: "Invalid signature format."
signVerifyMessageErrorChecksum: "Signature checksum verification failed."
signVerifyMessageErrorSign: "Failed to sign message. Please try again."
signVerifyMessageSettingsLabel: "Sign / Verify Message"
signVerifyMessageAccountMenu: "Sign a message"
```

## Authentication

- **Sign:** Requires `reAuthDialog(context)` before accessing the seed. Same pattern as Reveal Seed and Send.
- **Verify:** No authentication required. Verification is a public operation using only the public key.

## State Management

The screen is a `StatefulWidget` with local state only (no MobX store needed):
- `selectedAccountId` (String?)
- `messageText` (String)
- `signOutput` (String)
- `isSigning` (bool)
- `verifyInput` (String)
- `verifyResult` (enum: none, valid, invalid)
- `verifyError` (String)
- `isSignMode` (bool) — toggles between sign/verify

Form value changes clear the output/result.
