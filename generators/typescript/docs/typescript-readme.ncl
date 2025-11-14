# TypeScript README Generator
# Generates README.md for TypeScript/NPM SDK package

let config = import "../../../src/config.ncl" in
let api_reference = import "../../shared/api-reference-template.ncl" in

let typescript_config = {
  language = "TypeScript",
  package_name = "circular-protocol",
  package_url = "https://www.npmjs.com/package/circular-protocol",
  version = config.version,

  install_command = m%"
```bash
npm install circular-protocol
```

Or with Yarn:

```bash
yarn add circular-protocol
```

Or with pnpm:

```bash
pnpm add circular-protocol
```
"%,

  import_example = "import { CircularProtocolAPI } from 'circular-protocol';",

  quick_start_example = m%"
```typescript
import { CircularProtocolAPI } from 'circular-protocol';

async function main() {
  // Initialize the API client
  const api = new CircularProtocolAPI({
    nagUrl: 'https://nag.circularlabs.io/NAG.php?cep=',
    nagKey: 'your-api-key', // Optional
  });

  try {
    // Check if a wallet exists
    const result = await api.checkWallet({
      Address: '0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310',
      Blockchain: 'MainNet',
      Version: '%{config.version}',
    });

    console.log('Wallet exists:', result.Response);
  } catch (error) {
    if (error instanceof CircularAPIException) {
      console.error('API Error:', error.message);
    }
  }
}

main();
```
"%,
} in

{
  readme_content = m%"# Circular Protocol - TypeScript SDK

[![npm version](https://img.shields.io/npm/v/circular-protocol.svg)](https://www.npmjs.com/package/circular-protocol)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

The **Circular Protocol TypeScript SDK** is the official TypeScript/JavaScript library for seamless integration with the Circular blockchain ecosystem. This open-source SDK provides a comprehensive suite of tools for efficient and secure interaction with blockchain networks, managing wallets, assets, smart contracts, and more.

## 🔥 Key Features

- **Blockchain Interaction**: Connect and interact with Circular's blockchain networks
- **Smart Contracts**: Deploy, test, and interact with smart contracts
- **Wallet Management**: Create, retrieve, and manage blockchain wallets with balance tracking
- **Asset Management**: Issue and manage assets, handle transfers, and retrieve supply information
- **Domain Management**: Resolve blockchain domain names to wallet addresses
- **Transaction Management**: Send transactions, track status, and search the blockchain
- **Analytics**: Access blockchain performance data and insights
- **Cryptographic Helpers**: Built-in utilities for key generation, signing, and hashing
- **TypeScript Support**: Full type definitions for enhanced developer experience
- **Dual Module Support**: Works with both CommonJS (require) and ES Modules (import)

%{typescript_config.install_command}

## 🚀 Quick Start

%{typescript_config.quick_start_example}

## 📜 API Reference

The Circular Protocol TypeScript SDK provides **39 methods** across multiple categories for comprehensive blockchain interaction.

%{api_reference.api_reference_markdown}

> **Note**: For detailed parameter types, response structures, and advanced usage examples, refer to the **[TypeScript SDK Documentation](https://circular-protocol.gitbook.io/circular-sdk/api-docs/typescript)**.

## 🤝 Contributing

Contributions are welcome! Please see the [CONTRIBUTING.md](https://github.com/circular-protocol/circular-canonical/blob/main/CONTRIBUTING.md) file in the canonical repository for guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 Resources

- **[TypeScript SDK Documentation](https://circular-protocol.gitbook.io/circular-sdk/api-docs/typescript)** - Complete API reference
- **[Circular Protocol Docs](https://circular-protocol.gitbook.io)** - Protocol documentation
- **[Circular Canonical](https://github.com/circular-protocol/circular-canonical)** - Single source of truth
- **[Package on npm](%{typescript_config.package_url})** - Official TypeScript/JavaScript package

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
    language = "TypeScript",
  },
}
