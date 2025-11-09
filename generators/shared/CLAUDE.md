# generators/shared/CLAUDE.md

Guidance for working with shared generator utilities and templates.

> **Parent Context**: See `generators/CLAUDE.md` for generator system overview.

## Directory Structure

```
generators/shared/
├── CLAUDE.md                  # This file
├── openapi.ncl                # OpenAPI 3.0 generator (language-agnostic)
├── helpers.ncl                # Common helper functions
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
