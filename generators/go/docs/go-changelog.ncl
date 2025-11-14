# Go CHANGELOG.md Generator
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
- Initial Go SDK release for Circular Protocol blockchain
- Complete API client with 24 blockchain operations:
  - **Wallet Operations**: CheckWallet, GetWallet, GetWalletBalance, GetWalletNonce, GetLatestTransactions, RegisterWallet
  - **Transaction Operations**: SendTransaction, GetPendingTransaction, GetTransactionByID, GetTransactionByNode, GetTransactionByAddress, GetTransactionByDate
  - **Block Operations**: GetBlock, GetBlockRange, GetBlockCount, GetAnalytics
  - **Asset Operations**: GetAssetList, GetAsset, GetAssetSupply, GetVoucher
  - **Smart Contract Operations**: TestContract, CallContract
  - **Network Operations**: GetBlockchains
  - **Domain Operations**: GetDomain (resolve domains to wallet addresses)
- Context support for cancellation and timeouts
- Comprehensive error handling (returns error values, does NOT panic)
- HTTP timeout support (configurable via context)
- Custom header support for authentication and API keys
- Configurable NAG endpoint URL
- Full test suite:
  - Unit tests with mocked HTTP client
  - Integration tests with local mock server
  - E2E tests (optional, ENV-gated) against live API
- Complete documentation with usage examples and Godoc
- GitHub Actions CI/CD workflow
- Go 1.19+ support

### Developer Experience
- Idiomatic Go code with proper error handling
- Backwards compatible with circular-js v1.0.8 (Go equivalent)
- Clean, simple API design
- Comprehensive Godoc comments
- Resource cleanup with Close() method
- Thread-safe client
- Zero external dependencies (uses standard library only)

### Package Metadata
- Available via Go modules: `github.com/lessuseless-systems/circular-go`
- MIT License
- Supports all Go platforms
- Minimal dependencies

[%{config.version}]: https://github.com/lessuseless-systems/circular-go/releases/tag/v%{config.version}
"%,

  # Metadata
  metadata = {
    version = config.version,
    language = "Go",
    description = "Version history following Keep a Changelog format",
    format = "Keep a Changelog 1.0.0",
    versioning = "Semantic Versioning 2.0.0",
  },
}
