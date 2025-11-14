# PHP README Generator
# Generates README.md for PHP/Composer SDK package

let config = import "../../../src/config.ncl" in

let php_config = {
  language = "PHP",
  package_name = "circular/circular-protocol",
  package_url = "https://packagist.org/packages/circular/circular-protocol",
  version = config.version,

  install_command = m%"
```bash
composer require circular/circular-protocol
```
"%,

  import_example = "use Circular\\CircularProtocolAPI;",

  quick_start_example = m%"
```php
<?php

require_once 'vendor/autoload.php';

use Circular\\CircularProtocolAPI;
use Circular\\CircularAPIException;

// Initialize the API client
$api = new CircularProtocolAPI(
    'https://nag.circularlabs.io/NAG.php?cep=',
    'your-api-key' // Optional
);

try {
    // Check if a wallet exists
    $result = $api->checkWallet([
        'Address' => '0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310',
        'Blockchain' => 'MainNet',
        'Version' => '%{config.version}'
    ]);

    echo "Wallet exists: " . $result['Response'] . "\\n";
} catch (CircularAPIException $e) {
    echo "API Error: " . $e->getMessage() . "\\n";
}
```
"%,
} in

{
  readme_content = m%"# Circular Protocol - PHP SDK

[![Packagist Version](https://img.shields.io/packagist/v/circular/circular-protocol.svg)](https://packagist.org/packages/circular/circular-protocol)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

The **Circular Protocol PHP SDK** is the official PHP library for seamless integration with the Circular blockchain ecosystem. This open-source SDK provides a comprehensive suite of tools for efficient and secure interaction with blockchain networks, managing wallets, assets, smart contracts, and more.

## 🔥 Key Features

- **Blockchain Interaction**: Connect and interact with Circular's blockchain networks
- **Smart Contracts**: Deploy, test, and interact with smart contracts
- **Wallet Management**: Create, retrieve, and manage blockchain wallets with balance tracking
- **Asset Management**: Issue and manage assets, handle transfers, and retrieve supply information
- **Domain Management**: Resolve blockchain domain names to wallet addresses
- **Transaction Management**: Send transactions, track status, and search the blockchain
- **Analytics**: Access blockchain performance data and insights
- **Cryptographic Helpers**: Built-in utilities for key generation, signing, and hashing
- **PHP 8.0+ Support**: Compatible with PHP 8.0, 8.1, 8.2, and 8.3
- **PSR-4 Autoloading**: Follows PHP-FIG standards for modern PHP development

%{php_config.install_command}

## 🚀 Quick Start

%{php_config.quick_start_example}

## 📜 API Reference

For detailed information on all available methods, parameters, and return types, refer to the **[PHP SDK Documentation](https://circular-protocol.gitbook.io/circular-sdk/api-docs/php)**.

### Available Methods

**Wallet Operations**: `checkWallet`, `getWallet`, `getWalletBalance`, `getWalletNonce`, `getLatestTransactions`

**Transaction Operations**: `sendTransaction`, `getTransactionbyID`, `getTransactionbyNode`, `getTransactionbyAddress`, `getTransactionbyDate`, `getPendingTransaction`

**Asset Operations**: `getAssetList`, `getAsset`, `getAssetSupply`, `getVoucher`

**Block Operations**: `getBlock`, `getBlockRange`, `getBlockCount`, `getAnalytics`

**Contract Operations**: `testContract`, `callContract`

**Domain Operations**: `getDomain`

**Network Operations**: `getBlockchains`

**Cryptographic Helpers**: `getFormattedTimestamp`, `hashString`, `getPublicKey`, `signMessage`, `getKeysFromString`

## 🤝 Contributing

Contributions are welcome! Please see the [CONTRIBUTING.md](https://github.com/circular-protocol/circular-canonical/blob/main/CONTRIBUTING.md) file in the canonical repository for guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 Resources

- **[PHP SDK Documentation](https://circular-protocol.gitbook.io/circular-sdk/api-docs/php)** - Complete API reference
- **[Circular Protocol Docs](https://circular-protocol.gitbook.io)** - Protocol documentation
- **[Circular Canonical](https://github.com/circular-protocol/circular-canonical)** - Single source of truth
- **[Package on Packagist](%{php_config.package_url})** - Official PHP package

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
    language = "PHP",
  },
}
