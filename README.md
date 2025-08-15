# Qubic Wallet

An official **self-custody wallet** for the [Qubic Network](https://qubic.org), empowering users to securely hold and manage their QUBIC tokens and assets **locally on their device** — no third-party custody.

---

## About
- **Source Code:** Written in [Dart](https://dart.dev) with [Flutter](https://flutter.dev)  
- **Learn More:** [Qubic Documentation](https://docs.qubic.org/)  
- **Community:** [Join us on Discord](https://discord.com/invite/2vDMR8m)  
- **Tutorials:**  
  - [Qubic iOS Wallet Setup](https://discord.com/channels/@me/1280497695512989727/1405653740178116759)
  - [Qubic Android Wallet Setup](https://www.youtube.com/watch?v=a031L7Sz3iU)
  - [Using WalletConnect with Qubic Wallet for Qx](https://www.youtube.com/watch?v=vpqc9H5rc3A)  

---

## Features

### Core Functionality
- **Multi-account** – Add and manage multiple accounts  
- **Transfers** – Send and receive QUBIC  
- **Manual resend** – Retry failed transfers  
- **Blockchain Explorer** – View complete ticks, transactions, and account details  
- **Assets** – View tokens and Smart Contract shares in your accounts  
- **Asset transfers** – Send and receive tokens or Smart Contract shares  
- **WalletConnect support** – Connect with dApps  
- **Support multiple networks** – Switch between predefined networks (mainnet, testnet) or add a custom RPC and explorer URL



### Security & Privacy
- **Local-only key storage** – Private keys never leave the device  
- **Biometric authentication** – Fingerprint, Face ID, or password protection for seed access and transaction execution  

---

## Functional Information

### 1. Wallet Creation
The wallet app supports:
- **New empty wallets** – Start fresh  
- **Import from vault file** – Load an existing encrypted wallet backup  

You can add accounts to a wallet by:
- **Generating a new account** – Creates a new key pair and stores it securely  
- **Importing by private seed** – Restore access to an existing account  
- **Adding a watch-only account** – View balances using a public address (no transactions allowed)  

---

### 2. Transactions & Asset Transfers
- **Qubic transfers have 0 fees**  
- **Asset transfers** are performed via smart contract execution and **cost 100 QU**  
- *Qubic currently does not have a transaction memory pool (WIP). Because of this, only one concurrent transaction per sending account can exist in the network. Do not send a new transaction from the same source address until the previous transaction's target tick has passed. If multiple transactions are sent before that tick, only the last one will be processed — earlier ones will be ignored and the app will display them as failed once it knows the tick execution is completed.*

---

### 3. WalletConnect Integration
- Works with dApps via **QR codes** or **deep links**  
- Supports:
  - Session creation  
  - Transaction signing  
  - Message signing  
- **Sample integration**: [`qubic/wallet-app-dapp`](https://github.com/qubic/wallet-app-dapp)  
- **Security note:** A WalletConnect session grants the dApp **access to all accounts** in the wallet.  
  - dApps should implement account selection UI for each transaction or signing request.  

---

### 4. Vault Import & Export
- Vault files contain **encrypted wallets and keys** for backup/migration  
- Encrypted with **AES-256** using a password provided by the user  
- **Minimum password length:** 8 characters (no recovery possible if forgotten)  
- When exporting, the vault password can be the same as or different from the wallet password  
- Vaults can also be imported into the **[Qubic Web Wallet](https://qubic.wallet.org)**  

---

## RPC Communication

Qubic Wallet interacts with the network using the following RPC endpoints:

| RPC Type         | Purpose                                                                                                                       | Documentation                                                                                                 |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **Live RPC**     | Sends transactions and retrieves the latest blockchain data in real-time (ticks, account balances, unconfirmed transactions). | https://qubic.github.io/integration/Partners/qubic-rpc-doc.html?urls.primaryName=Qubic%20RPC%20Live%20Tree    |
| **Stats RPC**    | Provides network statistics, supply data, validator lists, and performance metrics.                                           | https://qubic.github.io/integration/Partners/qubic-rpc-doc.html?urls.primaryName=Qubic%20Stats%20API          |
| **Archiver RPC** | Allows access to historical blockchain data — older ticks, past transactions, and archived account states.                    | https://qubic.github.io/integration/Partners/qubic-rpc-doc.html?urls.primaryName=Qubic%20RPC%20Archive%20Tree |

The wallet automatically routes requests to the appropriate RPC type depending on the feature in use.  
For example:
- Sending a transaction → **Live RPC**
- Viewing latest balances → **Live RPC**
- Checking historical transactions → **Archiver RPC**
- Displaying market data → **Stats RPC**

**RPC Security:** All communication is performed over TLS.  
⚠ **Note:** Certificate pinning is **not** currently implemented.

---

## Cryptography Implementation

Qubic Wallet uses [ts-library-wrapper](https://github.com/qubic/ts-library-wrapper), which packages the core [Qubic TypeScript cryptographic library](https://github.com/qubic/ts-library) for use across:

- Desktop platforms (Windows, Linux, macOS)  
- Packaged web environments  

All cryptographic operations — including key generation, signing, and verification — are performed by the **ts-library**.  
The wrapper ensures compatibility and consistent cryptographic handling across all supported platforms.

---

## Data Storage

Qubic Wallet stores all sensitive data — including **private keys** — exclusively in secure, platform-native keystores:

- **Mobile (iOS / Android)** → Stored in OS-provided secure storage (Keychain / Keystore)  
- **Desktop** → Encrypted and stored locally using platform-specific secure storage APIs  
- **Web** → Encrypted in browser storage with keys derived from the user’s password (never stored in plain text)

**Important:**  
- Private keys never leave the device.  
- There is no remote backup or recovery — users must securely store their vault export.  
- The vault export file is encrypted with **AES-256** using the password provided by the user.  

---

## DApp Explorer

- Loads DApp metadata from **JSON files** stored in the [`qubic/dapps-explorer`](https://github.com/qubic/dapps-explorer) repository.  
- Presents a **curated catalog** of DApps, but also lets users open **any DApp by URL**, even if it’s not in the catalog.  
- Supports **WalletConnect**, allowing DApps to request account information and ask the user to **sign transactions/messages**.  

## Testing Coverage
There are currently no automated unit or integration tests. 

---

## Building & Compiling

### Prerequisites

To build Qubic Wallet, you will need:

* [Flutter SDK](https://flutter.dev/docs/get-started/install) (**3.22.2** or later)
* [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
* Platform-specific tools:

  * **Android:** Android Studio with Android SDK tools installed
  * **iOS:** Xcode, CocoaPods, and an active Apple Developer account
  * **macOS:** Xcode and macOS 12 or later
  * **Windows:** Windows 10 or later with Visual Studio (Desktop Development with C++ workload)


### Step 1: Clone the Repository

```bash
git clone https://github.com/qubic/wallet-app.git
cd wallet-app
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

---

### Step 3: Run in Development Mode

```bash
# Android
flutter run android

# iOS
flutter run ios

# macOS
flutter run macos

# Windows
flutter run windows
```

---

### Step 4: Build for Release

**Android (APK):**

```bash
flutter build apk --release
```

**Android (App Bundle):**

```bash
flutter build appbundle --release
```

**iOS:**

```bash
flutter build ios --release
```

**macOS:**

```bash
flutter build macos --release
```

**Windows:**

```bash
flutter build windows --release
```

---

## Limited Support & Contributions

We do not provide direct support in all cases.  
However, your contributions to the project are very welcome and appreciated.

You can help by:
- Adding new issues on the **Issues** page to report bugs or request new features/improvements.
- Providing updates, bug fixes, or other code changes via pull requests.

---

## License
See [LICENSE.md](LICENSE.md).