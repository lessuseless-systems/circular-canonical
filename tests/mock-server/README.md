# Mock API Server

Mock HTTP server for testing generated SDKs against the Circular Protocol API specification.

## Purpose

This mock server simulates all 24 Circular Protocol API endpoints with realistic responses. It is used for:
- Runtime testing of generated TypeScript and Python SDKs
- Development and debugging without needing actual API access
- Automated testing in CI/CD pipelines

## Usage

### Start the server

```bash
# From project root
python3 tests/mock-server/server.py

# Or from this directory
./server.py
```

The server will start on `http://localhost:8080` by default.

### Endpoints

The mock server implements all 24 API endpoints:

**Wallet API (6 endpoints)**
- POST /checkWallet
- POST /getWallet
- POST /getLatestTransactions
- POST /getWalletBalance
- POST /getWalletNonce
- POST /registerWallet

**Transaction API (6 endpoints)**
- POST /sendTransaction
- POST /getPendingTransaction
- POST /getTransactionbyID
- POST /getTransactionbyNode
- POST /getTransactionbyAddress
- POST /getTransactionbyDate

**Block API (4 endpoints)**
- POST /getBlock
- POST /getBlockRange
- POST /getBlockCount
- POST /getAnalytics

**Smart Contract API (2 endpoints)**
- POST /testContract
- POST /callContract

**Asset API (4 endpoints)**
- POST /getAssetList
- POST /getAsset
- POST /getAssetSupply
- POST /getVoucher

**Domain API (1 endpoint)**
- POST /getDomain

**Network API (1 endpoint)**
- POST /getBlockchains

## Example Request

```bash
curl -X POST http://localhost:8080/checkWallet \
  -H "Content-Type: application/json" \
  -d '{
    "Blockchain": "MainNet",
    "Address": "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
    "Version": "1.0.8"
  }'
```

## Response Format

All responses follow the Circular Protocol API format:

```json
{
  "Result": 200,
  "Response": {
    "exists": true,
    "address": "0xbbbb..."
  }
}
```

## Configuration

Edit `server.py` to modify:
- `PORT = 8080` - Change the listening port
- `VERSION = "1.0.8"` - Update API version
- Mock response data in handler methods

## Testing with Generated SDKs

### TypeScript SDK

```typescript
import { CircularProtocolAPI } from './sdk'

const api = new CircularProtocolAPI('http://localhost:8080')
const result = await api.checkWallet({
  Blockchain: 'MainNet',
  Address: '0xbbbb...',
  Version: '1.0.8'
})
```

### Python SDK

```python
from circular_protocol import CircularProtocolAPI

api = CircularProtocolAPI(base_url='http://localhost:8080')
result = api.check_wallet(
    blockchain='MainNet',
    address='0xbbbb...'
)
```

## Notes

- All endpoints return success responses (200 status code) by default
- Mock data is hardcoded but can be extended for specific test cases
- CORS is enabled for browser-based testing
- Server logs all requests for debugging
