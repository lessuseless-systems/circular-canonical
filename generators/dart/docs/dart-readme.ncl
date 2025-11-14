# Dart README Generator
# Generates README.md for Dart SDK package using shared template

let config = import "../../../src/config.ncl" in
let template = import "../../shared/templates/readme-template.ncl" in

let dart_config = {
  language = "Dart",
  package_name = "circular_protocol",
  package_url = "https://pub.dev/packages/circular_protocol",
  version = config.version,

  install_command = m%"
Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  circular_protocol: ^%{config.version}
```

Then run:

```bash
dart pub get
```

Or for Flutter projects:

```bash
flutter pub get
```
"%,

  import_example = "import 'package:circular_protocol/circular_protocol.dart';",

  quick_start_example = m%"
```dart
import 'package:circular_protocol/circular_protocol.dart';

void main() async {
  // Initialize the API client
  final api = CircularProtocolAPI(
    nagUrl: 'https://nag.circularlabs.io/NAG.php?cep=',
    nagKey: 'your-api-key',  // Optional
  );

  try {
    // Check if a wallet exists
    final result = await api.checkWallet({
      'Address': '0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310',
      'Blockchain': 'MainNet',
      'Version': '%{config.version}',
    });

    print('Wallet exists: ${result['Response']}');
  } on CircularAPIException catch (e) {
    print('Error: ${e.message}');
  } finally {
    api.dispose();
  }
}
```
"%,
} in

{
  readme_content = m%"# Circular Protocol - Dart SDK

[![pub package](https://img.shields.io/pub/v/circular_protocol.svg)](https://pub.dev/packages/circular_protocol)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

The **Circular Protocol Dart SDK** is the official Dart/Flutter library for seamless integration with the Circular blockchain ecosystem. This open-source SDK provides a comprehensive suite of tools for efficient and secure interaction with blockchain networks, managing wallets, assets, smart contracts, and more.

## 🔥 Key Features

- **Blockchain Interaction**: Connect and interact with Circular's blockchain networks
- **Smart Contracts**: Deploy, test, and interact with smart contracts
- **Wallet Management**: Create, retrieve, and manage blockchain wallets with balance tracking
- **Asset Management**: Issue and manage assets, handle transfers, and retrieve supply information
- **Domain Management**: Resolve blockchain domain names to wallet addresses
- **Transaction Management**: Send transactions, track status, and search the blockchain
- **Analytics**: Access blockchain performance data and insights
- **Cryptographic Helpers**: Built-in utilities for key generation, signing, and hashing
- **Multi-Platform**: Works on Android, iOS, Web, Linux, macOS, and Windows
- **Type-Safe**: Full Dart type hints with async/await support

%{dart_config.install_command}

## 🚀 Quick Start

%{dart_config.quick_start_example}

## 📜 API Reference

For detailed information on all available methods, parameters, and return types, refer to the **[Dart SDK Documentation](https://circular-protocol.gitbook.io/circular-sdk/api-docs/dart)**.

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

- **[Dart SDK Documentation](https://circular-protocol.gitbook.io/circular-sdk/api-docs/dart)** - Complete API reference
- **[Circular Protocol Docs](https://circular-protocol.gitbook.io)** - Protocol documentation
- **[Circular Canonical](https://github.com/circular-protocol/circular-canonical)** - Single source of truth
- **[Package on pub.dev](%{dart_config.package_url})** - Official Dart package

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
    language = "Dart",
  },
}
