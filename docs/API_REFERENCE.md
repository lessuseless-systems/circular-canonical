# Circular Protocol API Reference

Comprehensive reference for all 24+ API endpoints extracted from circular-js v1.0.8.

This document serves as the authoritative source for implementing Nickel definitions in the Canonical project.

## Table of Contents

1. [Wallet Operations](#wallet-operations) (6 endpoints)
2. [Smart Contracts](#smart-contracts) (2 endpoints)
3. [Assets](#assets) (4 endpoints)
4. [Blocks](#blocks) (4 endpoints)
5. [Transactions](#transactions) (6 endpoints)
6. [Domains](#domains) (1 endpoint)
7. [Network](#network) (1 endpoint)
8. [Utility Functions](#utility-functions)

---

## Wallet Operations

### 1. checkWallet

**Description**: Checks if a wallet is registered on the blockchain.

**Method**: POST

**Endpoint**: `Circular_CheckWallet_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where the wallet is registered |
| address | string | Yes | Wallet address (64 or 66 hex characters) |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "Address": string,     // hex-fixed
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,      // 200 for success, 500 for error
  "Response": mixed      // Wallet existence information or error message
}
```

**Example**:
```javascript
await checkWallet("MainNet", "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb");
```

---

### 2. getWallet

**Description**: Retrieves complete wallet information including balance and nonce.

**Method**: POST

**Endpoint**: `Circular_GetWallet_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where the wallet is registered |
| address | string | Yes | Wallet address |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "Address": string,     // hex-fixed
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": {
    "Address": string,
    "Balance": number,
    "Nonce": number,
    // Additional wallet properties
  }
}
```

**Example**:
```javascript
await getWallet("MainNet", "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb");
```

---

### 3. getLatestTransactions

**Description**: Retrieves the latest transactions for a wallet address.

**Method**: POST

**Endpoint**: `Circular_GetLatestTransactions_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where the wallet is registered |
| address | string | Yes | Wallet address |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "Address": string,     // hex-fixed
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": [
    {
      "ID": string,
      "From": string,
      "To": string,
      "Amount": number,
      "Timestamp": string,
      // Additional transaction fields
    }
  ]
}
```

**Example**:
```javascript
await getLatestTransactions("MainNet", "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb");
```

---

### 4. getWalletBalance

**Description**: Retrieves the balance of a specified asset in a wallet.

**Method**: POST

**Endpoint**: `Circular_GetWalletBalance_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where the wallet is registered |
| address | string | Yes | Wallet address |
| asset | string | Yes | Asset name (e.g., 'CIRX') |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "Address": string,     // hex-fixed
  "Asset": string,       // Asset name
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": {
    "Balance": number,
    "Asset": string
  }
}
```

**Example**:
```javascript
await getWalletBalance("MainNet", "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb", "CIRX");
```

---

### 5. getWalletNonce

**Description**: Retrieves the nonce of a wallet (transaction counter).

**Method**: POST

**Endpoint**: `Circular_GetWalletNonce_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where the wallet is registered |
| address | string | Yes | Wallet address |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "Address": string,     // hex-fixed
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": {
    "Nonce": number
  }
}
```

**Example**:
```javascript
await getWalletNonce("MainNet", "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb");
```

---

### 6. registerWallet

**Description**: Registers a wallet on a desired blockchain. The same wallet can be registered on multiple blockchains. Without registration, the wallet will not be reachable on the blockchain.

**Method**: POST (via sendTransaction)

**Endpoint**: Constructs and sends a transaction of type `C_TYPE_REGISTERWALLET`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where the wallet will be registered |
| publicKey | string | Yes | Wallet public key |

**Request Construction**:
```javascript
{
  From: sha256(publicKey),
  To: sha256(publicKey),
  Nonce: '0',
  Type: 'C_TYPE_REGISTERWALLET',
  Payload: stringToHex({
    "Action": "CP_REGISTERWALLET",
    "PublicKey": publicKey
  }),
  Timestamp: getFormattedTimestamp(),
  ID: sha256(blockchain + From + To + Payload + Nonce + Timestamp),
  Signature: ""
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": mixed  // Transaction result
}
```

**Example**:
```javascript
await registerWallet("MainNet", "04abc123...");
```

---

## Smart Contracts

### 7. testContract

**Description**: Tests smart contract execution locally without sending a transaction.

**Method**: POST

**Endpoint**: `Circular_TestContract_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where the smart contract is deployed |
| from | string | Yes | Caller wallet address |
| project | string | Yes | Smart contract project/code |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "From": string,        // hex-fixed
  "Project": string,     // hex-encoded project
  "Timestamp": string,
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": mixed  // Contract execution result
}
```

**Example**:
```javascript
await testContract("MainNet", "0x742d35...", contractCode);
```

---

### 8. callContract

**Description**: Calls a smart contract function on the blockchain.

**Method**: POST

**Endpoint**: `Circular_CallContract_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where the smart contract is deployed |
| from | string | Yes | Caller wallet address |
| address | string | Yes | Smart contract address |
| request | string | Yes | Smart contract local endpoint/function call |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "From": string,        // hex-fixed
  "Address": string,     // hex-fixed
  "Request": string,     // hex-encoded request
  "Timestamp": string,
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": mixed  // Contract call result
}
```

**Example**:
```javascript
await callContract("MainNet", "0x742d35...", "0xContract123...", "functionName");
```

---

## Assets

### 9. getAssetList

**Description**: Retrieves the list of all assets minted on a specific blockchain.

**Method**: POST

**Endpoint**: `Circular_GetAssetList_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where to request the list |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": [
    {
      "AssetName": string,
      // Additional asset properties
    }
  ]
}
```

**Example**:
```javascript
await getAssetList("MainNet");
```

---

### 10. getAsset

**Description**: Retrieves an asset descriptor with complete asset information.

**Method**: POST

**Endpoint**: `Circular_GetAsset_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where the asset is minted |
| name | string | Yes | Asset name (e.g., 'CIRX') |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "AssetName": string,
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": {
    "AssetName": string,
    "TotalSupply": number,
    "Decimals": number,
    "Owner": string,
    // Additional asset properties
  }
}
```

**Example**:
```javascript
await getAsset("MainNet", "CIRX");
```

---

### 11. getAssetSupply

**Description**: Retrieves the total, circulating, and residual supply of a specified asset.

**Method**: POST

**Endpoint**: `Circular_GetAssetSupply_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where the asset is minted |
| name | string | Yes | Asset name (e.g., 'CIRX') |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "AssetName": string,
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": {
    "TotalSupply": number,
    "CirculatingSupply": number,
    "ResidualSupply": number
  }
}
```

**Example**:
```javascript
await getAssetSupply("MainNet", "CIRX");
```

---

### 12. getVoucher

**Description**: Retrieves an existing voucher by code.

**Method**: POST

**Endpoint**: `Circular_GetVoucher_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where the voucher was minted |
| code | string | Yes | Voucher code (with or without 0x prefix) |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "Code": string,        // hex code without 0x prefix
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": {
    "Code": string,
    "Value": number,
    "Asset": string,
    "Redeemed": boolean,
    // Additional voucher properties
  }
}
```

**Example**:
```javascript
await getVoucher("MainNet", "0xVOUCHERCODE123...");
```

**Note**: Code is automatically stripped of 0x prefix if present.

---

## Blocks

### 13. getBlock

**Description**: Retrieves a desired block by block number.

**Method**: POST

**Endpoint**: `Circular_GetBlock_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where to search the block |
| num | number/string | Yes | Block number |

**Request Body**:
```javascript
{
  "Blockchain": string,    // hex-fixed
  "BlockNumber": string,   // converted to string
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": {
    "BlockNumber": number,
    "Timestamp": string,
    "Transactions": array,
    "Hash": string,
    // Additional block properties
  }
}
```

**Example**:
```javascript
await getBlock("MainNet", 12345);
```

---

### 14. getBlockRange

**Description**: Retrieves all blocks in a specified range. If End = 0, then Start is the number of blocks from the last one minted going backward.

**Method**: POST

**Endpoint**: `Circular_GetBlockRange_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where to search the blocks |
| start | number/string | Yes | Initial block (or count from end if end=0) |
| end | number/string | Yes | End block (or 0 for backward count) |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "Start": string,       // converted to string
  "End": string,         // converted to string
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": [
    {
      "BlockNumber": number,
      "Timestamp": string,
      "Transactions": array,
      // Additional block properties
    }
  ]
}
```

**Example**:
```javascript
// Get blocks 100 to 200
await getBlockRange("MainNet", 100, 200);

// Get last 50 blocks
await getBlockRange("MainNet", 50, 0);
```

---

### 15. getBlockCount

**Description**: Retrieves the blockchain block height (total number of blocks).

**Method**: POST

**Endpoint**: `Circular_GetBlockCount_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where to count the blocks |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": {
    "BlockCount": number
  }
}
```

**Example**:
```javascript
await getBlockCount("MainNet");
```

**Note**: This is also referred to as `getBlockHeight` in some documentation.

---

### 16. getAnalytics

**Description**: Retrieves blockchain analytics and statistics.

**Method**: POST

**Endpoint**: `Circular_GetAnalytics_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Selected blockchain |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": {
    "TotalTransactions": number,
    "TotalWallets": number,
    "TotalAssets": number,
    "BlockHeight": number,
    // Additional analytics
  }
}
```

**Example**:
```javascript
await getAnalytics("MainNet");
```

---

## Transactions

### 17. sendTransaction

**Description**: Submits a transaction to the blockchain.

**Method**: POST

**Endpoint**: `Circular_SendTransaction_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| id | string | Yes | Transaction ID (hash of tx components) |
| from | string | Yes | Sender wallet address |
| to | string | Yes | Recipient wallet address |
| timestamp | string | Yes | Transaction timestamp |
| type | string | Yes | Transaction type |
| payload | string | Yes | Transaction payload (hex-encoded) |
| nonce | string | Yes | Wallet nonce |
| signature | string | Yes | Transaction signature |
| blockchain | string | Yes | Target blockchain |

**Request Body**:
```javascript
{
  "ID": string,          // hex-fixed
  "From": string,        // hex-fixed
  "To": string,          // hex-fixed
  "Timestamp": string,
  "Type": string,        // hex-fixed
  "Payload": string,     // hex-fixed
  "Nonce": string,
  "Signature": string,   // hex-fixed
  "Blockchain": string,  // hex-fixed
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": {
    "TransactionID": string,
    "Status": string,  // "pending", "confirmed", etc.
  }
}
```

**Example**:
```javascript
await sendTransaction(
  txId,
  "0x742d35...",
  "0x123456...",
  timestamp,
  "C_TYPE_TRANSACTION",
  payloadHex,
  "5",
  signature,
  "MainNet"
);
```

---

### 18. getPendingTransaction

**Description**: Searches for a transaction by ID among pending transactions.

**Method**: POST

**Endpoint**: `Circular_GetPendingTransaction_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where to search the transaction |
| TxID | string | Yes | Transaction ID |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "ID": string,          // hex-fixed
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": {
    "ID": string,
    "From": string,
    "To": string,
    "Status": "pending",
    // Additional transaction fields
  }
}
```

**Example**:
```javascript
await getPendingTransaction("MainNet", "0xTXID123...");
```

---

### 19. getTransactionbyID

**Description**: Finds a transaction by ID within a specified block range.

**Method**: POST

**Endpoint**: `Circular_GetTransactionbyID_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where to search |
| TxID | string | Yes | Transaction ID |
| start | number/string | Yes | Start block |
| end | number/string | Yes | End block |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "ID": string,          // hex-fixed
  "Start": string,       // converted to string
  "End": string,         // converted to string
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": {
    "ID": string,
    "From": string,
    "To": string,
    "BlockNumber": number,
    "Timestamp": string,
    // Additional transaction fields
  }
}
```

**Example**:
```javascript
await getTransactionbyID("MainNet", "0xTXID123...", 0, 1000);
```

---

### 20. getTransactionbyNode

**Description**: Finds transactions by node ID within a specified block range.

**Method**: POST

**Endpoint**: `Circular_GetTransactionbyNode_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where to search |
| nodeID | string | Yes | Node ID |
| start | number/string | Yes | Start block |
| end | number/string | Yes | End block |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "NodeID": string,      // hex-fixed
  "Start": string,       // converted to string
  "End": string,         // converted to string
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": [
    {
      "ID": string,
      "NodeID": string,
      "BlockNumber": number,
      // Additional transaction fields
    }
  ]
}
```

**Example**:
```javascript
await getTransactionbyNode("MainNet", "NODE123", 0, 1000);
```

---

### 21. getTransactionbyAddress

**Description**: Finds transactions by wallet address within a specified block range.

**Method**: POST

**Endpoint**: `Circular_GetTransactionbyAddress_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where to search |
| address | string | Yes | Wallet address (sender or recipient) |
| start | number/string | Yes | Start block |
| end | number/string | Yes | End block |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "Address": string,     // hex-fixed
  "Start": string,       // converted to string
  "End": string,         // converted to string
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": [
    {
      "ID": string,
      "From": string,
      "To": string,
      "BlockNumber": number,
      // Additional transaction fields
    }
  ]
}
```

**Example**:
```javascript
await getTransactionbyAddress("MainNet", "0x742d35...", 0, 1000);
```

---

### 22. getTransactionbyDate

**Description**: Finds transactions by wallet address within a specified date range.

**Method**: POST

**Endpoint**: `Circular_GetTransactionbyDate_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| Blockchain | string | Yes | Blockchain where to search |
| Address | string | Yes | Wallet address |
| StartDate | string | Yes | Start date (format: YYYY-MM-DD or timestamp) |
| EndDate | string | Yes | End date (format: YYYY-MM-DD or timestamp) |

**Request Body**:
```javascript
{
  "Blockchain": string,   // hex-fixed
  "Address": string,      // hex-fixed
  "StartDate": string,
  "EndDate": string,
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": [
    {
      "ID": string,
      "From": string,
      "To": string,
      "Timestamp": string,
      // Additional transaction fields
    }
  ]
}
```

**Example**:
```javascript
await getTransactionbyDate("MainNet", "0x742d35...", "2024-01-01", "2024-12-31");
```

**Note**: Parameter names use capital letters (Blockchain, Address, StartDate, EndDate) unlike other endpoints.

---

### 23. getTransactionOutcome

**Description**: Waits for and retrieves the outcome of a transaction, with timeout support.

**Method**: Polling-based (multiple POST requests)

**Endpoint**: Uses `getPendingTransaction` and `getTransactionbyID`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where transaction was sent |
| TxID | string | Yes | Transaction ID |
| timeoutSec | number | Yes | Timeout in seconds |

**Implementation**:
- Polls every 5 seconds for transaction confirmation
- Returns when transaction is confirmed or timeout reached
- Uses `getPendingTransaction` and `getTransactionbyID` internally

**Response**:
```javascript
{
  "Result": number,
  "Response": {
    "ID": string,
    "Status": string,  // "confirmed" or "timeout"
    "BlockNumber": number,
    // Additional transaction fields
  }
}
```

**Example**:
```javascript
// Wait up to 60 seconds for transaction confirmation
await getTransactionOutcome("MainNet", "0xTXID123...", 60);
```

---

## Domains

### 24. getDomain

**Description**: Resolves a domain name to a wallet address. A single wallet can have multiple domain associations.

**Method**: POST

**Endpoint**: `Circular_GetDomain_<NETWORK_NODE>`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| blockchain | string | Yes | Blockchain where domain and wallet are registered |
| name | string | Yes | Domain name |

**Request Body**:
```javascript
{
  "Blockchain": string,  // hex-fixed
  "Domain": string,      // domain name
  "Version": "1.0.8"
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": {
    "Domain": string,
    "Address": string,   // Resolved wallet address
  }
}
```

**Example**:
```javascript
await getDomain("MainNet", "myname.circular");
```

**Note**: Also referred to as `resolveDomain` in some documentation.

---

## Network

### 25. getBlockchains

**Description**: Retrieves the list of blockchains available in the network.

**Method**: POST

**Endpoint**: `Circular_GetBlockchains_<NETWORK_NODE>`

**Parameters**: None

**Request Body**:
```javascript
{
  // Empty body or minimal version info
}
```

**Response**:
```javascript
{
  "Result": number,
  "Response": [
    {
      "Name": string,      // e.g., "MainNet", "TestNet"
      "ChainID": string,
      "Active": boolean,
      // Additional blockchain properties
    }
  ]
}
```

**Example**:
```javascript
await getBlockchains();
```

---

## Utility Functions

The following are helper functions exported by the library but are not blockchain API endpoints:

### Configuration
- **setNAGKey(key)**: Sets the Network Access Gateway key
- **getNAGKey()**: Gets the current NAG key
- **setNAGURL(url)**: Sets the NAG URL
- **getNAGURL()**: Gets the current NAG URL
- **setNode(address)**: Sets the network node address
- **getVersion()**: Returns library version (currently "1.0.8")

### Cryptography
- **signMessage(message, privateKey)**: Signs a message with ECDSA
- **verifySignature(publicKey, message, signature)**: Verifies an ECDSA signature
- **getPublicKey(privateKey)**: Derives public key from private key

### Encoding/Formatting
- **hexFix(word)**: Normalizes hex strings (removes/adds 0x prefix)
- **stringToHex(str)**: Converts string to hex encoding
- **hexToString(hex)**: Converts hex to string
- **getFormattedTimestamp()**: Returns formatted timestamp (YYYY-MM-DD:HH:MM:SS)

---

## Common Patterns

### Error Handling

All API functions return a consistent error format:
```javascript
{
  "Result": 500,
  "Response": "Error: <error message>"
}
```

Success responses typically have:
```javascript
{
  "Result": 200,
  "Response": <data>
}
```

### Hex Fixing

Most string parameters (blockchain, addresses, IDs) are passed through `hexFix()` which:
1. Converts to string
2. Removes 0x prefix if present
3. Adds back 0x prefix if needed

### Version

All requests include `"Version": "1.0.8"` in the request body.

### HTTP Method

All API endpoints use POST method with JSON body, despite many being read operations.

---

## Implementation Notes for Nickel Canonical

1. **Parameter Names**: Note inconsistencies:
   - Most use lowercase: `blockchain`, `address`
   - `getTransactionbyDate` uses capital: `Blockchain`, `Address`, `StartDate`, `EndDate`
   - Should normalize to camelCase in Canonical

2. **Endpoint Naming**:
   - `getTransactionbyID` (lowercase 'by') in actual API
   - Could normalize to `getTransactionByID` in Canonical

3. **Optional Parameters**:
   - Most blockchains default to "MainNet" if not specified
   - Consider making blockchain optional with default in Canonical

4. **Type Conversions**:
   - Numbers converted to strings in request bodies (block numbers, nonces)
   - Should handle both number and string inputs gracefully

5. **Response Standardization**:
   - All APIs return `{Result, Response}` structure
   - Result: 200 (success), 500 (error)
   - Should define standard error contract in Nickel

6. **Hex Encoding**:
   - Addresses: 64 or 66 characters (with/without 0x)
   - Payload: hex-encoded JSON strings
   - Should define Address contract to validate length and hex format

7. **Missing Documentation**:
   - Response schemas are not fully documented in code
   - May need to test against live API to confirm exact response structures
   - Could extract from tests if circular-js has comprehensive test suite

---

## Total API Count

| Category | Count |
|----------|-------|
| Wallet Operations | 6 |
| Smart Contracts | 2 |
| Assets | 4 |
| Blocks | 4 |
| Transactions | 6 |
| Domains | 1 |
| Network | 1 |
| **TOTAL** | **24** |

Plus 1 helper function (getTransactionOutcome) that uses other APIs internally.

---

**Reference**: circular-js v1.0.8 (Last Update: 28/01/2025)
**License**: Open Source for private and commercial use
**Authors**: Gianluca De Novi, PhD; Danny De Novi
