# scripts/CLAUDE.md

Guidance for automation scripts in the `scripts/` directory.

> **Parent Context**: See `/CLAUDE.md` for project overview and essential commands.

## Purpose

The `scripts/` directory contains utility scripts for project automation, tooling, and development workflows.

**Key principle**: Scripts should be **simple, documented, and idempotent** (safe to run multiple times).

## Directory Structure

```
scripts/
├── CLAUDE.md              # This file
├── setup-dev.sh           # Development environment setup
├── generate-all.sh        # Generate all artifacts from Nickel
├── validate-output.sh     # Validate generated artifacts
└── sync-submodules.sh     # Sync git submodules (dist/typescript, dist/python)
```

## Script Categories

### 1. Setup Scripts

**Purpose**: Initialize development environment
**When to run**: Once during project setup, or after major environment changes

```bash
# scripts/setup-dev.sh
# - Creates dist/ directories
# - Initializes git submodules
# - Installs dependencies (npm, pip)
# - Runs initial validation
```

**Usage**:
```bash
./scripts/setup-dev.sh
```

### 2. Generation Scripts

**Purpose**: Generate artifacts from Nickel definitions
**When to run**: After modifying src/*.ncl files

```bash
# scripts/generate-all.sh
# - Exports all Nickel generators
# - Generates TypeScript SDK
# - Generates Python SDK
# - Generates OpenAPI spec
# - Generates MCP server schema
```

**Usage**:
```bash
./scripts/generate-all.sh

# Or use justfile shortcut:
just generate
```

### 3. Validation Scripts

**Purpose**: Validate generated artifacts
**When to run**: After generation, before commit

```bash
# scripts/validate-output.sh
# - TypeScript syntax check (tsc --noEmit)
# - Python syntax check (py_compile)
# - OpenAPI spec validation
# - JSON schema validation
```

**Usage**:
```bash
./scripts/validate-output.sh

# Or use justfile shortcut:
just validate
```

### 4. Sync Scripts

**Purpose**: Sync git submodules with generated code
**When to run**: After generating SDKs, before pushing

```bash
# scripts/sync-submodules.sh
# - Commits changes in dist/typescript/ submodule
# - Commits changes in dist/python/ submodule
# - Updates submodule references in parent repo
```

**Usage**:
```bash
./scripts/sync-submodules.sh

# Or use justfile shortcut:
just sync-sdks
```

## Script Best Practices

### 1. Shell Script Template

```bash
#!/usr/bin/env bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Script: generate-example.sh
# Purpose: Generate example artifacts from Nickel
# Usage: ./scripts/generate-example.sh [--force]

# Default values
FORCE=false
OUTPUT_DIR="dist/example"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --force)
      FORCE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Main logic
main() {
  echo "Generating examples..."

  # Check prerequisites
  if ! command -v nickel &> /dev/null; then
    echo "Error: nickel not found. Run 'nix develop' first."
    exit 1
  fi

  # Create output directory
  mkdir -p "$OUTPUT_DIR"

  # Generate artifacts
  nickel export generators/example.ncl --format raw > "$OUTPUT_DIR/output.txt"

  echo "✅ Generation complete: $OUTPUT_DIR"
}

# Run main function
main
```

### 2. Error Handling

Always handle errors gracefully:

```bash
# Check command exists
if ! command -v nickel &> /dev/null; then
  echo "Error: nickel not found"
  exit 1
fi

# Check file exists
if [[ ! -f "src/config.ncl" ]]; then
  echo "Error: src/config.ncl not found"
  exit 1
fi

# Check directory writable
if [[ ! -w "dist" ]]; then
  echo "Error: dist/ directory not writable"
  exit 1
fi
```

### 3. Idempotency

Scripts should be safe to run multiple times:

```bash
# ✅ Good: Check before creating
if [[ ! -d "dist/typescript" ]]; then
  mkdir -p "dist/typescript"
fi

# ❌ Bad: Fails on second run
mkdir "dist/typescript"

# ✅ Good: Overwrite safely
cp -f source.txt dest.txt

# ❌ Bad: Appends on each run
cat source.txt >> dest.txt
```

### 4. Clear Output

Provide informative messages:

```bash
echo "🔨 Generating TypeScript SDK..."
nickel export generators/typescript/typescript-sdk.ncl > dist/typescript/sdk.ts
echo "✅ TypeScript SDK generated"

echo "🔨 Generating Python SDK..."
nickel export generators/python/python-sdk.ncl > dist/python/sdk.py
echo "✅ Python SDK generated"

echo ""
echo "🎉 All artifacts generated successfully!"
```

### 5. Documentation

Every script should have:
- **Shebang**: `#!/usr/bin/env bash`
- **Purpose comment**: What the script does
- **Usage comment**: How to run it
- **Examples**: Common use cases

```bash
#!/usr/bin/env bash

# Script: generate-all.sh
# Purpose: Generate all SDK artifacts from Nickel definitions
# Usage: ./scripts/generate-all.sh [OPTIONS]
#
# Options:
#   --force       Force regeneration (skip cache)
#   --skip-tests  Skip post-generation validation
#
# Examples:
#   ./scripts/generate-all.sh                # Normal generation
#   ./scripts/generate-all.sh --force        # Force regeneration
#   ./scripts/generate-all.sh --skip-tests   # Skip validation
```

## Common Script Patterns

### 1. Generate from Nickel

```bash
generate_typescript() {
  echo "Generating TypeScript SDK..."
  nickel export generators/typescript/typescript-sdk.ncl \
    --field sdk_code \
    --format raw \
    > dist/typescript/sdk/circular-protocol.ts
}

generate_python() {
  echo "Generating Python SDK..."
  nickel export generators/python/python-sdk.ncl \
    --field sdk_code \
    --format raw \
    > dist/python/sdk/circular_protocol.py
}
```

### 2. Validate Generated Code

```bash
validate_typescript() {
  echo "Validating TypeScript..."
  cd dist/typescript
  npx tsc --noEmit || {
    echo "❌ TypeScript validation failed"
    exit 1
  }
  cd ../..
  echo "✅ TypeScript valid"
}

validate_python() {
  echo "Validating Python..."
  python3 -m py_compile dist/python/sdk/circular_protocol.py || {
    echo "❌ Python validation failed"
    exit 1
  }
  echo "✅ Python valid"
}
```

### 3. Sync Git Submodules

```bash
sync_typescript_sdk() {
  echo "Syncing TypeScript SDK submodule..."
  cd dist/typescript
  git add .
  git commit -m "chore: sync from canonical $(git -C ../.. rev-parse --short HEAD)" || true
  cd ../..
}

sync_python_sdk() {
  echo "Syncing Python SDK submodule..."
  cd dist/python
  git add .
  git commit -m "chore: sync from canonical $(git -C ../.. rev-parse --short HEAD)" || true
  cd ../..
}
```

### 4. Parallel Execution

```bash
# Run tasks in parallel for speed
generate_all_parallel() {
  generate_typescript &
  PID_TS=$!

  generate_python &
  PID_PY=$!

  # Wait for both to complete
  wait $PID_TS || exit 1
  wait $PID_PY || exit 1

  echo "✅ All generations complete"
}
```

## Integration with Justfile

Scripts should be callable from `justfile` for convenience:

```makefile
# justfile

# Generate all artifacts
generate:
    @./scripts/generate-all.sh

# Validate generated artifacts
validate:
    @./scripts/validate-output.sh

# Setup development environment
setup:
    @./scripts/setup-dev.sh

# Sync SDK submodules
sync-sdks:
    @./scripts/sync-submodules.sh

# Complete workflow: generate, validate, sync
dev: generate validate sync-sdks
```

## Debugging Scripts

### Enable Debug Mode

```bash
# Add to script header
set -x  # Print each command before executing

# Or run with debug flag
bash -x ./scripts/generate-all.sh
```

### Common Issues

#### 1. Script Not Executable

**Problem**: `Permission denied` when running script
**Solution**:
```bash
chmod +x scripts/my-script.sh
```

#### 2. Command Not Found (Outside Nix)

**Problem**: `nickel: command not found`
**Solution**: Run inside Nix environment:
```bash
nix develop --command ./scripts/my-script.sh
```

Or add to script:
```bash
if ! command -v nickel &> /dev/null; then
  echo "Error: Run 'nix develop' first"
  exit 1
fi
```

#### 3. Relative Path Issues

**Problem**: Script works from root but fails from subdirectories
**Solution**: Use script directory as base:
```bash
# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Use absolute paths
cd "$PROJECT_ROOT"
nickel export src/config.ncl
```

## Performance Optimization

### 1. Caching

```bash
# Check if output is up-to-date
if [[ dist/typescript/sdk.ts -nt src/api/wallet.ncl ]]; then
  echo "✅ TypeScript SDK is up-to-date (skipping)"
  return 0
fi

# Generate if source is newer
generate_typescript
```

### 2. Incremental Generation

```bash
# Only regenerate changed files
for ncl_file in src/api/*.ncl; do
  basename="${ncl_file##*/}"
  output="dist/generated/${basename%.ncl}.json"

  if [[ "$ncl_file" -nt "$output" ]]; then
    echo "Regenerating $basename..."
    nickel export "$ncl_file" > "$output"
  fi
done
```

### 3. Parallel Processing

```bash
# Generate multiple artifacts in parallel
generate_typescript &
generate_python &
generate_openapi &

# Wait for all to complete
wait

echo "✅ All generations complete"
```

## Cross-References

- Build automation: `justfile` (root)
- CI/CD integration: `.github/workflows/test.yml`
- Nix environment: `flake.nix` (root)
- Git workflow: `docs/DEVELOPMENT_WORKFLOW.md`
- Generator system: `generators/CLAUDE.md`
