# PHP CHANGELOG.md Generator
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
- Initial PHP SDK release for Circular Protocol blockchain
- Complete API client with 24 blockchain operations:
  - **Wallet Operations**: checkWallet, getWallet, getWalletBalance, getWalletNonce, getLatestTransactions, registerWallet
  - **Transaction Operations**: sendTransaction, getPendingTransaction, getTransactionbyID, getTransactionbyNode, getTransactionbyAddress, getTransactionbyDate
  - **Block Operations**: getBlock, getBlockRange, getBlockCount, getAnalytics
  - **Asset Operations**: getAssetList, getAsset, getAssetSupply, getVoucher
  - **Smart Contract Operations**: testContract, callContract
  - **Network Operations**: getBlockchains
  - **Domain Operations**: getDomain (resolve domains to wallet addresses)
- PSR-12 compliant code style
- Type declarations (PHP 7.4+)
- Comprehensive error handling (returns Result codes, does NOT throw)
- HTTP timeout support (configurable via cURL options)
- Custom header support for authentication and API keys
- Configurable NAG endpoint URL
- Full test suite:
  - Unit tests with PHPUnit
  - Integration tests with local mock server
  - E2E tests (optional, ENV-gated) against live API
- Complete documentation with usage examples
- GitHub Actions CI/CD workflow
- PHP 7.4, 8.0, 8.1, 8.2, 8.3 support

### Developer Experience
- Idiomatic PHP code with proper type hints
- Backwards compatible with circular-js v1.0.8 (PHP equivalent)
- Clean, object-oriented design
- Comprehensive PHPDoc blocks
- Resource cleanup with destructor
- PSR-12 coding standard compliance
- PHPStan level 8 static analysis

### Package Metadata
- Published to Packagist as `circular-protocol/sdk`
- MIT License
- Composer package
- Minimal dependencies (cURL extension required)

[%{config.version}]: https://github.com/lessuseless-systems/circular-php/releases/tag/v%{config.version}
"%,

  # Metadata
  metadata = {
    version = config.version,
    language = "PHP",
    description = "Version history following Keep a Changelog format for Packagist",
    format = "Keep a Changelog 1.0.0",
    versioning = "Semantic Versioning 2.0.0",
  },
}
