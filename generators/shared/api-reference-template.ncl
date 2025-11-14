# Shared API Reference Template
# Comprehensive method documentation for all SDK READMEs

{
  api_reference_markdown = m%"
### Wallet Operations (5 methods)

- **`checkWallet`** - Verify wallet existence on the blockchain
- **`getWallet`** - Retrieve complete wallet details and metadata
- **`getLatestTransactions`** - Get recent wallet activity and transaction history
- **`getWalletBalance`** - Query current wallet balance across assets
- **`getWalletNonce`** - Get transaction nonce for the wallet

### Transaction Operations (6 methods)

- **`sendTransaction`** - Submit new transaction to the blockchain
- **`getPendingTransaction`** - Check transaction status in the mempool
- **`getTransactionbyID`** - Query transaction by unique identifier
- **`getTransactionbyNode`** - Query transactions by validator node
- **`getTransactionbyAddress`** - Query all transactions for a wallet address
- **`getTransactionbyDate`** - Query transactions within a date range

### Block Operations (4 methods)

- **`getBlock`** - Retrieve block data by block number or hash
- **`getBlockRange`** - Query multiple blocks within a range
- **`getBlockCount`** - Get current blockchain height (latest block number)
- **`getAnalytics`** - Retrieve blockchain performance metrics and analytics

### Contract Operations (2 methods)

- **`testContract`** - Validate smart contract logic before deployment
- **`callContract`** - Execute smart contract function call

### Asset Operations (4 methods)

- **`getAssetList`** - List all available assets on the blockchain
- **`getAsset`** - Get detailed asset information and metadata
- **`getAssetSupply`** - Query total and circulating supply for an asset
- **`getVoucher`** - Retrieve voucher data and redemption details

### Domain Operations (1 method)

- **`getDomain`** - Query blockchain domain registry (resolve domain to address)

### Network Operations (1 method)

- **`getBlockchains`** - List all supported blockchain networks

---

### Cryptographic Helpers (5 methods)

- **`signMessage`** - Generate ECDSA secp256k1 signatures (DER format)
- **`verifySignature`** - Verify message signatures against public keys
- **`getPublicKey`** - Derive public key from private key (128 hex characters, uncompressed, no 0x04 prefix)
- **`hashString`** - Generate SHA-256 hash of string input
- **`getFormattedTimestamp`** - Get current UTC timestamp in Circular Protocol format (`YYYY:MM:DD-HH:mm:ss`)

**Implementation Details:**
- **TypeScript/JavaScript**: `crypto-browserify` (browser-compatible)
- **Python**: `ecdsa` + `hashlib` (standard library)
- **Java**: Bouncy Castle library for secp256k1
- **PHP**: `phpseclib3` elliptic curve cryptography
- **Go**: `btcsuite/btcd/btcec/v2` secp256k1
- **Dart**: `pointycastle` package

---

### Encoding Helpers (4 methods)

- **`hexFix`** - Normalize hex strings (remove `0x` prefix if present)
- **`stringToHex`** - Convert UTF-8 string to hexadecimal encoding
- **`hexToString`** - Convert hexadecimal string to UTF-8
- **`padNumber`** - Zero-pad single-digit numbers (e.g., `5` → `"05"`)

---

### Advanced Helpers (3 methods)

- **`GetError`** - Retrieve last error message from SDK
- **`handleError`** - Internal error tracking and logging
- **`getTransactionOutcome`** - Poll for transaction confirmation with automatic retries

**Transaction Polling Behavior:**
- Checks transaction status every **5 seconds** (configurable via `intervalSec`)
- Returns successfully when transaction has `BlockNumber > 0` (confirmed)
- Throws timeout error after **120 seconds** (configurable via `timeoutSec`)
- Handles "pending" status gracefully with automatic retries
- Distinguishes between temporary "pending" and permanent errors

---

### Convenience Methods (1 method)

- **`registerWallet`** - Simplified wallet registration (wraps `sendTransaction`)

**Implementation:**
- Automatically derives `From` and `To` addresses via `hashString(publicKey)`
- Constructs transaction payload: `{"Action": "CP_WALLET", "PublicKey": "..."}`
- Sets default values: `Nonce="00000000"`, `Type="C"`, `Signature="0000..."`
- Calculates transaction ID as SHA-256 hash of transaction fields
- Returns same response structure as `sendTransaction`

---

## 📊 Total Methods: 39

- **23** API Endpoint Methods
- **5** Cryptographic Helpers
- **4** Encoding Helpers
- **3** Advanced Helpers
- **3** Configuration Methods (getNagUrl, setNagUrl, getNagKey, setNagKey, setHeader, etc.)
- **1** Convenience Method
"%,
}
