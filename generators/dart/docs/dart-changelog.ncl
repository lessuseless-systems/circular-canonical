# Dart CHANGELOG.md Generator
# Generates version history documentation following Keep a Changelog format
# Required for pub.dev package scoring and user transparency

let config = import "../../../src/config.ncl" in

{
  changelog_content = m%"
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [%{config.version}] - 2025-11-13

### Added
- Initial Dart SDK release for Circular Protocol blockchain
- Complete API client with 24 blockchain operations:
  - **Wallet Operations**: checkWallet, getWallet, getWalletBalance, getWalletNonce, getLatestTransactions
  - **Transaction Operations**: addTransaction, getPendingTransaction, getTransactionbyID, getTransactionbyNode, getTransactionbyAddress, getTransactionbyDate
  - **Block Operations**: getBlock, getBlockRange, getBlockCount
  - **Asset Operations**: getAssetList, getAsset, getAssetSupply, getVoucher
  - **Smart Contract Operations**: testContract, callContract
  - **Network Operations**: getBlockchains, getAnalytics
  - **Domain Operations**: getDomain (resolve domains to wallet addresses)
- Async/await support with Future-based API
- Comprehensive error handling with CircularAPIException
- HTTP timeout support (configurable, 30s default)
- Custom header support for authentication and API keys
- Configurable NAG endpoint URL
- Cross-platform support (Android, iOS, Linux, macOS, Web, Windows)
- Full test suite:
  - 11 unit tests with mocked HTTP client
  - 26 integration tests with local mock server
  - 24 E2E tests (optional, ENV-gated)
- Complete documentation with usage examples
- GitHub Actions CI/CD workflow with multi-version testing
- Static analysis configuration (analysis_options.yaml)
- Dart 2.19+ and Dart 3.x support

### Developer Experience
- Idiomatic Dart code with proper type hints
- Null-safety support
- Package follows pub.dev best practices
- Comprehensive API documentation
- Clean exception hierarchy
- Resource cleanup with dispose() method

### Package Metadata
- Published to pub.dev as `circular_protocol`
- MIT License
- Full platform compatibility
- Proper dependency management

[%{config.version}]: https://github.com/circular-protocol/circular-dart/releases/tag/v%{config.version}
"%,

  # Metadata
  metadata = {
    version = config.version,
    language = "Dart",
    description = "Version history following Keep a Changelog format for pub.dev scoring",
    format = "Keep a Changelog 1.0.0",
    versioning = "Semantic Versioning 2.0.0",
  },
}
