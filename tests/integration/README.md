# Integration Tests

Integration tests for Circular Protocol SDKs against real API endpoints.

## Setup

### 1. Install Dependencies

```bash
cd tests/integration
npm install
```

### 2. Configure API Endpoint

Set the `CIRCULAR_API_URL` environment variable:

```bash
# For local development node
export CIRCULAR_API_URL=http://localhost:3000

# Or for production/staging
export CIRCULAR_API_URL=https://api.circular.org
```

### 3. Verify Credentials

Ensure the root `.env` file contains test credentials:

```bash
# ../../.env
CIRCULAR_STANDARD_ADDRESS='0x...'
CIRCULAR_STANDARD_SEED='...'
```

## Running Tests

### Run All Integration Tests

```bash
npm test
```

### Run TypeScript SDK Tests Only

```bash
npm run test:ts
```

### Watch Mode (for development)

```bash
npm run test:watch
```

## Test Coverage

### TypeScript SDK

- **Wallet Operations**
  - ✅ checkWallet - Verify wallet exists
  - ✅ getWallet - Retrieve wallet information
  - ✅ getWalletBalance - Get balance for specific asset
  - ✅ getWalletNonce - Get current nonce
  - ✅ getLatestTransactions - Fetch recent transactions

- **Network Operations**
  - ✅ getBlockchains - List supported blockchains

- **Block Operations**
  - ✅ getBlockHeight - Get current blockchain height

- **Error Handling**
  - ✅ Connection failures
  - ✅ Invalid addresses
  - ✅ Network timeouts

### Python SDK

_(To be implemented)_

## Test Requirements

### Local Development Node

To run tests against a local node:

1. Start Circular Protocol node on port 3000
2. Ensure test wallet is registered
3. Run: `npm test`

### Production API

To test against production:

1. Set `CIRCULAR_API_URL=https://api.circular.org`
2. Ensure credentials have access
3. Run: `npm test`

**Warning**: Production tests may create real transactions. Use test credentials only!

## Troubleshooting

### Connection Refused

```
Error: connect ECONNREFUSED 127.0.0.1:3000
```

**Solution**: Ensure the API endpoint is running and accessible.

### Wallet Not Found

```
Result: 404, Response: { exists: false }
```

**Solution**: The test wallet may not be registered. Register it using `registerWallet` endpoint or use a different test address.

### Timeout Errors

```
Timeout - Async callback was not invoked within the 10000 ms timeout
```

**Solution**: Increase timeout in test file or check API performance.

## Adding New Tests

### Template for New Integration Test

```typescript
describe('YourFeature', () => {
  it('should perform operation', async () => {
    const result = await api.yourMethod({
      Blockchain: 'MainNet',
      // ... parameters
      Version: API_VERSION,
    })

    expect(result).toBeDefined()
    expect(result.Result).toBeDefined()

    if (result.Response) {
      console.log('  ✅ Success:', result.Response)
    }
  }, 10000) // 10 second timeout
})
```

## CI/CD Integration

### GitHub Actions

Add to `.github/workflows/integration-tests.yml`:

```yaml
name: Integration Tests

on:
  push:
    branches: [main, development]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20.x'

      - name: Install dependencies
        run: cd tests/integration && npm install

      - name: Run integration tests
        env:
          CIRCULAR_API_URL: ${{ secrets.TEST_API_URL }}
          CIRCULAR_STANDARD_ADDRESS: ${{ secrets.TEST_ADDRESS }}
          CIRCULAR_STANDARD_SEED: ${{ secrets.TEST_SEED }}
        run: cd tests/integration && npm test
```

## Notes

- Integration tests require a running API endpoint
- Tests are **read-only** where possible to avoid side effects
- Tests that create data (registerWallet, sendTransaction) are marked accordingly
- All tests use credentials from `.env` file
- Default timeout: 10 seconds per test (configurable)

## See Also

- [Testing Strategy](../../docs/TESTING_STRATEGY.md)
- [API Reference](../../docs/API_REFERENCE.md)
- [TypeScript SDK](../../dist/typescript/)
- [Python SDK](../../dist/python/)
