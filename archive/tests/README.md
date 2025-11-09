# Archived Test Code

This directory contains manual test code that has been replaced by Nickel-generated test infrastructure as part of Sprint 3: Test Infrastructure "Nickel-First" Transformation.

## Why Archived?

**Principle**: `tests/` should contain ONLY `.ncl` files. All test infrastructure must be **generated** from Nickel definitions to prevent drift and maintain single source of truth.

### The Problem with Manual Test Code

Manual test code duplicates API definitions:
- API endpoints defined in `src/api/*.ncl`
- Mock server responses manually coded in `tests/mock-server/server.py`
- Test cases manually written in `tests/integration/*.py`

This creates **drift risk**: When API changes, manual code must be updated separately, leading to:
- Out-of-sync mock responses
- Outdated test expectations
- Inconsistent behavior across SDKs

### The Solution: Nickel-Generated Tests

All test infrastructure is now generated from canonical Nickel definitions:

```
src/api/*.ncl (single source of truth)
    ↓
generators/shared/mock-server.ncl
    ↓
dist/tests/mock-server.py (auto-generated)
```

**Benefits**:
- Zero drift: Mock server responses always match API definitions
- DRY: 24 API endpoints defined once, not twice
- Consistency: All SDKs tested against same definitions
- Maintainability: Update API once, all tests update automatically

## Archived Files

### integration/test-python-real-api.py (201 lines)

**Original Purpose**: Test Python SDK against live Circular Protocol NAG API (https://nag.circularlabs.io)

**Why Archived**:
- Tests depended on external live API (bad for CI/CD)
- Not replaceable by mock server-based integration tests
- Live API testing should be separate E2E suite, not integration tests
- Current focus: Mock server-based integration tests for fast feedback

**Replaced By**:
- Generated integration tests: `dist/tests/test_sdk.py` (329 lines)
- Generated from: `generators/python/tests/python-tests.ncl` (345 lines)
- Tests against: Mock server (http://localhost:8080)

**Notes**:
- Live API testing still valuable for E2E validation
- May be reintroduced as separate E2E test suite in future sprint
- Kept in archive for reference

## When to Restore

Files in this archive should ONLY be restored if:
1. Converting to `.ncl` test specification format
2. Migrating to Nickel-generated test infrastructure
3. Extracting unique test logic not covered by generated tests

**Never restore** manual test code as-is. Always convert to Nickel-first approach.

## Sprint 3 Cleanup (2025-11-09)

### Phase 4: Integration Tests (201 lines archived)

#### integration/test-python-real-api.py (201 lines)
**Archived**: 2025-11-08 (Phase 4)
**Replaced By**: `generators/python/tests/python-tests.ncl` → `dist/tests/test_sdk.py`

### Full Cleanup: Manual Duplicates (1,554 lines archived)

#### mock-server/server.py (13KB / ~410 lines)
**Archived**: 2025-11-09
**Why**: Manual duplicate of generated mock server
**Replaced By**: `generators/shared/mock-server.ncl` → `dist/tests/mock-server.py` (11KB)
**Benefit**: Zero drift - mock responses always match `src/api/*.ncl` definitions

#### scripts/run-contract-tests.sh (~50 lines)
**Archived**: 2025-11-09
**Why**: Manual duplicate of generated test runner
**Replaced By**: `generators/shared/test-runners/contract-runner.ncl` → `dist/tests/run-contract-tests.sh` (8.8KB)
**Benefit**: Test orchestration generated from Nickel specs

#### integration/typescript-integration.test.ts (7.2KB / ~200 lines)
**Archived**: 2025-11-09
**Why**: Manual TypeScript integration tests, duplicates generated tests
**Replaced By**: `generators/typescript/tests/typescript-tests.ncl` → `dist/tests/sdk.test.ts`
**Benefit**: Integration tests generated from same API specs as SDK

#### integration/test-real-api.ts (5.0KB / ~140 lines)
**Archived**: 2025-11-09
**Why**: Manual live API testing, should be E2E suite not integration
**Future**: May be converted to `.ncl` E2E test specs in Sprint 3 Phase 7

#### integration/test-helpers-simple.ts (4.7KB / ~130 lines)
**Archived**: 2025-11-09
**Why**: Manual helper function tests, replaced by generated unit tests
**Replaced By**: `generators/typescript/tests/typescript-unit-tests.ncl` → `dist/tests/sdk.unit.test.ts`

#### integration/run-with-mock-server.sh (~40 lines)
**Archived**: 2025-11-09
**Why**: Manual orchestration script, should be generated
**Future**: Will be replaced by E2E pipeline generator (Phase 7)

### Deleted (Not Archived)

**Compiled Artifacts**:
- `tests/integration/dist/` - Compiled JavaScript (29KB)
- `tests/integration/tests/integration/*.js` - Compiled TypeScript tests (27KB)

**Dependencies Pollution**:
- `tests/integration/node_modules/` - Hundreds of npm packages
- Reason: Should be in `dist/tests/node_modules/` where generated tests run

**Total Removed**: ~1,554 lines of manual code + 56KB compiled artifacts

## Sprint 3 Progress Summary

**Total Manual Code Eliminated**: 1,554 lines
**Replaced With**: ~1,200 lines of Nickel generators → auto-generated test infrastructure
**Lines of Code Saved**: 354 lines (plus zero-drift guarantee)
**Maintenance Burden**: -100% for removed files
**Drift Risk**: Eliminated

**Created**: `tests/.gitignore` to prevent future pollution

See `CANONICAL_TODOs.md` Sprint 3 for complete transformation checklist.
