# Go README Generator
# Generates README.md for Go SDK package

let config = import "../../../src/config.ncl" in

let go_config = {
  language = "Go",
  package_name = "github.com/circular-protocol/circular-go",
  package_url = "https://pkg.go.dev/github.com/circular-protocol/circular-go",
  version = config.version,

  install_command = m%"
```bash
go get github.com/circular-protocol/circular-go
```
"%,

  import_example = "import \"github.com/circular-protocol/circular-go\"",

  quick_start_example = m%"
```go
package main

import (
    "fmt"
    "log"

    circular "github.com/circular-protocol/circular-go"
)

func main() {
    // Initialize the API client
    api := circular.NewCircularProtocolAPI(
        "https://nag.circularlabs.io/NAG.php?cep=",
        circular.WithAPIKey("your-api-key"), // Optional
    )

    // Check if a wallet exists
    params := map[string]interface{}{
        "Address":    "0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310",
        "Blockchain": "MainNet",
        "Version":    "%{config.version}",
    }

    result, err := api.CheckWallet(params)
    if err != nil {
        log.Fatalf("API Error: %v", err)
    }

    fmt.Printf("Wallet exists: %v\\n", result["Response"])
}
```
"%,
} in

{
  readme_content = m%"# Circular Protocol - Go SDK

[![Go Reference](https://pkg.go.dev/badge/github.com/circular-protocol/circular-go.svg)](https://pkg.go.dev/github.com/circular-protocol/circular-go)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Go Report Card](https://goreportcard.com/badge/github.com/circular-protocol/circular-go)](https://goreportcard.com/report/github.com/circular-protocol/circular-go)

The **Circular Protocol Go SDK** is the official Go library for seamless integration with the Circular blockchain ecosystem. This open-source SDK provides a comprehensive suite of tools for efficient and secure interaction with blockchain networks, managing wallets, assets, smart contracts, and more.

## 🔥 Key Features

- **Blockchain Interaction**: Connect and interact with Circular's blockchain networks
- **Smart Contracts**: Deploy, test, and interact with smart contracts
- **Wallet Management**: Create, retrieve, and manage blockchain wallets with balance tracking
- **Asset Management**: Issue and manage assets, handle transfers, and retrieve supply information
- **Domain Management**: Resolve blockchain domain names to wallet addresses
- **Transaction Management**: Send transactions, track status, and search the blockchain
- **Analytics**: Access blockchain performance data and insights
- **Cryptographic Helpers**: Built-in utilities for key generation, signing, and hashing
- **Go 1.19+ Support**: Compatible with modern Go versions
- **Context Support**: Full context.Context integration for cancellation and timeouts

%{go_config.install_command}

## 🚀 Quick Start

%{go_config.quick_start_example}

## 📜 API Reference

For detailed information on all available methods, parameters, and return types, refer to the **[Go SDK Documentation](https://circular-protocol.gitbook.io/circular-sdk/api-docs/go)**.

### Available Methods

**Wallet Operations**: `CheckWallet`, `GetWallet`, `GetWalletBalance`, `GetWalletNonce`, `GetLatestTransactions`

**Transaction Operations**: `SendTransaction`, `GetTransactionbyID`, `GetTransactionbyNode`, `GetTransactionbyAddress`, `GetTransactionbyDate`, `GetPendingTransaction`

**Asset Operations**: `GetAssetList`, `GetAsset`, `GetAssetSupply`, `GetVoucher`

**Block Operations**: `GetBlock`, `GetBlockRange`, `GetBlockCount`, `GetAnalytics`

**Contract Operations**: `TestContract`, `CallContract`

**Domain Operations**: `GetDomain`

**Network Operations**: `GetBlockchains`

**Cryptographic Helpers**: `GetFormattedTimestamp`, `HashString`, `GetPublicKey`, `SignMessage`, `GetKeysFromString`

## 🤝 Contributing

Contributions are welcome! Please see the [CONTRIBUTING.md](https://github.com/circular-protocol/circular-canonical/blob/main/CONTRIBUTING.md) file in the canonical repository for guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 Resources

- **[Go SDK Documentation](https://circular-protocol.gitbook.io/circular-sdk/api-docs/go)** - Complete API reference
- **[Circular Protocol Docs](https://circular-protocol.gitbook.io)** - Protocol documentation
- **[Circular Canonical](https://github.com/circular-protocol/circular-canonical)** - Single source of truth
- **[Package on pkg.go.dev](%{go_config.package_url})** - Official Go package

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
    language = "Go",
  },
}
