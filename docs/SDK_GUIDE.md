# Circular Protocol SDK Guide

This guide explains how to use the generated TypeScript and Python SDKs for the Circular Protocol API.

## Overview

The Circular Protocol SDKs are automatically generated from the Nickel API specification and provide type-safe, idiomatic access to all 24 API endpoints across 7 categories:

- **Wallet API** (6 endpoints) - Wallet management and queries
- **Transaction API** (6 endpoints) - Transaction submission and queries
- **Block API** (4 endpoints) - Block data and analytics
- **Smart Contract API** (2 endpoints) - Contract testing and execution
- **Asset API** (4 endpoints) - Asset information and supply
- **Domain API** (1 endpoint) - Domain name resolution
- **Network API** (1 endpoint) - Network/blockchain information

## Available SDKs

### TypeScript SDK
- **File**: `dist/sdk/circular-protocol.ts`
- **Features**: Full TypeScript type safety, async/await, Promise-based, works in Node.js and browsers
- **See**: [TypeScript SDK Documentation](./SDK_TYPESCRIPT.md)

### Python SDK
- **File**: `dist/sdk/circular_protocol.py`
- **Features**: Type hints, docstrings, requests-based HTTP client, mypy compatible
- **See**: [Python SDK Documentation](./SDK_PYTHON.md)

## Quick Start

### TypeScript

```typescript
import { CircularProtocolAPI } from './circular-protocol'

const api = new CircularProtocolAPI('https://api.circular.network')

// Check if a wallet exists
const result = await api.checkWallet({
  Blockchain: 'MainNet',
  Address: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
  Version: '2.0.0-alpha.1'
})

console.log(result.Response.exists) // true/false
```

### Python

```python
from circular_protocol import CircularProtocolAPI

api = CircularProtocolAPI('https://api.circular.network')

# Check if a wallet exists
result = api.check_wallet(
    blockchain='MainNet',
    address='0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
)

print(result['Response']['exists'])  # True/False
```

## Generation

The SDKs are generated from the Nickel specification using:

```bash
# Generate all SDKs
just generate

# Generate TypeScript only
just generate-ts

# Generate Python only
just generate-py
```

## Testing

### Mock Server

Start the mock API server for local testing:

```bash
just mock-server
# Server runs on http://localhost:8080
```

### With Mock Server

```typescript
// TypeScript
const api = new CircularProtocolAPI('http://localhost:8080')
const result = await api.checkWallet({...})
```

```python
# Python
api = CircularProtocolAPI('http://localhost:8080')
result = api.check_wallet(...)
```

## API Categories

### Wallet API

Manage and query wallet information:

- `checkWallet` - Check if wallet exists
- `getWallet` - Get complete wallet information
- `getLatestTransactions` - Get recent transactions
- `getWalletBalance` - Get balance for specific asset
- `getWalletNonce` - Get transaction nonce
- `registerWallet` - Register new wallet

### Transaction API

Submit and query transactions:

- `sendTransaction` - Submit new transaction
- `getPendingTransaction` - Query pending transaction
- `getTransactionbyID` - Find transaction by ID
- `getTransactionbyNode` - Find transactions by node
- `getTransactionbyAddress` - Find transactions by address
- `getTransactionbyDate` - Find transactions by date range

### Block API

Query blockchain blocks:

- `getBlock` - Get specific block
- `getBlockRange` - Get range of blocks
- `getBlockCount` - Get total block count
- `getAnalytics` - Get blockchain analytics

### Smart Contract API

Execute and test smart contracts:

- `testContract` - Test contract execution
- `callContract` - Call deployed contract

### Asset API

Query asset information:

- `getAssetList` - List all assets
- `getAsset` - Get asset details
- `getAssetSupply` - Get asset supply information
- `getVoucher` - Get voucher information

### Domain API

- `getDomain` - Resolve domain name to address

### Network API

- `getBlockchains` - List available blockchains

## Error Handling

Both SDKs provide error handling for failed requests:

### TypeScript

```typescript
try {
  const result = await api.checkWallet({...})
  // Handle success
} catch (error) {
  console.error('API request failed:', error.message)
}
```

### Python

```python
import requests

try:
    result = api.check_wallet(...)
    # Handle success
except requests.exceptions.RequestException as e:
    print(f'API request failed: {e}')
```

## Response Format

All endpoints return responses in the Circular Protocol standard format:

```json
{
  "Result": 200,
  "Response": {
    // Endpoint-specific response data
  }
}
```

- `Result`: HTTP status code (200 = success, 400/500 = error)
- `Response`: Either response object (success) or error string (failure)

## Authentication

Both SDKs support optional API key authentication:

```typescript
// TypeScript
const api = new CircularProtocolAPI(
  'https://api.circular.network',
  'your-api-key'
)
```

```python
# Python
api = CircularProtocolAPI(
    base_url='https://api.circular.network',
    api_key='your-api-key'
)
```

## Type Safety

### TypeScript

The TypeScript SDK provides full type safety with interfaces for all requests and responses:

```typescript
import type {
  CheckWalletRequest,
  CheckWalletResponse
} from './circular-protocol'

const request: CheckWalletRequest = {
  Blockchain: 'MainNet',
  Address: '0x...',
  Version: '2.0.0-alpha.1'
}

const response: CheckWalletResponse = await api.checkWallet(request)
```

### Python

The Python SDK includes type hints compatible with mypy:

```python
from typing import Dict, Any

result: Dict[str, Any] = api.check_wallet(
    blockchain='MainNet',
    address='0x...'
)
```

## Best Practices

1. **Reuse Client Instances**: Create one API client and reuse it
2. **Handle Errors**: Always wrap API calls in try/catch blocks
3. **Use Type Safety**: Leverage TypeScript interfaces or Python type hints
4. **Connection Pooling**: Both SDKs use connection pooling for better performance
5. **Version Management**: The SDK version automatically matches the specification version

## Next Steps

- [TypeScript SDK detailed documentation](./SDK_TYPESCRIPT.md)
- [Python SDK detailed documentation](./SDK_PYTHON.md)
- [API endpoint examples](./EXAMPLES.md)
- [Contributing to the SDKs](./CONTRIBUTING.md)

## Support

For issues with the SDKs:
1. Check the [API specification](../dist/openapi/openapi.yaml)
2. Test with the [mock server](../tests/mock-server/)
3. Review [generated code](../dist/sdk/)
4. Open an issue on GitHub

## Version

Current SDK version: **2.0.0-alpha.1**

Generated from: `circular-canonical` Nickel specification
