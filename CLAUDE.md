# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Scoped Documentation**: This is the root CLAUDE.md. Each major directory has its own scoped CLAUDE.md file for context-specific guidance. Always check the relevant scoped file before working in that directory:
>
> **Core Directories**:
> - `src/CLAUDE.md` - API definitions and schema patterns
> - `generators/CLAUDE.md` - Generator system overview
> - `tests/CLAUDE.md` - Test infrastructure and Nickel-first philosophy
> - `docs/CLAUDE.md` - Documentation standards and maintenance
> - `hooks/CLAUDE.md` - Git hooks and pre-commit/pre-push validation
> - `scripts/CLAUDE.md` - Automation scripts and tooling
>
> **Language-Specific Generators**:
> - `generators/typescript/CLAUDE.md` - TypeScript SDK generation
> - `generators/python/CLAUDE.md` - Python SDK generation
> - `generators/shared/CLAUDE.md` - Shared utilities and templates
>
> **Note**: If you're working in a directory and don't see a CLAUDE.md file, check if one should exist. The goal is to have scoped context in every major directory to prevent implementation drift.

## Project Overview

**Circular Protocol Canonical** is a single source of truth for Circular Protocol standard APIs. It uses [Nickel](https://nickel-lang.org/) to define API specifications, contracts, and schemas in one canonical location, then generates multiple artifacts from these definitions:

- OpenAPI 3.0 specifications
- MCP (Model Context Protocol) servers for AI agents
- Multi-language SDKs (TypeScript, Python, Java, PHP) with runtime validation
- Documentation and examples

**Key Principle**: One Nickel definition → many outputs. This prevents drift across SDKs and ensures consistency.

**Reference Implementation**: [circular-js](https://github.com/circular-protocol/circular-js) (20+ API endpoints for blockchain wallet operations, transactions, assets, blocks, domains, and network queries)

## Architecture

### Single Source of Truth Pattern

```
Nickel Definitions (src/)
        ↓
Contracts enforce validation
        ↓
Generators transform (generators/)
        ↓
Multiple Outputs (dist/)
    ├── OpenAPI spec
    ├── TypeScript SDK
    ├── Python SDK
    ├── Java SDK
    ├── PHP SDK
    ├── MCP server schema
    └── Documentation
```

### Three-Layer Structure

1. **Canonical Layer** (`src/`): Nickel definitions with contracts
   - `src/schemas/`: Type definitions (Address, Amount, Blockchain enums)
   - `src/api/`: Endpoint definitions organized by domain (wallet, transaction, asset, block)
   - `src/config.ncl`: Base configuration (version, defaults)
   - See `src/CLAUDE.md` for detailed guidance

2. **Transformation Layer** (`generators/`): Nickel programs organized by target language
   - `generators/typescript/`: TypeScript SDK and tooling generators
   - `generators/python/`: Python SDK and tooling generators
   - `generators/shared/`: Language-agnostic generators (OpenAPI, helpers, test data)
   - See `generators/CLAUDE.md` for generator architecture

3. **Output Layer** (`dist/`): Generated artifacts (gitignored)
   - Never manually edit generated files
   - Always regenerate from Nickel source

### Nickel Language Essentials

**Contracts**: Runtime validation at export time
```nickel
field | std.string.NonEmpty = "value"  # Contract before equals
```

**Merging**: Compose configurations without duplication
```nickel
base_config & override_config
```

**Custom Contracts**: Reusable validation
```nickel
Address = std.contract.from_predicate (fun value =>
  let len = std.string.length value in
  (len == 64 || len == 66) && std.string.is_match "^(0x)?[0-9a-fA-F]+$" value
)
```

## Essential Commands

### Environment Setup
```bash
# Enter development environment (recommended - includes git hooks)
nix develop

# This automatically installs:
# - Nickel language tools
# - TypeScript/Node.js tooling
# - Python environment
# - Just command runner
# - Git pre-commit/pre-push hooks
# - All development dependencies

# Verify installation
nickel --version
just --version

# Initial project setup (creates dist dirs)
just setup
```

### Git Hooks (Automatic)

When you enter `nix develop`, git hooks are automatically installed:

**Pre-commit hooks:**
- ✅ Nickel type checking (validates all .ncl files)
- ✅ Secrets detection (prevents committing API keys, private keys)
- ✅ Large file check (blocks files >500KB)
- ✅ Trailing whitespace fix
- ✅ End-of-file fixer
- ✅ JSON/YAML validation
- ✅ Markdown linting

**Pre-push hooks:**
- ✅ Repository URL check (prevents push to numbered test repos or typos)
- ✅ Protects against: circular-canonicle (typo), circular-py-1, circular-js-npm-2, etc.

**Note:** Hooks are managed via git-hooks.nix and configured in flake.nix

### Development Workflow
```bash
# Type check all Nickel files (fast, run frequently)
just validate
# Or manually:
nickel typecheck src/api/*.ncl
find src -name "*.ncl" -exec nickel typecheck {} \;

# Run test suite (contract validation + generator output validation)
just test

# Generate all artifacts from Nickel definitions
just generate

# Watch mode: auto-regenerate on file changes
just watch

# Clean generated files
just clean

# Quick development cycle (validate + generate)
just dev

# See all available commands
just --list
```

### Testing
```bash
# Contract validation tests (Layer 1: fastest)
./tests/run-contract-tests.sh

# Generator syntax validation (Layer 2: verify generated code compiles)
./tests/generators/syntax-validation.sh

# Snapshot tests (verify generator output matches expected)
./tests/generators/snapshot-test.sh

# Cross-language validation (Layer 3: all SDKs behave identically)
python3 tests/cross-lang/run-tests.py

# Regression tests (detect breaking changes)
./tests/regression/compare-versions.sh
```

### Working with Nickel Files
```bash
# Export Nickel to JSON for inspection
nickel export src/api/wallet.ncl --format json | jq .

# Export to YAML
nickel export generators/shared/openapi.ncl --format yaml > dist/openapi/openapi.yaml

# Query specific fields
nickel query src/api/wallet.ncl checkWallet

# Interactive REPL for debugging
nickel repl
> import "src/schemas/types.ncl"
```

## Important Files

### Documentation (Critical Reference)
- **`docs/WEEK_1_2_GUIDE.md`**: Day-by-day implementation plan for first 2 weeks. Start here for new development.
- **`docs/NICKEL_PATTERNS.md`**: Comprehensive Nickel syntax, contracts, generator patterns, 10+ examples. Reference when writing Nickel code.
- **`docs/TESTING_STRATEGY.md`**: Four-layer testing approach (contracts → generators → cross-lang → integration). Reference when adding tests.
- **`docs/DEVELOPMENT_WORKFLOW.md`**: Git workflow, PR process, release process, IDE setup, troubleshooting.
- **`docs/MIGRATION_PATH.md`**: 24-week migration strategy from existing circular-js SDK. Context for "why Canonical?"

### Reference Files
- `circular-js.xml`: Repomix export of reference implementation (20+ endpoints to implement)
- `NodeJS-Enterprise-APIs.xml`, `Java-Enterprise-APIs.xml`, `PHP-Enterprise-APIs.xml`: Enterprise API references
- `CANONICAL_TODOs.md`: Comprehensive transformation checklist (12-16 week plan across 10 domains)

## Official Repositories

**⚠️ IMPORTANT:** Only these 3 repositories are official. All others are outdated/test repos.

1. **circular-canonical** - THIS REPO (Single source of truth)
   - URL: `git@github.com:lessuseless-systems/circular-canonical.git`
   - Purpose: Nickel definitions, generators, canonical API spec
   - Branch: `main`

2. **circular-js-npm** - TypeScript/NPM SDK (generated)
   - URL: `git@github.com:lessuseless-systems/circular-js-npm.git`
   - Purpose: Generated TypeScript SDK
   - Branch: `development`
   - Submodule at: `dist/typescript/`

3. **circular-py** - Python SDK (generated)
   - URL: `git@github.com:lessuseless-systems/circular-py.git`
   - Purpose: Generated Python SDK
   - Branch: `development`
   - Submodule at: `dist/python/`

**Never push to:**
- `circular-canonicle` (typo)
- `circular-py-1`, `circular-py-2` (numbered test repos)
- `circular-js-npm-1`, `circular-js-npm-2` (numbered test repos)

Git hooks will automatically prevent pushes to wrong repositories.

## Version and Compatibility

- **Current Status**: Pre-release, implementing foundation
- **Target Version**: 2.0.0-alpha.1
- **Reference Version**: circular-js 1.0.8
- **Semantic Versioning**: Strictly followed (MAJOR.MINOR.PATCH)
- **Breaking Changes**: Require major version bump + migration guide + CHANGELOG entry

## Workflow Integration

### Git Workflow
- Branch naming: `feature/`, `fix/`, `docs/`, `hotfix/`
- Commit format: Conventional Commits (`feat(api): add getAsset endpoint`)
- **Pre-commit hooks** (automatic via git-hooks.nix):
  - Nickel type checking
  - Secrets detection
  - File size limits
  - Code quality checks
- **Pre-push hooks** (automatic):
  - Repository URL validation (prevents numbered repos/typos)
- PR requires: All tests pass, no breaking changes (or documented), CHANGELOG updated

### Release Process
1. Update version in `src/config.ncl`
2. Update `CHANGELOG.md`
3. `just test && just generate`
4. Verify generated SDKs build in target languages
5. Commit: `chore(release): prepare vX.Y.Z`
6. Tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
7. Push: `git push origin develop && git push origin vX.Y.Z`
8. CI/CD creates GitHub release with artifacts

## External Resources

- [Nickel Language Documentation](https://nickel-lang.org/)
- [circular-js Reference Implementation](https://github.com/circular-protocol/circular-js)
- [OpenAPI 3.0 Specification](https://spec.openapis.org/oas/v3.0.0)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)
