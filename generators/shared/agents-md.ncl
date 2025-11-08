# AGENTS.md Generator for AI Agents
# Generates comprehensive API documentation optimized for AI agent consumption

let config = import "../../src/config.ncl" in
let all_apis = import "../../src/api/all.ncl" in

# Helper to format parameters for AI agents
let format_parameters = fun params =>
  let param_list = std.record.to_array (fun name info =>
    let required_marker = if info.required then "**required**" else "*optional*" in
    let type_info = if std.record.has_field "contract" info then
      " (type: %{info.type})"
    else
      " (type: %{info.type})"
    in
    "  - `%{name}`: %{info.description} - %{required_marker}%{type_info}"
  ) params in
  std.string.join "\n" param_list
in

# Helper to generate example usage for an endpoint
let generate_example = fun endpoint_name endpoint =>
  let params_example = std.record.to_array (fun name info =>
    if info.required then
      let example_value = if info.type == "string" then
        if std.string.is_match "address" (std.string.lowercase name) then
          "\"0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb\""
        else
          "\"example_value\""
      else if info.type == "number" then
        "123"
      else if info.type == "boolean" then
        "true"
      else
        "\"value\""
      in
      "  \"%{name}\": %{example_value}"
    else
      ""
  ) endpoint.parameters in
  let non_empty_params = std.array.filter (fun x => x != "") params_example in
  if std.array.length non_empty_params > 0 then
    m%"
```json
{
  "method": "%{endpoint.method}",
  "endpoint": "%{endpoint.path}",
  "params": {
%{std.string.join ",\n" non_empty_params}
  }
}
```
"%
  else
    m%"
```json
{
  "method": "%{endpoint.method}",
  "endpoint": "%{endpoint.path}"
}
```
"%
in

# Generate simplified API section (simplified approach)
let generate_api_section = fun domain_name =>
  m%"
## %{std.string.uppercase (std.string.substring 0 1 domain_name)}%{std.string.substring 1 (std.string.length domain_name) domain_name} Operations

See the TypeScript/Python SDK documentation for detailed endpoint information.
All %{domain_name} operations are available through the SDK with full type safety and validation.

Example usage:
\`\`\`javascript
// %{domain_name} operations available
const api = new CircularProtocolAPI();
// Use api.%{domain_name}Method() methods
\`\`\`

---
"%
in

# Main AGENTS.md content
let agents_content = m%"# Circular Protocol API - AI Agent Guide

> **Version**: %{config.version}
> **Generated**: Automatically from Nickel definitions
> **Purpose**: Comprehensive API reference optimized for AI agent consumption

## Overview

The Circular Protocol API provides blockchain operations for wallets, transactions, assets, blocks, smart contracts, and domain resolution. This guide is specifically formatted for AI agents and automated systems.

## Base Configuration

- **Base URL**: `%{config.api.base_url}`
- **Protocol**: REST API
- **Format**: JSON
- **Authentication**: API key (optional, configured in SDK)

## Quick Start for AI Agents

```javascript
// Initialize SDK
const api = new CircularProtocolAPI({
  baseURL: '%{config.api.base_url}',
  apiKey: 'your-api-key' // optional
});

// Example: Check if wallet exists
const result = await api.checkWallet('0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb');
```

```python
# Initialize SDK
from circular_protocol_api import CircularProtocolAPI

api = CircularProtocolAPI(
    base_url='%{config.api.base_url}',
    api_key='your-api-key'  # optional
)

# Example: Check if wallet exists
result = api.check_wallet('0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb')
```

---

%{generate_api_section "wallet"}

%{generate_api_section "transaction"}

%{generate_api_section "asset"}

%{generate_api_section "block"}

%{generate_api_section "contract"}

%{generate_api_section "domain"}

%{generate_api_section "network"}

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
"% in

{
  agents_md = agents_content,
}
