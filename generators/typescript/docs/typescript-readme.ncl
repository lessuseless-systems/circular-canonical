# TypeScript Package README Generator
# Generates comprehensive README.md for npm package

let config = import "../../../src/config.ncl" in
let wallet = import "../../../src/api/wallet.ncl" in
let transaction = import "../../../src/api/transaction.ncl" in
let block = import "../../../src/api/block.ncl" in
let asset = import "../../../src/api/asset.ncl" in
let contract = import "../../../src/api/contract.ncl" in
let domain = import "../../../src/api/domain.ncl" in
let network = import "../../../src/api/network.ncl" in

# Helper: Generate API method documentation row
let generate_api_row = fun name endpoint =>
  "| `%{name}` | %{endpoint.summary} | %{endpoint.method} |"
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
# Circular Protocol API - TypeScript/JavaScript SDK

[![npm version](https://img.shields.io/npm/v/circular-protocol-api.svg)](https://www.npmjs.com/package/circular-protocol-api)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.4+-blue.svg)](https://www.typescriptlang.org/)
[![Node.js](https://img.shields.io/badge/Node.js-16+-green.svg)](https://nodejs.org/)

> %{config.description}

Official TypeScript/JavaScript SDK for interacting with Circular Protocol blockchain networks. Provides a type-safe, promise-based API for wallet operations, transactions, smart contracts, assets, and more.

**Version:** %{config.version}

## Features

- 🔒 **Fully Type-Safe** - Zero `any` types, complete TypeScript definitions
- 📦 **Dual Module Support** - Both CommonJS and ES Modules
- 🚀 **Promise-Based** - Modern async/await API
- 🎯 **24 API Methods** - Complete coverage of Circular Protocol operations
- ✅ **Runtime Validation** - Request/response validation
- 📝 **Auto-Generated** - Generated from canonical Nickel specifications
- 🧪 **Fully Tested** - Comprehensive unit and integration tests

## Installation

```bash
# npm
npm install circular-protocol-api

# yarn
yarn add circular-protocol-api

# pnpm
pnpm add circular-protocol-api
```

## Quick Start

```typescript
import { CircularProtocolAPI } from 'circular-protocol-api';

// Initialize the API client
const api = new CircularProtocolAPI({
  nodeUrl: 'https://your-node-url.com',
  blockchain: 'your-blockchain-id',
});

// Check if a wallet exists
const walletExists = await api.checkWallet({
  Address: '0x1234567890abcdef...',
});

console.log('Wallet exists:', walletExists.Result);

// Get wallet information
const wallet = await api.getWallet({
  Address: '0x1234567890abcdef...',
});

console.log('Wallet balance:', wallet.Response.Balance);
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

```typescript
const result = await api.checkWallet({
  Address: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
});

if (result.Result === 'true') {
  console.log('Wallet exists on the blockchain');
}
```

### Get Wallet Information

```typescript
const wallet = await api.getWallet({
  Address: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
});

console.log('Balance:', wallet.Response.Balance);
console.log('Nonce:', wallet.Response.Nonce);
console.log('Public Key:', wallet.Response.PublicKey);
```

### Send Transaction

```typescript
const txResult = await api.sendTransaction({
  Transaction: {
    From: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
    To: '0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199',
    Amount: '1000000',
    Nonce: 1,
    Timestamp: '2024:11:07-15:30:00',
    Signature: '0x...',
  },
});

console.log('Transaction ID:', txResult.Response.TransactionID);
```

### Get Transaction by ID

```typescript
const tx = await api.getTransactionbyID({
  ID: '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
});

console.log('Transaction:', tx.Response);
```

### Get Asset Information

```typescript
const asset = await api.getAsset({
  AssetName: 'MyToken',
});

console.log('Asset supply:', asset.Response.TotalSupply);
console.log('Asset decimals:', asset.Response.Decimals);
```

## Configuration Options

```typescript
interface CircularProtocolConfig {
  nodeUrl: string;           // Your Circular Protocol node URL
  blockchain: string;        // Blockchain identifier
  timeout?: number;          // Request timeout in ms (default: 30000)
  retries?: number;          // Retry attempts (default: 3)
  version?: string;          // API version (default: "%{config.version}")
}
```

## Error Handling

All API methods throw typed errors for better error handling:

```typescript
try {
  const wallet = await api.getWallet({ Address: 'invalid-address' });
} catch (error) {
  if (error instanceof ValidationError) {
    console.error('Invalid address format:', error.message);
  } else if (error instanceof NetworkError) {
    console.error('Network error:', error.message);
  } else {
    console.error('Unknown error:', error);
  }
}
```

## TypeScript Support

This package is written in TypeScript and includes complete type definitions:

```typescript
import type {
  WalletInfo,
  Transaction,
  BlockInfo,
  AssetInfo,
} from 'circular-protocol-api';

// All types are fully documented and type-safe
const wallet: WalletInfo = await api.getWallet({ Address: '0x...' });
```

## Requirements

- Node.js >= 16.0.0
- TypeScript >= 5.0 (if using TypeScript)

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.

## License

MIT © Danny De Novi

## Support

- 📧 Email: support@circular.com
- 🐛 Issues: [GitHub Issues](https://github.com/circular-protocol/circular-protocol-ts/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/circular-protocol/circular-protocol-ts/discussions)

## Related Projects

- [circular-protocol-py](https://github.com/circular-protocol/circular-protocol-py) - Python SDK
- [circular-canonical](https://github.com/circular-protocol/circular-canonical) - Canonical API specifications

---

**Generated from canonical Nickel specifications** | [View Source](https://github.com/circular-protocol/circular-canonical)
"%
