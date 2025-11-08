# Nickel Patterns and Best Practices

Comprehensive guide to Nickel syntax, patterns, and idioms for the Circular Protocol Canonical project.

## Table of Contents

1. [Basic Syntax](#basic-syntax)
2. [Contracts and Validation](#contracts-and-validation)
3. [Generator Patterns](#generator-patterns)
4. [Code Organization](#code-organization)
5. [Common Pitfalls](#common-pitfalls)
6. [Pattern Library](#pattern-library)

---

## Basic Syntax

### Records

Records are Nickel's fundamental data structure - similar to objects in JSON or dictionaries in Python.

```nickel
# Simple record
let person = {
  name = "Alice",
  age = 30,
  active = true,
}
```

### Fields with Documentation

Use the pipe operator `|` to add metadata to fields:

```nickel
let wallet = {
  address
    | doc "Wallet address (64 or 66 characters)"
    = "0x1234...",

  balance
    | doc "Current balance in smallest unit"
    = 1000,
}
```

### Contracts (Type Annotations)

Contracts enforce validation at export/runtime:

```nickel
let wallet = {
  # Contract before equals: field must satisfy contract
  address | std.string.NonEmpty = "0x1234...",
  balance | std.number.PosNat = 1000,
}
```

### Optional Fields

Use the `optional` contract modifier:

```nickel
let config = {
  required | std.string.NonEmpty = "value",
  optional_field | optional = null,
  optional_with_default | default = "default_value",
}
```

### Merging

Nickel's killer feature - compose records without duplication:

```nickel
let base_api = {
  version = "1.0.0",
  protocol = "https",
}

let wallet_api = base_api & {
  endpoint = "/wallet",
  methods = ["GET", "POST"],
}

# wallet_api now contains: version, protocol, endpoint, methods
```

### Functions

Functions are first-class values:

```nickel
# Simple function
let add = fun x y => x + y

# Function with type annotations
let greet
  | std.string.NonEmpty -> std.string.NonEmpty
  = fun name => "Hello, %{name}!"

# Multi-line function
let create_endpoint = fun method path => {
  http_method = method,
  path = path,
  full_url = "https://api.example.com%{path}",
}
```

### String Interpolation

Use `%{...}` for variable interpolation:

```nickel
let version = "1.0.0"
let message = "Current version: %{version}"

# Multi-line strings
let template = m%"
  Name: %{name}
  Age: %{std.string.from_number age}
  Active: %{std.string.from_bool active}
"%
```

---

## Contracts and Validation

### Built-in Contracts

Nickel provides many built-in contracts in the `std` library:

```nickel
{
  # String contracts
  name | std.string.NonEmpty = "Alice",

  # Number contracts
  positive | std.number.Positive = 42,
  natural | std.number.Nat = 10,

  # Boolean
  flag | std.bool.Bool = true,

  # Array contracts
  items | std.array.Array = [1, 2, 3],

  # Enum (one of specific values)
  status | [| 'Active, 'Inactive, 'Pending |] = 'Active,
}
```

### Custom Contracts

Create reusable validation contracts:

```nickel
# Contract for wallet addresses (64 hex chars or 66 with 0x)
let Address = std.contract.from_predicate (fun value =>
  let len = std.string.length value in
  let is_hex = std.string.is_match "^(0x)?[0-9a-fA-F]+$" value in
  (len == 64 || len == 66) && is_hex
)

# Contract for semantic version
let SemVer = std.contract.from_predicate (fun value =>
  std.string.is_match "^[0-9]+\\.[0-9]+\\.[0-9]+$" value
)

# Contract for positive amounts
let Amount = std.contract.from_predicate (fun value =>
  std.is_number value && value > 0
)

# Usage
let wallet = {
  address | Address = "0x1234567890abcdef...",
  version | SemVer = "1.0.8",
  balance | Amount = 1000,
}
```

### Contract Composition

Combine multiple contracts:

```nickel
# String that is non-empty AND matches pattern
let Email = std.string.NonEmpty & std.contract.from_predicate (fun value =>
  std.string.is_match "^[^@]+@[^@]+\\.[^@]+$" value
)

# Number that is positive AND less than max
let Percentage = std.contract.from_predicate (fun value =>
  std.is_number value && value >= 0 && value <= 100
)
```

### Contracts with Error Messages

Provide helpful error messages:

```nickel
let Address = std.contract.from_predicate (fun value =>
  let len = std.string.length value in
  if len != 64 && len != 66 then
    std.contract.blame_with_message "Address must be 64 or 66 characters" value
  else if not (std.string.is_match "^(0x)?[0-9a-fA-F]+$" value) then
    std.contract.blame_with_message "Address must be hexadecimal" value
  else
    true
)
```

### Record Contracts

Enforce structure of entire records:

```nickel
let WalletResponse = {
  address | Address,
  balance | std.number.Nat,
  nonce | std.number.Nat,
  transactions | optional | std.array.Array = [],
}

# Now use as a contract
let my_wallet | WalletResponse = {
  address = "0x123...",
  balance = 1000,
  nonce = 5,
}
```

---

## Generator Patterns

### Basic JSON Export

Simple structure to JSON:

```nickel
# generators/json-export.ncl
let types = import "../src/schemas/types.ncl" in
let api = import "../src/api/wallet.ncl" in

{
  version = types.Version,
  endpoints = api.endpoints,
}

# Export: nickel export generators/json-export.ncl --format json
```

### OpenAPI Generation

Generate OpenAPI 3.0 specification:

```nickel
# generators/openapi.ncl
let types = import "../src/schemas/types.ncl" in
let wallet_api = import "../src/api/wallet.ncl" in

let openapi_version = "3.0.0"

let create_parameter = fun name type required =>
{
  name = name,
  "in" = "query",
  required = required,
  schema = { type = type },
}

let create_response = fun description schema =>
{
  description = description,
  content = {
    "application/json" = {
      schema = schema,
    },
  },
}

{
  openapi = openapi_version,
  info = {
    title = "Circular Protocol API",
    version = types.Version,
    description = "Standard API endpoints for Circular Protocol blockchain",
  },

  paths = {
    "/checkWallet" = {
      get = {
        summary = wallet_api.checkWallet.summary,
        description = wallet_api.checkWallet.description,

        parameters = [
          create_parameter "address" "string" true,
          create_parameter "blockchain" "string" false,
        ],

        responses = {
          "200" = create_response
            "Wallet exists check result"
            {
              type = "object",
              properties = {
                exists = { type = "boolean" },
                address = { type = "string" },
              },
            },
        },
      },
    },
  },
}
```

### String Template Generation

Generate code from templates:

```nickel
# generators/typescript-types.ncl
let types = import "../src/schemas/types.ncl" in

let generate_interface = fun name fields =>
  m%"
export interface %{name} {
%{std.string.join "\n" (std.array.map (fun field => "  %{field.name}: %{field.type};") fields)}
}
  "%

let typescript_type = fun nickel_type =>
  if nickel_type == "string" then "string"
  else if nickel_type == "number" then "number"
  else if nickel_type == "boolean" then "boolean"
  else if nickel_type == "array" then "any[]"
  else "unknown"

{
  content = generate_interface "WalletInfo" [
    { name = "address", type = "string" },
    { name = "balance", type = "number" },
    { name = "nonce", type = "number" },
  ],
}
```

### Multi-File Generation

Generate multiple files from single source:

```nickel
# generators/multi-output.ncl
let types = import "../src/schemas/types.ncl" in
let apis = import "../src/api/all.ncl" in

{
  # File 1: Types
  "output/types.ts" = {
    content = generate_typescript_types types,
  },

  # File 2: API client
  "output/client.ts" = {
    content = generate_typescript_client apis,
  },

  # File 3: Documentation
  "output/README.md" = {
    content = generate_markdown_docs apis,
  },
}

# Then process with a script:
# nickel export generators/multi-output.ncl --format json | jq -r 'to_entries[] | "\(.value.content)" > "\(.key)"'
```

### Transformation Functions

Convert between formats:

```nickel
# Convert camelCase to snake_case for Python
let to_snake_case = fun str =>
  # Simple implementation - replace uppercase with underscore + lowercase
  std.string.replace_regex "([A-Z])" "_$1" str
  |> std.string.lowercase
  |> std.string.replace_regex "^_" ""

# Convert type definitions between languages
let to_python_type = fun nickel_type =>
  if nickel_type == "string" then "str"
  else if nickel_type == "number" then "int | float"
  else if nickel_type == "boolean" then "bool"
  else if nickel_type == "array" then "List[Any]"
  else "Any"

# Apply transformations to entire API
let pythonify_api = fun api => api & {
  methods = std.array.map (fun method => method & {
    name = to_snake_case method.name,
    parameters = std.array.map (fun param => param & {
      name = to_snake_case param.name,
      type = to_python_type param.type,
    }) method.parameters,
  }) api.methods,
}
```

---

## Code Organization

### Module Structure

Organize code into logical modules:

```
src/
├── schemas/
│   ├── types.ncl          # Basic types (Address, Amount, etc.)
│   ├── requests.ncl       # Request body schemas
│   └── responses.ncl      # Response schemas
├── api/
│   ├── wallet.ncl         # Wallet endpoints
│   ├── transaction.ncl    # Transaction endpoints
│   ├── asset.ncl          # Asset endpoints
│   └── all.ncl            # Combine all APIs
└── config.ncl             # Base configuration
```

### Import Patterns

```nickel
# Absolute import from project root
let types = import "src/schemas/types.ncl" in

# Relative import
let types = import "../schemas/types.ncl" in

# Import and use immediately
(import "../config.ncl").version

# Import and merge
let base = import "./base.ncl" in
base & {
  additional_field = "value",
}
```

### Creating Reusable Libraries

```nickel
# lib/validators.ncl
{
  # Export reusable contracts
  Address = std.contract.from_predicate (fun value =>
    let len = std.string.length value in
    (len == 64 || len == 66)
  ),

  Amount = std.contract.from_predicate (fun value =>
    std.is_number value && value > 0
  ),

  # Export helper functions
  is_valid_address = fun addr =>
    let len = std.string.length addr in
    len == 64 || len == 66,

  format_amount = fun amount decimals =>
    amount / (std.number.pow 10 decimals),
}

# Usage in other files
let lib = import "../lib/validators.ncl" in

{
  address | lib.Address = "0x123...",
  formatted_balance = lib.format_amount 1000000 6,
}
```

### Configuration Layers

Use merging for environment-specific configs:

```nickel
# config/base.ncl
{
  version = "1.0.8",
  timeout = 30000,
  retry_attempts = 3,
}

# config/development.ncl
let base = import "./base.ncl" in
base & {
  api_url = "http://localhost:3000",
  debug = true,
}

# config/production.ncl
let base = import "./base.ncl" in
base & {
  api_url = "https://api.circular.money",
  debug = false,
  timeout = 60000,
}
```

---

## Common Pitfalls

### 1. Contract vs Value Order

```nickel
# ❌ WRONG - Contract after value
let x = "value" | std.string.NonEmpty

# ✅ CORRECT - Contract before equals
let x | std.string.NonEmpty = "value"
```

### 2. String Interpolation Type Errors

```nickel
# ❌ WRONG - Can't interpolate numbers directly
let msg = "Count: %{42}"

# ✅ CORRECT - Convert to string first
let msg = "Count: %{std.string.from_number 42}"
```

### 3. Optional Field Access

```nickel
# ❌ WRONG - May fail if field doesn't exist
let name = record.optional_field

# ✅ CORRECT - Provide default
let name = record.optional_field or "default"

# ✅ CORRECT - Check existence first
let name = if std.record.has_field "optional_field" record then
  record.optional_field
else
  "default"
```

### 4. Array vs Record Iteration

```nickel
# For arrays, use std.array functions
let numbers = [1, 2, 3]
let doubled = std.array.map (fun x => x * 2) numbers

# For record fields, use std.record functions
let rec = { a = 1, b = 2 }
let fields = std.record.fields rec  # ["a", "b"]
let values = std.record.values rec  # [1, 2]
```

### 5. Import Path Resolution

```nickel
# ❌ WRONG - Imports are relative to current file
let types = import "schemas/types.ncl"  # Only works if schemas/ is in same dir

# ✅ CORRECT - Use relative path
let types = import "../schemas/types.ncl"

# ✅ CORRECT - Use project root (if configured)
let types = import "src/schemas/types.ncl"
```

### 6. Merging Precedence

```nickel
# Right side wins in merge conflicts
let base = { x = 1, y = 2 }
let override = { x = 10 }
let result = base & override
# result = { x = 10, y = 2 }

# Use merge priorities for complex scenarios
let result = base & { x | force = 10 }
```

### 7. Contract Failure Messages

```nickel
# ❌ WRONG - Unclear error on failure
let Age = std.contract.from_predicate (fun x => x >= 0 && x <= 120)

# ✅ CORRECT - Helpful error message
let Age = std.contract.from_predicate (fun x =>
  if not (std.is_number x) then
    std.contract.blame_with_message "Age must be a number" x
  else if x < 0 then
    std.contract.blame_with_message "Age must be non-negative" x
  else if x > 120 then
    std.contract.blame_with_message "Age must be 120 or less" x
  else
    true
)
```

---

## Pattern Library

### Pattern 1: Simple Type Definition

```nickel
# src/schemas/types.ncl
{
  Version = "1.0.8",

  Address = std.string.NonEmpty
    | doc "Wallet address (64 or 66 hex characters)",

  Amount = std.number.PosNat
    | doc "Amount in smallest unit (wei equivalent)",

  Blockchain = [| 'MainNet, 'TestNet, 'DevNet |]
    | doc "Available blockchain networks",
}
```

### Pattern 2: Request/Response Schemas

```nickel
# src/schemas/requests.ncl
let types = import "./types.ncl" in

{
  CheckWalletRequest = {
    address | types.Address,
    blockchain | optional | types.Blockchain = 'MainNet,
  },

  SendTransactionRequest = {
    from | types.Address,
    to | types.Address,
    amount | types.Amount,
    memo | optional | std.string.String = "",
  },
}

# src/schemas/responses.ncl
let types = import "./types.ncl" in

{
  CheckWalletResponse = {
    exists | std.bool.Bool,
    address | types.Address,
    blockchain | types.Blockchain,
  },

  ErrorResponse = {
    error | std.string.NonEmpty,
    code | std.number.Nat,
    details | optional | std.string.String = "",
  },
}
```

### Pattern 3: Complete API Endpoint

```nickel
# src/api/wallet.ncl
let types = import "../schemas/types.ncl" in
let requests = import "../schemas/requests.ncl" in
let responses = import "../schemas/responses.ncl" in

{
  checkWallet = {
    method = "GET",
    path = "/checkWallet",
    summary = "Check if wallet exists",
    description = m%"
      Checks whether a wallet address exists on the specified blockchain.
      Returns existence status and confirms the address format.
    "%,

    parameters = {
      address = {
        type = "string",
        contract = types.Address,
        required = true,
        description = "Wallet address to check",
      },
      blockchain = {
        type = "string",
        contract = types.Blockchain,
        required = false,
        default = "MainNet",
        description = "Blockchain network to query",
      },
    },

    request_schema = requests.CheckWalletRequest,
    response_schema = responses.CheckWalletResponse,

    example_request = {
      address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      blockchain = "MainNet",
    },

    example_response = {
      exists = true,
      address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      blockchain = "MainNet",
    },
  },

  getWallet = {
    method = "GET",
    path = "/getWallet",
    summary = "Get wallet information",
    description = "Retrieves complete wallet information including balance and nonce",

    parameters = {
      address = {
        type = "string",
        contract = types.Address,
        required = true,
        description = "Wallet address",
      },
    },

    response_schema = {
      address | types.Address,
      balance | types.Amount,
      nonce | std.number.Nat,
    },
  },
}
```

### Pattern 4: OpenAPI Generator

```nickel
# generators/openapi.ncl
let types = import "../src/schemas/types.ncl" in
let wallet_api = import "../src/api/wallet.ncl" in

let param_to_openapi = fun param => {
  name = param.name,
  "in" = "query",
  required = param.required,
  description = param.description or "",
  schema = {
    type = param.type,
  },
}

let endpoint_to_path = fun endpoint =>
{
  (std.string.lowercase endpoint.method) = {
    summary = endpoint.summary,
    description = endpoint.description,
    parameters = std.array.map param_to_openapi (std.record.values endpoint.parameters),
    responses = {
      "200" = {
        description = "Success",
        content = {
          "application/json" = {
            schema = endpoint.response_schema,
          },
        },
      },
    },
  },
}

{
  openapi = "3.0.0",
  info = {
    title = "Circular Protocol API",
    version = types.Version,
    description = "Blockchain API for Circular Protocol",
  },
  paths = {
    (wallet_api.checkWallet.path) = endpoint_to_path wallet_api.checkWallet,
    (wallet_api.getWallet.path) = endpoint_to_path wallet_api.getWallet,
  },
}
```

### Pattern 5: TypeScript SDK Generator

```nickel
# generators/typescript-sdk.ncl
let types = import "../src/schemas/types.ncl" in
let wallet_api = import "../src/api/wallet.ncl" in

let nickel_to_ts_type = fun nickel_type =>
  if nickel_type == "string" then "string"
  else if nickel_type == "number" then "number"
  else if nickel_type == "boolean" then "boolean"
  else "unknown"

let generate_method = fun endpoint =>
  let params = std.record.to_array endpoint.parameters in
  let param_list = std.string.join ", " (std.array.map (fun p => "%{p.name}: %{nickel_to_ts_type p.type}") params) in
  m%"
  async %{endpoint.name}(%{param_list}): Promise<any> {
    const response = await this.client.get('%{endpoint.path}', {
      params: { %{std.string.join ", " (std.array.map (fun p => p.name) params)} }
    });
    return response.data;
  }
  "%

{
  content = m%"
import axios, { AxiosInstance } from 'axios';

export class CircularClient {
  private client: AxiosInstance;

  constructor(baseURL: string = 'https://api.circular.money') {
    this.client = axios.create({ baseURL });
  }

  %{generate_method wallet_api.checkWallet}

  %{generate_method wallet_api.getWallet}
}
  "%
}
```

### Pattern 6: MCP Server Schema Generator

```nickel
# generators/mcp-server.ncl
let wallet_api = import "../src/api/wallet.ncl" in

let endpoint_to_mcp_tool = fun endpoint => {
  name = std.string.replace "/" "_" endpoint.path,
  description = endpoint.summary,
  inputSchema = {
    type = "object",
    properties = std.record.map (fun _name param => {
      type = param.type,
      description = param.description or "",
    }) endpoint.parameters,
    required = std.array.filter (fun p => p.required) (std.record.fields endpoint.parameters),
  },
}

{
  tools = [
    endpoint_to_mcp_tool wallet_api.checkWallet,
    endpoint_to_mcp_tool wallet_api.getWallet,
  ],
}
```

### Pattern 7: Validation Test Suite

```nickel
# tests/contract-validation.test.ncl
let types = import "../src/schemas/types.ncl" in
let requests = import "../src/schemas/requests.ncl" in

{
  test_address_validation = {
    valid_cases = [
      { input = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb", expected = true },
      { input = "742d35Cc6634C0532925a3b844Bc9e7595f0bEb742d35Cc6634C0532925a3b8", expected = true },
    ],

    invalid_cases = [
      { input = "", reason = "empty string" },
      { input = "not-hex", reason = "non-hexadecimal" },
      { input = "0x123", reason = "too short" },
    ],
  },

  test_request_schema = {
    valid_request = requests.CheckWalletRequest & {
      address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      blockchain = 'MainNet,
    },

    # This should fail contract validation
    # invalid_request = requests.CheckWalletRequest & {
    #   address = "invalid",
    # },
  },
}
```

### Pattern 8: Multi-Language Type Generation

```nickel
# generators/multi-lang-types.ncl
let types = import "../src/schemas/types.ncl" in

let to_typescript = {
  content = m%"
export type Address = string;
export type Amount = number;
export type Blockchain = 'MainNet' | 'TestNet' | 'DevNet';
  "%
}

let to_python = {
  content = m%"
from typing import Literal

Address = str
Amount = int
Blockchain = Literal['MainNet', 'TestNet', 'DevNet']
  "%
}

let to_java = {
  content = m%"
package com.circular.types;

public class Types {
    public static class Address {
        private String value;
        // getters, setters, validation
    }

    public enum Blockchain {
        MAIN_NET, TEST_NET, DEV_NET
    }
}
  "%
}

{
  typescript = to_typescript,
  python = to_python,
  java = to_java,
}
```

### Pattern 9: Configuration with Overrides

```nickel
# config/base.ncl
{
  api = {
    version = "1.0.8",
    timeout_ms = 30000,
    retry_attempts = 3,
    base_path = "/api/v1",
  },

  features = {
    enable_caching = true,
    enable_metrics = true,
    enable_debug_logs = false,
  },
}

# config/production.ncl
let base = import "./base.ncl" in

base & {
  api = base.api & {
    base_url = "https://api.circular.money",
    timeout_ms = 60000,
  },

  features = base.features & {
    enable_debug_logs = false,
  },
}

# config/development.ncl
let base = import "./base.ncl" in

base & {
  api = base.api & {
    base_url = "http://localhost:3000",
    timeout_ms = 10000,
  },

  features = base.features & {
    enable_debug_logs = true,
  },
}
```

### Pattern 10: Documentation Generator

```nickel
# generators/markdown-docs.ncl
let wallet_api = import "../src/api/wallet.ncl" in

let param_to_markdown = fun param =>
  "- `%{param.name}` (%{param.type}%{if param.required then ", required" else ", optional"}): %{param.description or ""}"

let endpoint_to_markdown = fun endpoint =>
  m%"
### %{endpoint.summary}

**Endpoint:** `%{endpoint.method} %{endpoint.path}`

%{endpoint.description}

**Parameters:**

%{std.string.join "\n" (std.array.map param_to_markdown (std.record.values endpoint.parameters))}

**Example Request:**

\```json
%{std.serialize 'Json endpoint.example_request}
\```

**Example Response:**

\```json
%{std.serialize 'Json endpoint.example_response}
\```
  "%

{
  content = m%"
# Circular Protocol API Documentation

## Wallet Operations

%{endpoint_to_markdown wallet_api.checkWallet}

%{endpoint_to_markdown wallet_api.getWallet}
  "%
}
```

---

## Quick Reference Card

### Syntax Cheat Sheet

```nickel
# Records
{ field = value }

# Contracts
field | Contract = value

# Optional
field | optional = null
field | default = "default_value"

# Documentation
field | doc "Description" = value

# Functions
fun arg1 arg2 => body

# String interpolation
"Hello %{name}"

# Merging
record1 & record2

# Imports
import "./path/to/file.ncl"

# Built-in contracts
std.string.NonEmpty
std.number.Positive
std.bool.Bool
std.array.Array

# Enums
[| 'Option1, 'Option2, 'Option3 |]

# Multi-line strings
m%"
  Line 1
  Line 2
"%
```

### Common Functions

```nickel
# String
std.string.length
std.string.join
std.string.split
std.string.is_match
std.string.from_number
std.string.from_bool

# Array
std.array.map
std.array.filter
std.array.fold
std.array.length

# Record
std.record.fields
std.record.values
std.record.has_field
std.record.map

# Number
std.number.pow
std.number.min
std.number.max

# Serialization
std.serialize 'Json
std.serialize 'Yaml
std.serialize 'Toml
```

---

## Next Steps

1. **Read** [WEEK_1_2_GUIDE.md](./WEEK_1_2_GUIDE.md) for day-by-day implementation
2. **Practice** with examples in this document
3. **Reference** [Official Nickel Documentation](https://nickel-lang.org/user-manual/)
4. **Experiment** in the Nickel REPL: `nickel repl`

---

**Pro Tip:** Use `nickel query` to inspect records and contracts interactively without full evaluation.

```bash
nickel query src/api/wallet.ncl
```
