# Python README Generator
# Generates README.md for Python/PyPI SDK package

let config = import "../../../src/config.ncl" in

let python_config = {
  language = "Python",
  package_name = "circular-protocol",
  package_url = "https://pypi.org/project/circular-protocol/",
  version = config.version,

  install_command = m%"
```bash
pip install circular-protocol
```

Or with poetry:

```bash
poetry add circular-protocol
```

Or with pipenv:

```bash
pipenv install circular-protocol
```
"%,

  import_example = "from circular_protocol import CircularProtocolAPI",

  quick_start_example = m%"
```python
from circular_protocol import CircularProtocolAPI, CircularAPIException

async def main():
    # Initialize the API client
    api = CircularProtocolAPI(
        nag_url='https://nag.circularlabs.io/NAG.php?cep=',
        nag_key='your-api-key'  # Optional
    )

    try:
        # Check if a wallet exists
        result = await api.check_wallet({
            'Address': '0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310',
            'Blockchain': 'MainNet',
            'Version': '%{config.version}'
        })

        print(f"Wallet exists: {result['Response']}")
    except CircularAPIException as e:
        print(f"API Error: {e.message}")
    finally:
        await api.close()

# Run with asyncio
import asyncio
asyncio.run(main())
```
"%,
} in

{
  readme_content = m%"# Circular Protocol - Python SDK

[![PyPI version](https://img.shields.io/pypi/v/circular-protocol.svg)](https://pypi.org/project/circular-protocol/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

The **Circular Protocol Python SDK** is the official Python library for seamless integration with the Circular blockchain ecosystem. This open-source SDK provides a comprehensive suite of tools for efficient and secure interaction with blockchain networks, managing wallets, assets, smart contracts, and more.

## 🔥 Key Features

- **Blockchain Interaction**: Connect and interact with Circular's blockchain networks
- **Smart Contracts**: Deploy, test, and interact with smart contracts
- **Wallet Management**: Create, retrieve, and manage blockchain wallets with balance tracking
- **Asset Management**: Issue and manage assets, handle transfers, and retrieve supply information
- **Domain Management**: Resolve blockchain domain names to wallet addresses
- **Transaction Management**: Send transactions, track status, and search the blockchain
- **Analytics**: Access blockchain performance data and insights
- **Cryptographic Helpers**: Built-in utilities for key generation, signing, and hashing
- **Async/Await Support**: Full async/await support with aiohttp
- **Type Hints**: Comprehensive type annotations for better IDE support

%{python_config.install_command}

## 🚀 Quick Start

%{python_config.quick_start_example}

## 📜 API Reference

For detailed information on all available methods, parameters, and return types, refer to the **[Python SDK Documentation](https://circular-protocol.gitbook.io/circular-sdk/api-docs/python)**.

### Available Methods

**Wallet Operations**: `check_wallet`, `get_wallet`, `get_wallet_balance`, `get_wallet_nonce`, `get_latest_transactions`

**Transaction Operations**: `send_transaction`, `get_transaction_by_id`, `get_transaction_by_node`, `get_transaction_by_address`, `get_transaction_by_date`, `get_pending_transaction`

**Asset Operations**: `get_asset_list`, `get_asset`, `get_asset_supply`, `get_voucher`

**Block Operations**: `get_block`, `get_block_range`, `get_block_count`, `get_analytics`

**Contract Operations**: `test_contract`, `call_contract`

**Domain Operations**: `get_domain`

**Network Operations**: `get_blockchains`

**Cryptographic Helpers**: `get_formatted_timestamp`, `hash_string`, `get_public_key`, `sign_message`, `get_keys_from_string`

## 🤝 Contributing

Contributions are welcome! Please see the [CONTRIBUTING.md](https://github.com/circular-protocol/circular-canonical/blob/main/CONTRIBUTING.md) file in the canonical repository for guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 Resources

- **[Python SDK Documentation](https://circular-protocol.gitbook.io/circular-sdk/api-docs/python)** - Complete API reference
- **[Circular Protocol Docs](https://circular-protocol.gitbook.io)** - Protocol documentation
- **[Circular Canonical](https://github.com/circular-protocol/circular-canonical)** - Single source of truth
- **[Package on PyPI](%{python_config.package_url})** - Official Python package

## ℹ️ About

**Version**: %{config.version}
**License**: MIT
**Generated**: Auto-generated from [Circular Canonical](https://github.com/circular-protocol/circular-canonical) specification

---

© 2025 Circular Global Ledgers, Inc. - Open source for private and commercial use
"%,

  # Metadata
  metadata = {
    version = config.version,
    language = "Python",
  },
}
