# generators/CLAUDE.md

Guidance for working with the generator system in the `generators/` directory.

> **Parent Context**: See `/CLAUDE.md` for project overview and essential commands.
> **Language-Specific Guides**: See subdirectory CLAUDE.md files for language-specific patterns.

## Directory Structure

```
generators/
├── shared/
│   ├── CLAUDE.md              # Shared utilities guidance
│   ├── openapi.ncl            # OpenAPI 3.0 generator
│   ├── helpers.ncl            # Common helper functions
│   ├── test-data.ncl          # Shared test data
│   └── templates/             # Shared templates for cross-language consistency
│       ├── readme-header.todo.ncl
│       └── readme-security.todo.ncl
├── typescript/
│   ├── CLAUDE.md              # TypeScript-specific guidance
│   ├── typescript-sdk.ncl     # Main SDK generator
│   ├── tests/                 # Test generators
│   ├── config/                # Config generators (tsconfig, webpack, jest)
│   ├── docs/                  # Documentation generators
│   ├── package-manifest/      # package.json generator
│   ├── metadata/              # Metadata generators (.gitignore, etc.)
│   └── ci-cd/                 # CI/CD workflow generators
└── python/
    ├── CLAUDE.md              # Python-specific guidance
    ├── python-sdk.ncl         # Main SDK generator
    ├── tests/                 # Test generators
    ├── config/                # Config generators (pytest.ini, etc.)
    ├── docs/                  # Documentation generators
    ├── package-manifest/      # pyproject.toml, setup.py generators
    ├── metadata/              # Metadata generators
    └── ci-cd/                 # CI/CD workflow generators
```

## Generator Architecture

### Language-First Organization

Generators are organized **by target language** rather than by generator type. This makes it easier to:

1. **Add new languages**: Create one new directory with all language-specific generators
2. **Maintain consistency**: All TypeScript generators are co-located, easier to ensure they work together
3. **Debug issues**: When TypeScript SDK has issues, all related generators are in same directory
4. **Track completion**: Clear checklist per language (SDK + tests + config + docs + CI/CD)

### Shared vs Language-Specific

**Use `generators/shared/` when:**
- Generator output is language-agnostic (OpenAPI, MCP server schema)
- Common functions used across multiple languages (helpers.ncl)
- Test data used by all language generators
- Templates for cross-language consistency (README structure)

**Use `generators/<language>/` when:**
- Generator produces language-specific code or configuration
- Type mappings are language-specific
- Naming conventions differ (camelCase vs snake_case)
- Build tools are language-specific (npm, pip, maven)

## Creating a New Generator

### Basic Generator Pattern

```nickel
# generators/<language>/<language>-<type>.ncl
let config = import "../../src/config.ncl" in
let types = import "../../src/schemas/types.ncl" in
let apis = import "../../src/api/all.ncl" in
let helpers = import "../shared/helpers.ncl" in

# Transformation functions
let to_target_type = fun nickel_type =>
  if nickel_type == "string" then "TargetString"
  else if nickel_type == "number" then "TargetNumber"
  else if nickel_type == "boolean" then "TargetBoolean"
  else "TargetUnknown"
in

let to_target_name = fun nickel_name =>
  # Apply language-specific naming conventions
  # e.g., camelCase, snake_case, PascalCase
  nickel_name
in

# String template generation
let generate_function = fun endpoint =>
  m%"
  function %{to_target_name endpoint.name}() {
    // Generated function for %{endpoint.summary}
  }
  "%
in

# Main output
{
  content = std.string.join "\n" (
    std.array.map generate_function (std.record.values apis)
  ),
}
```

### Multi-String Interpolation

Use `m%"..."` for multi-line strings with interpolation:

```nickel
let generate_class = fun class_name fields =>
  m%"
  class %{class_name} {
    %{std.string.join "\n    " (std.array.map generate_field fields)}
  }
  "%
```

### Import Paths in Generators

Generators are nested in subdirectories, so import paths need to account for depth:

```nickel
# In generators/<language>/<language>-sdk.ncl (depth 2):
let config = import "../../src/config.ncl" in
let helpers = import "../shared/helpers.ncl" in

# In generators/<language>/config/<language>-tsconfig.ncl (depth 3):
let config = import "../../../src/config.ncl" in
let helpers = import "../../shared/helpers.ncl" in
```

## Generator Requirements

All generators must meet these criteria:

### 1. Syntactic Validity

Generated code must be syntactically valid in the target language:

```bash
# TypeScript
nickel export generators/typescript/typescript-sdk.ncl --field sdk_code > /tmp/test.ts
npx tsc --noEmit /tmp/test.ts

# Python
nickel export generators/python/python-sdk.ncl --field sdk_code > /tmp/test.py
python -m py_compile /tmp/test.py

# Java
nickel export generators/java/java-sdk.ncl --field sdk_code > /tmp/Test.java
javac /tmp/Test.java
```

### 2. Language Idioms

Generated code must follow language-specific conventions:

- **TypeScript**: camelCase functions, PascalCase classes, async/await
- **Python**: snake_case functions, PascalCase classes, async def
- **Java**: camelCase methods, PascalCase classes, CompletableFuture
- **PHP**: snake_case or camelCase (PSR-12), PascalCase classes

### 3. Edge Case Handling

Generators must handle:
- Optional fields (undefined, None, null)
- Arrays and nested objects
- Enums and union types
- Default values
- Nullable vs non-nullable types

### 4. Snapshot Testing

Changes to generators require snapshot tests:

```bash
# Generate snapshot
nickel export generators/typescript/typescript-sdk.ncl --field sdk_code > tests/snapshots/typescript-sdk.snapshot

# Compare on future runs
nickel export generators/typescript/typescript-sdk.ncl --field sdk_code | diff - tests/snapshots/typescript-sdk.snapshot
```

## Helper Functions

### Common Patterns in helpers.ncl

```nickel
# generators/shared/helpers.ncl
{
  # Convert to camelCase
  to_camel_case = fun str =>
    # Implementation
    str,

  # Convert to snake_case
  to_snake_case = fun str =>
    # Implementation
    str,

  # Convert to PascalCase
  to_pascal_case = fun str =>
    # Implementation
    str,

  # Escape string for JSON
  escape_json = fun str =>
    # Implementation
    str,

  # Map Nickel types to language-specific types
  type_mapping = {
    typescript = fun nickel_type =>
      if nickel_type == "string" then "string"
      else if nickel_type == "number" then "number"
      else if nickel_type == "boolean" then "boolean"
      else "unknown",

    python = fun nickel_type =>
      if nickel_type == "string" then "str"
      else if nickel_type == "number" then "int"
      else if nickel_type == "boolean" then "bool"
      else "Any",
  },
}
```

## Testing Generators

### Layer 2: Syntax Validation

Verify generated code compiles:

```bash
./tests/generators/syntax-validation.sh
```

### Layer 3: Snapshot Testing

Verify generator output matches expected:

```bash
./tests/generators/snapshot-test.sh
```

### Manual Testing

```bash
# Generate to temp file
nickel export generators/typescript/typescript-sdk.ncl --field sdk_code > /tmp/sdk.ts

# Inspect output
cat /tmp/sdk.ts

# Validate syntax
npx tsc --noEmit /tmp/sdk.ts
```

## Adding Generators to Build

Update `justfile` to include new generator:

```makefile
# Generate TypeScript SDK
generate-ts-sdk:
    @echo "Generating TypeScript SDK..."
    @nickel export generators/typescript/typescript-sdk.ncl --field sdk_code --format raw > dist/typescript/sdk/circular-protocol.ts

# Generate Python SDK
generate-py-sdk:
    @echo "Generating Python SDK..."
    @nickel export generators/python/python-sdk.ncl --field sdk_code --format raw > dist/python/sdk/circular_protocol.py

# Generate all
generate: generate-ts-sdk generate-py-sdk
```

## Common Generator Patterns

### Iterating Over Endpoints

```nickel
let generate_all_endpoints = fun apis =>
  std.string.join "\n\n" (
    std.array.map generate_single_endpoint (std.record.values apis)
  )
```

### Conditional Generation

```nickel
let generate_optional_field = fun field =>
  if field.required then
    m%"  %{field.name}: %{field.type}"%
  else
    m%"  %{field.name}?: %{field.type}"%
```

### Nested Template Composition

```nickel
let generate_class = fun class_name =>
  m%"
  class %{class_name} {
    %{generate_constructor class_name}

    %{generate_methods class_name}
  }
  "%
```

## Cross-References

- Source schemas used by generators: `src/CLAUDE.md`
- TypeScript-specific patterns: `generators/typescript/CLAUDE.md`
- Python-specific patterns: `generators/python/CLAUDE.md`
- Shared utilities: `generators/shared/CLAUDE.md`
