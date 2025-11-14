# Certificate Transactions - Implementation Guide

## Overview

Data certification on the Circular Protocol blockchain uses a specific transaction type `C_TYPE_CERTIFICATE` to permanently record data hashes and metadata on-chain.

## Discovery Process

Through testing with the canonical API v1.0.8 against Circular SandBox blockchain, we discovered:

1. **Transaction Type**: `C_TYPE_CERTIFICATE` (found in Java Enterprise APIs)
2. **Signature Format**: DER-encoded ECDSA signatures (matching circular-js reference)
3. **Payload Structure**: JSON with `Action: "CP_CERTIFICATE"` and hex-encoded data
4. **Nonce Management**: Sequential counter, getWalletNonce returns next available nonce

## Working Example

### Successful Transaction

**Transaction ID**: `0xf6c83ca16bc0d63d73767359e7db94958b9a78deac6c466d63acf0c920604f66`

**Result**: `200` (Success)

**Certified Data**:
```json
{
  "document": "test-certification.pdf",
  "hash": "52c2fe6316d5cc2cc84065f6a80357a324ed016fa5ced8cdbd811063d39d2eaf",
  "timestamp": "2025-11-13T17:10:51.432600",
  "description": "Test certificate via canonical API v1.0.8 with DER signature"
}
```

## Transaction Structure

### Request Format

```json
{
  "ID": "0x<transaction_id>",
  "From": "0x<sender_address>",
  "To": "0x<recipient_address>",
  "Timestamp": "YYYY:MM:DD-HH:MM:SS",
  "Type": "C_TYPE_CERTIFICATE",
  "Payload": "<hex_encoded_json>",
  "Nonce": "1",
  "Signature": "<der_encoded_signature>",
  "Blockchain": "0x<blockchain_id>",
  "Version": "1.0.8"
}
```

### Payload Structure

The `Payload` field contains hex-encoded JSON:

```json
{
  "Action": "CP_CERTIFICATE",
  "Data": "<hex_encoded_data_string>"
}
```

**Example**:
```python
data_to_certify = json.dumps({
    "document": "test.pdf",
    "hash": "sha256_hash_here",
    "timestamp": "2025-11-13T17:10:51"
})

payload_obj = {
    "Action": "CP_CERTIFICATE",
    "Data": data_to_certify.encode().hex()
}

payload = json.dumps(payload_obj).encode().hex()
```

## Signature Generation

### Critical: DER Encoding Required

The Circular Protocol requires **DER-encoded** ECDSA signatures, not raw r,s values.

**Python Example**:
```python
import hashlib
from ecdsa import SigningKey, SECP256k1
from ecdsa.util import sigencode_der

# Create signing key
private_key_bytes = bytes.fromhex(PRIVATE_KEY)
sk = SigningKey.from_string(private_key_bytes, curve=SECP256k1)

# Calculate transaction ID
id_input = blockchain + from_addr + to_addr + payload + nonce + timestamp
transaction_id = hashlib.sha256(id_input.encode()).hexdigest()

# Sign the ID (hash it first)
message_hash = hashlib.sha256(transaction_id.encode()).digest()
signature_der_bytes = sk.sign_digest(message_hash, sigencode=sigencode_der)
signature = signature_der_bytes.hex()
```

**TypeScript Example** (circular-js reference):
```javascript
const EC = elliptic.ec;
const ec = new EC('secp256k1');
const key = ec.keyFromPrivate(hexFix(privateKey), 'hex');
const msgHash = sha256(message);

// DER-encoded signature
const signature = key.sign(msgHash).toDER('hex');
```

## Transaction ID Calculation

The transaction ID is a SHA256 hash of concatenated transaction components:

```
ID = SHA256(blockchain + from + to + payload + nonce + timestamp)
```

**Important**:
- All hex values should have `0x` prefix removed before concatenation
- The timestamp is in string format: `YYYY:MM:DD-HH:MM:SS`
- The result is hex-encoded (without `0x` for concatenation)

**Python Example**:
```python
blockchain_hex = BLOCKCHAIN.replace('0x', '')
from_hex = FROM_ADDRESS.replace('0x', '')
to_hex = TO_ADDRESS.replace('0x', '')

id_input = blockchain_hex + from_hex + to_hex + payload + nonce + timestamp
transaction_id = hashlib.sha256(id_input.encode()).hexdigest()
```

## Nonce Management

### Sequential Counter

- Each wallet maintains a nonce counter starting at 0
- Wallet registration uses nonce 0
- Each subsequent transaction increments the nonce
- `getWalletNonce` returns the *next* nonce to use

### Example Flow

```python
# 1. Register wallet (nonce = 0)
register_wallet(...)  # Uses nonce "0"

# 2. Get current nonce
nonce_response = api.get_wallet_nonce(address, blockchain)
# Returns: {"Nonce": 0}

# 3. Next transaction uses nonce 1
certify_data(..., nonce="1")

# 4. After successful transaction, nonce increments
# Next transaction would use nonce "2"
```

## Complete Working Example

```python
#!/usr/bin/env python3
import hashlib
import json
from datetime import datetime
from ecdsa import SigningKey, SECP256k1
from ecdsa.util import sigencode_der
from circular_protocol_api import CircularProtocolAPI

# Configuration
PRIVATE_KEY = 'your_private_key_here'
BLOCKCHAIN = '0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5ad72b2'
ADDRESS = '0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310'

# Initialize
api = CircularProtocolAPI()
sk = SigningKey.from_string(bytes.fromhex(PRIVATE_KEY), curve=SECP256k1)

# Get nonce
nonce_response = api.get_wallet_nonce(address=ADDRESS, blockchain=BLOCKCHAIN)
nonce = str(nonce_response['Response']['Nonce'] + 1)

# Prepare data
data_to_certify = json.dumps({
    "document": "important-document.pdf",
    "hash": hashlib.sha256(b"Document content").hexdigest(),
    "timestamp": datetime.utcnow().isoformat()
})

# Create payload
payload_obj = {
    "Action": "CP_CERTIFICATE",
    "Data": data_to_certify.encode().hex()
}
payload = json.dumps(payload_obj).encode().hex()

# Transaction details
From = ADDRESS.replace('0x', '')
To = From  # Self-transaction for certification
Type = 'C_TYPE_CERTIFICATE'
now = datetime.utcnow()
Timestamp = f"{now.year}:{now.month:02d}:{now.day:02d}-{now.hour:02d}:{now.minute:02d}:{now.second:02d}"

# Calculate ID
blockchain_hex = BLOCKCHAIN.replace('0x', '')
id_input = blockchain_hex + From + To + payload + nonce + Timestamp
ID = hashlib.sha256(id_input.encode()).hexdigest()

# Sign with DER encoding
message_hash = hashlib.sha256(ID.encode()).digest()
signature_der = sk.sign_digest(message_hash, sigencode=sigencode_der)
Signature = signature_der.hex()

# Send transaction
result = api.send_transaction(
    blockchain=BLOCKCHAIN,
    from_address='0x' + From,
    transaction_id='0x' + ID,
    nonce=nonce,
    payload=payload,
    signature=Signature,
    timestamp=Timestamp,
    to_address='0x' + To,
    tx_type=Type
)

if result['Result'] == 200:
    print(f"✅ Certified! TxID: {result['Response']['TxID']}")
else:
    print(f"❌ Error {result['Result']}: {result['Response']}")
```

## Known Transaction Types

Based on testing and API exploration:

1. **`C_TYPE_REGISTERWALLET`** - Wallet registration (working, reference: circular-js.xml)
2. **`C_TYPE_CERTIFICATE`** - Data certification (working, tested 2025-11-13)
3. **`C_TYPE_TRANSACTION`** - Result 117 "Unknown Type" (may be unsupported or incorrect name)

## Error Codes

- **Result 117**: "Invalid Payload [Unknown Type]" - Transaction type not recognized
- **Result 119**: "Invalid Signature" - Signature validation failed (likely not DER-encoded)
- **Result 121**: "Invalid Nonce" - Nonce mismatch (using wrong sequence number)
- **Result 200**: Success

## Integration with Canonical API

### What Needs to be Added to Generators

1. **Transaction Type Constants**:
   ```nickel
   {
     C_TYPE_REGISTERWALLET = "C_TYPE_REGISTERWALLET",
     C_TYPE_CERTIFICATE = "C_TYPE_CERTIFICATE",
   }
   ```

2. **Signature Helpers** (DER encoding):
   - TypeScript: Use elliptic.js `.toDER('hex')`
   - Python: Use ecdsa `sigencode_der`
   - Java: Use BouncyCastle DER encoding
   - PHP: Use `openssl_sign` with appropriate flags

3. **Certificate Helper Functions**:
   ```python
   def certify_data(self, data: dict, private_key: str, blockchain: str):
       # 1. Get nonce
       # 2. Create CP_CERTIFICATE payload
       # 3. Calculate transaction ID
       # 4. Sign with DER encoding
       # 5. Submit transaction
   ```

4. **Transaction ID Calculator**:
   ```python
   def calculate_transaction_id(blockchain, from_addr, to_addr, payload, nonce, timestamp):
       return hashlib.sha256(
           (blockchain + from_addr + to_addr + payload + nonce + timestamp).encode()
       ).hexdigest()
   ```

## Testing Checklist

- [x] Wallet registration works (C_TYPE_REGISTERWALLET)
- [x] Data certification works (C_TYPE_CERTIFICATE)
- [x] DER-encoded signatures accepted
- [x] Nonce management working
- [x] Transaction ID calculation correct
- [ ] Generated SDK matches manual implementation
- [ ] All 6 SDK languages support certificates
- [ ] E2E tests include certificate transactions

## References

- Circular JS Reference: `circular-js.xml` (v1.0.8, C_TYPE_REGISTERWALLET pattern)
- Java Enterprise APIs: `Java-Enterprise-APIs.xml` (C_TYPE_CERTIFICATE discovery)
- Working Test Script: `/tmp/test_certificate_der.py`
- Test Blockchain: Circular SandBox (`0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5ad72b2`)
