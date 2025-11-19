# Circular Protocol API - AI Agent Guide

> **Version**: 1.0.8
> **Generated**: Automatically from Nickel definitions
> **Purpose**: Comprehensive API reference optimized for AI agent consumption

## Overview

The Circular Protocol API provides blockchain operations for wallets, transactions, assets, blocks, smart contracts, and domain resolution. This guide is specifically formatted for AI agents and automated systems.

## Base Configuration

- **Base URL**: `https://api.circular.example`
- **Protocol**: REST API
- **Format**: JSON
- **Authentication**: API key (optional, configured in SDK)

## Quick Start for AI Agents

```javascript
// Initialize SDK
const api = new CircularProtocolAPI({
  baseURL: 'https://api.circular.example',
  apiKey: 'your-api-key' // optional
});

// Example: Check if wallet exists
const result = await api.checkWallet('0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb');
```

```python
# Initialize SDK
from circular_protocol_api import CircularProtocolAPI

api = CircularProtocolAPI(
    base_url='https://api.circular.example',
    api_key='your-api-key'  # optional
)

# Example: Check if wallet exists
result = api.check_wallet('0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb')
```

---

## Wallet Operations

See the TypeScript/Python SDK documentation for detailed endpoint information.
All wallet operations are available through the SDK with full type safety and validation.

Example usage:
\`\`\`javascript
// wallet operations available
const api = new CircularProtocolAPI();
// Use api.walletMethod() methods
\`\`\`

---

## Transaction Operations

See the TypeScript/Python SDK documentation for detailed endpoint information.
All transaction operations are available through the SDK with full type safety and validation.

Example usage:
\`\`\`javascript
// transaction operations available
const api = new CircularProtocolAPI();
// Use api.transactionMethod() methods
\`\`\`

---

## Asset Operations

See the TypeScript/Python SDK documentation for detailed endpoint information.
All asset operations are available through the SDK with full type safety and validation.

Example usage:
\`\`\`javascript
// asset operations available
const api = new CircularProtocolAPI();
// Use api.assetMethod() methods
\`\`\`

---

## Block Operations

See the TypeScript/Python SDK documentation for detailed endpoint information.
All block operations are available through the SDK with full type safety and validation.

Example usage:
\`\`\`javascript
// block operations available
const api = new CircularProtocolAPI();
// Use api.blockMethod() methods
\`\`\`

---

## Contract Operations

See the TypeScript/Python SDK documentation for detailed endpoint information.
All contract operations are available through the SDK with full type safety and validation.

Example usage:
\`\`\`javascript
// contract operations available
const api = new CircularProtocolAPI();
// Use api.contractMethod() methods
\`\`\`

---

## Domain Operations

See the TypeScript/Python SDK documentation for detailed endpoint information.
All domain operations are available through the SDK with full type safety and validation.

Example usage:
\`\`\`javascript
// domain operations available
const api = new CircularProtocolAPI();
// Use api.domainMethod() methods
\`\`\`

---

## Network Operations

See the TypeScript/Python SDK documentation for detailed endpoint information.
All network operations are available through the SDK with full type safety and validation.

Example usage:
\`\`\`javascript
// network operations available
const api = new CircularProtocolAPI();
// Use api.networkMethod() methods
\`\`\`

---

## Common Patterns for AI Agents

### Pattern 1: Wallet Status Check

```javascript
async function checkWalletStatus(address) {
  const exists = await api.checkWallet(address);
  if (exists.result) {
    const wallet = await api.getWallet(address);
    const balance = await api.getWalletBalance(address);
    return { wallet, balance };
  }
  return null;
}
```

### Pattern 2: Transaction History

```javascript
async function getTransactionHistory(address, limit = 10) {
  const transactions = await api.getLatestTransactions(address, limit);
  return transactions.map(tx => ({
    id: tx.id,
    amount: tx.amount,
    timestamp: tx.timestamp,
    status: tx.status
  }));
}
```

### Pattern 3: Block Analytics

```javascript
async function getBlockchainMetrics() {
  const height = await api.getBlockHeight();
  const analytics = await api.getAnalytics();
  const blockchains = await api.getBlockchains();
  return { height, analytics, blockchains };
}
```

## Error Handling for AI Agents

All endpoints may return errors. Always handle:

1. **Network errors**: Connection failures, timeouts
2. **HTTP errors**: 400 (Bad Request), 404 (Not Found), 500 (Server Error)
3. **Validation errors**: Invalid parameters, malformed data

```javascript
try {
  const result = await api.checkWallet(address);
  // Process result
} catch (error) {
  if (error.statusCode === 404) {
    // Wallet not found
  } else if (error.statusCode === 400) {
    // Invalid address format
  } else {
    // Other error
  }
}
```

## Rate Limiting

- Default: No explicit rate limits
- Recommended: Max 100 requests/second
- For bulk operations: Use batch endpoints when available

## Data Types Reference

### Address
- **Format**: Hexadecimal string, 64 or 66 characters
- **Example**: `0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb` or `742d35Cc6634C0532925a3b844Bc9e7595f0bEb`
- **Validation**: Must match regex `^(0x)?[0-9a-fA-F]+$`

### Amount
- **Format**: String representation of integer
- **Example**: `"1000000000000000000"` (1 token with 18 decimals)
- **Validation**: Must contain only digits

### Blockchain
- **Format**: String enum
- **Values**: `ethereum`, `polygon`, `bsc`, `avalanche`

### Timestamp
- **Format**: ISO 8601 string or Unix timestamp
- **Example**: `"2024-01-15T10:30:00Z"` or `1705315800`

## AI Agent Tool Definitions

For AI frameworks that support tool definitions (Anthropic, OpenAI), use these schemas:

### Example: checkWallet Tool

```json
{
  "name": "checkWallet",
  "description": "Check if a wallet address exists on the Circular Protocol blockchain",
  "parameters": {
    "type": "object",
    "properties": {
      "address": {
        "type": "string",
        "description": "Wallet address (64 or 66 hex characters)",
        "pattern": "^(0x)?[0-9a-fA-F]{64,66}$"
      }
    },
    "required": ["address"]
  }
}
```

## MCP (Model Context Protocol) Integration

This API is compatible with MCP servers. See the MCP schema generator for tool definitions compatible with Claude Desktop and other MCP clients.

## Support

- **Documentation**: https://docs.circular.org
- **API Reference**: https://api-docs.circular.org
- **GitHub**: https://github.com/circular-protocol/circular-canonical
- **Issues**: https://github.com/circular-protocol/circular-canonical/issues

## License

MIT License - See LICENSE file for details

---

*This document is automatically generated from the Circular Protocol canonical API definitions. Do not edit manually.*
*Generated with: [Circular Canonical](https://github.com/circular-protocol/circular-canonical)*