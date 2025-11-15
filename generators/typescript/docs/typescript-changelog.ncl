# TypeScript CHANGELOG.md Generator
# Generates version history documentation following Keep a Changelog format

let config = import "../../../src/config.ncl" in

{
  changelog_content = m%"
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [%{config.version}] - 2025-11-14

### Added
- Initial TypeScript SDK release for Circular Protocol blockchain
- Complete API client with 24 blockchain operations:
  - **Wallet Operations**: checkWallet, getWallet, getWalletBalance, getWalletNonce, getLatestTransactions, registerWallet
  - **Transaction Operations**: sendTransaction, getPendingTransaction, getTransactionbyID, getTransactionbyNode, getTransactionbyAddress, getTransactionbyDate
  - **Block Operations**: getBlock, getBlockRange, getBlockCount, getAnalytics
  - **Asset Operations**: getAssetList, getAsset, getAssetSupply, getVoucher
  - **Smart Contract Operations**: testContract, callContract
  - **Network Operations**: getBlockchains
  - **Domain Operations**: getDomain (resolve domains to wallet addresses)
- Async/await Promise-based API with TypeScript types
- Comprehensive error handling (returns Result codes, does NOT throw)
- HTTP timeout support (configurable, default 30s)
- Custom header support for authentication and API keys
- Configurable NAG endpoint URL
- Full test suite:
  - Unit tests with mocked fetch client
  - Integration tests with local mock server
  - E2E tests (optional, ENV-gated) against live API
- Complete documentation with usage examples
- GitHub Actions CI/CD workflow
- Dual module support: CommonJS and ESM
- Webpack bundling configuration
- Jest testing framework

### Developer Experience
- TypeScript type definitions for all methods and responses
- Backwards compatible with circular-js v1.0.8
- Clean, idiomatic TypeScript code
- Comprehensive inline documentation
- Resource cleanup with dispose() method

### Package Metadata
- Published to npm as `@circular-protocol/sdk`
- MIT License
- Node.js 16+ and browser support
- Zero runtime dependencies
- Type declaration files included

[%{config.version}]: https://github.com/lessuseless-systems/circular-ts/releases/tag/v%{config.version}
"%,

  # Metadata
  metadata = {
    version = config.version,
    language = "TypeScript",
    description = "Version history following Keep a Changelog format for npm",
    format = "Keep a Changelog 1.0.0",
    versioning = "Semantic Versioning 2.0.0",
  },
}
