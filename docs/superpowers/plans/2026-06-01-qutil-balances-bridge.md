# QUTIL on-chain balances via a generic contract-query bridge — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> **⚠️ Git policy (user override):** Do NOT run `git commit` or `git push` without the user's explicit, per-action confirmation. The commit steps below are checkpoints — when you reach one, show the staged files + message and wait for the user to confirm before running it. Never push.

> **⚠️ No worktrees (user override):** Work directly in the main checkouts of `ts-library-wrapper/` and `wallet-app/`. Do not create or use git worktrees.

**Goal:** Make the mobile wallet (and all platforms) fetch QU balances from the on-chain QUTIL `GetBalances16` procedure via a generic, reusable contract-query bridge, replacing the off-chain `GET /live/v1/balances/{id}` endpoint.

**Architecture:** A *thin* bridge — the `ts-library-wrapper` gains two pure encode/decode functions (`buildContractInput` / `decodeContractOutput`) backed by `@qubic.org/contracts`; the actual `querySmartContract` HTTP call stays in Dart (`QubicLiveApi`) via existing `dio`/`NetworkStore`/`ErrorHandler`. The bridge is reached through `QubicCmd`, which routes to the WebView (`QubicJs`, mobile + Windows/macOS) or the rebuilt CLI executable (`QubicCmdUtils`, Linux).

**Tech Stack:** TypeScript + functioneer + Parcel + esbuild + pkg (wrapper, Jest tests); Flutter/Dart + dio + get_it + mobx (wallet-app).

**Spec:** `wallet-app/docs/superpowers/specs/2026-06-01-qutil-balances-bridge-design.md`

**Repo roots (absolute):**
- Wrapper: `/Users/ahmedtareksalem/Development/projects/qu/ts-library-wrapper`
- App: `/Users/ahmedtareksalem/Development/projects/qu/wallet-app`

---

## Phase 1 — Wrapper: bridge functions (TDD with Jest)

### Task 1: Add `@qubic.org/*` deps and make them importable under Jest

**Files:**
- Modify: `ts-library-wrapper/package.json`
- Create: `ts-library-wrapper/babel.config.js`
- Modify: `ts-library-wrapper/jest.config.js`
- Test: `ts-library-wrapper/tests/contractBridge.test.ts`

- [ ] **Step 1: Add dependencies**

In `ts-library-wrapper/package.json`, add to `dependencies`:
```json
"@qubic.org/contracts": "0.2.6",
"@qubic.org/crypto": "0.2.6",
```
and to `devDependencies`:
```json
"@babel/preset-env": "^7.24.7",
```

- [ ] **Step 2: Install**

Run: `cd /Users/ahmedtareksalem/Development/projects/qu/ts-library-wrapper && npm install`
Expected: completes; `node_modules/@qubic.org/contracts` and `@qubic.org/crypto` exist.

- [ ] **Step 3: Write the failing import/constant test**

Create `tests/contractBridge.test.ts`:
```ts
import { describe, it, expect } from "@jest/globals";
import {
  Q_UTIL_CONTRACT_INDEX,
  Q_UTIL_GET_BALANCES16_INPUT_TYPE,
  Q_UTIL_GET_BALANCES16_INPUT_SIZE,
} from "@qubic.org/contracts";

describe("@qubic.org/contracts imports", () => {
  it("exposes the QUTIL GetBalances16 constants", () => {
    expect(Q_UTIL_CONTRACT_INDEX).toBe(4);
    expect(Q_UTIL_GET_BALANCES16_INPUT_TYPE).toBe(9);
    expect(Q_UTIL_GET_BALANCES16_INPUT_SIZE).toBe(512);
  });
});
```

- [ ] **Step 4: Run it — expect it to fail with an ESM error**

Run: `npx jest tests/contractBridge.test.ts`
Expected: FAIL — typically `SyntaxError: Cannot use import statement outside a module` or `Must use import to load ES Module` (ts-jest emits CJS but the dep is ESM).

- [ ] **Step 5: Configure Babel + Jest to transpile the ESM deps**

Create `babel.config.js`:
```js
module.exports = {
  presets: [
    ["@babel/preset-env", { targets: { node: "current" } }],
    "@babel/preset-typescript",
  ],
};
```

Replace `jest.config.js` with:
```js
/** @type {import('ts-jest').JestConfigWithTsJest} */
module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  transform: {
    "^.+\\.ts$": "ts-jest",
    "^.+\\.js$": "babel-jest",
  },
  transformIgnorePatterns: ["/node_modules/(?!@qubic\\.org)"],
};
```

- [ ] **Step 6: Run it — expect PASS**

Run: `npx jest tests/contractBridge.test.ts`
Expected: PASS (1 test). Also run the full suite to confirm the config didn't break existing tests:
Run: `npx jest`
Expected: all existing tests (`runObj`, `argv`) still PASS.

> If Step 6 still errors on ESM, fallback: add `"@qubic.org/registry"` and `"@qubic.org/crypto"` to the `transformIgnorePatterns` negative lookahead, e.g. `"/node_modules/(?!(@qubic\\.org|@qubic.org))"` — confirm the actual scope folder name under `node_modules/` and widen the pattern to match it.

- [ ] **Step 7: Commit** *(pause for user confirmation per git policy)*

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/ts-library-wrapper
git add package.json package-lock.json babel.config.js jest.config.js tests/contractBridge.test.ts
git commit -m "chore(wrapper): add @qubic.org contract deps and ESM-capable jest config"
```

---

### Task 2: Contract registry module

**Files:**
- Create: `ts-library-wrapper/functions/contractRegistry.ts`
- Test: `ts-library-wrapper/tests/contractBridge.test.ts` (extend)

- [ ] **Step 1: Write the failing test (build + decode round-trip)**

Append to `tests/contractBridge.test.ts`:
```ts
import { CONTRACT_REGISTRY } from "../functions/contractRegistry";

describe("CONTRACT_REGISTRY.qUtilGetBalances16", () => {
  const ID = "A".repeat(60); // 60-char identity placeholder accepted by the encoder

  it("builds a 512-byte input and carries the right metadata", () => {
    const entry = CONTRACT_REGISTRY["qUtilGetBalances16"];
    expect(entry.contractIndex).toBe(4);
    expect(entry.inputType).toBe(9);
    expect(entry.inputSize).toBe(512);
    const bytes = entry.build({ publicKeys: [ID, ID] });
    expect(bytes).toBeInstanceOf(Uint8Array);
    expect(bytes.length).toBe(512);
  });

  it("decodes 16 little-endian sint64 balances", () => {
    const buf = new Uint8Array(128);
    const view = new DataView(buf.buffer);
    for (let i = 0; i < 16; i++) view.setBigInt64(i * 8, BigInt(i + 1), true);
    const out = CONTRACT_REGISTRY["qUtilGetBalances16"].decode(buf);
    expect(out.balances.map((b: bigint) => b.toString())).toEqual(
      Array.from({ length: 16 }, (_, i) => String(i + 1))
    );
  });
});
```

- [ ] **Step 2: Run — expect FAIL**

Run: `npx jest tests/contractBridge.test.ts`
Expected: FAIL — `Cannot find module '../functions/contractRegistry'`.

- [ ] **Step 3: Create the registry**

Create `functions/contractRegistry.ts`:
```ts
import {
  Q_UTIL_CONTRACT_INDEX,
  Q_UTIL_GET_BALANCES16_INPUT_TYPE,
  Q_UTIL_GET_BALANCES16_INPUT_SIZE,
  buildQUtilGetBalances16Input,
  decodeQUtilGetBalances16Output,
} from "@qubic.org/contracts";
import { identityToPublicKey } from "@qubic.org/crypto";

export interface ContractFunctionEntry {
  contractIndex: number;
  inputType: number;
  inputSize: number;
  build: (args: any) => Uint8Array;
  decode: (data: Uint8Array) => any;
}

export const CONTRACT_REGISTRY: Record<string, ContractFunctionEntry> = {
  qUtilGetBalances16: {
    contractIndex: Q_UTIL_CONTRACT_INDEX,
    inputType: Q_UTIL_GET_BALANCES16_INPUT_TYPE,
    inputSize: Q_UTIL_GET_BALANCES16_INPUT_SIZE,
    build: (args: { publicKeys: string[] }) =>
      buildQUtilGetBalances16Input(
        { publicKeys: args.publicKeys },
        identityToPublicKey
      ),
    decode: (data: Uint8Array) => decodeQUtilGetBalances16Output(data),
  },
};
```

- [ ] **Step 4: Run — expect PASS**

Run: `npx jest tests/contractBridge.test.ts`
Expected: PASS (all describe blocks).

- [ ] **Step 5: Commit** *(pause for user confirmation)*

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/ts-library-wrapper
git add functions/contractRegistry.ts tests/contractBridge.test.ts
git commit -m "feat(wrapper): add contract-function registry for qUtilGetBalances16"
```

---

### Task 3: `buildContractInput` bridge function

**Files:**
- Create: `ts-library-wrapper/functions/buildContractInput.ts`
- Modify: `ts-library-wrapper/functions/index.ts`
- Test: `ts-library-wrapper/tests/contractBridge.test.ts` (extend)

- [ ] **Step 1: Write the failing test (via `runBrowser`)**

Append to `tests/contractBridge.test.ts`:
```ts
import { runBrowser } from "../functions/index";

describe("runBrowser buildContractInput", () => {
  const ID = "A".repeat(60);

  it("returns the request metadata + 512-byte base64 payload", async () => {
    const out: any = await runBrowser(
      "buildContractInput",
      "qUtilGetBalances16",
      JSON.stringify({ publicKeys: [ID] })
    );
    expect(out.status).toBe("ok");
    expect(out.contractIndex).toBe(4);
    expect(out.inputType).toBe(9);
    expect(out.inputSize).toBe(512);
    expect(Buffer.from(out.requestData, "base64").length).toBe(512);
  });

  it("errors on an unknown function", async () => {
    const out: any = await runBrowser("buildContractInput", "nope", "{}");
    expect(out.status).toBe("error");
  });
});
```

- [ ] **Step 2: Run — expect FAIL**

Run: `npx jest tests/contractBridge.test.ts -t "buildContractInput"`
Expected: FAIL — `Function buildContractInput not found`.

- [ ] **Step 3: Create the function**

Create `functions/buildContractInput.ts`:
```ts
import { Functioneer } from "functioneer";
import { CONTRACT_REGISTRY } from "./contractRegistry";

export function addFunction(func: Functioneer) {
  func
    .registerFunction(
      "buildContractInput",
      "Builds a querySmartContract request for a registered contract function",
      async (functionName: string, argsJson: string) => {
        try {
          const entry = CONTRACT_REGISTRY[functionName];
          if (!entry) {
            return JSON.stringify({
              status: "error",
              error: `Unknown contract function: ${functionName}`,
            });
          }
          const args = JSON.parse(argsJson);
          const payload = entry.build(args);
          return JSON.stringify({
            contractIndex: entry.contractIndex,
            inputType: entry.inputType,
            inputSize: entry.inputSize,
            requestData: Buffer.from(payload).toString("base64"),
          });
        } catch (e: any) {
          return JSON.stringify({
            status: "error",
            error: e.message || "Failed to build contract input",
          });
        }
      }
    )
    .addField("functionName", "string", "Registered contract function name")
    .addField("argsJson", "string", "JSON-encoded arguments for the function");
}
```

- [ ] **Step 4: Register it**

In `functions/index.ts`, add the import alongside the others:
```ts
import { addFunction as buildContractInput } from "./buildContractInput";
```
and inside `addFunctions(func)`, add:
```ts
  buildContractInput(func);
```

- [ ] **Step 5: Run — expect PASS**

Run: `npx jest tests/contractBridge.test.ts -t "buildContractInput"`
Expected: PASS (both cases).

- [ ] **Step 6: Commit** *(pause for user confirmation)*

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/ts-library-wrapper
git add functions/buildContractInput.ts functions/index.ts tests/contractBridge.test.ts
git commit -m "feat(wrapper): expose buildContractInput bridge function"
```

---

### Task 4: `decodeContractOutput` bridge function

**Files:**
- Create: `ts-library-wrapper/functions/decodeContractOutput.ts`
- Modify: `ts-library-wrapper/functions/index.ts`
- Test: `ts-library-wrapper/tests/contractBridge.test.ts` (extend)

- [ ] **Step 1: Write the failing test**

Append to `tests/contractBridge.test.ts`:
```ts
describe("runBrowser decodeContractOutput", () => {
  it("decodes balances (bigint serialized as string)", async () => {
    const buf = new Uint8Array(128);
    const view = new DataView(buf.buffer);
    for (let i = 0; i < 16; i++) view.setBigInt64(i * 8, BigInt(i + 1), true);
    const b64 = Buffer.from(buf).toString("base64");
    const out: any = await runBrowser(
      "decodeContractOutput",
      "qUtilGetBalances16",
      b64
    );
    expect(out.status).toBe("ok");
    expect(out.balances).toEqual(
      Array.from({ length: 16 }, (_, i) => String(i + 1))
    );
  });
});
```

- [ ] **Step 2: Run — expect FAIL**

Run: `npx jest tests/contractBridge.test.ts -t "decodeContractOutput"`
Expected: FAIL — `Function decodeContractOutput not found`.

- [ ] **Step 3: Create the function**

Create `functions/decodeContractOutput.ts`:
```ts
import { Functioneer } from "functioneer";
import { CONTRACT_REGISTRY } from "./contractRegistry";

export function addFunction(func: Functioneer) {
  func
    .registerFunction(
      "decodeContractOutput",
      "Decodes a querySmartContract response for a registered contract function",
      async (functionName: string, responseB64: string) => {
        try {
          const entry = CONTRACT_REGISTRY[functionName];
          if (!entry) {
            return JSON.stringify({
              status: "error",
              error: `Unknown contract function: ${functionName}`,
            });
          }
          const data = new Uint8Array(Buffer.from(responseB64, "base64"));
          const result = entry.decode(data);
          return JSON.stringify(result, (_key, value) =>
            typeof value === "bigint" ? value.toString() : value
          );
        } catch (e: any) {
          return JSON.stringify({
            status: "error",
            error: e.message || "Failed to decode contract output",
          });
        }
      }
    )
    .addField("functionName", "string", "Registered contract function name")
    .addField("responseB64", "string", "Base64 querySmartContract responseData");
}
```

- [ ] **Step 4: Register it**

In `functions/index.ts`, add:
```ts
import { addFunction as decodeContractOutput } from "./decodeContractOutput";
```
and inside `addFunctions(func)`:
```ts
  decodeContractOutput(func);
```

- [ ] **Step 5: Run — expect PASS (full suite)**

Run: `npx jest`
Expected: all PASS.

- [ ] **Step 6: Commit** *(pause for user confirmation)*

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/ts-library-wrapper
git add functions/decodeContractOutput.ts functions/index.ts tests/contractBridge.test.ts
git commit -m "feat(wrapper): expose decodeContractOutput bridge function"
```

---

## Phase 2 — Wrapper: builds

### Task 5: Build the HTML asset (`3_2_0`)

**Files:**
- Build output: `ts-library-wrapper/dist/index.html` → renamed `qubic-helper-html-3_2_0.html`

- [ ] **Step 1: Build the HTML bundle**

Run: `cd /Users/ahmedtareksalem/Development/projects/qu/ts-library-wrapper && npm run build-html-ts`
Expected: `tsc` + `parcel build index.html` complete with no errors; `dist/index.html` produced.

- [ ] **Step 2: Rename to the versioned asset**

Run: `mv dist/index.html dist/qubic-helper-html-3_2_0.html && ls -l dist/qubic-helper-html-3_2_0.html`
Expected: file exists, size in the same ballpark as the old one (~450–700 KB; larger is fine — it now bundles `@qubic.org/*`).

- [ ] **Step 3: Sanity-check the bundle exposes the new function**

Run: `grep -c "buildContractInput" dist/qubic-helper-html-3_2_0.html`
Expected: ≥ 1.

- [ ] **Step 4: Commit** *(pause for user confirmation)*

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/ts-library-wrapper
git add dist/qubic-helper-html-3_2_0.html
git commit -m "build(wrapper): build 3_2_0 HTML asset with contract bridge"
```

---

### Task 6: Build the CLI executables (esbuild → CJS → pkg)

**Files:**
- Modify: `ts-library-wrapper/package.json` (scripts + esbuild devDep)
- Build output: `ts-library-wrapper/dist/packaged/qubic-helper-{win-64.exe,linux-64,mac-64}`

- [ ] **Step 1: Add esbuild + a CJS bundle script**

In `package.json` `devDependencies` add:
```json
"esbuild": "^0.21.5",
```
In `scripts`, add a bundle step and point the pkg builds at it:
```json
"build-cli-bundle": "npx esbuild index.ts --bundle --platform=node --format=cjs --target=node16 --outfile=dist/index.js",
"build-win": "npx pkg --debug -o dist/packaged/qubic-helper-win-64.exe --targets node16-win-x64 dist/index.js",
"build-linux": "npx pkg --debug -o dist/packaged/qubic-helper-linux-64 --targets node16-linux-x64 dist/index.js",
"build-mac": "npx pkg --debug -o dist/packaged/qubic-helper-mac-64 --targets node16-macos-x64 dist/index.js",
"build-all": "npm run build-cli-bundle && rm -rf .parcel-cache && npm run build-html && mv dist/index.html dist/qubic-helper-html-3_2_0.html && npm run build-win && npm run build-linux && npm run build-mac"
```
> Note: `build-cli-bundle` replaces the `tsc`-emitted `dist/index.js` with an esbuild CJS bundle that **inlines** the ESM `@qubic.org/*` packages, so `pkg`/node16 never has to `require()` an ESM module.

- [ ] **Step 2: Install esbuild**

Run: `npm install`
Expected: `node_modules/.bin/esbuild` exists.

- [ ] **Step 3: Bundle for CLI**

Run: `npm run build-cli-bundle`
Expected: `dist/index.js` produced, no errors. (If esbuild reports unresolved ESM/`import.meta` issues, see fallback note at the end of this task.)

- [ ] **Step 4: Build the three executables**

Run: `npm run build-win && npm run build-linux && npm run build-mac`
Expected: three files under `dist/packaged/`.

- [ ] **Step 5: Smoke-test the host-OS executable**

On macOS (host), run:
```bash
chmod +x dist/packaged/qubic-helper-mac-64
dist/packaged/qubic-helper-mac-64 buildContractInput qUtilGetBalances16 '{"publicKeys":["AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"]}'
```
Expected: JSON with `"contractIndex":4,"inputType":9,"inputSize":512,"requestData":"…","status":"ok"`.
(Use a real 60-char identity for a meaningful payload; any 60-char string exercises the code path.)

- [ ] **Step 6: Compute md5 checksums (needed for `Config.qubicHelper` in Task 14)**

Run:
```bash
md5 -q dist/packaged/qubic-helper-win-64.exe
md5 -q dist/packaged/qubic-helper-linux-64
md5 -q dist/packaged/qubic-helper-mac-64
```
Record the three hashes for Task 14. (On Linux/CI use `md5sum`.)

- [ ] **Step 7: Commit** *(pause for user confirmation)*

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/ts-library-wrapper
git add package.json package-lock.json
git commit -m "build(wrapper): esbuild CJS bundle so pkg can ship the ESM contract deps"
```

> **Fallback if Step 3/4 fails on ESM/node16:** bump the pkg + esbuild target to `node18` (`--target=node18`, `--targets node18-*`). If `pkg` still rejects the bundle, switch the CLI packager to `@yao-pkg/pkg` (the maintained fork with ESM/node18+ support) — update the `build-win/linux/mac` scripts to call `npx @yao-pkg/pkg` instead of `npx pkg`. Re-run Steps 3–6.

---

## Phase 3 — wallet-app: consume the bridge

> No Dart unit-test harness exists in `wallet-app` (no `test/` dir, no mocking lib), and adding one would violate "follow existing conventions." Verification for Dart tasks is `flutter analyze` (must be clean) plus the manual run in Task 15.

### Task 7: Install the HTML asset and update config paths

**Files:**
- Create: `wallet-app/assets/qubic_js/qubic-helper-html-3_2_0.html`
- Delete: `wallet-app/assets/qubic_js/qubic-helper-html-3_1_3.html`
- Modify: `wallet-app/lib/config.dart`

- [ ] **Step 1: Copy the new asset, remove the old**

Run:
```bash
cp /Users/ahmedtareksalem/Development/projects/qu/ts-library-wrapper/dist/qubic-helper-html-3_2_0.html \
   /Users/ahmedtareksalem/Development/projects/qu/wallet-app/assets/qubic_js/
rm /Users/ahmedtareksalem/Development/projects/qu/wallet-app/assets/qubic_js/qubic-helper-html-3_1_3.html
```

- [ ] **Step 2: Add the querySmartContract endpoint + bump the asset path**

In `wallet-app/lib/config.dart`, after the `submitTransaction` line (≈line 56) add:
```dart
  static const querySmartContract = "$liveApiPrefix/querySmartContract";
```
Change `qubicJSAssetPath` (≈line 128) to:
```dart
  static const qubicJSAssetPath =
      "assets/qubic_js/qubic-helper-html-3_2_0.html";
```
(Leave `Config.qubicHelper` CLI entries for Task 14. Leave `addressQubicBalance` for Task 13.)

- [ ] **Step 3: Verify analyze is clean for this file**

Run: `cd /Users/ahmedtareksalem/Development/projects/qu/wallet-app && flutter analyze lib/config.dart`
Expected: No issues.

- [ ] **Step 4: Commit** *(pause for user confirmation)*

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/wallet-app
git add assets/qubic_js/qubic-helper-html-3_2_0.html lib/config.dart
git rm assets/qubic_js/qubic-helper-html-3_1_3.html
git commit -m "chore(app): ship 3_2_0 helper asset and add querySmartContract endpoint"
```

---

### Task 8: Add bridge function-name constants

**Files:**
- Modify: `wallet-app/lib/models/qubic_js.dart`

- [ ] **Step 1: Add the constants**

In `lib/models/qubic_js.dart`, inside `abstract class QubicJSFunctions`, append:
```dart
  // Builds a querySmartContract request for a registered contract function
  static const buildContractInput = "buildContractInput";

  // Decodes a querySmartContract response for a registered contract function
  static const decodeContractOutput = "decodeContractOutput";
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/models/qubic_js.dart`
Expected: No issues.

- [ ] **Step 3: Commit** *(pause for user confirmation)*

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/wallet-app
git add lib/models/qubic_js.dart
git commit -m "chore(app): add contract-bridge function-name constants"
```

---

### Task 9: `QubicJs` bridge methods (WebView path)

**Files:**
- Modify: `wallet-app/lib/resources/qubic_js.dart`

- [ ] **Step 1: Add the two methods**

In `lib/resources/qubic_js.dart`, add inside `class QubicJs` (e.g. after `publicKeyStringToBytes`):
```dart
  /// Builds a querySmartContract request for a registered contract function.
  /// Returns { contractIndex, inputType, inputSize, requestData(base64) }.
  Future<Map<String, dynamic>> buildContractInput(
      String functionName, String argsJson) async {
    CallAsyncJavaScriptResult? result = await runFunction(
        QubicJSFunctions.buildContractInput, [functionName, argsJson]);

    if (result == null) {
      throw const AppException(QubicJsErrors.jsReturnedNull,
          'Contract input build returned empty result');
    }
    if (result.error != null) {
      throw AppException(
          QubicJsErrors.jsReturnedError, 'JS error: ${result.error}');
    }
    final Map<String, dynamic> data = json.decode(result.value);
    if (data['status'] == 'error') {
      throw AppException(
          QubicJsErrors.jsReturnedError, data['error'] ?? 'Unknown error');
    }
    return data;
  }

  /// Decodes a querySmartContract response for a registered contract function.
  Future<Map<String, dynamic>> decodeContractOutput(
      String functionName, String responseData) async {
    CallAsyncJavaScriptResult? result = await runFunction(
        QubicJSFunctions.decodeContractOutput, [functionName, responseData]);

    if (result == null) {
      throw const AppException(QubicJsErrors.jsReturnedNull,
          'Contract output decode returned empty result');
    }
    if (result.error != null) {
      throw AppException(
          QubicJsErrors.jsReturnedError, 'JS error: ${result.error}');
    }
    final Map<String, dynamic> data = json.decode(result.value);
    if (data['status'] == 'error') {
      throw AppException(
          QubicJsErrors.jsReturnedError, data['error'] ?? 'Unknown error');
    }
    return data;
  }
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/resources/qubic_js.dart`
Expected: No issues.

- [ ] **Step 3: Commit** *(pause for user confirmation)*

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/wallet-app
git add lib/resources/qubic_js.dart
git commit -m "feat(app): add QubicJs contract-bridge methods"
```

---

### Task 10: `QubicCmdUtils` bridge methods (CLI path)

**Files:**
- Modify: `wallet-app/lib/resources/qubic_cmd_utils.dart`

- [ ] **Step 1: Add the two methods**

In `lib/resources/qubic_cmd_utils.dart`, add inside `class QubicCmdUtils`:
```dart
  /// Builds a querySmartContract request via the CLI helper.
  Future<Map<String, dynamic>> buildContractInput(
      String functionName, String argsJson) async {
    await validateFileStreamSignature();
    final p = await Process.run(
        await _getHelperFileFullPath(),
        [QubicJSFunctions.buildContractInput, functionName, argsJson],
        runInShell: true);

    if (p.exitCode != 0) {
      appLogger.e('Script execution failed with exit code ${p.exitCode}');
      appLogger.e(p.stderr);
      throw Exception('Failed to build contract input');
    }
    late dynamic parsedJson;
    try {
      parsedJson = jsonDecode(p.stdout.toString());
    } catch (e) {
      throw Exception('Failed to parse buildContractInput output');
    }
    final Map<String, dynamic> data = Map<String, dynamic>.from(parsedJson);
    if (data['status'] == 'error') {
      throw Exception(data['error'] ?? 'Failed to build contract input');
    }
    return data;
  }

  /// Decodes a querySmartContract response via the CLI helper.
  Future<Map<String, dynamic>> decodeContractOutput(
      String functionName, String responseData) async {
    await validateFileStreamSignature();
    final p = await Process.run(
        await _getHelperFileFullPath(),
        [QubicJSFunctions.decodeContractOutput, functionName, responseData],
        runInShell: true);

    if (p.exitCode != 0) {
      appLogger.e('Script execution failed with exit code ${p.exitCode}');
      appLogger.e(p.stderr);
      throw Exception('Failed to decode contract output');
    }
    late dynamic parsedJson;
    try {
      parsedJson = jsonDecode(p.stdout.toString());
    } catch (e) {
      throw Exception('Failed to parse decodeContractOutput output');
    }
    final Map<String, dynamic> data = Map<String, dynamic>.from(parsedJson);
    if (data['status'] == 'error') {
      throw Exception(data['error'] ?? 'Failed to decode contract output');
    }
    return data;
  }
```
> These use plain `Exception` (not localized strings). Localized messages can be added later if desired; kept generic here to avoid scope creep into the `.arb` localization files.

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/resources/qubic_cmd_utils.dart`
Expected: No issues.

- [ ] **Step 3: Commit** *(pause for user confirmation)*

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/wallet-app
git add lib/resources/qubic_cmd_utils.dart
git commit -m "feat(app): add QubicCmdUtils contract-bridge methods (CLI path)"
```

---

### Task 11: `QubicCmd` routing methods

**Files:**
- Modify: `wallet-app/lib/resources/qubic_cmd.dart`

- [ ] **Step 1: Add routing methods**

In `lib/resources/qubic_cmd.dart`, add inside `class QubicCmd`:
```dart
  Future<Map<String, dynamic>> buildContractInput(
      String functionName, String argsJson) async {
    if (useJs) {
      return await qubicJs.buildContractInput(functionName, argsJson);
    } else {
      return await qubicCmdUtils.buildContractInput(functionName, argsJson);
    }
  }

  Future<Map<String, dynamic>> decodeContractOutput(
      String functionName, String responseData) async {
    if (useJs) {
      return await qubicJs.decodeContractOutput(functionName, responseData);
    } else {
      return await qubicCmdUtils.decodeContractOutput(functionName, responseData);
    }
  }
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/resources/qubic_cmd.dart`
Expected: No issues.

- [ ] **Step 3: Commit** *(pause for user confirmation)*

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/wallet-app
git add lib/resources/qubic_cmd.dart
git commit -m "feat(app): route contract-bridge calls through QubicCmd"
```

---

### Task 12: `QubicLiveApi.querySmartContract`

**Files:**
- Modify: `wallet-app/lib/resources/apis/live/qubic_live_api.dart`

- [ ] **Step 1: Add the method**

In `lib/resources/apis/live/qubic_live_api.dart`, add inside `class QubicLiveApi` (next to `submitTransaction`):
```dart
  Future<String> querySmartContract({
    required int contractIndex,
    required int inputType,
    required int inputSize,
    required String requestData,
  }) async {
    try {
      final response = await _dio.post(
        '${_networkStore.currentNetwork.rpcUrl}${Config.querySmartContract}',
        data: {
          "contractIndex": contractIndex,
          "inputType": inputType,
          "inputSize": inputSize,
          "requestData": requestData,
        },
      );
      return response.data["responseData"] as String;
    } catch (error) {
      throw await ErrorHandler.handleError(error);
    }
  }
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/resources/apis/live/qubic_live_api.dart`
Expected: No issues.

- [ ] **Step 3: Commit** *(pause for user confirmation)*

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/wallet-app
git add lib/resources/apis/live/qubic_live_api.dart
git commit -m "feat(app): add QubicLiveApi.querySmartContract"
```

---

### Task 13: Rewrite `getQubicBalances` to use QUTIL; remove the old endpoint

**Files:**
- Modify: `wallet-app/lib/resources/apis/live/qubic_live_api.dart`
- Modify: `wallet-app/lib/config.dart` (remove `addressQubicBalance`)

- [ ] **Step 1: Add imports**

At the top of `qubic_live_api.dart`, add:
```dart
import 'dart:convert';
import 'dart:math';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
```

- [ ] **Step 2: Add the constants (top of file, after imports)**

```dart
const String _qUtilGetBalances16 = "qUtilGetBalances16";
const int _balancesBatchSize = 16;
```

- [ ] **Step 3: Replace the `getQubicBalances` method**

Replace the existing `getQubicBalances` with:
```dart
  Future<List<CurrentBalanceDto>> getQubicBalances(
      List<String> publicIds, int currentTick) async {
    if (publicIds.isEmpty) return [];
    try {
      final cmd = getIt<QubicCmd>();

      // QUTIL GetBalances16 handles up to 16 identities per call.
      final List<List<String>> batches = [];
      for (var i = 0; i < publicIds.length; i += _balancesBatchSize) {
        batches.add(publicIds.sublist(
            i, min(i + _balancesBatchSize, publicIds.length)));
      }

      final batchResults =
          await Future.wait(batches.map((batch) async {
        final input = await cmd.buildContractInput(
            _qUtilGetBalances16, jsonEncode({"publicKeys": batch}));

        final responseData = await querySmartContract(
          contractIndex: input["contractIndex"] as int,
          inputType: input["inputType"] as int,
          inputSize: input["inputSize"] as int,
          requestData: input["requestData"] as String,
        );

        final decoded =
            await cmd.decodeContractOutput(_qUtilGetBalances16, responseData);
        final List<dynamic> balances = decoded["balances"] as List<dynamic>;

        return List<CurrentBalanceDto>.generate(batch.length, (j) {
          return CurrentBalanceDto(
            id: batch[j],
            balance: BigInt.parse(balances[j].toString()).toInt(),
            validForTick: currentTick,
            latestIncomingTransferTick: 0,
            latestOutgoingTransferTick: 0,
            incomingAmount: "",
            outgoingAmount: "",
            numberOfIncomingTransfers: 0,
            numberOfOutgoingTransfers: 0,
          );
        });
      }));

      return batchResults.expand((e) => e).toList();
    } catch (e) {
      throw await ErrorHandler.handleError(e);
    }
  }
```

- [ ] **Step 4: Remove the dead endpoint helper**

In `lib/config.dart`, delete:
```dart
  static addressQubicBalance(String address) =>
      "$liveApiPrefix/balances/$address";
```

- [ ] **Step 5: Verify (project-wide; the signature change must compile at the call site)**

Run: `cd /Users/ahmedtareksalem/Development/projects/qu/wallet-app && flutter analyze lib/resources/apis/live/qubic_live_api.dart lib/config.dart`
Expected: No issues in these files. (Task 14 updates the one caller in `timed_controller.dart`; if you analyze the whole project now it will flag that call site until Task 14 — that's expected.)

- [ ] **Step 6: Commit** *(pause for user confirmation)*

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/wallet-app
git add lib/resources/apis/live/qubic_live_api.dart lib/config.dart
git commit -m "feat(app): fetch balances from QUTIL GetBalances16 via the bridge"
```

---

### Task 14: Thread the current tick from `timed_controller`; update CLI config

**Files:**
- Modify: `wallet-app/lib/timed_controller.dart`
- Modify: `wallet-app/lib/config.dart` (`Config.qubicHelper` entries)

- [ ] **Step 1: Pass the current tick into `getQubicBalances`**

In `lib/timed_controller.dart`, in `_fetchAndProcessBalances`, change:
```dart
      final balances = await _liveApi.getQubicBalances(myIds);
```
to:
```dart
      final balances =
          await _liveApi.getQubicBalances(myIds, appStore.currentTick);
```
(`appStore.currentTick` is already set in `fetchData()` before `_getNetworkBalancesAndAssets()` runs.)

- [ ] **Step 2: Update the CLI helper config to 3_2_0**

In `lib/config.dart`, replace the `qubicHelper` block with the new version/filenames/URLs and the md5 checksums recorded in Task 6 Step 6:
```dart
  static final qubicHelper = QubicHelperConfig(
      win64: QubicHelperConfigEntry(
          filename: "qubic-helper-win-x64-3_2_0.exe",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/v3.2.0/qubic-helper-win-x64-3_2_0.exe",
          checksum: "<MD5_WIN_FROM_TASK_6>"),
      linux64: QubicHelperConfigEntry(
          filename: "qubic-helper-linux-x64-3_2_0",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/v3.2.0/qubic-helper-linux-x64-3_2_0",
          checksum: "<MD5_LINUX_FROM_TASK_6>"),
      macOs64: QubicHelperConfigEntry(
          filename: "qubic-helper-mac-x64-3_2_0",
          downloadPath:
              "https://github.com/qubic/ts-library-wrapper/releases/download/v3.2.0/qubic-helper-mac-x64-3_2_0",
          checksum: "<MD5_MAC_FROM_TASK_6>"));
```
> Replace each `<MD5_…_FROM_TASK_6>` with the literal hash printed in Task 6 Step 6. The release artifacts must be named exactly as above (Task 16 publishes them). The download URLs only resolve after Task 16.

- [ ] **Step 3: Verify the whole project compiles**

Run: `cd /Users/ahmedtareksalem/Development/projects/qu/wallet-app && flutter analyze`
Expected: No issues (the `getQubicBalances` call site now matches the new signature).

- [ ] **Step 4: Format**

Run: `dart format lib/`
Expected: files formatted (commit any reformatting).

- [ ] **Step 5: Commit** *(pause for user confirmation)*

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/wallet-app
git add lib/timed_controller.dart lib/config.dart
git commit -m "feat(app): pass current tick to balances and point CLI config at v3.2.0"
```

---

### Task 15: Manual verification (mobile + WebView desktop)

**Files:** none (verification only)

- [ ] **Step 1: Run on a mobile target**

Run: `cd /Users/ahmedtareksalem/Development/projects/qu/wallet-app && flutter run` (iOS simulator or Android emulator).

- [ ] **Step 2: Verify the behaviors**

- Dashboard shows non-`?` balances for all accounts on first load.
- Balances refresh on the periodic timer (`Config.fetchEverySeconds`) without console errors.
- Unlock/import triggers a balance refresh.
- Switch network (mainnet ↔ testnet) in settings → balances reload against the selected network (proves network switching still works, since the HTTP call stayed in Dart).
- An account with zero balance shows `0`, not an error.
- Watch the network tab/logs: requests go to `…/live/v1/querySmartContract` (POST), not `…/balances/{id}`.

- [ ] **Step 3: (Optional) Windows/macOS desktop** — same checks; these also use the WebView/HTML path, so they exercise the same `QubicJs` methods.

- [ ] **Step 4: Commit** — nothing to commit (verification only). Record results in the PR description.

---

## Phase 4 — Release (external/team action)

### Task 16: Publish the CLI executables and finalize Linux support

**Files:** none in-repo (GitHub release on `qubic/ts-library-wrapper`)

- [ ] **Step 1: Rename build outputs to the release artifact names**

```bash
cd /Users/ahmedtareksalem/Development/projects/qu/ts-library-wrapper/dist/packaged
cp qubic-helper-win-64.exe qubic-helper-win-x64-3_2_0.exe
cp qubic-helper-linux-64  qubic-helper-linux-x64-3_2_0
cp qubic-helper-mac-64    qubic-helper-mac-x64-3_2_0
```

- [ ] **Step 2: Create the GitHub release (requires repo permissions — team action)**

```bash
gh release create v3.2.0 \
  qubic-helper-win-x64-3_2_0.exe \
  qubic-helper-linux-x64-3_2_0 \
  qubic-helper-mac-x64-3_2_0 \
  --repo qubic/ts-library-wrapper \
  --title "v3.2.0" \
  --notes "Add buildContractInput/decodeContractOutput contract-query bridge (QUTIL GetBalances16)."
```
> This step needs maintainer access to `qubic/ts-library-wrapper`. If you don't have it, hand the three artifacts + checksums to a maintainer. Do not run `gh release`/push without explicit user confirmation (git policy).

- [ ] **Step 3: Confirm `Config.qubicHelper` checksums/URLs match the published files**

Verify the md5 of each downloaded release asset equals the values committed in Task 14 Step 2. If you rebuilt between Task 6 and release, recompute and update `config.dart`.

- [ ] **Step 4: Verify on Linux**

On a Linux build, confirm the app downloads the helper, passes the checksum gate (`validateFileStreamSignature`), and balances load via the CLI path.

---

## Self-Review

**Spec coverage:**
- Decision 1 (network in Dart) → Tasks 12–13. ✓
- Decision 2 (generic pair) → Tasks 2–4 (registry + both functions). ✓
- Decision 3 (version 3_2_0) → Tasks 5, 6, 7, 14. ✓
- Decision 4 (full replace) → Task 13 (removes `addressQubicBalance`, rewrites `getQubicBalances`). ✓
- Decision 5 (full platform parity incl. CLI) → Tasks 6, 10, 11, 14, 16. ✓
- RPC request/response shape → Task 12. ✓
- ESM handling (Jest/esbuild) → Tasks 1, 6. ✓
- Tick source → Task 14. ✓

**Placeholder scan:** The only bracketed tokens are `<MD5_…_FROM_TASK_6>` in Task 14 — these are values *produced by a command in Task 6 Step 6*, not unspecified work; the instruction says exactly where to get them. No "TBD"/"add error handling"/"similar to" placeholders.

**Type/name consistency:** `buildContractInput(functionName, argsJson)` and `decodeContractOutput(functionName, responseData)` keep the same signatures across `QubicJs`, `QubicCmdUtils`, and `QubicCmd`. `getQubicBalances(List<String>, int)` is defined in Task 13 and called with the matching arity in Task 14. `querySmartContract` named params match between definition (Task 12) and call (Task 13). Constant `_qUtilGetBalances16` is used consistently.
