# generators/shared/CLAUDE.md

Guidance for working with shared generator utilities and templates.

> **Parent Context**: See `generators/CLAUDE.md` for generator system overview.

## Directory Structure

```
generators/shared/
├── CLAUDE.md                  # This file
├── openapi.ncl                # OpenAPI 3.0 generator (language-agnostic)
├── helpers.ncl                # Common helper functions (naming, types)
├── helpers-crypto.ncl         # Cryptographic helper generators (ALL languages)
├── helpers-encoding.ncl       # Encoding helper generators (ALL languages)
├── helpers-advanced.ncl       # Advanced utility generators (ALL languages)
├── helpers-config.ncl         # Configuration method generators (ALL languages)
├── test-data.ncl              # Shared test data
└── templates/                 # Shared templates for cross-language consistency
    ├── readme-header.todo.ncl      # Common README header
    └── readme-security.todo.ncl    # Common security section
```

## Purpose of Shared Generators

### When to Use Shared vs Language-Specific

**Use `generators/shared/` for:**

1. **Language-agnostic output**: OpenAPI spec, MCP server schema, documentation
2. **Cross-language utilities**: Helper functions used by multiple language generators
3. **Shared test data**: Common test cases that all language SDKs should handle
4. **Consistency templates**: README sections, security guidelines that should be identical across languages

**Use `generators/<language>/` for:**

1. **Language-specific code**: SDK implementation, language idioms
2. **Build configurations**: package.json, pyproject.toml, pom.xml
3. **Language-specific tests**: Unit tests in target language syntax
4. **Language tooling**: ESLint, Black, Checkstyle configs

## ⚠️ CRITICAL: Helper Generators

**Helper generators produce SDK helper methods for ALL languages - NEVER hand-code helpers!**

The shared helper generators (`helpers-*.ncl`) generate **15 helper/utility methods** included in every SDK:

### helpers-crypto.ncl (5 methods)

Generates cryptographic operations for all languages:

```nickel
{
  typescript = {
    signMessage = m%"
      signMessage(message: string, privateKey: string): string {
        // TypeScript implementation using crypto library
      }
    "%,

    verifySignature = m%"
      verifySignature(message: string, signature: string, publicKey: string): boolean {
        // TypeScript implementation
      }
    "%,

    getPublicKey = m%"/* TypeScript implementation */"%,
    hashString = m%"/* TypeScript implementation */"%,
    getFormattedTimestamp = m%"/* TypeScript implementation */"%,
  },

  python = {
    signMessage = m%"
      def sign_message(self, message: str, private_key: str) -> str:
          # Python implementation using cryptography library
    "%,
    # ... other methods
  },

  # ... go, dart, php, java, rust implementations
}
```

**Generated methods:**
1. `signMessage` / `sign_message` - Sign a message with private key
2. `verifySignature` / `verify_signature` - Verify signature with public key
3. `getPublicKey` / `get_public_key` - Derive public key from private key
4. `hashString` / `hash_string` - Hash a string (SHA-256)
5. `getFormattedTimestamp` / `get_formatted_timestamp` - Get ISO 8601 timestamp

### helpers-encoding.ncl (4 methods)

Generates encoding conversion utilities:

```nickel
{
  typescript = {
    hexFix = m%"
      hexFix(hex: string): string {
        // Ensure hex string has 0x prefix
      }
    "%,

    stringToHex = m%"/* Convert string to hex */"%,
    hexToString = m%"/* Convert hex to string */"%,
    padNumber = m%"/* Pad number to fixed length */"%,
  },

  python = { /* ... */ },
  # ... other languages
}
```

**Generated methods:**
1. `hexFix` / `hex_fix` - Ensure hex string has 0x prefix
2. `stringToHex` / `string_to_hex` - Convert string to hexadecimal
3. `hexToString` / `hex_to_string` - Convert hexadecimal to string
4. `padNumber` / `pad_number` - Pad number to fixed length with zeros

### helpers-advanced.ncl (3 methods)

Generates advanced utility methods:

```nickel
{
  typescript = {
    getTransactionOutcome = m%"
      getTransactionOutcome(tx: Transaction): string {
        // Parse transaction result to determine outcome
      }
    "%,

    GetError = m%"/* Extract error message from API response */"%,
    handleError = m%"/* Handle API errors with logging */"%,
  },

  python = { /* ... */ },
  # ... other languages
}
```

**Generated methods:**
1. `getTransactionOutcome` / `get_transaction_outcome` - Determine transaction success/failure
2. `GetError` / `get_error` - Extract error message from API response
3. `handleError` / `handle_error` - Centralized error handling with logging

### helpers-config.ncl (3 methods)

Generates configuration getter/setter methods:

```nickel
{
  typescript = {
    getNagUrl = m%"
      getNagUrl(): string {
        return this.baseURL;
      }
    "%,

    setNagUrl = m%"
      setNagUrl(url: string): void {
        this.baseURL = url;
      }
    "%,

    getNagKey = m%"/* Get API key */"%,
    setNagKey = m%"/* Set API key */"%,
  },

  python = { /* ... */ },
  # ... other languages
}
```

**Generated methods:**
1. `getNagUrl` / `get_nag_url` - Get current NAG (Node API Gateway) URL
2. `setNagUrl` / `set_nag_url` - Update NAG URL
3. `getNagKey` / `get_nag_key` - Get API key (if configured)

**Note:** Some helper generators may provide 4 methods instead of 3 (e.g., getNagKey + setNagKey).

### How Helper Generators Work

**1. Language-specific SDK generators import helpers:**

```nickel
# generators/typescript/typescript-sdk.ncl
let helpers_crypto = import "../shared/helpers-crypto.ncl" in
let helpers_encoding = import "../shared/helpers-encoding.ncl" in
let helpers_config = import "../shared/helpers-config.ncl" in
let helpers_advanced = import "../shared/helpers-advanced.ncl" in
```

**2. SDK generator includes helper methods in output:**

```nickel
{
  sdk_code = m%"
    export class CircularProtocolAPI {
      // ... API endpoints ...

      // ========== HELPER METHODS ==========
      %{helpers_crypto.typescript.signMessage}
      %{helpers_crypto.typescript.verifySignature}
      %{helpers_crypto.typescript.getPublicKey}
      %{helpers_crypto.typescript.hashString}
      %{helpers_encoding.typescript.hexFix}
      %{helpers_encoding.typescript.stringToHex}
      %{helpers_encoding.typescript.hexToString}
      %{helpers_encoding.typescript.padNumber}
      %{helpers_advanced.typescript.getTransactionOutcome}
      %{helpers_advanced.typescript.GetError}
      %{helpers_advanced.typescript.handleError}
      %{helpers_config.typescript.getNagUrl}
      %{helpers_config.typescript.setNagUrl}
    }
  "%
}
```

**3. Result:** Complete SDK with all 39 methods (24 endpoints + 15 helpers)

### Modifying Helper Methods

**To update a helper method across ALL languages:**

1. Edit the relevant helper generator in `generators/shared/helpers-*.ncl`
2. Run `just generate-packages` to regenerate all SDKs
3. **NEVER** manually edit helper implementations in `dist/circular-*/`

**Example: Adding a new cryptographic helper**

```nickel
# Edit generators/shared/helpers-crypto.ncl
{
  typescript = {
    # ... existing helpers ...

    # New helper
    encryptMessage = m%"
      encryptMessage(message: string, publicKey: string): string {
        // TypeScript encryption implementation
      }
    "%,
  },

  python = {
    # ... existing helpers ...

    encrypt_message = m%"
      def encrypt_message(self, message: str, public_key: str) -> str:
          # Python encryption implementation
    "%,
  },

  # ... add to all other languages
}
```

Then update language-specific SDK generators to include the new helper.

## OpenAPI Generator

### Purpose

The OpenAPI generator (`openapi.ncl`) transforms Nickel API definitions into OpenAPI 3.0 specification. This spec is:

- Language-agnostic (describes HTTP API, not any specific SDK)
- Machine-readable (can be consumed by code generators)
- Human-readable (can be viewed in Swagger UI)
- Version-controlled (single source of truth for API contract)

### Structure

```nickel
let config = import "../../src/config.ncl" in
let apis = import "../../src/api/all.ncl" in

{
  openapi = "3.0.0",
  info = {
    title = "Circular Protocol API",
    version = config.version,
    description = "Blockchain API for wallet, transaction, and asset operations",
  },
  servers = [
    { url = "https://api.circular.org", description = "Production" },
    { url = "https://staging-api.circular.org", description = "Staging" },
  ],
  paths = generate_paths apis,
  components = {
    schemas = generate_schemas apis,
  },
}
```

### Usage in Language Generators

Language generators can import OpenAPI spec to ensure consistency:

```nickel
# In generators/typescript/typescript-sdk.ncl
let openapi = import "../shared/openapi.ncl" in
let paths = openapi.paths in

# Generate TypeScript methods from OpenAPI paths
let generate_methods = std.record.map (fun path_name path_def =>
  generate_ts_method path_name path_def
) paths
```

## Helper Functions

### helpers.ncl Structure

Common utilities used across all language generators:

```nickel
{
  # String transformations
  to_camel_case = fun str => /* ... */,
  to_snake_case = fun str => /* ... */,
  to_pascal_case = fun str => /* ... */,
  to_kebab_case = fun str => /* ... */,

  # Type conversions
  type_to_typescript = fun nickel_type => /* ... */,
  type_to_python = fun nickel_type => /* ... */,
  type_to_java = fun nickel_type => /* ... */,

  # String utilities
  escape_json = fun str => /* ... */,
  indent = fun str level => /* ... */,
  wrap_comment = fun str max_width => /* ... */,

  # Array utilities
  join_with_comma = fun arr => std.string.join ", " arr,
  join_with_newline = fun arr => std.string.join "\n" arr,

  # Validation
  is_valid_identifier = fun str => /* ... */,
  sanitize_identifier = fun str => /* ... */,
}
```

### Usage Example

```nickel
# In generators/typescript/typescript-sdk.ncl
let helpers = import "../shared/helpers.ncl" in

let generate_method_name = fun endpoint_name =>
  helpers.to_camel_case endpoint_name
in

let generate_class_name = fun endpoint_name =>
  helpers.to_pascal_case endpoint_name
```

## Test Data

### test-data.ncl Purpose

Provides common test cases that all language SDKs should handle identically:

```nickel
{
  valid_addresses = [
    "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
    "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
  ],

  invalid_addresses = [
    "invalid",
    "0x123",  # Too short
    "xyz1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",  # Invalid chars
  ],

  valid_amounts = [
    "0",
    "1000000000000000000",  # 1 ETH in wei
    "999999999999999999999999",
  ],

  invalid_amounts = [
    "-1",
    "1.5",  # Decimals not allowed
    "abc",
  ],

  blockchains = [
    "ethereum",
    "polygon",
    "bsc",
    "avalanche",
  ],

  test_endpoints = {
    checkWallet = {
      valid_inputs = [
        { address = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef" },
      ],
      expected_outputs = [
        { exists = true, blockchain = "ethereum" },
      ],
    },
  },
}
```

### Usage in Test Generators

```nickel
# In generators/typescript/tests/typescript-unit-tests.ncl
let test_data = import "../../shared/test-data.ncl" in

let generate_address_tests = m%"
describe('Address Validation', () => {
  %{std.string.join "\n  " (std.array.map (fun addr =>
    m%"it('should accept valid address: %{addr}', () => {
      expect(isValidAddress('%{addr}')).toBe(true);
    });"%
  ) test_data.valid_addresses)}

  %{std.string.join "\n  " (std.array.map (fun addr =>
    m%"it('should reject invalid address: %{addr}', () => {
      expect(isValidAddress('%{addr}')).toBe(false);
    });"%
  ) test_data.invalid_addresses)}
});
"%
```

## Shared Templates

### Purpose

Templates ensure cross-language consistency for documentation sections that should be identical across all SDKs.

### README Header Template

`templates/readme-header.todo.ncl` (placeholder for future implementation):

```nickel
{
  generate = fun config =>
    m%"
    # Circular Protocol API - %{config.language} SDK

    [![npm version](https://img.shields.io/npm/v/%{config.package_name}.svg)](...)
    [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](...)

    > Official %{config.language} SDK for Circular Protocol blockchain

    ## Features

    - ✅ Full TypeScript/Python/Java support
    - ✅ 24 API methods covering all blockchain operations
    - ✅ Runtime type validation
    - ✅ Async/await patterns
    - ✅ Comprehensive error handling
    - ✅ 100% test coverage
    "%
}
```

### Usage in Language READMEs

```nickel
# In generators/typescript/docs/typescript-readme.ncl
let header_template = import "../../shared/templates/readme-header.todo.ncl" in

{
  readme_content = m%"
    %{header_template.generate { language = "TypeScript", package_name = "circular-protocol-api" }}

    ## Installation

    \`\`\`bash
    npm install circular-protocol-api
    \`\`\`

    [Language-specific content...]
  "%
}
```

### Security Section Template

`templates/readme-security.todo.ncl` (placeholder for future implementation):

```nickel
{
  generate = m%"
    ## Security

    ### API Key Management

    Never hardcode API keys in your source code. Use environment variables:

    \`\`\`bash
    export CIRCULAR_API_KEY=your_api_key
    \`\`\`

    ### Address Validation

    All addresses are validated before being sent to the API. Invalid addresses will throw errors.

    ### Rate Limiting

    The SDK respects API rate limits and will automatically retry with exponential backoff.

    ### Reporting Security Issues

    Please report security vulnerabilities to security@circular.org
  "%
}
```

## Cross-Language Validation

### Ensuring Consistency

The shared test data allows us to verify that all language SDKs behave identically:

```bash
# tests/cross-lang/run-tests.py
import json
import subprocess

test_data = json.load(open('generators/shared/test-data.ncl'))

# Run same test in TypeScript
ts_result = subprocess.run(['npm', 'test', '--', 'address-validation'], capture_output=True)

# Run same test in Python
py_result = subprocess.run(['pytest', 'tests/test_address_validation.py'], capture_output=True)

# Compare results
assert ts_result.returncode == py_result.returncode
```

## Adding a New Shared Utility

### Step-by-step Process

1. **Identify the pattern**: Find code duplicated across 2+ language generators
2. **Extract to helpers.ncl**: Create a generic function
3. **Update language generators**: Replace duplicated code with helper import
4. **Add tests**: Ensure helper works for all use cases
5. **Document**: Add example to this CLAUDE.md

### Example: Adding a New Helper

```nickel
# Add to generators/shared/helpers.ncl
{
  # Existing helpers...

  # New helper: pluralize a word
  pluralize = fun word =>
    if std.string.is_match ".*s$" word then word
    else if std.string.is_match ".*y$" word then
      std.string.replace_regex "y$" "ies" word
    else word ++ "s",
}
```

```nickel
# Use in generators/typescript/typescript-sdk.ncl
let helpers = import "../shared/helpers.ncl" in

let generate_array_type = fun type_name =>
  m%"Array<%{helpers.pluralize type_name}>"%
```

## Common Patterns

### Multi-Language Type Mapping

```nickel
let type_map = {
  typescript = fun t =>
    if t == "string" then "string"
    else if t == "number" then "number"
    else "unknown",

  python = fun t =>
    if t == "string" then "str"
    else if t == "number" then "int"
    else "Any",

  java = fun t =>
    if t == "string" then "String"
    else if t == "number" then "Integer"
    else "Object",
}
```

### Template Composition

```nickel
let compose_templates = fun templates =>
  std.string.join "\n\n" (std.array.map (fun t => t.generate) templates)
```

## Cross-References

- Using helpers in TypeScript: `generators/typescript/CLAUDE.md`
- Using helpers in Python: `generators/python/CLAUDE.md`
- Source schemas: `src/CLAUDE.md`
- Generator system: `generators/CLAUDE.md`
