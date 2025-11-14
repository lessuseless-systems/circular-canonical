# Layer 5: End-to-End Blockchain Tests

This directory contains end-to-end test specifications for the Circular Protocol SDKs. These tests run against **real blockchain endpoints** to verify SDKs work correctly with live data.

## Organization

Tests are organized by **operation type** (not speed):

### `read-operations/` - Safe Blockchain Queries ✅

24 read-only tests that query blockchain state without making any changes.

**Characteristics**:
- ✅ Safe - no side effects
- ✅ Free - no gas costs
- ✅ Automated - runs in CI/CD
- ✅ Fast - can run repeatedly

**Examples**: Check wallet balance, get transaction history, retrieve block data

**Environment Required**: `CIRCULAR_TEST_ADDRESS` (optional - tests skip gracefully if not set)

### `write-operations/` - Dangerous Blockchain Mutations ⚠️

3 write operation specs that create permanent blockchain records.

**Characteristics**:
- ⚠️ Dangerous - permanent changes
- ⚠️ Costs money - gas fees
- ⚠️ Manual only - NEVER automated
- ⚠️ Requires private keys

**Examples**: Register wallet, certify data, call smart contracts

**Environment Required**: `CIRCULAR_PRIVATE_KEY` + explicit enable flag

## Running Read-Only Tests (Safe)

All SDKs support automated E2E testing:

### TypeScript
```bash
# Set test wallet address (optional)
export CIRCULAR_TEST_ADDRESS="0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310"

# Run tests
cd dist/typescript
npm run test:e2e

# Tests skip gracefully if CIRCULAR_TEST_ADDRESS not set
```

### Python
```bash
# Set test wallet address (optional)
export CIRCULAR_TEST_ADDRESS="0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310"

# Run tests
cd dist/python
pytest tests/test_e2e.py -v -m e2e

# Tests skip gracefully if CIRCULAR_TEST_ADDRESS not set
```

### Dart
```bash
# Set test wallet address (optional)
export CIRCULAR_TEST_ADDRESS="0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310"

# Run tests
cd dist/dart
dart test test/e2e_test.dart

# Tests skip gracefully if CIRCULAR_TEST_ADDRESS not set
```

### Java, PHP, Go, Rust

See respective SDK documentation in `dist/<language>/README.md`

## Running Write Operations (Dangerous) ⚠️

**⚠️ WARNING**: Write operations create permanent blockchain records and may cost money.

**Only Python SDK currently supports write operations.**

### Prerequisites

1. **Test Network**: Use Circular SandBox (never production)
2. **Private Key**: 32-byte hex key for signing transactions
3. **Test Funds**: Ensure wallet has sufficient balance for gas
4. **Explicit Enable**: Must set `CIRCULAR_ALLOW_WRITE_TESTS=1`

### Example: Register Wallet (Python)

```bash
# REQUIRED environment variables
export CIRCULAR_ALLOW_WRITE_TESTS=1
export CIRCULAR_PRIVATE_KEY="your_private_key_here"  # NEVER commit this!
export CIRCULAR_PUBLIC_KEY="your_public_key_here"
export CIRCULAR_TEST_BLOCKCHAIN="0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5ad72b2"  # SandBox

# Run manual test script
python3 dist/tests/manual/manual-test-registerWallet.py
```

### Example: Certify Data (Python)

```bash
# Same environment variables as above

# Run data certification test
python3 dist/tests/manual/manual-test-certifyData.py
```

**Proven On-Chain**: Python SDK has successfully created these certificate transactions:
- `0xf6c83ca16bc0d63d73767359e7db94958b9a78deac6c466d63acf0c920604f66`
- `21c7b039b5d62c4bc7a1ce6ab5a8aeeb7e396aa57eab953ce954cf7c510520fa`

## Environment Variables

### Read-Only Tests (Optional)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `CIRCULAR_TEST_ADDRESS` | No | - | Wallet address to test (tests skip if not set) |
| `CIRCULAR_TEST_BLOCKCHAIN` | No | SandBox | Which blockchain network to query |
| `CIRCULAR_NAG_URL` | No | https://nag.circularlabs.io/NAG.php?cep= | NAG endpoint URL |
| `CIRCULAR_API_KEY` | No | - | API key for authenticated requests |
| `CIRCULAR_E2E_TIMEOUT` | No | 30000 | Request timeout in milliseconds |

### Write Operations (Required)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `CIRCULAR_ALLOW_WRITE_TESTS` | **YES** | - | Must be `1` to enable (safety flag) |
| `CIRCULAR_PRIVATE_KEY` | **YES** | - | Private key for signing (NEVER commit!) |
| `CIRCULAR_PUBLIC_KEY` | **YES** | - | Public key derived from private key |
| `CIRCULAR_TEST_BLOCKCHAIN` | **YES** | SandBox | Blockchain to write to (use SandBox!) |

## What Gets Tested

### Read-Only Operations (24 tests)

**Wallet Queries**:
- Check if wallet exists
- Get wallet details (balance, nonce, transactions)
- Query wallet balance for specific assets
- Find transactions by wallet address and date range

**Blockchain Queries**:
- Get blockchain height (block count)
- Retrieve specific blocks and block ranges
- Get blockchain analytics and statistics

**Asset Queries**:
- List all assets on blockchain
- Get detailed asset information
- Check asset supply (total, circulating, residual)
- Retrieve voucher details

**Network Queries**:
- List available blockchains
- Resolve domain names to wallet addresses
- Query pending transactions

**Contract Queries**:
- Test contract execution (dry run)
- Find transactions by ID and node

### Write Operations (3 specs, Python only)

**Wallet Operations**:
- Register new wallet on blockchain
- Creates permanent wallet registration

**Transaction Operations**:
- Certify data on blockchain (C_TYPE_CERTIFICATE)
- Creates immutable data certificate

**Contract Operations**:
- Call smart contract functions
- Modifies contract state permanently

## Test Data Sources

### Read Operations
- **Test Wallet**: `0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310`
- **Test Blockchain**: `0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5ad72b2` (SandBox)
- **NAG Endpoint**: `https://nag.circularlabs.io/NAG.php?cep=`

### Write Operations
- **Use your own private key** - NEVER use shared keys
- **Test on SandBox only** - never production
- **Verify funds available** - check balance before operations

## CI/CD Integration

### Read-Only Tests

Safe to run in CI/CD if secrets are configured:

```.github/workflows/test.yml
- name: Run E2E tests
  if: secrets.CIRCULAR_TEST_ADDRESS != ''
  env:
    CIRCULAR_TEST_ADDRESS: ${{ secrets.CIRCULAR_TEST_ADDRESS }}
  run: just test-e2e
```

Tests gracefully skip if secrets not configured (no failures).

### Write Operations

**NEVER run in CI/CD**:
- Requires private keys (security risk)
- Costs real money (gas fees)
- Creates permanent records
- Manual execution only

## Security Notes

### Read-Only Tests
- ✅ Safe to share test wallet address publicly
- ✅ No private keys required
- ✅ No risk of fund loss
- ✅ Can run on any network (mainnet, testnet)

### Write Operations
- ⚠️ **NEVER commit private keys to git**
- ⚠️ Use environment variables only
- ⚠️ Use test networks (SandBox) only
- ⚠️ Check balance before operations
- ⚠️ Double-check blockchain ID before signing
- ⚠️ Understand gas costs and implications

## Troubleshooting

### Read tests skip with "CIRCULAR_TEST_ADDRESS not set"

**Expected behavior** - tests skip gracefully when environment variable is not set. This is normal for local development without a test wallet.

To run the tests, export the test wallet address:
```bash
export CIRCULAR_TEST_ADDRESS="0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310"
```

### Write operations fail with "Write tests disabled"

This is a safety feature. Write operations require explicit enable:
```bash
export CIRCULAR_ALLOW_WRITE_TESTS=1
export CIRCULAR_PRIVATE_KEY="..."
```

### Tests timeout

Increase timeout value:
```bash
export CIRCULAR_E2E_TIMEOUT=60000  # 60 seconds
```

### Wrong network error

Verify blockchain ID matches expected network:
```bash
# SandBox (test network - recommended)
export CIRCULAR_TEST_BLOCKCHAIN="0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5ad72b2"

# MainNet (production - use with caution)
export CIRCULAR_TEST_BLOCKCHAIN="0x714d2ac07a826b66ac56752eebd7c77b58d2ee842e523d913fd0ef06e6bdfcae"
```

## Contributing

### Adding Read-Only Tests

Edit `read-operations/queries.test.ncl` and regenerate SDKs:
```bash
just generate-packages
```

All 7 languages (TypeScript, Python, Java, PHP, Go, Dart, Rust) get the new test automatically.

### Adding Write Operations

Currently requires creating a new generator (follow Python pattern). Contributions welcome!

## Further Reading

- [Test Infrastructure Overview](../CLAUDE.md) - Complete test pyramid documentation
- [Development Workflow](../../docs/DEVELOPMENT_WORKFLOW.md) - Git workflow and release process
- SDK Documentation - See `dist/<language>/README.md` for language-specific guides
