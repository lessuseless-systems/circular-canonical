# PHP Package README Generator
# Generates comprehensive README.md for Composer package

let config = import "../../../src/config.ncl" in
let wallet = import "../../../src/api/wallet.ncl" in
let transaction = import "../../../src/api/transaction.ncl" in
let block = import "../../../src/api/block.ncl" in
let asset = import "../../../src/api/asset.ncl" in
let contract = import "../../../src/api/contract.ncl" in
let domain = import "../../../src/api/domain.ncl" in
let network = import "../../../src/api/network.ncl" in

# Helper: Convert endpoint path to PHP method name (camelCase)
let to_php_method = fun path =>
  let without_slash = std.string.replace_regex "/" "" path in
  let first_lower = std.string.lowercase (std.string.substring 0 1 without_slash) in
  let rest = std.string.substring 1 (std.string.length without_slash) without_slash in
  first_lower ++ rest
in

# Helper: Generate API method documentation row
let generate_api_row = fun name endpoint =>
  "| `%{to_php_method endpoint.path}()` | %{endpoint.summary} | %{endpoint.method} |"
in

m%"
# Circular Protocol API - PHP SDK

[![Packagist Version](https://img.shields.io/packagist/v/circular/protocol-api.svg)](https://packagist.org/packages/circular/protocol-api)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PHP](https://img.shields.io/badge/PHP-8.0+-blue.svg)](https://www.php.net/)

> %{config.description}

Official PHP SDK for interacting with Circular Protocol blockchain networks. Provides a type-safe, PSR-4 compliant API for wallet operations, transactions, smart contracts, assets, and more.

**Version:** %{config.version}

## Features

- 🔒 **Type-Safe** - Full PHP 8.0+ type hints and return types
- 📦 **PSR-4 Autoloading** - Modern PHP autoloading standard
- 🎯 **24 API Methods** - Complete coverage of Circular Protocol operations
- ✅ **Composer Compatible** - Easy integration via Composer
- 🔧 **Curl-Based** - Reliable HTTP client using ext-curl
- 📝 **Auto-Generated** - Generated from canonical Nickel specifications
- 🧪 **Fully Tested** - Comprehensive PHPUnit test suite

## Requirements

- PHP 8.0 or higher
- ext-curl
- ext-json
- Composer 2.0+

## Installation

Install via Composer:

```bash
composer require circular/protocol-api
```

## Quick Start

```php
<?php

require_once 'vendor/autoload.php';

use Circular\Protocol\CircularProtocolAPI;
use Circular\Protocol\CircularProtocolException;

// Initialize the API client
$api = new CircularProtocolAPI(
    'https://nag.circularlabs.io/NAG.php?cep=',  // NAG URL
    null  // Optional API key
);

// Check if a wallet exists
try {
    $result = $api->%{to_php_method wallet.checkWallet.path}([
        'Address' => '0x1234567890abcdef...',
        'Blockchain' => 'MainNet',
        'Version' => '%{config.version}'
    ]);

    echo 'Result: ' . $result['Result'] . PHP_EOL;
    echo 'Response: ' . print_r($result['Response'], true);
} catch (CircularProtocolException $e) {
    echo 'Error: ' . $e->getMessage() . PHP_EOL;
    echo 'Status: ' . $e->getStatusCode() . PHP_EOL;
    echo 'Endpoint: ' . $e->getEndpoint() . PHP_EOL;
}

// Get wallet information
$wallet = $api->%{to_php_method wallet.getWallet.path}([
    'Address' => '0x1234567890abcdef...'
]);

echo 'Balance: ' . $wallet['Response']['Balance'] . PHP_EOL;
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

```php
$result = $api->%{to_php_method wallet.checkWallet.path}([
    'Address' => '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
    'Blockchain' => 'MainNet',
    'Version' => '%{config.version}'
]);

if ($result['Result'] === 200) {
    echo 'Wallet exists on the blockchain' . PHP_EOL;
}
```

### Get Wallet Information

```php
$wallet = $api->%{to_php_method wallet.getWallet.path}([
    'Address' => '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb'
]);

echo 'Balance: ' . $wallet['Response']['Balance'] . PHP_EOL;
echo 'Nonce: ' . $wallet['Response']['Nonce'] . PHP_EOL;
echo 'Public Key: ' . $wallet['Response']['PublicKey'] . PHP_EOL;
```

### Send Transaction

```php
$transaction = [
    'From' => '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
    'To' => '0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199',
    'Amount' => '1000000',
    'Nonce' => 1,
    'Timestamp' => '2024:11:07-15:30:00',
    'Signature' => '0x...'
];

$result = $api->%{to_php_method transaction.sendTransaction.path}([
    'Transaction' => $transaction
]);

echo 'Transaction ID: ' . $result['Response']['TransactionID'] . PHP_EOL;
```

### Get Transaction by ID

```php
$tx = $api->%{to_php_method transaction.getTransactionbyID.path}([
    'ID' => '0x1234567890abcdef...'
]);

print_r($tx['Response']);
```

### Get Asset Information

```php
$asset = $api->%{to_php_method asset.getAsset.path}([
    'AssetName' => 'MyToken'
]);

echo 'Total Supply: ' . $asset['Response']['TotalSupply'] . PHP_EOL;
echo 'Decimals: ' . $asset['Response']['Decimals'] . PHP_EOL;
```

## Configuration

### Custom NAG URL

```php
$api = new CircularProtocolAPI(
    'https://custom-nag-url.com/NAG.php?cep=',
    null
);
```

### With API Key

```php
$api = new CircularProtocolAPI(
    'https://nag.circularlabs.io/NAG.php?cep=',
    'your-api-key-here'
);
```

### Update Configuration at Runtime

```php
$api->setNagUrl('https://new-url.com/NAG.php?cep=');
$api->setNagKey('new-api-key');
```

### Get Current Configuration

```php
$currentUrl = $api->getNagUrl();
$currentKey = $api->getNagKey();
```

## Error Handling

The SDK throws `CircularProtocolException` for API errors:

```php
use Circular\Protocol\CircularProtocolException;

try {
    $result = $api->%{to_php_method wallet.checkWallet.path}($params);
    // Handle successful response
} catch (CircularProtocolException $e) {
    // API-level error
    echo 'API Error: ' . $e->getMessage() . PHP_EOL;
    echo 'Status Code: ' . $e->getStatusCode() . PHP_EOL;
    echo 'Endpoint: ' . $e->getEndpoint() . PHP_EOL;
} catch (\Exception $e) {
    // Other errors (network, JSON parsing, etc.)
    echo 'Error: ' . $e->getMessage() . PHP_EOL;
}
```

### Common Error Codes

- `200`: Success
- `400`: Bad Request - Invalid parameters
- `401`: Unauthorized - Invalid API key
- `404`: Not Found - Resource doesn't exist
- `500`: Internal Server Error

## Type Safety

All methods are fully type-hinted for PHP 8.0+:

```php
/**
 * Check if wallet exists
 *
 * @param array $request Request parameters
 * @return array Response with Result and Response fields
 * @throws CircularProtocolException
 */
public function %{to_php_method wallet.checkWallet.path}(array $request): array
{
    return $this->makeRequest('%{wallet.checkWallet.path}', $request);
}
```

## PSR-4 Autoloading

The SDK follows PSR-4 autoloading standards:

```json
{
    "autoload": {
        "psr-4": {
            "Circular\\Protocol\\": "src/"
        }
    }
}
```

## Development

### Running Tests

```bash
# Install dependencies
composer install

# Run PHPUnit tests
composer test

# Run tests with coverage
composer test:coverage

# Run PHPStan static analysis
composer phpstan

# Run code style checks
composer cs:check

# Fix code style issues
composer cs:fix
```

### Building from Source

```bash
# Clone the repository
git clone https://github.com/circular-protocol/circular-canonical.git
cd circular-canonical

# Generate PHP SDK
just generate-php-package

# Install dependencies
cd dist/php
composer install

# Run tests
composer test
```

## Code Quality

The SDK includes several quality assurance tools:

- **PHPUnit**: Unit testing framework
- **PHPStan**: Static analysis tool (Level 9)
- **PHP_CodeSniffer**: Code style checker (PSR-12)

## Contributing

Contributions are welcome! This SDK is auto-generated from Nickel specifications in the [circular-canonical](https://github.com/circular-protocol/circular-canonical) repository.

1. Fork the canonical repository
2. Make changes to Nickel specifications
3. Regenerate SDKs with `just generate-php-package`
4. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

- **Documentation**: [https://docs.circular.org](https://docs.circular.org)
- **Issues**: [https://github.com/circular-protocol/circular-canonical/issues](https://github.com/circular-protocol/circular-canonical/issues)
- **Discord**: [https://discord.gg/circular](https://discord.gg/circular)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## Packaging

To create a distributable package:

```bash
# Validate the package
composer validate

# Create ZIP archive
zip -r circular-protocol-api.zip src/ composer.json README.md LICENSE

# Or use Composer archive
composer archive --format=zip
```

## Publishing to Packagist

1. Tag a release: `git tag v%{config.version}`
2. Push the tag: `git push origin v%{config.version}`
3. Packagist will automatically detect and publish the new version

---

**Generated from**: Nickel canonical specification v%{config.version}
**Last updated**: 2024-11-09
"%
