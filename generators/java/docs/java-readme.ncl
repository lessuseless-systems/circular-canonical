# Java Package README Generator
# Generates comprehensive README.md for Maven package

let config = import "../../../src/config.ncl" in
let wallet = import "../../../src/api/wallet.ncl" in
let transaction = import "../../../src/api/transaction.ncl" in
let block = import "../../../src/api/block.ncl" in
let asset = import "../../../src/api/asset.ncl" in
let contract = import "../../../src/api/contract.ncl" in
let domain = import "../../../src/api/domain.ncl" in
let network = import "../../../src/api/network.ncl" in

# Helper: Convert endpoint path to Java method name (camelCase)
let to_java_method = fun path =>
  let without_slash = std.string.replace_regex "/" "" path in
  let first_lower = std.string.lowercase (std.string.substring 0 1 without_slash) in
  let rest = std.string.substring 1 (std.string.length without_slash) without_slash in
  first_lower ++ rest
in

# Helper: Generate API method documentation row
let generate_api_row = fun name endpoint =>
  "| `%{to_java_method endpoint.path}` | %{endpoint.summary} | %{endpoint.method} |"
in

m%"
# Circular Protocol API - Java SDK

[![Maven Central](https://img.shields.io/maven-central/v/io.circular/circular-protocol-api.svg)](https://search.maven.org/artifact/io.circular/circular-protocol-api)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Java](https://img.shields.io/badge/Java-11+-blue.svg)](https://www.oracle.com/java/)

> %{config.description}

Official Java SDK for interacting with Circular Protocol blockchain networks. Provides a type-safe, CompletableFuture-based API for wallet operations, transactions, smart contracts, assets, and more.

**Version:** %{config.version}

## Features

- 🔒 **Type-Safe** - Full Java type safety with generics
- ⚡ **Async Support** - CompletableFuture-based async operations
- 🎯 **24 API Methods** - Complete coverage of Circular Protocol operations
- 📦 **Maven Compatible** - Easy integration with Maven projects
- ✅ **Jackson Integration** - Automatic JSON serialization/deserialization
- 📝 **Auto-Generated** - Generated from canonical Nickel specifications
- 🧪 **Fully Tested** - Comprehensive unit and integration tests

## Requirements

- Java 11 or higher
- Maven 3.6+ or Gradle 7.0+

## Installation

### Maven

Add to your `pom.xml`:

```xml
<dependency>
    <groupId>io.circular</groupId>
    <artifactId>circular-protocol-api</artifactId>
    <version>%{config.version}</version>
</dependency>
```

### Gradle

Add to your `build.gradle`:

```gradle
implementation 'io.circular:circular-protocol-api:%{config.version}'
```

## Quick Start

```java
import io.circular.protocol.CircularProtocolAPI;
import io.circular.protocol.CircularProtocolAPI.*;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

public class Example {
    public static void main(String[] args) {
        // Initialize the API client
        CircularProtocolAPI api = new CircularProtocolAPI(
            "https://nag.circularlabs.io/NAG.php?cep=",  // NAG URL
            null  // Optional API key
        );

        // Synchronous call (blocking)
        try {
            Map<String, Object> result = api.%{to_java_method wallet.checkWallet.path}(
                Map.of("Address", "0x1234567890abcdef...")
            ).get();

            System.out.println("Result: " + result.get("Result"));
            System.out.println("Response: " + result.get("Response"));
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Asynchronous call (non-blocking)
        api.%{to_java_method wallet.getWallet.path}(
            Map.of("Address", "0x1234567890abcdef...")
        ).thenAccept(wallet -> {
            System.out.println("Wallet: " + wallet);
        }).exceptionally(ex -> {
            System.err.println("Error: " + ex.getMessage());
            return null;
        });
    }
}
```

## API Reference

Complete API documentation for all 24 methods:

### Wallet Operations

| Method | Description | HTTP Method |
|--------|-------------|-------------|
%{generate_api_row "checkWallet" wallet.checkWallet}
%{generate_api_row "getWallet" wallet.getWallet}
%{generate_api_row "getLatestTransactions" wallet.getLatestTransactions}
%{generate_api_row "getWalletBalance" wallet.getWalletBalance}
%{generate_api_row "getWalletNonce" wallet.getWalletNonce}
%{generate_api_row "registerWallet" wallet.registerWallet}

### Transaction Operations

| Method | Description | HTTP Method |
|--------|-------------|-------------|
%{generate_api_row "sendTransaction" transaction.sendTransaction}
%{generate_api_row "getTransactionbyID" transaction.getTransactionbyID}
%{generate_api_row "getTransactionbyNode" transaction.getTransactionbyNode}
%{generate_api_row "getTransactionbyAddress" transaction.getTransactionbyAddress}
%{generate_api_row "getTransactionbyDate" transaction.getTransactionbyDate}
%{generate_api_row "getPendingTransaction" transaction.getPendingTransaction}

### Block Operations

| Method | Description | HTTP Method |
|--------|-------------|-------------|
%{generate_api_row "getBlock" block.getBlock}
%{generate_api_row "getBlockRange" block.getBlockRange}
%{generate_api_row "getBlockCount" block.getBlockCount}
%{generate_api_row "getAnalytics" block.getAnalytics}

### Asset Operations

| Method | Description | HTTP Method |
|--------|-------------|-------------|
%{generate_api_row "getAssetList" asset.getAssetList}
%{generate_api_row "getAsset" asset.getAsset}
%{generate_api_row "getAssetSupply" asset.getAssetSupply}
%{generate_api_row "getVoucher" asset.getVoucher}

### Smart Contract Operations

| Method | Description | HTTP Method |
|--------|-------------|-------------|
%{generate_api_row "testContract" contract.testContract}
%{generate_api_row "callContract" contract.callContract}

### Domain Operations

| Method | Description | HTTP Method |
|--------|-------------|-------------|
%{generate_api_row "getDomain" domain.getDomain}

### Network Operations

| Method | Description | HTTP Method |
|--------|-------------|-------------|
%{generate_api_row "getBlockchains" network.getBlockchains}

## Usage Examples

### Check Wallet Exists

```java
CompletableFuture<Map<String, Object>> future = api.%{to_java_method wallet.checkWallet.path}(
    Map.of(
        "Address", "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
        "Blockchain", "MainNet",
        "Version", "%{config.version}"
    )
);

Map<String, Object> result = future.get();
if ((Integer) result.get("Result") == 200) {
    System.out.println("Wallet exists on the blockchain");
}
```

### Get Wallet Information

```java
api.%{to_java_method wallet.getWallet.path}(
    Map.of("Address", "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb")
).thenAccept(result -> {
    Map<String, Object> response = (Map<String, Object>) result.get("Response");
    System.out.println("Balance: " + response.get("Balance"));
    System.out.println("Nonce: " + response.get("Nonce"));
    System.out.println("Public Key: " + response.get("PublicKey"));
});
```

### Send Transaction

```java
Map<String, Object> transaction = Map.of(
    "From", "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    "To", "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199",
    "Amount", "1000000",
    "Nonce", 1,
    "Timestamp", "2024:11:07-15:30:00",
    "Signature", "0x..."
);

api.%{to_java_method transaction.sendTransaction.path}(Map.of("Transaction", transaction))
    .thenAccept(result -> {
        Map<String, Object> response = (Map<String, Object>) result.get("Response");
        System.out.println("Transaction ID: " + response.get("TransactionID"));
    })
    .exceptionally(ex -> {
        System.err.println("Transaction failed: " + ex.getMessage());
        return null;
    });
```

### Get Transaction by ID

```java
api.%{to_java_method transaction.getTransactionbyID.path}(
    Map.of("ID", "0x1234567890abcdef...")
).thenAccept(result -> {
    Map<String, Object> tx = (Map<String, Object>) result.get("Response");
    System.out.println("Transaction: " + tx);
});
```

### Get Asset Information

```java
api.%{to_java_method asset.getAsset.path}(
    Map.of("AssetName", "MyToken")
).thenAccept(result -> {
    Map<String, Object> asset = (Map<String, Object>) result.get("Response");
    System.out.println("Total Supply: " + asset.get("TotalSupply"));
    System.out.println("Decimals: " + asset.get("Decimals"));
});
```

## Configuration

### Custom NAG URL

```java
CircularProtocolAPI api = new CircularProtocolAPI(
    "https://custom-nag-url.com/NAG.php?cep=",
    null
);
```

### With API Key

```java
CircularProtocolAPI api = new CircularProtocolAPI(
    "https://nag.circularlabs.io/NAG.php?cep=",
    "your-api-key-here"
);
```

### Update Configuration at Runtime

```java
api.setNagUrl("https://new-url.com/NAG.php?cep=");
api.setNagKey("new-api-key");
```

## Error Handling

The SDK throws `CircularProtocolException` for API errors:

```java
try {
    Map<String, Object> result = api.%{to_java_method wallet.checkWallet.path}(params).get();
    // Handle successful response
} catch (ExecutionException e) {
    if (e.getCause() instanceof CircularProtocolException) {
        CircularProtocolException apiError = (CircularProtocolException) e.getCause();
        System.err.println("API Error at " + apiError.getEndpoint());
        System.err.println("Status: " + apiError.getStatusCode());
        System.err.println("Message: " + apiError.getMessage());
    } else {
        System.err.println("Network error: " + e.getMessage());
    }
} catch (InterruptedException e) {
    Thread.currentThread().interrupt();
    System.err.println("Request interrupted");
}
```

## Thread Safety

The `CircularProtocolAPI` class is thread-safe and can be shared across multiple threads. It uses `HttpClient` which manages its own connection pool.

```java
// Single instance for entire application
private static final CircularProtocolAPI API = new CircularProtocolAPI(
    "https://nag.circularlabs.io/NAG.php?cep=",
    null
);

// Use from multiple threads
ExecutorService executor = Executors.newFixedThreadPool(10);
for (int i = 0; i < 100; i++) {
    executor.submit(() -> {
        API.%{to_java_method wallet.checkWallet.path}(params)
            .thenAccept(System.out::println);
    });
}
```

## Building from Source

```bash
# Clone the repository
git clone https://github.com/circular-protocol/circular-canonical.git
cd circular-canonical

# Generate Java SDK
just generate-java-package

# Build with Maven
cd dist/java
mvn clean install

# Run tests
mvn test
```

## Contributing

Contributions are welcome! This SDK is auto-generated from Nickel specifications in the [circular-canonical](https://github.com/circular-protocol/circular-canonical) repository.

1. Fork the canonical repository
2. Make changes to Nickel specifications
3. Regenerate SDKs with `just generate-java-package`
4. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

- **Documentation**: [https://docs.circular.org](https://docs.circular.org)
- **Issues**: [https://github.com/circular-protocol/circular-canonical/issues](https://github.com/circular-protocol/circular-canonical/issues)
- **Discord**: [https://discord.gg/circular](https://discord.gg/circular)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

**Generated from**: Nickel canonical specification v%{config.version}
**Last updated**: 2024-11-09
"%
