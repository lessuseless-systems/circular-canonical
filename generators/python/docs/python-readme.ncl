# Python Package README Generator
# Generates comprehensive README.md for PyPI package

let config = import "../../../src/config.ncl" in
let wallet = import "../../../src/api/wallet.ncl" in
let transaction = import "../../../src/api/transaction.ncl" in
let block = import "../../../src/api/block.ncl" in
let asset = import "../../../src/api/asset.ncl" in
let contract = import "../../../src/api/contract.ncl" in
let domain = import "../../../src/api/domain.ncl" in
let network = import "../../../src/api/network.ncl" in
let helpers = import "../../shared/helpers.ncl" in

# Helper: Generate API method documentation row
let generate_api_row = fun name endpoint =>
  let snake_name = helpers.path_to_snake_case."%{endpoint.path}" in
  "| `%{snake_name}()` | %{endpoint.summary} | %{endpoint.method} |"
in

# All API endpoints for reference table
let all_endpoints = {
  # Wallet operations
  checkWallet = wallet.checkWallet,
  getWallet = wallet.getWallet,
  getLatestTransactions = wallet.getLatestTransactions,
  getWalletBalance = wallet.getWalletBalance,
  getWalletNonce = wallet.getWalletNonce,
  registerWallet = wallet.registerWallet,

  # Transaction operations
  sendTransaction = transaction.sendTransaction,
  getTransactionbyID = transaction.getTransactionbyID,
  getTransactionbyNode = transaction.getTransactionbyNode,
  getTransactionbyAddress = transaction.getTransactionbyAddress,
  getTransactionbyDate = transaction.getTransactionbyDate,
  getPendingTransaction = transaction.getPendingTransaction,

  # Block operations
  getBlock = block.getBlock,
  getBlockRange = block.getBlockRange,
  getBlockCount = block.getBlockCount,
  getAnalytics = block.getAnalytics,

  # Asset operations
  getAssetList = asset.getAssetList,
  getAsset = asset.getAsset,
  getAssetSupply = asset.getAssetSupply,
  getVoucher = asset.getVoucher,

  # Contract operations
  testContract = contract.testContract,
  callContract = contract.callContract,

  # Domain operations
  getDomain = domain.getDomain,

  # Network operations
  getBlockchains = network.getBlockchains,
} in

m%"
# Circular Protocol API - Python SDK

[![PyPI version](https://img.shields.io/pypi/v/circular-protocol-api.svg)](https://pypi.org/project/circular-protocol-api/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![Type Hints](https://img.shields.io/badge/Type%20Hints-100%25-green.svg)](https://docs.python.org/3/library/typing.html)

> %{config.description}

Official Python SDK for interacting with Circular Protocol blockchain networks. Provides a fully typed, async-ready API for wallet operations, transactions, smart contracts, assets, and more.

**Version:** %{config.version}

## Features

- 🔒 **Fully Typed** - 100% type hints coverage, zero `Any` types
- 🐍 **Python 3.8+** - Modern Python with dataclasses and type hints
- 🚀 **Async Support** - Both sync and async APIs (with aiohttp)
- 🎯 **24 API Methods** - Complete coverage of Circular Protocol operations
- ✅ **Runtime Validation** - Pydantic models for request/response validation
- 📝 **Auto-Generated** - Generated from canonical Nickel specifications
- 🧪 **Well-Tested** - Comprehensive unit and integration tests

## Installation

### Basic Installation

```bash
pip install circular-protocol-api
```

### With Async Support

```bash
pip install circular-protocol-api[async]
```

### Development Installation

```bash
pip install circular-protocol-api[dev]
```

## Quick Start

### Basic Usage

```python
from circular_protocol_api import CircularProtocolAPI

# Initialize the client
api = CircularProtocolAPI(base_url="https://api.circular.org")

# Check if a wallet exists
result = api.check_wallet(address="0x1234567890abcdef...")
print(f"Wallet exists: {result['exists']}")

# Get wallet details
wallet = api.get_wallet(address="0x1234567890abcdef...")
print(f"Balance: {wallet['balance']}")

# Get wallet balance
balance = api.get_wallet_balance(address="0x1234567890abcdef...")
print(f"Current balance: {balance['balance']}")
```

### Async Usage

```python
import asyncio
from circular_protocol_api import AsyncCircularProtocolAPI

async def main():
    # Initialize async client
    async with AsyncCircularProtocolAPI(base_url="https://api.circular.org") as api:
        # Check wallet
        result = await api.check_wallet(address="0x1234567890abcdef...")
        print(f"Wallet exists: {result['exists']}")

        # Get wallet details
        wallet = await api.get_wallet(address="0x1234567890abcdef...")
        print(f"Balance: {wallet['balance']}")

# Run async function
asyncio.run(main())
```

### Context Manager Support

```python
from circular_protocol_api import CircularProtocolAPI

# Automatic resource cleanup
with CircularProtocolAPI(base_url="https://api.circular.org") as api:
    wallet = api.check_wallet(address="0x1234567890abcdef...")
    print(f"Wallet exists: {wallet['exists']}")
```

## API Reference

### Wallet Operations

%{generate_api_row "checkWallet" all_endpoints.checkWallet}
%{generate_api_row "getWallet" all_endpoints.getWallet}
%{generate_api_row "getLatestTransactions" all_endpoints.getLatestTransactions}
%{generate_api_row "getWalletBalance" all_endpoints.getWalletBalance}
%{generate_api_row "getWalletNonce" all_endpoints.getWalletNonce}
%{generate_api_row "registerWallet" all_endpoints.registerWallet}

### Transaction Operations

%{generate_api_row "sendTransaction" all_endpoints.sendTransaction}
%{generate_api_row "getTransactionbyID" all_endpoints.getTransactionbyID}
%{generate_api_row "getTransactionbyNode" all_endpoints.getTransactionbyNode}
%{generate_api_row "getTransactionbyAddress" all_endpoints.getTransactionbyAddress}
%{generate_api_row "getTransactionbyDate" all_endpoints.getTransactionbyDate}
%{generate_api_row "getPendingTransaction" all_endpoints.getPendingTransaction}

### Block Operations

%{generate_api_row "getBlock" all_endpoints.getBlock}
%{generate_api_row "getBlockRange" all_endpoints.getBlockRange}
%{generate_api_row "getBlockCount" all_endpoints.getBlockCount}
%{generate_api_row "getAnalytics" all_endpoints.getAnalytics}

### Asset Operations

%{generate_api_row "getAssetList" all_endpoints.getAssetList}
%{generate_api_row "getAsset" all_endpoints.getAsset}
%{generate_api_row "getAssetSupply" all_endpoints.getAssetSupply}
%{generate_api_row "getVoucher" all_endpoints.getVoucher}

### Contract Operations

%{generate_api_row "testContract" all_endpoints.testContract}
%{generate_api_row "callContract" all_endpoints.callContract}

### Domain Operations

%{generate_api_row "getDomain" all_endpoints.getDomain}

### Network Operations

%{generate_api_row "getBlockchains" all_endpoints.getBlockchains}

## Advanced Usage

### Custom Configuration

```python
from circular_protocol_api import CircularProtocolAPI, CircularProtocolConfig

# Create custom configuration
config = CircularProtocolConfig(
    base_url="https://api.circular.org",
    timeout=30,  # Request timeout in seconds
    headers={"User-Agent": "MyApp/1.0"},
    verify_ssl=True,
)

# Initialize with custom config
api = CircularProtocolAPI(config=config)
```

### Error Handling

```python
from circular_protocol_api import CircularProtocolAPI, CircularAPIError

api = CircularProtocolAPI(base_url="https://api.circular.org")

try:
    wallet = api.get_wallet(address="invalid_address")
except CircularAPIError as e:
    print(f"API Error: {e.message}")
    print(f"Status Code: {e.status_code}")
    print(f"Endpoint: {e.endpoint}")
except ValueError as e:
    print(f"Validation Error: {e}")
```

### Type Hints

The SDK is fully typed with comprehensive type hints:

```python
from typing import Dict, List, Any
from circular_protocol_api import CircularProtocolAPI

api: CircularProtocolAPI = CircularProtocolAPI(base_url="https://api.circular.org")

# Return types are fully typed
wallet: Dict[str, Any] = api.get_wallet(address="0x1234...")
transactions: List[Dict[str, Any]] = api.get_latest_transactions(address="0x1234...")
```

## Development

### Running Tests

```bash
# Install development dependencies
pip install -e .[dev]

# Run all tests
pytest

# Run with coverage
pytest --cov=circular_protocol_api --cov-report=html

# Run only unit tests
pytest -m unit

# Run only integration tests
pytest -m integration
```

### Code Quality

```bash
# Format code
black src/ tests/

# Lint code
ruff check src/ tests/

# Type check
mypy src/
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Links

- [Documentation](https://docs.circular.org)
- [GitHub Repository](https://github.com/circular-protocol/circular-protocol-py)
- [Issue Tracker](https://github.com/circular-protocol/circular-protocol-py/issues)
- [Changelog](https://github.com/circular-protocol/circular-protocol-py/blob/main/CHANGELOG.md)
- [Circular Protocol](https://circular.org)

## Support

For support and questions:
- Open an issue on [GitHub](https://github.com/circular-protocol/circular-protocol-py/issues)
- Check the [documentation](https://docs.circular.org)
- Join our community discussions

---

Generated with ❤️ from [Nickel specifications](https://github.com/circular-protocol/circular-canonical)
"%
