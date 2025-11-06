# Circular Protocol SDK Examples

Complete examples for using the TypeScript and Python SDKs.

## Setup

### TypeScript
```typescript
import { CircularProtocolAPI } from './dist/sdk/circular-protocol'

const api = new CircularProtocolAPI('https://api.circular.network')
```

### Python
```python
from circular_protocol import CircularProtocolAPI

api = CircularProtocolAPI('https://api.circular.network')
```

## Wallet Operations

### Check Wallet Existence

**TypeScript:**
```typescript
const result = await api.checkWallet({
  Blockchain: 'MainNet',
  Address: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
  Version: '2.0.0-alpha.1'
})

if (result.Result === 200) {
  console.log('Wallet exists:', result.Response.exists)
}
```

**Python:**
```python
result = api.check_wallet(
    blockchain='MainNet',
    address='0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
)

if result['Result'] == 200:
    print(f"Wallet exists: {result['Response']['exists']}")
```

### Get Wallet Balance

**TypeScript:**
```typescript
const balance = await api.getWalletBalance({
  Blockchain: 'MainNet',
  Address: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
  Asset: 'CIRX',
  Version: '2.0.0-alpha.1'
})

console.log('Balance:', balance.Response.Balance, balance.Response.Asset)
```

**Python:**
```python
balance = api.get_wallet_balance(
    blockchain='MainNet',
    address='0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
    asset='CIRX'
)

print(f"Balance: {balance['Response']['Balance']} {balance['Response']['Asset']}")
```

## Transaction Operations

### Send Transaction

**TypeScript:**
```typescript
const tx = await api.sendTransaction({
  ID: '0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd',
  From: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
  To: '0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
  Timestamp: '2024-01-15:10:30:00',
  Type: 'C_TYPE_TRANSACTION',
  Payload: '0x48656c6c6f',
  Nonce: '5',
  Signature: '0xsig123',
  Blockchain: 'MainNet',
  Version: '2.0.0-alpha.1'
})

console.log('Transaction ID:', tx.Response.TransactionID)
console.log('Status:', tx.Response.Status)
```

**Python:**
```python
tx = api.send_transaction(
    transaction_id='0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd',
    from_address='0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
    to_address='0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
    timestamp='2024-01-15:10:30:00',
    tx_type='C_TYPE_TRANSACTION',
    payload='0x48656c6c6f',
    nonce='5',
    signature='0xsig123',
    blockchain='MainNet'
)

print(f"Transaction ID: {tx['Response']['TransactionID']}")
print(f"Status: {tx['Response']['Status']}")
```

## Block Operations

### Get Block

**TypeScript:**
```typescript
const block = await api.getBlock({
  Blockchain: 'MainNet',
  BlockNumber: '12345',
  Version: '2.0.0-alpha.1'
})

console.log('Block:', block.Response.BlockNumber)
console.log('Hash:', block.Response.Hash)
```

**Python:**
```python
block = api.get_block(
    blockchain='MainNet',
    block_number='12345'
)

print(f"Block: {block['Response']['BlockNumber']}")
print(f"Hash: {block['Response']['Hash']}")
```

## Error Handling Example

**TypeScript:**
```typescript
async function safeWalletCheck(address: string) {
  try {
    const result = await api.checkWallet({
      Blockchain: 'MainNet',
      Address: address,
      Version: '2.0.0-alpha.1'
    })

    if (result.Result === 200) {
      return result.Response.exists
    } else {
      console.error('API error:', result.Response)
      return null
    }
  } catch (error) {
    console.error('Request failed:', error)
    return null
  }
}
```

**Python:**
```python
import requests

def safe_wallet_check(address: str):
    try:
        result = api.check_wallet(
            blockchain='MainNet',
            address=address
        )

        if result['Result'] == 200:
            return result['Response']['exists']
        else:
            print(f"API error: {result['Response']}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None
```

## Complete Application Example

### TypeScript Application

```typescript
import { CircularProtocolAPI } from './dist/sdk/circular-protocol'

class WalletMonitor {
  private api: CircularProtocolAPI

  constructor(apiUrl: string, apiKey?: string) {
    this.api = new CircularProtocolAPI(apiUrl, apiKey)
  }

  async monitorWallet(address: string) {
    // Check wallet exists
    const exists = await this.api.checkWallet({
      Blockchain: 'MainNet',
      Address: address,
      Version: '2.0.0-alpha.1'
    })

    if (!exists.Response.exists) {
      console.log('Wallet does not exist')
      return
    }

    // Get wallet info
    const wallet = await this.api.getWallet({
      Blockchain: 'MainNet',
      Address: address,
      Version: '2.0.0-alpha.1'
    })

    console.log('Wallet Balance:', wallet.Response.Balance)
    console.log('Wallet Nonce:', wallet.Response.Nonce)

    // Get recent transactions
    const transactions = await this.api.getLatestTransactions({
      Blockchain: 'MainNet',
      Address: address,
      Version: '2.0.0-alpha.1'
    })

    console.log('Recent transactions:', transactions.Response)
  }
}

// Usage
const monitor = new WalletMonitor('https://api.circular.network')
await monitor.monitorWallet('0xbbbb...')
```

### Python Application

```python
from circular_protocol import CircularProtocolAPI
from typing import Optional

class WalletMonitor:
    def __init__(self, api_url: str, api_key: Optional[str] = None):
        self.api = CircularProtocolAPI(api_url, api_key)

    def monitor_wallet(self, address: str):
        # Check wallet exists
        exists = self.api.check_wallet(
            blockchain='MainNet',
            address=address
        )

        if not exists['Response']['exists']:
            print('Wallet does not exist')
            return

        # Get wallet info
        wallet = self.api.get_wallet(
            blockchain='MainNet',
            address=address
        )

        print(f"Wallet Balance: {wallet['Response']['Balance']}")
        print(f"Wallet Nonce: {wallet['Response']['Nonce']}")

        # Get recent transactions
        transactions = self.api.get_latest_transactions(
            blockchain='MainNet',
            address=address
        )

        print(f"Recent transactions: {transactions['Response']}")

# Usage
monitor = WalletMonitor('https://api.circular.network')
monitor.monitor_wallet('0xbbbb...')
```

## Testing with Mock Server

Start the mock server:
```bash
just mock-server
```

Then use localhost:

**TypeScript:**
```typescript
const api = new CircularProtocolAPI('http://localhost:8080')
// All methods will use mock data
```

**Python:**
```python
api = CircularProtocolAPI('http://localhost:8080')
# All methods will use mock data
```

## More Examples

See the generated SDKs for:
- Smart Contract operations
- Asset queries
- Domain resolution
- Network information

All methods follow the same patterns shown above.
