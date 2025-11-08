# Feature Parity Analysis

Comparison of circular-js reference implementation vs our generated SDKs.

## Summary

**API Endpoints**: ✅ 24/24 (100% coverage)
**Helper Functions**: ❌ 0/15 (0% coverage)
**Overall Parity**: ⚠️ 62% (24/39 methods)

---

## ✅ API Endpoints (24/24) - COMPLETE

All standard API endpoints are implemented:

### Wallet API (6/6)
- ✅ `checkWallet`
- ✅ `getWallet`
- ✅ `getLatestTransactions`
- ✅ `getWalletBalance`
- ✅ `getWalletNonce`
- ✅ `registerWallet`

### Transaction API (6/6)
- ✅ `sendTransaction`
- ✅ `getPendingTransaction`
- ✅ `getTransactionbyID`
- ✅ `getTransactionbyNode`
- ✅ `getTransactionbyAddress`
- ✅ `getTransactionbyDate`

### Block API (4/4)
- ✅ `getBlock`
- ✅ `getBlockRange`
- ✅ `getBlockCount`
- ✅ `getAnalytics`

### Smart Contract API (2/2)
- ✅ `testContract`
- ✅ `callContract`

### Asset API (4/4)
- ✅ `getAssetList`
- ✅ `getAsset`
- ✅ `getAssetSupply`
- ✅ `getVoucher`

### Domain API (1/1)
- ✅ `getDomain`

### Network API (1/1)
- ✅ `getBlockchains`

---

## ❌ Helper Functions (0/15) - MISSING

### Cryptographic Functions (4 missing)

#### `signMessage(message, privateKey)`
**Purpose**: Sign a message using secp256k1
**Returns**: DER-encoded signature (hex string)
**Dependencies**: elliptic, sha256
**Priority**: 🔴 CRITICAL - Required for transactions

```javascript
// Example
const signature = CircularProtocolAPI.signMessage(
  "Hello World",
  "0f55c0c43496a9c3e1813180bec90e610769e15354771aebe7e28e83b3f89e8a"
);
```

#### `verifySignature(publicKey, message, signature)`
**Purpose**: Verify a signature
**Returns**: boolean
**Dependencies**: elliptic, sha256
**Priority**: 🟡 HIGH - Useful for validation

```javascript
const valid = CircularProtocolAPI.verifySignature(
  publicKey,
  message,
  signature
);
```

#### `getPublicKey(privateKey)`
**Purpose**: Derive public key from private key
**Returns**: Public key (hex string)
**Dependencies**: elliptic
**Priority**: 🔴 CRITICAL - Required for wallet operations

```javascript
const publicKey = CircularProtocolAPI.getPublicKey(privateKey);
```

#### `hashString(str)`
**Purpose**: SHA256 hash of string
**Returns**: Hash (hex string)
**Dependencies**: sha256
**Priority**: 🟡 HIGH - Used for addresses, IDs

```javascript
const hash = CircularProtocolAPI.hashString("test");
```

---

### Configuration Functions (4 missing)

#### `setNAGURL(url)`
**Purpose**: Set custom NAG endpoint
**Default**: `https://nag.circularlabs.io/NAG.php?cep=`
**Priority**: 🟡 HIGH - Required for testnet/devnet

```javascript
CircularProtocolAPI.setNAGURL('https://testnet.circularlabs.io/NAG.php?cep=');
```

#### `getNAGURL()`
**Purpose**: Get current NAG endpoint
**Returns**: URL string
**Priority**: 🟢 MEDIUM

#### `setNAGKey(key)`
**Purpose**: Set NAG API key for authenticated requests
**Priority**: 🟢 MEDIUM

#### `getNAGKey()`
**Purpose**: Get current NAG key
**Returns**: Key string
**Priority**: 🟢 MEDIUM

---

### Encoding/Utility Functions (5 missing)

#### `hexFix(hexString)`
**Purpose**: Normalize hex strings (add/remove 0x prefix)
**Returns**: Normalized hex string
**Priority**: 🟡 HIGH - Used internally

```javascript
const fixed = CircularProtocolAPI.hexFix("0x1234"); // "1234"
const fixed2 = CircularProtocolAPI.hexFix("abcd");  // "abcd"
```

#### `stringToHex(str)`
**Purpose**: Convert string to hex encoding
**Returns**: Hex string
**Priority**: 🟡 HIGH - Required for payloads

```javascript
const hex = CircularProtocolAPI.stringToHex("Hello"); // "48656c6c6f"
```

#### `hexToString(hex)`
**Purpose**: Convert hex to string
**Returns**: String
**Priority**: 🟡 HIGH - Required for reading payloads

```javascript
const str = CircularProtocolAPI.hexToString("48656c6c6f"); // "Hello"
```

#### `getFormattedTimestamp()`
**Purpose**: Generate Circular Protocol timestamp format
**Format**: `YYYY:MM:DD-hh:mm:ss` (UTC)
**Returns**: Formatted timestamp string
**Priority**: 🔴 CRITICAL - Required for transactions

```javascript
const timestamp = CircularProtocolAPI.getFormattedTimestamp();
// "2025:11:08-22:30:45"
```

#### `GetError()` / `handleError(error)`
**Purpose**: Error handling utilities
**Returns**: Last error message
**Priority**: 🟢 MEDIUM

---

### Advanced Functions (2 missing)

#### `getTransactionOutcome(blockchain, txID, timeoutSec, intervalSec)`
**Purpose**: Poll for transaction confirmation
**Behavior**: Recursively checks transaction status until confirmed or timeout
**Returns**: Promise<TransactionResponse>
**Priority**: 🔴 CRITICAL - Required for certificate workflows

```javascript
// Wait up to 120 seconds, checking every 5 seconds
const outcome = await CircularProtocolAPI.getTransactionOutcome(
  "MainNet",
  txID,
  120,  // timeout
  5     // interval
);
```

#### Internal helper: `padNumber(num)`
**Purpose**: Pad single digits with leading zero
**Priority**: 🟢 LOW - Used by getFormattedTimestamp

---

## Priority Implementation Order

### Phase 1: Critical Functions (Required for basic usage)
1. ✅ `getFormattedTimestamp()` - Timestamps for all transactions
2. ✅ `getPublicKey(privateKey)` - Derive wallet address
3. ✅ `signMessage(message, privateKey)` - Sign transactions
4. ✅ `stringToHex(str)` / `hexToString(hex)` - Payload encoding
5. ✅ `hexFix(hexString)` - Normalize addresses
6. ✅ `hashString(str)` - Generate IDs

### Phase 2: High Priority (Common usage)
7. ✅ `setNAGURL(url)` - Configure endpoints
8. ✅ `getTransactionOutcome()` - Wait for confirmation
9. ✅ `verifySignature()` - Validate data

### Phase 3: Medium Priority (Nice to have)
10. ✅ `getNAGURL()` / `getNAGKey()` / `setNAGKey()` - Configuration getters/setters
11. ✅ `GetError()` - Error tracking

---

## Implementation Strategy

### 1. Add Helpers to Nickel Generator

Create `generators/shared/helpers-crypto.ncl`:
```nickel
{
  crypto_helpers = {
    signMessage = { ... },
    verifySignature = { ... },
    getPublicKey = { ... },
    hashString = { ... },
  }
}
```

Create `generators/shared/helpers-encoding.ncl`:
```nickel
{
  encoding_helpers = {
    hexFix = { ... },
    stringToHex = { ... },
    hexToString = { ... },
    getFormattedTimestamp = { ... },
  }
}
```

### 2. Update TypeScript Generator

Inject helper implementations into generated SDK class.

### 3. Update Python Generator

Translate helpers to Python equivalents:
- `elliptic` → `ecdsa` or `cryptography`
- `sha256` → `hashlib`

### 4. Add Dependencies

**TypeScript** (`package.json`):
```json
{
  "dependencies": {
    "elliptic": "^6.5.4",
    "sha256": "^0.2.0"
  }
}
```

**Python** (`pyproject.toml`):
```toml
dependencies = [
    "ecdsa>=0.18.0",
    "cryptography>=41.0.0"
]
```

---

## Testing Requirements

### Unit Tests for Helpers
- Test signature generation and verification
- Test hex encoding/decoding
- Test timestamp format
- Test public key derivation

### Integration Tests
- Test signing real transactions
- Test getTransactionOutcome polling
- Test NAG endpoint configuration

---

## Dependencies Analysis

### circular-js Dependencies
```json
{
  "elliptic": "^6.5.7",
  "node-fetch": "^3.3.2",
  "sha256": "^0.2.0"
}
```

### Our Generated SDK Currently Has
```json
{
  // TypeScript: none
  // Python: requests only
}
```

### What We Need to Add
- ✅ `elliptic` (or equivalent) - secp256k1 crypto
- ✅ `sha256` - hashing
- ✅ Already have `fetch` (native) / `requests` (Python)

---

## Breaking Changes

Adding these helpers will:
- ✅ Increase bundle size (~50KB for elliptic)
- ✅ Add crypto dependencies
- ✅ Change class interface (new methods)
- ✅ Require regeneration of all SDKs

## Next Steps

1. ✅ Add crypto helpers to generators
2. ✅ Add encoding helpers to generators
3. ✅ Add config helpers to generators
4. ✅ Update package dependencies
5. ✅ Regenerate SDKs
6. ✅ Update tests
7. ✅ Test against real Circular Protocol testnet
8. ✅ Update documentation
