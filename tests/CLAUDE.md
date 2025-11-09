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
**Run**: `./tests/infrastructure/e2e/test-pipeline.sh full`
**Speed**: < 5 minutes
**Status**: Deferred to Phase 5 (cross-lang) and Phase 6 (regression)

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
- ✅ `dist/typescript/tests/index.test.ts` (610 lines, 38 tests)
- ✅ `dist/python/tests/test_unit.py` (597 lines, 45 tests)

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

### Phase 5: Cross-Language Validator
Generate from `tests/cross-lang/*.test.ncl`.

### Phase 6: Regression Test Generator
Generate from `tests/regression/*.test.ncl`.

## Running Tests

### Individual Test Layers
```bash
# Layer 1: Contract validation (fastest)
./dist/tests/run-contract-tests.sh

# Layer 2a: Syntax validation
./dist/tests/syntax-validation.sh

# Layer 2b: Snapshot tests
./dist/tests/snapshot-test.sh

# Layer 2c: Unit tests
just test-unit

# Layer 3: Integration tests (requires mock server)
just test-integration

# Layer 4: Full suite (slow)
just test-all
```

### Development Workflow
```bash
# Quick validation (< 5 seconds)
just validate

# Fast feedback loop (< 30 seconds)
just test-unit

# Pre-commit checks (< 2 minutes)
just test

# Full suite before PR (< 5 minutes)
just test-all
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
