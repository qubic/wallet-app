# QUTIL on-chain balances via a generic contract-query bridge

**Date:** 2026-06-01
**Status:** Approved (pending spec review)
**Repos touched:** `ts-library-wrapper` (JS bridge), `wallet-app` (Flutter mobile)

## Problem

The mobile wallet fetches QU balances from the off-chain RPC endpoint
`GET /live/v1/balances/{id}` (`QubicLiveApi.getQubicBalances`, one HTTP call per
address). This depends on the archiver/QLI indexer rather than reading on-chain
state directly. The web wallet (PR qubic/wallet#261, by `alez04`) already migrated
to the on-chain **QUTIL `GetBalances16`** smart-contract procedure via
`@qubic.org/contracts`, dropping the QLI dependency and batching up to 16
identities per request.

This change brings the **mobile** wallet to parity, and does so through a
**generic** contract-query bridge so future on-chain reads (QEarn, QX, Quottery,
…) need no new native plumbing — only a new registry entry.

## Decisions (locked during brainstorming)

1. **Network location: in Dart (thin bridge).** The JS wrapper only does pure
   encode/decode using the library; the actual `querySmartContract` HTTP call
   stays in Dart via the existing `dio` + `NetworkStore` (mainnet/testnet) +
   `ErrorHandler`. Rationale: avoids the CORS/`file://`-origin risk of calling
   `fetch` from the headless WebView, preserves network switching and centralized
   error handling, keeps the wrapper's "every function is pure compute" convention,
   and is independently unit-testable.
2. **Bridge shape: generic pair.** `buildContractInput(functionName, argsJson)` and
   `decodeContractOutput(functionName, responseB64)` dispatch on `functionName`
   through a small registry. Only `qUtilGetBalances16` is registered now.
3. **Version bump: minor → `3_2_0`** (new capability + new dependency).
4. **Old endpoint: fully replaced, on every platform.** The mobile UI reads only
   `balance` and `validForTick` from `CurrentBalanceDto` (confirmed: the extra
   fields `incomingAmount`/`outgoingAmount`/transfer counts+ticks are referenced
   nowhere outside the DTO). `validForTick` is sourced from the existing tick poller.
5. **Full platform parity, including the desktop CLI.** The bridge is reached
   through the `QubicCmd` service, which routes to `QubicJs` (WebView: iOS,
   Android, Windows, macOS) or `QubicCmdUtils` (the `pkg` CLI executable: Linux).
   The CLI executables are therefore **rebuilt** so Linux also queries QUTIL. This
   pulls the `@qubic.org/*` (ESM) packages into the wrapper's `pkg`/`node16` build
   path, the wrapper's Jest tests, a new GitHub release (`v3.2.0`), and the
   `Config.qubicHelper` filename/downloadPath/checksum entries.

## Library facts (verified against `@qubic.org/contracts@0.2.6`)

- `Q_UTIL_CONTRACT_INDEX = 4`
- `Q_UTIL_GET_BALANCES16_INPUT_TYPE = 9`
- `Q_UTIL_GET_BALANCES16_INPUT_SIZE = 512` (16 × 32-byte public keys, zero-padded)
- `buildQUtilGetBalances16Input(input: { publicKeys: string[] }, identityToPublicKey): Uint8Array`
- `decodeQUtilGetBalances16Output(data: Uint8Array): { balances: bigint[] }` (16 × sint64)
- `identityToPublicKey` is exported from `@qubic.org/crypto`.
- `qutil.js` build/decode import only `buildPayload`/`decodePayload` from
  `@qubic.org/registry` — **no `@qubic.org/rpc` dependency** on the thin path.
- RPC `POST /live/v1/querySmartContract`:
  - request `{ contractIndex, inputType, inputSize, requestData (base64) }`
  - response `{ responseData (base64) }`

## Data flow

```
timed_controller._fetchAndProcessBalances(ids)
  → QubicLiveApi.getQubicBalances(ids, currentTick)        // rewritten
     batch ids into groups of ≤16, for each batch:
       ① QubicCmd.buildContractInput("qUtilGetBalances16", {publicKeys: batch})
            → { contractIndex:4, inputType:9, inputSize:512, requestData:<b64> }   [QubicJs OR QubicCmdUtils → library]
       ② dio.post /live/v1/querySmartContract {…} → { responseData:<b64> }         [Dart / existing infra]
       ③ QubicCmd.decodeContractOutput("qUtilGetBalances16", responseData)
            → { balances: ["123", …] }   (bigint serialized as string)             [QubicJs OR QubicCmdUtils → library]
     map balances[i] ↔ batch[i] → CurrentBalanceDto(balance, validForTick = currentTick)
  → appStore.setAmounts(balances)                          // unchanged
```

`QubicCmd` is reached lazily via `getIt<QubicCmd>()` inside `getQubicBalances`
(matches the codebase's pervasive get_it usage; avoids a di.dart registration-order
change since `QubicLiveApi` is registered before `QubicCmd`). Steps ①/③ run on
whichever backend `QubicCmd` selects for the platform. No raw bytes are handled in
Dart — it only forwards base64 strings and reads JSON.

## Component changes

### A. `ts-library-wrapper` (JS)

- **`package.json` deps:** add `@qubic.org/contracts@0.2.6`, `@qubic.org/crypto@0.2.6`
  (`@qubic.org/registry` comes transitively). Match the web wallet's pinned versions.
- **`functions/buildContractInput.ts`** — new, follows the `addFunction(func)` /
  `registerFunction(...).addField(...)` pattern:
  - Signature: `(functionName: string, argsJson: string)`.
  - Looks up `functionName` in the registry; parses `argsJson`; calls the entry's
    `build(args)` → `Uint8Array`; returns
    `JSON.stringify({ contractIndex, inputType, inputSize, requestData: base64(bytes) })`.
  - Unknown `functionName` / parse failure → `{ status:"error", error }`.
- **`functions/decodeContractOutput.ts`** — new:
  - Signature: `(functionName: string, responseB64: string)`.
  - Base64-decodes to `Uint8Array`; calls the entry's `decode(bytes)`; returns
    `JSON.stringify(result, bigintReplacer)` (`bigint → string`, like
    `parseTransferSendManyPayload`).
- **Registry** (shared module imported by both functions):
  ```ts
  import {
    Q_UTIL_CONTRACT_INDEX, Q_UTIL_GET_BALANCES16_INPUT_TYPE,
    Q_UTIL_GET_BALANCES16_INPUT_SIZE,
    buildQUtilGetBalances16Input, decodeQUtilGetBalances16Output,
  } from "@qubic.org/contracts";
  import { identityToPublicKey } from "@qubic.org/crypto";

  export const CONTRACT_REGISTRY = {
    qUtilGetBalances16: {
      contractIndex: Q_UTIL_CONTRACT_INDEX,        // 4
      inputType: Q_UTIL_GET_BALANCES16_INPUT_TYPE, // 9
      inputSize: Q_UTIL_GET_BALANCES16_INPUT_SIZE, // 512
      build: (a: { publicKeys: string[] }) =>
        buildQUtilGetBalances16Input({ publicKeys: a.publicKeys }, identityToPublicKey),
      decode: (b: Uint8Array) => decodeQUtilGetBalances16Output(b),
    },
  } as const;
  ```
- **`functions/index.ts`:** import + register both new functions in `addFunctions`.

### B. `wallet-app` (Flutter)

- **`lib/models/qubic_js.dart` (`QubicJSFunctions`):** add
  `buildContractInput = "buildContractInput"` and
  `decodeContractOutput = "decodeContractOutput"`.
- **`lib/resources/qubic_js.dart` (`QubicJs`)** and
  **`lib/resources/qubic_cmd_utils.dart` (`QubicCmdUtils`)**: each gets the two new
  functions, mirroring their existing per-function methods (QubicJs via
  `runFunction`/`runBrowser`; QubicCmdUtils via `Process.run(scriptPath, [fn, ...])`
  + `QubicCmdResponse`/`jsonDecode`). Both call the same wrapper function names, so
  one wrapper registration serves both backends:
  - `buildContractInput(String functionName, String argsJson)` → JSON
    `{contractIndex, inputType, inputSize, requestData}`.
  - `decodeContractOutput(String functionName, String responseB64)` → JSON
    `{balances:[...]}` (or the generic decoded struct).
- **`lib/resources/qubic_cmd.dart` (`QubicCmd`):** two routing methods
  (`buildContractInput`, `decodeContractOutput`) that dispatch to `qubicJs` when
  `useJs`, else `qubicCmdUtils` — exactly like `createTransaction` etc.
- **`lib/resources/apis/live/qubic_live_api.dart`:**
  - New `querySmartContract({required int contractIndex, required int inputType, required int inputSize, required String requestData})`
    → `dio.post('${rpcUrl}${Config.querySmartContract}', data: {...})`,
    `ErrorHandler.handleError` on failure, returns `response.data["responseData"]`.
  - Rewrite `getQubicBalances(List<String> ids, int currentTick)`: obtain
    `final cmd = getIt<QubicCmd>();`, chunk ids into ≤16, `Future.wait` over batches
    running ①(`cmd.buildContractInput`)→②(`querySmartContract`)→③(`cmd.decodeContractOutput`),
    assemble `List<CurrentBalanceDto>` (`balance` from decoded `balances[i]` via
    `BigInt.parse(...).toInt()`, `validForTick = currentTick`, unused fields default
    to `0`/`""`).
- **`lib/config.dart`:**
  - Add `static const querySmartContract = "$liveApiPrefix/querySmartContract";`
  - Remove `addressQubicBalance`.
  - Bump `qubicJSAssetPath` → `"assets/qubic_js/qubic-helper-html-3_2_0.html"`.
- **`lib/timed_controller.dart`:** pass the already-fetched current tick into
  `getQubicBalances`. (`_getNetworkBalancesAndAssets` / `_fetchAndProcessBalances`
  already run alongside the tick fetch.)
- **`CurrentBalanceDto`:** unchanged for now; only `balance` + `validForTick`
  populated. Trimming the dead fields is optional follow-up cleanup, deliberately
  out of scope to keep the change tight.

### C. Build, asset & CLI wiring

ESM handling — `@qubic.org/*` ships ESM (`"type":"module"`) and the wrapper's
`tsconfig` emits CommonJS (`module: "CommonJS"`), so naive `tsc`+`pkg`(node16) will
`require()` an ESM package and fail. Two toolchain touch-points:
- **Parcel (HTML):** handles ESM natively — low risk.
- **Jest (tests):** ts-jest compiles tests to CJS and will choke importing the ESM
  deps. Fix in `jest.config.js`: keep ts-jest for `.ts`, add `babel-jest` for `.js`
  with `transformIgnorePatterns: ['/node_modules/(?!@qubic\\.org)']` and a
  `@babel/preset-env` config (add `@babel/preset-env` devDep; `@babel/preset-typescript`
  is already present).
- **pkg (CLI):** bundle to a single CJS file with **esbuild** before `pkg`
  (`esbuild index.ts --bundle --platform=node --format=cjs --outfile=dist/index.js`)
  so the ESM deps are inlined; then `pkg dist/index.js`. Add `esbuild` devDep and a
  `build-cli-bundle` script; point `build-win/linux/mac` at the bundled output.

Steps:
1. `ts-library-wrapper`: `npm install` the new deps; verify Jest import works
   (ESM config above); build the HTML via Parcel.
2. Emit/rename to `qubic-helper-html-3_2_0.html`; copy into
   `wallet-app/assets/qubic_js/`; delete `qubic-helper-html-3_1_3.html`; bump
   `Config.qubicJSAssetPath`.
3. Build the three CLIs (`npm run build-all` after the esbuild change); smoke-test
   each (`./qubic-helper-… buildContractInput qUtilGetBalances16 '{"publicKeys":["…"]}'`);
   compute md5 checksums.
4. **Release (external/team action):** publish the three exes to a
   `qubic/ts-library-wrapper` GitHub release `v3.2.0` (the download URLs in
   `Config.qubicHelper` point at `releases/download/v{ver}/qubic-helper-…`). This
   needs repo release permissions and cannot be done by an automated executor.
5. Update `Config.qubicHelper` (`win64`/`linux64`/`macOs64`): `filename` →
   `…-3_2_0…`, `downloadPath` → `…/v3.2.0/…`, `checksum` → the new md5s.

## Error handling

- **JS:** unknown `functionName`, malformed `argsJson`, or any library throw →
  `{ status:"error", error }` (existing convention; surfaced to Dart as
  `result.error`).
- **Dart:** bridge `null`/`error` → `AppException`; HTTP failures →
  `ErrorHandler.handleError` (unchanged). A failed batch propagates like today's
  `getQubicBalances` failure.

## Testing

- **Wrapper (Jest, `tests/`):** `buildContractInput`/`decodeContractOutput` with a
  known identity vector — assert the 512-byte input (base64) for a fixed set of IDs
  and a sample `decode` round-trip.
- **Manual (mobile):** dashboard balances load; periodic refresh updates them;
  mainnet↔testnet switch still works (network stays in Dart); unlock/import
  triggers a refresh; an account with 0 balance shows 0 (not error).

## Risks / non-goals

- **CORS** is avoided by keeping the network in Dart.
- **ESM + `pkg`/`node16`** is the top execution risk (in scope now, full parity).
  Mitigation: esbuild CJS bundling before `pkg`. Validate with a CLI smoke test
  before relying on it; if esbuild bundling still fails under node16, bump the pkg
  target (e.g. `node18`) as a fallback.
- **Release dependency:** the CLI exes must be published to a GitHub release before
  `Config.qubicHelper` can point at real URLs/checksums. This is a team/manual step
  with repo permissions — the plan stops short of performing it.
- The **wallet-extension** migration is a separate effort (it can consume
  `@qubic.org/contracts` directly) and is not part of this task.
- Verify `@qubic.org/contracts`/`crypto`/`registry` install cleanly into the
  wrapper and bundle through Parcel/esbuild before wiring the Dart side.
```
