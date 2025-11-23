# WalletConnect Integration

## Terminology

| Term      | Explanation                                                                                             |
| :-------- | :------------------------------------------------------------------------------------------------------ |
| dApp      | A (web3) application that needs access to the Qubic Wallet.                                             |
| Session   | A connection between a dApp and the Qubic Wallet.                                                      |
| Chain ID | Identifier of the blockchain network. For Qubic wallet, it's `qubic:mainnet`. |
| Method    | Functionality exposed by the Qubic Wallet that can be invoked by the dApp.                             |
| Event     | Information that the Qubic Wallet can push to a dApp without the dApp initiating a request.             |

## Session Establishment

When a dApp initiates a WalletConnect connection, it specifies required namespaces, including the Qubic Mainnet chain ID, along with details about the dApp and the necessary methods and events. This information is encoded within the generated URL. The URL is then shared with the Qubic Wallet (via QR code or copy-paste), prompting the user to either accept or reject the connection.

**Example:**

```json
{
  "requiredNamespaces": {
    "qubic": {
      "chains": ["qubic:mainnet"],
      "methods": ["qubic_requestAccounts", "qubic_sendQubic", "qubic_signTransaction", "qubic_sendTransaction", "qubic_sign", "qubic_sendAsset"],
      "events": ["accountsChanged", "amountChanged", "assetAmountChanged"]
    }
  }
}
```

If the connection is rejected, the dApp receives the following response:
`{ code: 5000, message: 'User rejected.' }`

If accepted, the dApp receives a `SessionConnect` event containing information such as the *expiration time* (when the session expires) and *topic* (a unique ID). Once accepted, the connection is established as a session, which can remain active for a few hours to a few days.

## WalletConnect Mobile Linking

### How It Works

Mobile linking enables seamless communication between the Qubic Wallet and dApps using deep links, ensuring a smooth user experience with minimal interaction.

### Connection Flow

1.  **Dapp requests connection:** The dApp generates a WalletConnect URI and sends it using a deep link.

    -   Example:

        ```
        qubic-wallet://pairwc/wc:<session-id>@2?expiryTimestamp=<timestamp>&relay-protocol=irn&symKey=<key>
        ```

    -   Example with real values:

        ```
        qubic-wallet://pairwc/wc:bbea07131b87b98b819697298fbf0e02470f80c6aa31ff0da87f7f8e69daacea@2?expiryTimestamp=1738400769&relay-protocol=irn&symKey=79817979c7230496d451b3f46bd0be62fb698f78bd605a3cec49152a03533ba1
        ```

2.  **Wallet opens and prompts approval:** The user approves or rejects the connection.

3.  **User is redirected back:** If the dApp provides redirect links in the `SessionProposalEvent` metadata (`args?.params.proposer.metadata.redirect`), Qubic Wallet will automatically redirect the user after approval or rejection.

    -   The dApp should include at least one of the following:
        -   **Native deep link:** `metadata.redirect.native`
        -   **Universal link (fallback):** `metadata.redirect.universal`

### Custom Links in Qubic Wallet

Qubic Wallet deep links securely handle both connection requests and method callbacks.

*   **Custom URL Scheme:** Ensures only valid WalletConnect links are processed.
*   **Automatic Handling:** The app detects and processes WalletConnect links when opened.

## Exposed Methods

The dApp can optionally use deep links after sending a method request using `qubic-wallet://open` schema that will open the Qubic Wallet. After the user approves the request in the Qubic Wallet, and if the `redirectUrl` parameter is provided, the Qubic Wallet will redirect back to the dApp using the provided URL.

### qubic_requestAccounts

Requests all accounts in the wallet. This method provides the dApp with information about the accounts, including balances and associated assets.

**Method parameters:** *None*

On success, an array of `RequestAccountsResult` objects is received:

| Property | Type   | Description                                 |
| :------- | :----- | :------------------------------------------ |
| address  | String | The public ID of the account.               |
| name    | String | The name of the account in the wallet.      |
| amount   | Number | The number of Qubic in the wallet.          |
| assets   | Array | An array containing the assets associated with this account. Each element represents a single asset. |
| assets[index] | Object | An object containing the details of a specific asset. |
| assets[index].assetName | String | The name of the asset. |
| assets[index].issuerIdentity | String | The public ID of the issuer of the asset. |
| assets[index].ownedAmount | Number | The balance of the specified asset in the account.	|
| assets[index].managingContractIndex | Number | The index of the smart contract managing this asset. |

### qubic_sendQubic

Asks the wallet to send Qubic to a specific address (upon user confirmation).

**Method parameters:**

| Param  | Type   | Description                             |
| :----- | :----- | :-------------------------------------- |
| from | String | The public ID of the source account.    |
| to   | String | The public ID of the destination account. |
| amount| Number | The number of Qubic to send. Must be positive. |
| redirectUrl | String (optional) | The deep or universal link for the dApp to redirect back |


On success, the following data is received:

| Property        | Type   | Value                         |
| :-------------- | :----- | :---------------------------- |
| transactionId | String | Transaction unique identifier. |
| tick          | Number | Tick the transfer is scheduled for. (Approval time + 5 ticks) |

On error, a standard `JsonRpcError` is received. See the `JSON-RPC errors` section for more details.

### qubic_signTransaction

Asks the wallet to sign a transaction. The transaction either transfers Qu or invokes a Smart Contract procedure. The returned `signedTransaction` value can be broadcasted to the network at a later time (e.g., using `https://rpc.qubic.org/v1/broadcast-transaction`).

**Method parameters:**

| Param       | Type     | Description                                                                                       |
| :---------- | :------- | :------------------------------------------------------------------------------------------------ |
| from      | String   | The public ID of the source account.                                                              |
| to        | String   | The public ID of the destination account.                                                            |
| amount    | Number   | The number of Qubic to send. Must be 0 or positive.                                                 |
| tick     | Number  (optional)| If defined, indicates the tick for the transaction. Otherwise, it will be calculated as the tick at the moment of approval + 5 ticks.|
| inputType | Number (optional)  | Transaction input type. Default value is 0.                                                          |
| payload   | String (optional)  | Payload bytes in base64 format.                                                               |
| redirectUrl| String (optional)  | The deep or universal link for the dApp to redirect back  |

On success, the following data is received:

| Property          | Type   | Value                                     |
| :---------------- | :----- | :---------------------------------------- |
| signedTransaction| String | The signed transaction payload.            |
| transactionId   | String | Transaction unique identifier.           |
| tick            | Number | The tick that the transfer was signed for.|

On error, a standard `JsonRpcError` is received. See the `JSON-RPC errors` section for more details.

### qubic_sendTransaction

Asks the wallet to sign and broadcast a transaction. The transaction either transfers Qu or invokes a Smart Contract procedure. The parameters are the same as `qubic_signTransaction`.

**Method parameters:**

| Param       | Type     | Description                                                                                       |
| :---------- | :------- | :------------------------------------------------------------------------------------------------ |
| from      | String   | The public ID of the source account.                                                              |
| to        | String   | The public ID of the destination account.                                                            |
| amount    | Number   | The number of Qubic to send. Must be 0 or positive.                                                 |
| tick     | Number (optional) | If defined, indicates the tick for the transaction. Otherwise, it will be calculated as the tick at the moment of approval + 5 ticks.|
| inputType | Number (optional)  | Transaction input type. Default value is 0.                                                          |
| payload   | String (optional) | Payload bytes in base64 format.                                                              |
| redirectUrl| String (optional)  | The deep or universal link for the dApp to redirect back  |


On success, the following data is received:

| Property        | Type   | Value                         |
| :-------------- | :----- | :---------------------------- |
| transactionId | String | Transaction unique identifier.|
| tick          | Number | The tick the transfer is scheduled for. |

On error, a standard `JsonRpcError` is received. See the `JSON-RPC errors` section for more details.

### qubic_sign

Asks the wallet to sign a message.

**Method parameters:**

| Param   | Type   | Description                                                                 |
| :------ | :----- | :-------------------------------------------------------------------------- |
| from  | String | The public ID of the account to be used for signing the message.            |
| message| String | The message to be signed.                                                  |
| redirectUrl| String (optional)  | The deep or universal link for the dApp to redirect back                |

On success, the following data is received:

| Property    | Type   | Value                                                                                                     |
| :---------- | :----- | :---------------------------------------------------------------------------------------------------------- |
| signedData| String | The signed message. Before creating the signature, the string `'Qubic Signed Message:\n'` is prepended to the message. |
| digest    | String |                                                                                                            |
| signature | String |                                                                                                            |

On error, a standard `JsonRpcError` is received. See the `JSON-RPC errors` section for more details.

### qubic_sendAsset

Asks the wallet to transfer assets to a specific address (upon user confirmation).

**Important:** This method only supports transferring assets managed by the QX smart contract (contract index 1). Assets managed by other contracts cannot be transferred through this method.

**Method parameters:**

| Param       | Type   | Description                                     |
| :---------- | :----- | :---------------------------------------------- |
| from      | String | The public ID of the source account.            |
| to        | String | The public ID of the destination account.         |
| assetName | String | The name of the asset to transfer.              |
| issuer    | String | The public ID of the issuer of the token to transfer. |
| amount    | Number | The amount of tokens to send.                  |
| redirectUrl| String (optional)  | The deep or universal link for the dApp to redirect back  |

On success, the following data is received:

| Property        | Type   | Value                         |
| :-------------- | :----- | :---------------------------- |
| transactionId | String | Transaction unique identifier.|
| tick          | Number | The tick the transfer is scheduled for. |

On error, a standard `JsonRpcError` is received. See the `JSON-RPC errors` section for more details.

## Exposed Events

### accountsChanged

Fires when the accounts in the wallet are changed (added/renamed/deleted/wallet is launched).

**Payload:**

```json
[
  {
    "address": "ACDRUPXVDMRVDBVYHUEUTBNNIQOCRXLYSLEZZHHXYGQXITDFCEJB",
    "name": "QH",
    "amount": 17483927320
  },
  {
    "address": "ACDRUPXVDMRVDBVYHUEUTBNNIQOCRXLYSLEZZHHXYGQXITDFCEJBBUUBGJGM",
    "name": "QH2",
    "amount": 0
  }
]
```

| Field   | Type   | Description                                                   |
| :------ | :----- | :------------------------------------------------------------ |
| address| String | The public ID of the account.                                 |
| name  | String | The human-readable name of the wallet account.                |
| amount| Number | The number of Qubics in the account. (-1 if wallet does not have this information for the account)|

### amountChanged

Fires when the Qubic amount in one or more wallet accounts changes.

**Payload:**

```json
[
  {
    "address": "ACDRUPXVDMRVDBVYHUEUTBNNIQOCRXLYSLEZZHHXYGQXITDFCEJB",
    "name": "QH",
    "amount": 17483927320
  },
  {
    "address": "ACDRUPXVDMRVDBVYHUEUTBNNIQOCRXLYSLEZZHHXYGQXITDFCEJBBUUBGJGM",
    "name": "QH2",
    "amount": 0
  }
]
```

| Field   | Type   | Description                           |
| :------ | :----- | :------------------------------------ |
| address| String | The public ID of the account.         |
| name  | String | The human-readable name of the wallet account.|
| amount| Number | The number of Qubics in the account. |


### assetAmountChanged

Fires when the amount of a specific asset in one or more wallet accounts changes.

**Payload:**

```json
[
  {
    "address": "RBMXEFMDFABRTBJIYIBOQZMAWKWCPMJIQVEQDKONOFPEFWLMXQECDGEBIRBM",
    "name": "Account 1",
    "assets": [
      {
        "assetName": "CFB",
        "issuerIdentity": "CFBMEMZOIDEXQAUXYYSZIURADQLAPWPMNJXQSNVQZAHYVOPYUKKJBJUCTVJL",
        "ownedAmount": 1288696,
        "managingContractIndex": 1
      }
    ]
  },
  {
    "address": "NVGZSPIDZNQNYCLWBVFGCJPZODZBMUVHNYJGLFETXCMCNBVFEDOCSCNGOSSK",
    "name": "Account 2",
    "assets": []
  }
]
```

| Field   | Type   | Description                                                   |
| :------ | :----- | :------------------------------------------------------------ |
| address| String | The public ID of the account.                                 |
| name  | String | The human-readable name of the wallet account.                |
| assets   | Array | An array containing the assets that have changed for this account. Each element represents a single asset. |
| assets[index] | Object | An object containing the details of a specific asset. |
| assets[index].assetName | String | The name of the asset. |
| assets[index].issuerIdentity | String | The public ID of the issuer of the asset. |
| assets[index].ownedAmount | Number | The balance of the specified asset in the account.	|
| assets[index].managingContractIndex | Number | The index of the smart contract managing this asset. |

## JSON-RPC errors

| Code | Message        | Meaning                      |
| :--- | :------------- | :--------------------------- |
| -32001 |  User is unavailable | The request comes while the user have another existing one. |
| -32002 | Tick expired | The tick the user sends became expired during the approval. |
| -32602 | Invalid argument(s) | The dApp didn't send valid parameters. |
| -32603 | Internal error | Unexpected internal error occurs. |
| 5000 | User rejected | The user rejected the request. |

## Testing & Development

Test the WalletConnect integration with our live demo app: **[https://qubic.github.io/wallet-app-dapp/](https://qubic.github.io/wallet-app-dapp/)**

## References

For more details on WalletConnect integration, please refer to the official [Documentation](https://docs.reown.com/).

```

