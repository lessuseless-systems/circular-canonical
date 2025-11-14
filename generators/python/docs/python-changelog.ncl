# Python CHANGELOG.md Generator
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
- Initial Python SDK release for Circular Protocol blockchain
- Complete API client with 24 blockchain operations:
  - **Wallet Operations**: check_wallet, get_wallet, get_wallet_balance, get_wallet_nonce, get_latest_transactions, register_wallet
  - **Transaction Operations**: send_transaction, get_pending_transaction, get_transaction_by_id, get_transaction_by_node, get_transaction_by_address, get_transaction_by_date
  - **Block Operations**: get_block, get_block_range, get_block_count, get_analytics
  - **Asset Operations**: get_asset_list, get_asset, get_asset_supply, get_voucher
  - **Smart Contract Operations**: test_contract, call_contract
  - **Network Operations**: get_blockchains
  - **Domain Operations**: get_domain (resolve domains to wallet addresses)
- Async support with asyncio (async/await)
- Synchronous API also available
- Type hints with TypedDict for all request/response types
- Comprehensive error handling (returns Result codes, does NOT raise)
- HTTP timeout support (configurable, default 30s)
- Custom header support for authentication and API keys
- Configurable NAG endpoint URL
- Full test suite:
  - Unit tests with mocked requests
  - Integration tests with local mock server
  - E2E tests (optional, ENV-gated) against live API
- Complete documentation with usage examples
- GitHub Actions CI/CD workflow
- Python 3.8+ support

### Developer Experience
- Idiomatic Python code with snake_case naming
- Backwards compatible with circular-js v1.0.8 (Python equivalent)
- Clean modular architecture:
  - `client.py`: Main API class
  - `models.py`: TypedDict definitions
  - `exceptions.py`: Custom exception classes
  - `_helpers.py`: Utility functions
  - `_crypto.py`: Cryptographic operations
- Comprehensive docstrings (Google style)
- Resource cleanup with context manager support
- Type checking with mypy
- Linting with ruff
- Formatting with black

### Package Metadata
- Published to PyPI as `circular-protocol-api`
- MIT License
- Pure Python package
- Minimal dependencies (requests only)
- Wheels for all platforms

[%{config.version}]: https://github.com/lessuseless-systems/circular-py/releases/tag/v%{config.version}
"%,

  # Metadata
  metadata = {
    version = config.version,
    language = "Python",
    description = "Version history following Keep a Changelog format for PyPI",
    format = "Keep a Changelog 1.0.0",
    versioning = "Semantic Versioning 2.0.0",
  },
}
