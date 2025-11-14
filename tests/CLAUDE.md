# tests/CLAUDE.md

Guidance for working with the test infrastructure in the `tests/` directory.

> **Parent Context**: See `/CLAUDE.md` for project overview and essential commands.

## Critical Philosophy: Nickel-First Testing

**Core Principle**: `tests/` should contain ONLY `.ncl` files. All test infrastructure (mock servers, test runners, validators) must be **generated** from Nickel definitions.

### Why Nickel-First?

**Problem**: Manual test code duplicates API definitions and creates drift risk.

Example of the problem:
```python
# tests/mock-server/server.py (WRONG - manual duplication)
def _handle_check_wallet(self, body):
    return {"Result": 200, "Response": {"exists": True, ...}}
```

```nickel
# src/api/wallet.ncl (RIGHT - single source of truth)
checkWallet = {
  example_response = { Result = 200, Response = { exists = true, ... } }
}
```

**Solution**: Generate mock server from `src/api/*.ncl` definitions.

```
src/api/*.ncl → generators/shared/mock-server.ncl → dist/tests/mock-server.py
```

**Benefits**:
1. **Zero Drift**: Mock server responses always match API definitions
2. **DRY**: 24 API endpoints defined once, not twice
3. **Consistency**: All test infrastructure generated from same source
4. **Maintainability**: Update API once, all tests update automatically

## Directory Structure (Post-Sprint 3 Restructure)

**Philosophy**: Test pyramid layers are explicit (L1-L4), test specs (.ncl) separated from infrastructure (scripts/data).

```
tests/
├── CLAUDE.md                         # This file
├── .gitignore                       # Prevents compiled artifacts pollution
│
├── L1-contracts/                    # Layer 1: Contract validation (< 5s)
│   ├── types.test.ncl              # Primitive type contracts
│   └── endpoints/                  # Endpoint request/response contracts (24 files)
│       ├── checkWallet.test.ncl
│       ├── getWallet.test.ncl
│       └── ...
│
├── L2-unit/                         # Layer 2: Unit tests (< 30s)
│   └── helpers.test.ncl            # Helper function tests (21 tests)
│
├── L3-integration/                  # Layer 3: Integration tests (< 2m)
│   └── [.ncl test specs]           # Integration flow specifications
│
├── L4-crosslang/                    # Layer 4a: Cross-language parity tests (< 5m)
│   └── [.ncl test specs]           # SDK parity validation
│
├── L4-regression/                   # Layer 4b: Regression tests (< 5m)
│   └── [.ncl test specs]           # Breaking change detection
│
├── validators/                      # Runtime validator function tests
│   └── runtime-validation.test.ncl # Tests validator functions (not contracts)
│
└── infrastructure/                  # Supporting infrastructure (all generated ✅)
    └── mock-server/                # Mock API server (Phase 1 - generated ✅)
```

**Key Improvements**:
- **Layer visibility**: L1-L4 prefixes make test pyramid explicit
- **Separation**: Test specs (.ncl) vs infrastructure (scripts/data)
- **Self-documenting**: Directory names encode test layer and purpose
- **Scalability**: Clear where new tests belong

**Generated artifacts** (in `dist/tests/`, gitignored):
```
dist/tests/
├── mock-server.py              # Generated HTTP mock server (Phase 1 ✅)
├── run-contract-tests.sh       # Generated contract test runner (Phase 2 ✅)
├── syntax-validation.sh        # Generated syntax validator (Phase 2 ✅)
├── snapshot-test.sh            # Generated snapshot test runner (Phase 2 ✅)
├── test-pipeline.sh            # Generated pipeline test - full (Phase 2 ✅)
├── test-pipeline-fast.sh       # Generated pipeline test - fast (Phase 2 ✅)
└── unit/                       # Generated unit tests (Phase 3)
    ├── test_helpers.py
    ├── test_helpers.test.ts
    └── ...
```

## Test Pyramid (Four Layers)

### Layer 1: Contract Validation (Fastest)
**Location**: `tests/L1-contracts/*.test.ncl`
**Purpose**: Validate Nickel contracts and type definitions
**Run**: `./dist/tests/run-contract-tests.sh` (generated)
**Speed**: < 5 seconds

```nickel
# tests/L1-contracts/types.test.ncl
let types = import "../../src/schemas/types.ncl" in

{
  test_name = "Core Types Validation",
  valid_addresses = {
    with_prefix_66_chars = {
      value | types.Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
      expected = "valid",
    },
  },
}
```

```nickel
# tests/L1-contracts/endpoints/checkWallet.test.ncl
let types = import "../../../src/schemas/types.ncl" in

{
  test_name = "checkWallet Endpoint Validation",
  valid_requests = {
    mainnet_with_prefix = {
      request | {
        Blockchain | types.Blockchain,
        Address | types.Address,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        Address = "0xbbbb...",
        Version = "2.0.0-alpha.1",
      },
      expected = "valid",
    },
  },
}
```

### Layer 2: Unit Tests (Fast)
**Location**: `tests/L2-unit/*.test.ncl`
**Purpose**: Test individual helper functions, validators
**Run**: `npm test` (TypeScript), `pytest` (Python)
**Speed**: < 30 seconds
**Generated**: Unit test files created from `.test.ncl` specs

```nickel
# tests/L2-unit/helpers.test.ncl
{
  address_helpers = {
    hex_fix = {
      description = "Normalize hex strings (add/remove 0x prefix, lowercase)",
      tests = [
        {
          name = "adds_0x_prefix_when_missing",
          input = "1234567890abcdef...",
          expected = "0x1234567890abcdef...",
        },
      ],
    },
  },
}
```

### Layer 3: Integration Tests (Medium)
**Location**: `tests/L3-integration/*.test.ncl`
**Purpose**: Test API flows using generated mock server
**Run**: `./dist/tests/test-pipeline.sh integration`
**Speed**: < 2 minutes
**Requires**: Generated mock server running
**Status**: Specs to be created in Phase 4

### Layer 4: Cross-Language & Regression (Slow)
**Location**: `tests/L4-crosslang/*.test.ncl`, `tests/L4-regression/*.test.ncl`
**Purpose**: Verify SDK parity across languages, detect breaking changes
**Run**: `./dist/tests/run-crosslang-tests.py` (cross-lang), regression TBD
**Speed**: < 5 minutes
**Status**: Phase 5 complete (cross-lang ✅), Phase 6 pending (regression)

## Sprint 3: Test Infrastructure Transformation

**Current State**: 1,554 lines of manual Python/shell code
**Target State**: 100% generated from Nickel

### Phase 1: Mock Server Generator (CRITICAL PATH)
**File**: `generators/shared/mock-server.ncl`
**Input**: `src/api/*.ncl` (8 files, 24 endpoints)
**Output**: `dist/tests/mock-server.py` (replaces 410-line manual file)

**Key insight**: Use `example_response` fields from API definitions:
```nickel
# src/api/wallet.ncl
checkWallet = {
  example_response = { Result = 200, Response = { exists = true, ... } }
}

# generators/shared/mock-server.ncl reads this and generates:
# def _handle_check_wallet(self, body):
#     return {"Result": 200, "Response": {"exists": True, ...}}
```

### Phase 2: Test Runner Generators ✅ COMPLETE
Created `generators/shared/test-runners/`:
- ✅ `contract-runner.ncl` → `dist/tests/run-contract-tests.sh`
- ✅ `syntax-validator.ncl` → `dist/tests/syntax-validation.sh`
- ✅ `snapshot-validator.ncl` → `dist/tests/snapshot-test.sh`
- ✅ `pipeline.ncl` → `dist/tests/test-pipeline.sh` + `test-pipeline-fast.sh`

**Result**: 994 lines of test runner code generated from Nickel (replaced 694 lines of manual scripts)

### Phase 3: Unit Test Generators ✅ COMPLETE
Enhanced existing generators:
- ✅ `generators/typescript/tests/typescript-unit-tests.ncl` (634 lines, 45 tests)
- ✅ `generators/python/tests/python-unit-tests.ncl` (621 lines, 51 tests)

Generated unit tests for 21 helper functions across both languages:
- ✅ `dist/circular-ts/tests/index.test.ts` (610 lines, 38 tests)
- ✅ `dist/circular-py/tests/test_unit.py` (597 lines, 45 tests)

**Result**: 1,207 lines of test code generated from 21 helper test specifications

**Note**: Tests generated but require SDK implementation to run. Generate full packages with `just generate-packages`.

### Phase 4: Integration Test Specs ✅ COMPLETE
Created integration test specifications and generator:
- ✅ `tests/L3-integration/integration-tests.test.ncl` (157 lines) - Test specs for 9 core endpoints
- ✅ `generators/typescript/tests/typescript-integration-tests.ncl` (140 lines) - Generator
- ✅ `tests/L3-integration/integration.test.ts` (147 lines, 9 tests generated)

**Test Coverage**:
- Wallet API (5 tests): checkWallet, getWallet, getWalletBalance, getWalletNonce, getLatestTransactions
- Network API (1 test): getBlockchains
- Block API (1 test): getBlockCount
- Error Handling (2 tests): invalid address, connection error

**Result**: Integration tests generated from Nickel specs, fully aligned with mock server

### Phase 5: Cross-Language Validator ✅ COMPLETE
Created cross-language parity validation system:
- ✅ `tests/L4-crosslang/crosslang-parity.test.ncl` (141 lines) - Parity test specs for 9 endpoints
- ✅ `generators/shared/test-runners/crosslang-validator.ncl` (305 lines) - Validator generator
- ✅ `dist/tests/run-crosslang-tests.py` (505 lines, 9 parity tests generated)

**Test Coverage**:
Tests that TypeScript and Python SDKs produce **identical** results for:
- Wallet API: checkWallet, getWallet, getWalletBalance, getWalletNonce, getLatestTransactions
- Network API: getBlockchains
- Block API: getBlockCount
- Asset API: getAsset
- Block API: getBlock

**Validation Logic**:
- Runs same test in both TypeScript and Python SDKs
- Compares specific fields in responses (Result, Response.*, etc.)
- Reports any discrepancies with detailed diff
- Automatically starts/stops mock server

**Result**: Cross-language validator generated from Nickel specs, ensures SDK behavioral parity

### Phase 6: Regression Test Generator ✅ COMPLETE
Created regression test system for breaking change detection:
- ✅ `tests/L4-regression/regression-tests.test.ncl` (103 lines) - Breaking change rules
- ✅ `generators/shared/test-runners/regression-validator.ncl` (243 lines) - Regression generator
- ✅ `dist/tests/detect-breaking-changes.sh` (243 lines, generated)

**Breaking Change Detection**:
- Compares current OpenAPI spec with previous git tag version
- Detects removed endpoints, parameter changes, type changes
- Categorizes as breaking (MAJOR) vs non-breaking (MINOR/PATCH)
- Provides semantic versioning guidance

**Change Categories**:

Breaking (require MAJOR version bump):
- Removed endpoints
- Removed required parameters
- Changed parameter types
- Changed response schemas
- Optional → required parameters
- Renamed endpoints

Non-breaking (MINOR/PATCH allowed):
- Added endpoints
- Added optional parameters
- Added response fields
- Required → optional parameters
- Documentation updates
- Example updates

**Result**: Automated breaking change detection with semantic versioning guidance

---

## Sprint 3 Complete ✅

**Mission**: Transform test infrastructure to 100% Nickel-generated

**Starting Point**: 1,554 lines of manual Python/shell test code

**End Result**: 4,790+ lines of test code generated from Nickel specifications

### Sprint 3 Final Statistics

**Phase 1: Mock Server Generator**
- Generator: 1 file (300+ lines)
- Generated: dist/tests/mock-server.py (192 lines)
- Coverage: 24 API endpoints

**Phase 2: Test Runner Generators**
- Generators: 4 files (635 lines)
- Generated: 5 shell scripts (994 lines)
  - run-contract-tests.sh (297 lines)
  - syntax-validation.sh (226 lines)
  - snapshot-test.sh (128 lines)
  - test-pipeline.sh (271 lines)
  - test-pipeline-fast.sh (82 lines)

**Phase 3: Unit Test Generators**
- Generators: 2 files enhanced (1,255 lines)
- Generated: 2 test files (1,207 lines, 83 tests)
  - TypeScript: index.test.ts (610 lines, 38 tests)
  - Python: test_unit.py (597 lines, 45 tests)

**Phase 4: Integration Test Specs**
- Specs: 1 file (157 lines)
- Generator: 1 file (140 lines)
- Generated: integration.test.ts (147 lines, 9 tests)

**Phase 5: Cross-Language Validator**
- Specs: 1 file (141 lines)
- Generator: 1 file (305 lines)
- Generated: run-crosslang-tests.py (505 lines, 9 parity tests)

**Phase 6: Regression Validator**
- Specs: 1 file (103 lines)
- Generator: 1 file (243 lines)
- Generated: detect-breaking-changes.sh (243 lines)

### Total Impact

**Nickel Specifications**: 11 files, ~1,600 lines
**Generators**: 9 files, ~3,000 lines
**Generated Test Code**: 13 files, ~4,790 lines
**Manual Test Code Eliminated**: 1,554 lines

**Zero-Drift Guarantee**: All test infrastructure regenerates from single source of truth

### Test Pyramid Coverage

- **Layer 1 (L1-contracts)**: ✅ Contract validation (< 5s)
- **Layer 2 (L2-unit)**: ✅ Unit tests (< 30s)
- **Layer 3 (L3-integration)**: ✅ Integration tests (< 2m)
- **Layer 4a (L4-crosslang)**: ✅ Cross-language parity (< 5m)
- **Layer 4b (L4-regression)**: ✅ Breaking change detection (< 5m)

**Result**: 100% Nickel-first test infrastructure across all pyramid layers

---

## Test Automation Strategy

### Comprehensive Automation Philosophy

**Core Principle**: All tests run automatically with intelligent environment variable gating. No manual intervention or interactive prompts required.

### Test Execution Matrix

```
┌──────────────────────────────────────────────────────────────────────────┐
│ Test Pyramid Automation Matrix                                          │
├─────────────────────┬─────────────────────┬───────────────────────────────┤
│ Layer               │ Environment Vars    │ Execution Behavior            │
├─────────────────────┼─────────────────────┼───────────────────────────────┤
│ L1: Contracts       │ None                │ ✅ Always runs automatically  │
│ L2: Unit            │ None                │ ✅ Always runs automatically  │
│ L3: Integration     │ None (mock server)  │ ✅ Always runs automatically  │
│ L4a: Cross-Lang     │ None                │ ✅ Always runs automatically  │
│ L4b: Regression     │ None (git history)  │ ✅ Always runs automatically  │
│ L5a: E2E (read)     │ CIRCULAR_TEST_      │ ✅ Runs if vars present,      │
│                     │ ADDRESS             │    skips gracefully if missing│
│ L5b: Manual (write) │ CIRCULAR_ALLOW_     │ ✅ Runs ONLY if explicitly    │
│                     │ WRITE_TESTS=1       │    enabled (safety first)     │
└─────────────────────┴─────────────────────┴───────────────────────────────┘
```

### Layer-by-Layer Execution Details

#### Layer 1: Contract Validation (L1-contracts)
**Execution**: Always runs automatically, no dependencies
**Speed**: < 5 seconds
**Command**: `just test-contracts` or `./dist/tests/run-contract-tests.sh`
**Environment Variables**: None required
**CI/CD**: Runs on every commit (pre-commit hook)

#### Layer 2: Unit Tests (L2-unit)
**Execution**: Always runs automatically, no dependencies
**Speed**: < 30 seconds
**Commands**:
- TypeScript: `cd dist/circular-ts && npm test`
- Python: `cd dist/circular-py && pytest tests/test_unit.py`
- All: `just test-unit`
**Environment Variables**: None required
**CI/CD**: Runs on every push to development/main

#### Layer 3: Integration Tests (L3-integration)
**Execution**: Always runs automatically with generated mock server
**Speed**: < 2 minutes
**Command**: `just test-integration`
**Environment Variables**: None (uses generated mock server)
**CI/CD**: Runs on every pull request

#### Layer 4: Cross-Language & Regression (L4-crosslang, L4-regression)
**Execution**: Always runs automatically
**Speed**: < 5 minutes
**Commands**:
- Cross-language: `./dist/tests/run-crosslang-tests.py`
- Regression: `./dist/tests/detect-breaking-changes.sh`
- All: `just test-cross-lang`
**Environment Variables**: None required
**CI/CD**: Runs before merge to main

#### Layer 5a: E2E Tests (L5-e2e) - Read-Only Operations
**Execution**: Runs automatically IF environment variables are present, **skips gracefully** if missing
**Speed**: Variable (depends on real NAG response time)
**Commands**:
- TypeScript: `just test-ts-e2e` or `cd dist/circular-ts && npm run test:e2e`
- Python: `just test-py-e2e` or `cd dist/circular-py && pytest tests/test_e2e.py -v -m e2e`
- All: `just test-e2e`

**Environment Variables** (Read-Only Tests):
```bash
# Required for read-only E2E tests
export CIRCULAR_TEST_ADDRESS="0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310"

# Optional
export CIRCULAR_NAG_URL="https://nag.circularlabs.io/NAG.php?cep="  # default
export CIRCULAR_TEST_BLOCKCHAIN="0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5ad72b2"  # SandBox
export CIRCULAR_API_KEY="..."  # if using authenticated NAG
export CIRCULAR_E2E_TIMEOUT="30000"  # timeout in milliseconds
```

**Graceful Skip Behavior**:
- If `CIRCULAR_TEST_ADDRESS` is NOT set: Tests skip gracefully with informative message
- TypeScript: Uses `test.skip()` and exits with code 0
- Python: Uses `pytest.skip(allow_module_level=True)`
- No errors, no failures, just clear skip message

**Implementation**:
- TypeScript generator: `generators/typescript/tests/typescript-e2e-tests.ncl:226-244`
- Python generator: `generators/python/tests/python-e2e-tests.ncl:259-277`

**CI/CD**: Runs on scheduled nightly builds (if env vars configured in CI secrets)

#### Layer 5b: Manual Write Tests (L5-manual) - Blockchain Write Operations
**Execution**: Runs ONLY if explicitly enabled via `CIRCULAR_ALLOW_WRITE_TESTS=1` environment variable
**Speed**: Variable (depends on blockchain confirmation time)
**Command**: `just test-manual-write` or `python3 dist/tests/manual/manual-test-registerWallet.py`

**Environment Variables** (Write Operation Tests):
```bash
# Safety flag - REQUIRED to enable write tests
export CIRCULAR_ALLOW_WRITE_TESTS=1

# Credentials - REQUIRED for signing transactions
export CIRCULAR_PRIVATE_KEY="0f55c0c43496a9c3e1813180bec90e610769e15354771aebe7e28e83b3f89e8a"
export CIRCULAR_PUBLIC_KEY="04..."  # derived from private key

# Blockchain - REQUIRED (whitelisted to SandBox only)
export CIRCULAR_TEST_BLOCKCHAIN="0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5ad72b2"

# Optional
export CIRCULAR_NAG_URL="https://nag.circularlabs.io/NAG.php?cep="
```

**Safety Features**:
1. **Explicit Enable Flag**: Must set `CIRCULAR_ALLOW_WRITE_TESTS=1` (disabled by default)
2. **Blockchain Whitelist**: Only SandBox blockchain allowed (0x8a20baa...)
3. **No Interactive Prompts**: Fully automated (no `input()` calls)
4. **Clear Error Messages**: If disabled, shows exactly how to enable

**Implementation**:
- Spec: `tests/L5-manual/manual-tests.test.ncl:42-48`
- Generator: `generators/python/tests/python-manual-tests.ncl:87-100`

**CI/CD**: NOT run in CI (too risky for automated pipelines)

### Running Tests in Different Contexts

#### Local Development (Fast Feedback Loop)
```bash
# Quick validation (< 5s)
just validate

# Unit tests only (< 30s)
just test-unit

# Pre-commit (< 2m)
just test
```

#### Pre-Push (Comprehensive but Fast)
```bash
# Run full pyramid without E2E/manual (< 5m)
just test-pyramid
```

#### Pre-Release (Complete Validation)
```bash
# Run everything including E2E tests
export CIRCULAR_TEST_ADDRESS="0x..."
just test-pyramid

# Optionally test write operations (SandBox only!)
export CIRCULAR_ALLOW_WRITE_TESTS=1
export CIRCULAR_PRIVATE_KEY="..."
export CIRCULAR_PUBLIC_KEY="..."
just test-manual-write
```

#### CI/CD Pipeline (Automated)
```yaml
# .github/workflows/test.yml
- name: Run L1-L4 tests (always)
  run: |
    just test-contracts
    just test-unit
    just test-integration
    just test-cross-lang

- name: Run E2E tests (conditional on secrets)
  if: secrets.CIRCULAR_TEST_ADDRESS != ''
  env:
    CIRCULAR_TEST_ADDRESS: ${{ secrets.CIRCULAR_TEST_ADDRESS }}
  run: just test-e2e
```

### Test Execution Flowchart

```
┌─────────────────────────────────────────────────┐
│ User runs: just test-e2e                        │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Check: CIRCULAR_TEST_ADDRESS set?               │
└────────┬────────────────────────────────┬───────┘
         │ YES                            │ NO
         ▼                                ▼
┌─────────────────────────┐  ┌──────────────────────────┐
│ Run E2E tests           │  │ Print skip message:      │
│ - checkWallet           │  │ "⏭️  Skipping E2E tests" │
│ - getWallet             │  │ "Set CIRCULAR_TEST_      │
│ - getWalletBalance      │  │  ADDRESS=0x..."          │
│ - getBlockchains        │  │                          │
│ - ...                   │  │ Exit code: 0 (success)   │
└─────────────────────────┘  └──────────────────────────┘
```

```
┌─────────────────────────────────────────────────┐
│ User runs: just test-manual-write               │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Check: CIRCULAR_ALLOW_WRITE_TESTS == 1?         │
└────────┬────────────────────────────────┬───────┘
         │ YES                            │ NO
         ▼                                ▼
┌─────────────────────────┐  ┌──────────────────────────┐
│ Check: Blockchain       │  │ Print error message:     │
│ in whitelist?           │  │ "❌ Write tests disabled"│
└────┬────────────────────┘  │ "To enable:              │
     │ YES                   │  export CIRCULAR_ALLOW_  │
     ▼                       │  WRITE_TESTS=1"          │
┌─────────────────────────┐  │                          │
│ Run write tests:        │  │ Exit code: 1 (error)     │
│ - registerWallet        │  └──────────────────────────┘
│ - Verify with           │
│   checkWallet           │
│ - Verify with           │
│   getWallet             │
└─────────────────────────┘
```

### Key Design Decisions

1. **No Interactive Prompts**: All tests use environment variables, never `input()` or prompts
   - **Why**: Breaks CI/CD automation
   - **Example Violation**: `response = input("Continue? [y/N]:")` ❌
   - **Correct Approach**: `if os.getenv('CIRCULAR_ALLOW_WRITE_TESTS') == '1':` ✅

2. **Graceful Skipping**: E2E tests skip gracefully when env vars missing, don't fail
   - **Why**: Allows local development without live blockchain access
   - **Implementation**: TypeScript uses `test.skip()`, Python uses `pytest.skip(allow_module_level=True)`

3. **Explicit Enable for Write Operations**: Write tests require explicit flag
   - **Why**: Safety first - prevents accidental blockchain writes
   - **Implementation**: `CIRCULAR_ALLOW_WRITE_TESTS=1` must be set

4. **Blockchain Whitelist**: Write tests only allow SandBox blockchain
   - **Why**: Prevent accidental writes to production blockchain
   - **Implementation**: Hardcoded whitelist in test spec

5. **Zero Configuration for L1-L4**: First 4 layers require no setup
   - **Why**: Fast feedback loop for developers
   - **Result**: Can run `just test` immediately after clone

## Running Tests

### Quick Reference Table

| Command                  | Layers    | Speed  | Env Vars Required | Use Case                          |
|--------------------------|-----------|--------|-------------------|-----------------------------------|
| `just validate`          | L1        | < 5s   | None              | Quick type checking               |
| `just test-contracts`    | L1        | < 5s   | None              | Contract validation only          |
| `just test-unit`         | L2        | < 30s  | None              | Unit tests only                   |
| `just test-integration`  | L3        | < 2m   | None (mock)       | Integration tests only            |
| `just test-cross-lang`   | L4        | < 5m   | None              | Cross-language & regression       |
| `just test`              | L1-L2     | < 30s  | None              | Pre-commit checks                 |
| `just test-pyramid`      | L1-L5     | < 10m  | None (L1-L4)      | Complete pyramid (E2E conditional)|
| `just test-e2e`          | L5a       | Varies | Optional          | E2E tests (skips if no env vars)  |
| `just test-manual-write` | L5b       | Varies | **Required**      | Write operations (SandBox only)   |

### Individual Test Layers
```bash
# Layer 1: Contract validation (fastest)
just test-contracts
# Or manually:
./dist/tests/run-contract-tests.sh

# Layer 2: Unit tests
just test-unit
# Or per language:
just test-ts-unit        # TypeScript only
just test-py-unit        # Python only

# Layer 3: Integration tests (requires mock server)
just test-integration

# Layer 4: Cross-language & regression
just test-cross-lang

# Layer 5a: E2E tests (gracefully skips if env vars missing)
just test-e2e
# Or per language:
just test-ts-e2e         # TypeScript only
just test-py-e2e         # Python only

# Layer 5b: Manual write tests (requires explicit enable)
just test-manual-write
```

### Development Workflow
```bash
# Quick validation (< 5 seconds)
just validate

# Fast feedback loop (< 30 seconds)
just test-unit

# Pre-commit checks (< 2 minutes)
just test

# Pre-push validation (< 10 minutes)
just test-pyramid

# E2E testing with live blockchain (conditional)
export CIRCULAR_TEST_ADDRESS="0x..."
just test-e2e

# Write operation testing (requires explicit enable, SandBox only!)
export CIRCULAR_ALLOW_WRITE_TESTS=1
export CIRCULAR_PRIVATE_KEY="..."
export CIRCULAR_PUBLIC_KEY="..."
just test-manual-write
```

## Creating New Tests

### 1. Contract Tests (Layer 1)
```nickel
# tests/L1-contracts/endpoints/my-feature.test.ncl
let types = import "../../../src/schemas/types.ncl" in
let config = import "../../../src/config.ncl" in

{
  test_name = "MyFeature Endpoint Validation",
  valid_requests = {
    test_case_name = {
      request | {
        Field1 | types.SomeType,
        Field2 | String,
      } = {
        Field1 = ...,
        Field2 = ...,
      },
      expected = "valid",
    },
  },
}
```

### 2. Unit Tests (Layer 2)
```nickel
# tests/L2-unit/my-helpers.test.ncl
{
  helper_category = {
    my_function = {
      description = "What the function does",
      tests = [
        { name = "test case 1", input = ..., expected = ... },
        { name = "test case 2", input = ..., expected = ... },
      ],
    },
  },
}
```

### 3. Integration Tests (Layer 3)
```nickel
# tests/L3-integration/my-flow.test.ncl
{
  scenario = "Description of flow",
  steps = [
    { endpoint = "...", request = {...}, expected_response = {...} },
  ],
}
```

## Common Issues

### Manual Test Code Exists
**Problem**: Found `.py`, `.sh`, or `.js` files in `tests/`
**Solution**: These should be `.test.ncl` specs that generate the actual test code

### Mock Server Out of Sync
**Problem**: API changed but mock server responses didn't update
**Solution**: This shouldn't happen with generated mock server! Regenerate: `just generate`

### Test Drift Between Languages
**Problem**: TypeScript tests pass but Python tests fail
**Solution**: Use cross-language validator (Layer 4) to catch this early

### Slow Test Feedback
**Problem**: Running full test suite takes too long
**Solution**: Use test pyramid - run Layer 1 (< 5s) frequently, Layer 4 (< 5m) only pre-commit

## Cross-References

- API definitions used for mock generation: `src/CLAUDE.md`
- Generator patterns: `generators/CLAUDE.md`
- Test generator specifics: `generators/shared/CLAUDE.md`
- TypeScript unit test generation: `generators/typescript/CLAUDE.md`
- Python unit test generation: `generators/python/CLAUDE.md`
