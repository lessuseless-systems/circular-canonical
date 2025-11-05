# Circular Protocol Canonacle

Single source of truth for Circular Protocol standard APIs, defined in Nickel.

## Overview

This project uses [Nickel](https://nickel-lang.org/) to define the Circular Protocol API specifications, contracts, and schemas in a single location. From these Nickel definitions, we generate:

- OpenAPI 3.0 specifications
- MCP (Model Context Protocol) servers
- AI tool schemas (Anthropic, OpenAI)
- TypeScript SDK with runtime validation
- Documentation and examples

## Why Nickel?

Nickel provides:
- **Contracts**: Runtime validation with clear error messages
- **Merging**: Composable configurations that prevent duplication
- **Type safety**: Gradual typing for improved code quality
- **Single source of truth**: One definition → multiple outputs

## Project Structure

```
circular-canonacle/
├── src/
│   ├── api/              # API endpoint definitions
│   ├── schemas/          # Type definitions and contracts
│   └── config.ncl        # Base configuration
├── generators/           # Code generators (OpenAPI, MCP, etc.)
├── output/              # Generated artifacts
├── tests/               # Validation tests
└── examples/            # Usage examples
```

## Getting Started

### Prerequisites

```bash
# Install Nickel
nix shell nixpkgs#nickel
```

### Generate OpenAPI Spec

```bash
nickel export generators/openapi.ncl --format yaml > output/openapi.yaml
```

### Validate Definitions

```bash
nickel typecheck src/api/*.ncl
```

## API Reference

See [circular-js](https://github.com/circular-protocol/circular-js) for the reference implementation.

### Available APIs

**Wallet Operations**
- checkWallet - Check if a wallet exists on the blockchain
- getWallet - Retrieve wallet information
- getLatestTransactions - Get latest transactions for a wallet
- getWalletBalance - Get asset balance for a wallet
- getWalletNonce - Get wallet nonce
- registerWallet - Register a new wallet

**Smart Contracts**
- testContract - Test smart contract execution
- callContract - Call smart contract function

**Assets**
- getAssetList - List all assets on blockchain
- getAsset - Get specific asset information
- getAssetSupply - Get asset supply information
- getVoucher - Retrieve voucher information

**Blocks**
- getBlock - Get specific block
- getBlockRange - Get range of blocks
- getBlockHeight - Get blockchain height
- getAnalytics - Get blockchain analytics

**Transactions**
- sendTransaction - Submit transaction to blockchain
- getTransactionByID - Find transaction by ID
- getTransactionByNode - Find transactions by node
- getTransactionByAddress - Find transactions by address
- getTransactionByDate - Find transactions by date range
- getPendingTransaction - Get pending transaction

**Domains**
- resolveDomain - Resolve domain to wallet address

**Network**
- getBlockchains - List available blockchains

## Development

### Adding a New API Endpoint

1. Define the endpoint in `src/api/<category>.ncl`
2. Add request/response schemas in `src/schemas/`
3. Update generators to include the new endpoint
4. Regenerate artifacts: `just generate`
5. Test: `just test`

### Common Commands

```bash
# Setup development environment
just setup

# Validate Nickel files
just validate

# Run tests
just test

# Generate all artifacts
just generate

# Full development cycle
just dev

# See all available commands
just --list
```

## License

Open Source for private and commercial use

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
