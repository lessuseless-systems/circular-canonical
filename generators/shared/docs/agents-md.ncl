# Circular Protocol Canonical - AGENTS.md Generator
# Generates comprehensive AGENTS.md documentation for AI agent consumption
# This file provides guidance to AI agents (Claude, Gemini, etc.) when working with SDK code

let config = import "../../../src/config.ncl" in

let agents_md_content = m%"
# AGENTS.md - AI Agent Guidance for Circular Protocol SDK

> **Purpose**: This file provides guidance to AI coding assistants (Claude, Gemini, Copilot, etc.) when working with this Circular Protocol SDK codebase.

## Project Overview

This is the **Circular Protocol SDK**, a client library for interacting with the Circular Protocol blockchain network. It provides a simple, idiomatic interface for:

- **Wallet Operations**: Check, retrieve, and manage wallet information
- **Transaction Operations**: Send transactions and query transaction data
- **Asset Operations**: Query assets, vouchers, and asset supply
- **Block Operations**: Retrieve block data and analytics
- **Domain Operations**: Query blockchain domains
- **Network Operations**: Get blockchain network information
- **Smart Contract Operations**: Test and call smart contracts

**Key Properties**:
- Generated from canonical Nickel definitions in [circular-canonical](https://github.com/lessuseless-systems/circular-canonical)
- Implements 24 API endpoints from Circular Protocol NAG API
- Backwards compatible with circular-js v1.0.8
- Comprehensive test coverage (unit, integration, e2e)

## Architecture

### API Client Pattern

This SDK uses a simple HTTP client pattern:

```
User Code
    ↓
SDK Methods (24 endpoints)
    ↓
HTTP Client (fetch/axios/requests/http)
    ↓
Circular Protocol NAG API
```

### Request/Response Flow

1. **User calls SDK method** with parameters
2. **SDK validates parameters** (address format, blockchain ID, etc.)
3. **SDK constructs request body** with Version field
4. **SDK makes HTTP POST** to NAG API endpoint
5. **SDK receives response** with Result code and Response data
6. **SDK returns response** to user (or throws error if Result != 200)

### Error Handling

**IMPORTANT**: The SDK does NOT throw exceptions for non-200 Result codes. This is by design for backwards compatibility with circular-js v1.0.8.

The Result field indicates success (200) or error (500):
- `Result: 200` - Success, Response contains data
- `Result: 500` - Error, Response contains error message

Users must check the Result field:
```typescript
const result = await api.checkWallet('MainNet', address);
if (result.Result === 200) {
  console.log('Wallet exists:', result.Response);
} else {
  console.error('Error:', result.Response);
}
```

## API Endpoints (24 Total)

### Wallet Operations (6 endpoints)
- `checkWallet` - Check if wallet exists
- `getWallet` - Get complete wallet information
- `getLatestTransactions` - Get recent transactions for wallet
- `getWalletBalance` - Get wallet balance
- `getWalletNonce` - Get wallet nonce
- `registerWallet` - **Convenience method** - Register wallet on blockchain

### Transaction Operations (6 endpoints)
- `sendTransaction` - Send a transaction to the blockchain
- `getPendingTransaction` - Get pending transaction by ID
- `getTransactionbyID` - Get transaction by ID
- `getTransactionbyNode` - Get transactions by node
- `getTransactionbyAddress` - Get transactions by address
- `getTransactionbyDate` - Get transactions by date

### Asset Operations (4 endpoints)
- `getAssetList` - Get list of all assets
- `getAsset` - Get specific asset information
- `getAssetSupply` - Get total supply of an asset
- `getVoucher` - Get voucher information

### Block Operations (4 endpoints)
- `getBlock` - Get block by ID
- `getBlockRange` - Get range of blocks
- `getBlockCount` - Get total block count
- `getAnalytics` - Get blockchain analytics

### Domain Operations (1 endpoint)
- `getDomain` - Get domain information

### Network Operations (1 endpoint)
- `getBlockchains` - Get list of all blockchains

### Smart Contract Operations (2 endpoints)
- `testContract` - Test smart contract code
- `callContract` - Execute smart contract

## Development Workflow

### Environment Setup

```bash
# Enter development environment (Nix)
nix develop

# Install dependencies
[language-specific command]

# Run tests
just test-unit
just test-integration
just test-e2e  # Requires credentials
```

### Testing Strategy

**3-Layer Test Approach**:

1. **Unit Tests** (fast, isolated)
   - Test individual methods in isolation
   - Mock HTTP requests
   - Validate request construction
   - No external dependencies

2. **Integration Tests** (moderate, spans multiple methods)
   - Test method interactions
   - Use mock API server
   - Validate request/response flow
   - No credentials required

3. **E2E Tests** (slow, live endpoints)
   - Test against live Circular Protocol NAG API
   - Require API credentials via environment variables
   - Skipped if credentials missing
   - Use Circular SandBox blockchain (`0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5c8e73f`)

**Environment Variables for E2E**:
```bash
CIRCULAR_NAG_API_URL=https://nag.circularlabs.io/NAG.php
CIRCULAR_TEST_BLOCKCHAIN=0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5c8e73f
CIRCULAR_TEST_ADDRESS=<test_wallet_address>
CIRCULAR_TEST_PRIVATE_KEY=<test_private_key>
```

### Making Changes

**When modifying code**:
1. ⚠️ **DO NOT edit generated files directly** - Changes will be overwritten
2. ✅ **Modify Nickel definitions** in [circular-canonical](https://github.com/lessuseless-systems/circular-canonical)
3. ✅ **Regenerate SDK** using `just generate-<lang>-package`
4. ✅ **Run tests** to verify changes: `just test`

**When adding new endpoints**:
1. Add endpoint definition in `circular-canonical/src/api/<category>.ncl`
2. Update generator in `circular-canonical/generators/<lang>/`
3. Regenerate SDK
4. Add tests for new endpoint

### Git Workflow

**Branch**: `development` (do not commit to main)

**Commit Convention**: Use Conventional Commits
```
feat(wallet): add new getWalletHistory method
fix(transaction): correct date format in getTransactionbyDate
docs(readme): update installation instructions
test(e2e): add tests for new SandBox blockchain
chore(deps): update dependencies
```

**Before Committing**:
```bash
# Run all tests
just test

# Verify types/linting pass
just lint
just typecheck
```

## Common Tasks

### Add a New API Endpoint

This SDK is generated from canonical source. To add an endpoint:

1. **Define in canonical source** (`circular-canonical/src/api/<category>.ncl`):
```nickel
newEndpoint = {
  method = "POST",
  path = "/newEndpoint",
  summary = "Brief description",
  description = "Detailed description",
  parameters = { ... },
  request_body = { ... },
  response_schema = { ... },
}
```

2. **Update generator** (`circular-canonical/generators/<lang>/`)
3. **Regenerate SDK** from canonical source
4. **Add tests** for new endpoint

### Debug API Errors

**Check Result field first**:
```typescript
const result = await api.someMethod(...);
console.log('Result code:', result.Result);  // 200 = success, 500 = error
console.log('Response:', result.Response);
```

**Common issues**:
- `Result: 500, "Wallet not found"` - Wallet doesn't exist on blockchain
- `Result: 500, "Invalid address"` - Address format incorrect (must be 64-66 hex chars)
- `Result: 500, "Blockchain not found"` - Invalid blockchain ID

### Run Specific Tests

```bash
# Unit tests only (fast)
just test-unit

# Integration tests (medium)
just test-integration

# E2E tests (requires credentials)
just test-e2e

# All tests
just test

# Run single test file
[language-specific command for single test file]
```

## Backwards Compatibility

This SDK maintains backwards compatibility with circular-js v1.0.8:

**Do NOT**:
- Throw exceptions for non-200 Result codes (users must check Result field)
- Change method signatures
- Remove methods
- Change response structure

**Breaking changes require**:
- Major version bump
- Migration guide
- CHANGELOG entry
- Deprecation notice period

## API Endpoint Reference

All endpoints follow this pattern:

**Request**:
```json
{
  "Blockchain": "hex-encoded-blockchain-id",
  "Address": "hex-encoded-address",
  "Version": "%%{config.version}"
}
```

**Response**:
```json
{
  "Result": 200 | 500,
  "Response": <data> | <error_message>
}
```

## Additional Resources

- **Canonical Source**: [circular-canonical](https://github.com/lessuseless-systems/circular-canonical)
- **API Reference**: See circular-canonical/docs/API_REFERENCE.md
- **Nickel Patterns**: See circular-canonical/docs/NICKEL_PATTERNS.md
- **Testing Strategy**: See circular-canonical/docs/TESTING_STRATEGY.md
- **Original SDK**: [circular-js v1.0.8](https://github.com/circular-protocol/circular-js)

## Questions?

- Check CONTRIBUTING.md for contribution guidelines
- Check README.md for usage examples
- Check test files for endpoint usage patterns
- File issues in the canonical repository

---

*This SDK is generated from canonical Nickel definitions. Do not edit generated files directly.*
*Generated from: circular-canonical v%{config.version}*
"% in

{
  agents_md = agents_md_content,
}
