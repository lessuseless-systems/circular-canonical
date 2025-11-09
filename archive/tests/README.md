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

## Sprint 3 Progress

**Eliminated**: 201 lines of manual integration test code
**Replaced With**: 345 lines of Nickel generator → 329 lines of generated tests
**Benefit**: Zero drift, automatic updates when API changes

See `CANONICAL_TODOs.md` Sprint 3 for complete transformation checklist.
