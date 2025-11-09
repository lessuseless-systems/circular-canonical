# Circular Protocol Canonical

Single source of truth for Circular Protocol standard APIs, defined in Nickel.

## Official Repositories

**⚠️ IMPORTANT:** Only these repositories are official:

| Repository | Purpose | URL |
|------------|---------|-----|
| **circular-canonical** | Source of truth (THIS REPO) | `lessuseless-systems/circular-canonical` |
| **circular-js-npm** | Generated TypeScript SDK | `lessuseless-systems/circular-js-npm` |
| **circular-py** | Generated Python SDK | `lessuseless-systems/circular-py` |

**Ignore these repos** (outdated/test):
- `circular-canonicle` (typo)
- `circular-py-1`, `circular-py-2` (numbered test repos)
- `circular-js-npm-1`, `circular-js-npm-2` (numbered test repos)

All generated SDKs are managed as git submodules in `dist/typescript/` and `dist/python/`.

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
circular-canonical/
├── src/
│   ├── api/              # API endpoint definitions
│   ├── schemas/          # Type definitions and contracts
│   └── config.ncl        # Base configuration
├── generators/
│   ├── shared/           # Language-agnostic generators (OpenAPI, helpers)
│   ├── typescript/       # TypeScript SDK & tooling generators
│   └── python/           # Python SDK & tooling generators
├── dist/                 # Generated artifacts (gitignored)
├── tests/                # Validation tests
└── docs/                 # Documentation
```

## Getting Started

### Prerequisites

```bash
# Enter development environment (recommended)
nix develop

# This automatically installs:
# - Nickel language tools
# - TypeScript/Node.js
# - Python environment
# - Git hooks (pre-commit, pre-push)
# - All dev dependencies
```

### Git Hooks (Automatic)

When you run `nix develop`, git hooks are automatically installed:

**Pre-commit:** Nickel typecheck, secrets detection, JSON/YAML validation, markdown linting
**Pre-push:** Repository URL validation (prevents pushes to numbered repos or typos)

### Generate OpenAPI Spec

```bash
nickel export generators/shared/openapi.ncl --format yaml > dist/openapi/openapi.yaml
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
4. Regenerate artifacts: `just generate-packages`
5. Sync to forks: `just sync-all`
6. Test: `just test`

### Common Commands

```bash
# Setup development environment
just setup

# Validate Nickel files
just validate

# Run tests
just test

# Generate complete packages
just generate-packages

# Sync to fork submodules
just sync-all

# Push to lessuseless-systems
just push-forks

# Full development cycle
just dev

# See all available commands
just --list
```

### Multi-Repo Workflow

This project uses a fork workflow to sync generated code to upstream repositories.

#### One-Time Setup

Install GitHub CLI and run automated setup:

```bash
# Install gh CLI (if needed)
brew install gh  # macOS
# or: sudo apt install gh  # Linux

# Authenticate
gh auth login

# Automated setup (forks, branches, submodules)
just setup-forks

# Commit submodule configuration (NOT dist/ contents!)
git add .gitmodules
git commit -m "chore: add fork submodules"
```

#### Daily Workflow

1. **Generate** - Create packages from Nickel source: `just generate-packages`
2. **Sync** - Copy to fork submodules and commit: `just sync-all`
3. **Push** - Push development branches: `just push-forks`
4. **PR** - Create pull requests: `just create-prs`

**Or all in one command:**

```bash
just generate-packages && just sync-all && just push-forks && just create-prs
```

See [FORK_WORKFLOW.md](FORK_WORKFLOW.md) for detailed documentation.

## License

Open Source for private and commercial use

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
