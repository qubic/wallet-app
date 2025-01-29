# Qubic Wallet

Official self-custodial wallet app for the QUBIC network (https://qubic.org/).
Source code is written in [Dart](https://dart.dev) using [Flutter](https://flutter.dev).
Find more about QUBIC on (https://doc.qubic.world/).
Find us on discord (https://discord.com/invite/2vDMR8m).

## Functionality

- [x] Multi account: Add and manage multiple accounts
- [x] Transfers: Send and receive QUBIC
- [x] Manual resend: Manual resend failed transfers
- [x] Block Explorer: View complete tick / transacation / account info
- [x] Assets: View shares in your accounts
- [x] Asset transfers: Allow to send and receive shares
- [x] WalletConnect support

## Other features

- [x] Requires password to login
- [x] Requires authentication view seed / make transfer
- [x] Biometric authentication (provided that your phone has the required hardware)
- [x] Scan QR codes

# Supported Platforms

- [x] iOS - Available in the [App Store](https://apps.apple.com/us/app/qubic-wallet/id6502265811)
- [x] Android - Available in the [Play Store](https://play.google.com/store/apps/details?id=org.qubic.wallet)
- [x] Windows
- [x] Linux
- [x] MacOS
- [x] Web

## Wallet connect integration and custom links

The application registers `qubic-wallet://` custom scheme. 
To initialize a wallet connect session please link to
`qubic-wallet://pairwc/wc:....`

This application is WalletConnect compatible, which allows to communicate with dApps.
Please read the `WalletConnect integration` section below for more information.

## Security

All stored data is encrypted via (https://pub.dev/packages/flutter_secure_storage)

- Android : Use of EncryptedSharedPreferences
- iOS: KeyChain
- MacOS: KeyChain
- Windows: Windows Credentials Manager

## Cryptographic operations

### Mobile version

Open source Dart cryptographic libraries for required algorithms state that are not audited / production ready. For this, we are using an embedded web browser
which features the Web Crypto API and use Javascript libs for the cryptographic operations. This is transparent to the end user. Javascript libs are extracted by qubic.li wallet and added as an asset.

### Desktop version

In order to not have to embed a javascript runtime inside the application, for desktop apps, we have compiled the Javascript libs to standalone executables using pkg. You can find them here: https://github.com/qubic/ts-library-wrapper
Desktop versions try to locate the appropriate executable and if it's missing it automatically downloads it (or allows the user to manually download it).

### Anti-tampering

Both mobile and desktop version check the Hashes of the assets / executables before using them, in order to prevent tampering.

## Backend

Your keys are never shared to any 3rd party. Yet the wallet uses some backend services:

### Access to Qubic Network

Access to the Qubic Network is currently provided by the wonderful work of (https://www.qubic.org). We are working with a new version to interface directly with the Computor nodes.

# Compiling - Downloading - Running

Fluter 3.22.2 is required.
Soon there will be a dedicated compilation manual page. Until then here's some brief instructions:

## iOS

```bash
flutter build ios
```

## Android

```bash
flutter build apk --split-per-abi
```

and run the .apk file on your device.

## Windows

- Run : `flutter build windows` to build the windows version. Run it in your windows
- Please note that running the windows version requires the VC++ Redistributables which can be found here(https://www.microsoft.com/en-gb/download/details.aspx?id=48145)

# Contribution - Bug reports

Feel free to contribute to the project. Just create an MR. Feel free to post any found bugs in Issues page. We cannot support you in any case. You are welcome to provide updates, bugfixes or other code changes by pull requests.

# License

Permission is hereby granted, perpetual, worldwide, non-exclusive, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The Software cannot be used in any form or in any substantial portions for development, maintenance and for any other purposes, in the military sphere and in relation to military products, including, but not limited to: a. any kind of armored force vehicles, missile weapons, warships, artillery weapons, air military vehicles (including military aircrafts, combat helicopters, military drones aircrafts), air defense systems, rifle armaments, small arms, firearms and side arms, melee weapons, chemical weapons, weapons of mass destruction;

b. any special software for development technical documentation for military purposes;

c. any special equipment for tests of prototypes of any subjects with military purpose of use;

d. any means of protection for conduction of acts of a military nature;

e. any software or hardware for determining strategies, reconnaissance, troop positioning, conducting military actions, conducting special operations;

f. any dual-use products with possibility to use the product in military purposes;

g. any other products, software or services connected to military activities;

h. any auxiliary means related to abovementioned spheres and products.

The Software cannot be used as described herein in any connection to the military activities. A person, a company, or any other entity, which wants to use the Software, shall take all reasonable actions to make sure that the purpose of use of the Software cannot be possibly connected to military purposes.

The Software cannot be used by a person, a company, or any other entity, activities of which are connected to military sphere in any means. If a person, a company, or any other entity, during the period of time for the usage of Software, would engage in activities, connected to military purposes, such person, company, or any other entity shall immediately stop the usage of Software and any its modifications or alterations.

Abovementioned restrictions should apply to all modification, alteration, merge, and to other actions, related to the Software, regardless of how the Software was changed due to the abovementioned actions.

The above copyright notice and this permission notice shall be included in all copies or substantial portions, modifications and alterations of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# WalletConnect Integration

## Introduction

Qubic Wallet supports the WalletConnect protocol, allowing dApps to securely interact with the wallet.

### Why WalletConnect?

WalletConnect enables a secure and decentralized way for dApps to connect with mobile or hardware wallets. It uses a simple QR code scanning or copy-paste of a connection URL for a connection and requires no browser plugins or extensions.

## Terminology

| Term    | Explanation                                                                                        |
| ------- | -------------------------------------------------------------------------------------------------- |
| dApp    | A (web3) application which needs access to the Qubic Wallet                                        |
| session | A connection between a dApp and the Qubic Wallet                                                   |
| method  | Functionality that is exposed by the Qubic Wallet and can be invoked by the dApp                   |
| event   | Information that can be pushed from the Qubic Wallet to a dApp without the later making any action |

## Session Establishment

A dApp initializes a connection to the WC servers and generates a connection URL. 
The URL contains information about the dApp and the required _methods_ and _events_ that are going to be used in the connection. 
The URL is passed to the wallet (via QR code scanning or copy-paste). 
The wallet prompts the user to accept or reject the connection.

If rejected, the dApp receives the following response: 
`{code: 5000, message: 'User rejected.'}`

If accepted, the dApp receives a
`SessionConnect` event. This event contains various information, most importantly the _expiration time_(when the session dies) and _topic_(which is an ID)
Once accepted, the connection is established as a session. The session can be active for a few hours to a few days.

## Exposed Methods

### qubic_requestAccounts

Requests all accounts in wallet.

Method parameters: _None_

On success, an array of `RequestAccountsResult` objects is received:

| Property | Type   | Description                           |
| -------- | ------ | ------------------------------------- |
| address  | String | The public ID of the account.         |
| name     | String | The name of the account in the wallet.|
| amount   | Number | The number of Qubic in the wallet.    |


### qubic_sendQubic

Asks the wallet to send Qubic to a specific address (upon confirmation of the user)

Method parameters:

|Param |Type | Description|
|--|--|--|
|from | String | The public ID of the source account.|
|to | String | The public ID of the destination account.|
|amount| Number| The number of Qubic to send. Value must be positive.|

On success, the following data is received:

|Property| Type | Value |
|--|--|--|
|transactionId| String | Transaction unique identifier.|
|tick| Number | The tick that the transfer was scheduled for. This will be calculated as the tick at the moment of the approval + 5 ticks.|

On error, a standard `JsonRpcError` is received. See `JSON-RPC errors` section for more details.


### qubic_signTransaction

Asks the wallet to sign a transaction. The transaction either transfers Qu or invokes a Smart Contract procedure.
The returned `signedTransaction` value can be broadcasted to the network at a later time (i.e using https://rpc.qubic.org/v1/broadcast-transaction)

Method parameters:

|Param |Type | Description|
|--|--|--|
|from | String | The public ID of the source account.|
|to | String | The public ID of the destination account.|
|amount| Number| The number of Qubic to send. Value must be 0 or positive.|
|tick| Number (optional) | If defined, indicates the tick for the transaction. Otherwise, this will be calculated as the tick at the moment of the approval + 5 ticks. |
|inputType|	Number (optional) | Transaction input type. Default value is 0.|
|payload| String (optional) | Payload bytes in base64 format. |

On success, the following data is received:

|Property| Type | Value |
|--|--|--|
|signedTransaction| String | The signed transaction payload.|
|transactionId| String | Transaction unique identifier. |
|tick| Number | The tick that the transfer was signed for.|

On error, a standard `JsonRpcError` is received. See `JSON-RPC errors` section for more details.

### qubic_sendTransaction

Asks the wallet to sign and broadcast a transaction. The transaction either transfers Qu or invokes a Smart Contract procedure.
The parameters are equal to those of qubic_signTransaction.

Method parameters:

|Param |Type | Description|
|--|--|--|
|from | String | The public ID of the source account. |
|to | String | The public ID of the destination account. |
|amount| Number| The number of Qubic to send. Value must be 0 or positive.|
|tick| Number (optional) | If defined, indicates the tick for the transaction. Otherwise, this will be calculated as the tick at the moment of the approval + 5 ticks.|
|inputType|	Number (optional) | Transaction input type. Default value is 0.|
|payload| String (optional) | Payload bytes in base64 format.|

On success, the following data is received:

|Property| Type | Value |
|--|--|--|
|transactionId| String | Transaction unique identifier.|
|tick| Number | The tick that the transfer was scheduled for.|

On error, a standard `JsonRpcError` is received. See `JSON-RPC errors` section for more details.

### qubic_sign

Asks the wallet sign a message.

Method parameters:

|Param |Type | Description|
|--|--|--|
|from | String | The public ID of the account to be used for signing the message.|
|message | String |The message to be signed.|

On success, the following data is received:

|Property| Type | Value |
|--|--|--|
|signedData| String | The signed message. Before creating the signature, the string 'Qubic Signed Message:\n' is prepended to the message.|
|digest| String ||
|signature| String ||

On error, a standard `JsonRpcError` is received. See `JSON-RPC errors` section for more details.

### qubic_sendAsset 

Asks the wallet to transfer assets to a specific address (upon confirmation of the user)

Method parameters:

|Param |Type | Description|
|--|--|--|
|from | String | The public ID of the source account.|
|to | String | The public ID of the destination account.|
|assetName| String| The name of the asset to transfer.|
|issuer| String| The public ID of the issuer of the token to transfer.|
|amount| Number| The amount of tokens to send.|

On success, the following data is received:

|Property| Type | Value |
|--|--|--|
|transactionId| String | Transaction unique identifier.|
|tick| Number | The tick that the transfer was scheduled for.|

On error, a standard `JsonRpcError` is received. See `JSON-RPC errors` section for more details.

## Exposed Events

### accountsChanged

Fires when the accounts in the wallet are changed (added/ renamed / deleted / wallet is launched)

Payload:
`[{"address":"ACDRUPXVDMRVDBVYHUEUTBNNIQOCRXLYSLEZZHHXYGQXITDFCEJB","name":"QH","amount":17483927320},{"address":"ACDRUPXVDMRVDBVYHUEUTBNNIQOCRXLYSLEZZHHXYGQXITDFCEJBBUUBGJGM","name":"QH2","amount":0}]`

|Field |Type |Description |
|--|--|--|
|address | String| The public ID of the account.|
|name | String| The human readable name of the wallet account.|
|amount| Number| The number of Qubics in the account. -1 value indicates the wallet does not have this information for the account.|

### amountChanged

Fires when the Qubic amount in one or more wallet accounts is changed

Payload
`[{"address":"ACDRUPXVDMRVDBVYHUEUTBNNIQOCRXLYSLEZZHHXYGQXITDFCEJB","name":"QH","amount":17483927320},{"address":"ACDRUPXVDMRVDBVYHUEUTBNNIQOCRXLYSLEZZHHXYGQXITDFCEJBBUUBGJGM","name":"QH2","amount":0}]`
|Field |Type |Description|
|--|--|--|
|address | String| The public ID of the account.|
|name | String| The human readable name of the wallet account.|
|amount| Number| The number of Qubics in the account.|

## JSON-RPC errors

| Code | Message | Meaning |
|---|---|---|
| 5000 | User rejected | The user rejected the request |

