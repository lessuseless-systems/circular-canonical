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

## Directory Structure (Sprint 3 Target)

```
tests/
├── CLAUDE.md                    # This file
├── contracts/                   # Contract validation specs (Layer 1)
│   ├── types.test.ncl          # Primitive type contracts
│   └── endpoints/              # Endpoint request/response contracts
│       ├── checkWallet.test.ncl
│       ├── getWallet.test.ncl
│       └── ...
├── unit/                        # Unit test specs (Layer 2)
│   ├── helpers.test.ncl
│   └── validators.test.ncl
├── integration/                 # Integration test specs (Layer 3)
│   ├── wallet-flow.test.ncl
│   └── ...
├── e2e/                        # E2E test specs (Layer 4)
│   └── complete-workflow.test.ncl
├── cross-lang/                 # Cross-language validator specs
│   └── sdk-parity.test.ncl
├── regression/                 # Regression test specs
│   └── version-compare.test.ncl
└── generators/                 # Test infrastructure generators
    ├── mock-server.ncl         # Generates mock server from API defs
    ├── contract-runner.ncl     # Generates contract test runner
    ├── syntax-validator.ncl    # Generates syntax validation scripts
    └── e2e-pipeline.ncl        # Generates E2E test orchestration
```

**Generated artifacts** (in `dist/tests/`, gitignored):
```
dist/tests/
├── mock-server.py              # Generated HTTP mock server
├── run-contract-tests.sh       # Generated contract test runner
├── syntax-validation.sh        # Generated syntax validator
├── unit/                       # Generated unit tests
│   ├── test_helpers.py
│   ├── test_helpers.test.ts
│   └── ...
└── e2e-pipeline.sh            # Generated E2E orchestrator
```

## Test Pyramid (Four Layers)

### Layer 1: Contract Validation (Fastest)
**Location**: `tests/contracts/*.test.ncl`
**Purpose**: Validate Nickel contracts and type definitions
**Run**: `./dist/tests/run-contract-tests.sh` (generated)
**Speed**: < 5 seconds

```nickel
# tests/contracts/wallet.test.ncl
let api = import "../../src/api/wallet.ncl" in

{
  test_check_wallet_valid = {
    input = { Address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb" },
    expected = true,
    # Contract validation happens at export time
  },
}
```

### Layer 2: Unit Tests (Fast)
**Location**: `tests/unit/*.test.ncl`
**Purpose**: Test individual helper functions, validators
**Run**: `npm test` (TypeScript), `pytest` (Python)
**Speed**: < 30 seconds
**Generated**: Unit test files created from `.test.ncl` specs

```nickel
# tests/unit/helpers.test.ncl
{
  function = "validateAddress",
  tests = [
    {
      name = "accepts valid hex address",
      input = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      expected = true,
    },
    {
      name = "rejects invalid format",
      input = "invalid",
      expected = false,
    },
  ],
}
```

### Layer 3: Integration Tests (Medium)
**Location**: `tests/integration/*.test.ncl`
**Purpose**: Test API flows using generated mock server
**Run**: `./dist/tests/e2e-pipeline.sh integration`
**Speed**: < 2 minutes
**Requires**: Generated mock server running

```nickel
# tests/integration/wallet-flow.test.ncl
{
  scenario = "Check wallet, register if not exists",
  steps = [
    {
      endpoint = "checkWallet",
      request = { Address = "0xNEW..." },
      expected_response = { Result = 200, Response = { exists = false } },
    },
    {
      endpoint = "registerWallet",
      request = { Address = "0xNEW...", Blockchain = "ethereum" },
      expected_response = { Result = 200, Response = { success = true } },
    },
  ],
}
```

### Layer 4: Cross-Language & Regression (Slow)
**Location**: `tests/cross-lang/*.test.ncl`, `tests/regression/*.test.ncl`
**Purpose**: Verify SDK parity across languages, detect breaking changes
**Run**: `./dist/tests/e2e-pipeline.sh full`
**Speed**: < 5 minutes

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

### Phase 2: Test Runner Generators
Create `generators/shared/test-runners/`:
- `contract-runner.ncl` → `dist/tests/run-contract-tests.sh`
- `syntax-validator.ncl` → `dist/tests/syntax-validation.sh`
- `e2e-pipeline.ncl` → `dist/tests/e2e-pipeline.sh`

### Phase 3: Unit Test Generators
Enhance existing:
- `generators/typescript/tests/typescript-unit-tests.ncl`
- `generators/python/tests/python-unit-tests.ncl`

Generate tests for 15 helper functions across both languages.

### Phase 4: Integration Test Migration
Convert manual `tests/integration/*.py` to `.ncl` specs.

### Phase 5: Cross-Language Validator
Generate from `tests/cross-lang/*.test.ncl`.

### Phase 6: Regression Test Generator
Generate from `tests/regression/*.test.ncl`.

## Running Tests

### Individual Test Layers
```bash
# Layer 1: Contract validation (fastest)
./dist/tests/run-contract-tests.sh

# Layer 2: Unit tests
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

### 1. Contract Tests
```nickel
# tests/contracts/my-feature.test.ncl
let api = import "../../src/api/my-feature.ncl" in

{
  test_case_name = {
    input = { ... },
    expected = { ... },
  },
}
```

### 2. Unit Tests
```nickel
# tests/unit/my-function.test.ncl
{
  function = "myFunction",
  tests = [
    { name = "test case 1", input = ..., expected = ... },
    { name = "test case 2", input = ..., expected = ... },
  ],
}
```

### 3. Integration Tests
```nickel
# tests/integration/my-flow.test.ncl
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
