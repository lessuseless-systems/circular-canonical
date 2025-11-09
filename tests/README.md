# Test Infrastructure

This directory contains **Nickel test specifications only**. All test infrastructure (mock servers, test runners, validators) is **generated** from these specifications.

## Nickel-First Philosophy

**Critical Principle**: `tests/` should contain ONLY `.ncl` files. All test infrastructure must be generated from Nickel definitions to prevent drift and maintain single source of truth.

### Why Nickel-First?

**Problem**: Manual test code duplicates API definitions and creates drift risk.
- API endpoints defined in `src/api/*.ncl`
- Mock server responses manually coded → gets out of sync
- Test cases manually written → drift from API spec

**Solution**: Generate all test infrastructure from canonical Nickel definitions:

```
src/api/*.ncl (single source of truth)
    ↓
generators/shared/mock-server.ncl
    ↓
dist/tests/mock-server.py (auto-generated)
```

**Benefits**:
- **Zero Drift**: Mock responses always match API definitions
- **DRY**: 24 endpoints defined once, not twice
- **Consistency**: All SDKs tested against same definitions
- **Maintainability**: Update API once, all tests update automatically

## Directory Structure

```
tests/
├── README.md                    # This file
├── contracts/                   # Contract validation specs (Layer 1)
│   ├── types.test.ncl
│   ├── wallet.test.ncl
│   └── ... (future)
├── unit/                        # Unit test specs (Layer 2)
│   └── ... (future)
├── integration/                 # Integration test specs (Layer 3)
│   └── ... (manual test files being migrated)
├── e2e/                        # E2E test specs (Layer 4)
│   └── ... (future)
├── cross-lang/                 # Cross-language validator specs
│   └── run-tests.py (to be migrated)
└── regression/                 # Regression test specs
    └── ... (future)
```

## Generated Test Infrastructure

All generated artifacts are in `dist/tests/` (gitignored):

```
dist/tests/
├── mock-server.py              # HTTP mock server (192 lines)
├── run-contract-tests.sh       # Contract test runner (150 lines)
├── syntax-validation.sh        # Syntax validator (86 lines)
├── sdk.test.ts                 # TypeScript integration tests (381 lines)
├── test_sdk.py                 # Python integration tests (329 lines)
├── sdk.unit.test.ts            # TypeScript unit tests (495 lines)
└── test_sdk_unit.py            # Python unit tests (474 lines)
```

**Total**: ~2,100 lines of test infrastructure generated from ~1,800 lines of Nickel specs.

## Test Pyramid (Four Layers)

### Layer 1: Contract Validation ⚡ Fastest
**Purpose**: Validate Nickel contracts and type definitions
**Location**: `tests/contracts/*.test.ncl`
**Run**: `./dist/tests/run-contract-tests.sh` (generated)
**Speed**: < 5 seconds

Validates at export time - no runtime needed.

### Layer 2: Unit Tests 🔵 Fast
**Purpose**: Test SDK methods in isolation
**Location**: Generated from `generators/*/tests/*-unit-tests.ncl`
**Run**: `just test-sdk-unit`
**Speed**: < 30 seconds
**Server**: None required (mocks HTTP libraries)

Tests request building, response parsing, error handling.

### Layer 3: Integration Tests 🟡 Medium
**Purpose**: Test API flows using generated mock server
**Location**: Generated from `generators/*/tests/*-tests.ncl`
**Run**: `just test-sdk` (requires mock server)
**Speed**: < 2 minutes
**Server**: Mock server on http://localhost:8080

Full HTTP requests to mock server, validates full response structures.

### Layer 4: Cross-Language & Regression 🔴 Slow
**Purpose**: Verify SDK parity, detect breaking changes
**Location**: `tests/cross-lang/*.py` (to be migrated)
**Run**: `python3 tests/cross-lang/run-tests.py`
**Speed**: < 5 minutes

Ensures TypeScript and Python SDKs behave identically.

## Running Tests

```bash
# Quick validation (Layer 1 - contract tests)
./dist/tests/run-contract-tests.sh

# Unit tests (Layer 2 - no server needed)
just test-sdk-unit

# Integration tests (Layer 3 - requires mock server)
just mock-server  # Terminal 1
just test-sdk     # Terminal 2

# Full test suite (all layers)
just test-all
```

## Development Workflow

```bash
# 1. Make changes to API definition
vim src/api/wallet.ncl

# 2. Regenerate all test infrastructure
just generate-all-tests

# 3. Run fast tests (< 5 seconds)
./dist/tests/run-contract-tests.sh

# 4. Run unit tests (< 30 seconds)
just test-sdk-unit

# 5. Run integration tests (< 2 minutes)
just mock-server  # Terminal 1
just test-sdk     # Terminal 2
```

## Sprint 3 Transformation

### Before (Manual Test Code)
- `tests/mock-server/server.py`: 410 lines (manual duplication)
- `tests/integration/test-python-real-api.py`: 201 lines (manual)
- Total: 1,554 lines of manual Python/shell code

### After (Generated from Nickel)
- `generators/shared/mock-server.ncl`: 135 lines → generates 192 lines
- `generators/shared/test-runners/*.ncl`: 223 lines → generates 236 lines
- `generators/*/tests/*.ncl`: 1,745 lines → generates 1,679 lines
- **Total**: ~2,100 lines generated from ~1,800 lines of Nickel

### Benefits
- **Eliminated**: 655 lines of manual test code
- **Zero drift**: Tests can't get out of sync with API
- **Automatic updates**: Add endpoint → all tests include it
- **Type safety**: Nickel contracts validate test specs

## Manual Test Code Archive

Manual test code has been moved to `archive/tests/` for reference:

- `archive/tests/integration/test-python-real-api.py`: Live API test (not suitable for CI/CD)
- `archive/tests/README.md`: Explanation of why code was archived

**Never restore** manual test code as-is. Always convert to Nickel-first approach.

## Creating New Tests

### Contract Tests (Layer 1)
```nickel
# tests/contracts/my-feature.test.ncl
let api = import "../../src/api/my-feature.ncl" in
{
  test_valid_input = {
    input = { Address = "0x742d35..." },
    expected = { Result = 200 },
  },
}
```

### Integration Test Scenarios (Layer 3)
Integration tests are generated from `example_request` and `example_response` fields in `src/api/*.ncl`. To add new test scenarios:

1. Add `example_request`/`example_response` to endpoint definition
2. Run `just generate-tests`
3. Generated tests will include new scenarios

## Common Issues

### Mock Server Out of Sync
**Problem**: API changed but mock responses didn't update
**Solution**: This shouldn't happen with generated mock server! Run: `just generate-mock-server && just mock-server`

### Test Drift Between Languages
**Problem**: TypeScript tests pass but Python tests fail
**Solution**: Use cross-language validator (Layer 4) to catch this early

### Slow Test Feedback
**Problem**: Running full suite takes too long
**Solution**: Use test pyramid - run Layer 1 (< 5s) frequently, Layer 4 (< 5m) only pre-commit

## References

- **Testing Strategy**: `docs/TESTING_STRATEGY.md` - Comprehensive testing philosophy
- **Generator Patterns**: `generators/CLAUDE.md` - How generators work
- **Test Generators**: `generators/shared/CLAUDE.md`, `generators/*/tests/CLAUDE.md`
- **Sprint 3 Plan**: `CANONICAL_TODOs.md` - Test infrastructure transformation checklist
