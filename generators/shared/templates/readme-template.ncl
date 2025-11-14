# Shared README Template for All SDKs
# This template provides consistent structure across all language SDKs

let generate_readme = fun language_config =>
  let lang = language_config.language in
  let pkg_name = language_config.package_name in
  let pkg_url = language_config.package_url in
  let install_cmd = language_config.install_command in
  let import_example = language_config.import_example in
  let quick_start = language_config.quick_start_example in
  let version = language_config.version in
  let gitbook_url = "https://circular-protocol.gitbook.io/circular-sdk/api-docs/%{std.string.lowercase lang}" in

  m%"
# Circular Protocol - %{lang} SDK

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

The **Circular Protocol %{lang} SDK** is the official %{lang} library for seamless integration with the Circular blockchain ecosystem. This open-source SDK provides a comprehensive suite of tools for efficient and secure interaction with blockchain networks, managing wallets, assets, smart contracts, and more.

## 🔥 Key Features

- **Blockchain Interaction**: Connect and interact with Circular's blockchain networks
- **Smart Contracts**: Deploy, test, and interact with smart contracts
- **Wallet Management**: Create, retrieve, and manage blockchain wallets with balance tracking
- **Asset Management**: Issue and manage assets, handle transfers, and retrieve supply information
- **Domain Management**: Resolve blockchain domain names to wallet addresses
- **Transaction Management**: Send transactions, track status, and search the blockchain
- **Analytics**: Access blockchain performance data and insights
- **Cryptographic Helpers**: Built-in utilities for key generation, signing, and hashing

## Installation

%{install_cmd}

## 🚀 Quick Start

%{quick_start}

## 📜 API Reference

For detailed information on all available methods, parameters, and return types, refer to the **[%{lang} SDK Documentation](%{gitbook_url})**.

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

- **[%{lang} SDK Documentation](%{gitbook_url})** - Complete API reference
- **[Circular Protocol Docs](https://circular-protocol.gitbook.io)** - Protocol documentation
- **[Circular Canonical](https://github.com/circular-protocol/circular-canonical)** - Single source of truth
- **[Package Registry](%{pkg_url})** - Official %{lang} package

## ℹ️ About

**Version**: %{version}
**License**: MIT
**Generated**: Auto-generated from [Circular Canonical](https://github.com/circular-protocol/circular-canonical) specification

---

© 2025 Circular Global Ledgers, Inc. - Open source for private and commercial use
"%
in

{
  generate = generate_readme,
}
