# Java README Generator
# Generates README.md for Java/Maven SDK package

let config = import "../../../src/config.ncl" in

let java_config = {
  language = "Java",
  package_name = "circular-protocol",
  package_url = "https://central.sonatype.com/artifact/io.circular/circular-protocol",
  version = config.version,

  install_command = m%"
Add this dependency to your `pom.xml`:

```xml
<dependency>
    <groupId>io.circular</groupId>
    <artifactId>circular-protocol</artifactId>
    <version>%{config.version}</version>
</dependency>
```

Or for Gradle:

```gradle
implementation 'io.circular:circular-protocol:%{config.version}'
```
"%,

  import_example = "import io.circular.CircularProtocolAPI;",

  quick_start_example = m%"
```java
import io.circular.CircularProtocolAPI;
import io.circular.CircularAPIException;
import java.util.HashMap;
import java.util.Map;

public class Example {
    public static void main(String[] args) {
        // Initialize the API client
        CircularProtocolAPI api = new CircularProtocolAPI(
            "https://nag.circularlabs.io/NAG.php?cep=",
            "your-api-key" // Optional
        );

        try {
            // Check if a wallet exists
            Map<String, Object> params = new HashMap<>();
            params.put("Address", "0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310");
            params.put("Blockchain", "MainNet");
            params.put("Version", "%{config.version}");

            Map<String, Object> result = api.checkWallet(params);
            System.out.println("Wallet exists: " + result.get("Response"));
        } catch (CircularAPIException e) {
            System.err.println("API Error: " + e.getMessage());
        }
    }
}
```
"%,
} in

{
  readme_content = m%"# Circular Protocol - Java SDK

[![Maven Central](https://img.shields.io/maven-central/v/io.circular/circular-protocol.svg)](https://central.sonatype.com/artifact/io.circular/circular-protocol)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

The **Circular Protocol Java SDK** is the official Java library for seamless integration with the Circular blockchain ecosystem. This open-source SDK provides a comprehensive suite of tools for efficient and secure interaction with blockchain networks, managing wallets, assets, smart contracts, and more.

## 🔥 Key Features

- **Blockchain Interaction**: Connect and interact with Circular's blockchain networks
- **Smart Contracts**: Deploy, test, and interact with smart contracts
- **Wallet Management**: Create, retrieve, and manage blockchain wallets with balance tracking
- **Asset Management**: Issue and manage assets, handle transfers, and retrieve supply information
- **Domain Management**: Resolve blockchain domain names to wallet addresses
- **Transaction Management**: Send transactions, track status, and search the blockchain
- **Analytics**: Access blockchain performance data and insights
- **Cryptographic Helpers**: Built-in utilities for key generation, signing, and hashing
- **Java 11+ Support**: Compatible with Java 11, 17, and 21
- **Type Safety**: Strong typing with comprehensive Javadoc documentation

%{java_config.install_command}

## 🚀 Quick Start

%{java_config.quick_start_example}

## 📜 API Reference

For detailed information on all available methods, parameters, and return types, refer to the **[Java SDK Documentation](https://circular-protocol.gitbook.io/circular-sdk/api-docs/java)**.

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

- **[Java SDK Documentation](https://circular-protocol.gitbook.io/circular-sdk/api-docs/java)** - Complete API reference
- **[Circular Protocol Docs](https://circular-protocol.gitbook.io)** - Protocol documentation
- **[Circular Canonical](https://github.com/circular-protocol/circular-canonical)** - Single source of truth
- **[Package on Maven Central](%{java_config.package_url})** - Official Java package

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
    language = "Java",
  },
}
