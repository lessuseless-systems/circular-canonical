# tests/ Directory Cleanup Analysis

**Status**: tests/ directory violates Sprint 3 Nickel-First philosophy
**Impact**: 15 manual files (1,554 lines) duplicate generated artifacts
**Goal**: tests/ should contain ONLY .ncl specification files

---

## Core Problem

Per `tests/CLAUDE.md`:
> **Core Principle**: `tests/` should contain ONLY `.ncl` files. All test infrastructure (mock servers, test runners, validators) must be **generated** from Nickel definitions.

**Current Reality**: tests/ contains mix of:
- ✅ 29 .ncl specification files (good)
- ❌ 15 manual Python/shell/TypeScript files (1,554 lines - violates principle)
- ❌ node_modules pollution (hundreds of packages)
- ❌ Compiled JavaScript artifacts (.js files)

---

## Files Analysis

### Category 1: Manual Duplicates of Generated Files (ARCHIVE IMMEDIATELY)

| Manual File | Size | Generated Version | Status |
|------------|------|-------------------|--------|
| `tests/mock-server/server.py` | 13KB | `dist/tests/mock-server.py` (11KB) | ❌ DELETE - old manual version |
| `tests/run-contract-tests.sh` | 1.5KB | `dist/tests/run-contract-tests.sh` (8.8KB) | ❌ DELETE - replaced by generator |

**Action**: Move to `archive/tests/` with README explaining replacement

### Category 2: Integration Test Manual Code (SHOULD BE GENERATED)

| File | Size | Issue |
|------|------|-------|
| `tests/integration/typescript-integration.test.ts` | 7.2KB | Manual TypeScript - should be .ncl spec |
| `tests/integration/test-real-api.ts` | 5.0KB | Manual TypeScript - should be .ncl spec |
| `tests/integration/test-helpers-simple.ts` | 4.7KB | Manual TypeScript - should be .ncl spec |
| `tests/integration/run-with-mock-server.sh` | 1.3KB | Manual shell script - should be generated |

**Status**: Sprint 3 Phase 4 marked complete, but manual files still exist
**Action**:
- Option A: Archive (already have generated integration tests)
- Option B: Convert to .ncl specs and regenerate

### Category 3: Compiled JavaScript Artifacts (GITIGNORE)

| File | Size | Issue |
|------|------|-------|
| `tests/integration/dist/typescript/src/index.js` | 29KB | Compiled output - should be gitignored |
| `tests/integration/tests/integration/test-real-api.js` | 9.9KB | Compiled output - should be gitignored |
| `tests/integration/tests/integration/test-helpers-simple.js` | 8.7KB | Compiled output - should be gitignored |

**Action**: Delete + add to tests/.gitignore

### Category 4: Phase 2/5/6 Generators (KEEP - NOT YET GENERATED)

| File | Size | Sprint Phase | Status |
|------|------|--------------|--------|
| `tests/generators/syntax-validation.sh` | 6.6KB | Phase 2 | ⏭️ Deferred - manual until generator created |
| `tests/generators/snapshot-test.sh` | 3.1KB | Phase 2 | ⏭️ Deferred - manual until generator created |
| `tests/cross-lang/run-tests.py` | 1.8KB | Phase 5 | ⏭️ Deferred - manual until generator created |
| `tests/regression/detect-breaking-changes.sh` | 3.3KB | Phase 6 | ⏭️ Deferred - manual until generator created |

**Action**: Keep for now, mark clearly as "TEMPORARY - pending generator"

### Category 5: E2E Orchestration (KEEP - PHASE 7 DEFERRED)

| File | Size | Sprint Phase | Status |
|------|------|--------------|--------|
| `tests/e2e/test-pipeline.sh` | 8.3KB | Phase 7 | ⏭️ Deferred - manual orchestration |
| `tests/e2e/test-pipeline-fast.sh` | 2.3KB | Phase 7 | ⏭️ Deferred - fast variant |

**Action**: Keep for now

### Category 6: node_modules Pollution (DELETE + GITIGNORE)

**Location**: `tests/integration/node_modules/`
**Contains**: Hundreds of npm packages (Jest, Babel, etc.)
**Issue**: Should be in dist/tests/node_modules/ (where generated tests run)

**Action**:
1. Delete tests/integration/node_modules/
2. Add to tests/.gitignore
3. Use dist/tests/ for all test execution

---

## Missing Infrastructure

### No tests/.gitignore
**Problem**: No .gitignore in tests/ allows pollution
**Solution**: Create tests/.gitignore:

```gitignore
# Compiled artifacts
*.js
*.pyc
__pycache__/
*.py[cod]

# Dependencies
node_modules/
dist/
build/

# Test outputs
.coverage
coverage/
.pytest_cache/
.jest/

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
```

---

## Recommended Cleanup Plan

### Immediate Actions (Safe to do now)

1. **Archive manual duplicates**:
   ```bash
   mkdir -p archive/tests/mock-server
   mkdir -p archive/tests/scripts
   mv tests/mock-server/server.py archive/tests/mock-server/
   mv tests/run-contract-tests.sh archive/tests/scripts/
   ```

2. **Delete compiled artifacts**:
   ```bash
   rm -rf tests/integration/dist/
   rm -rf tests/integration/tests/integration/*.js
   ```

3. **Delete node_modules pollution**:
   ```bash
   rm -rf tests/integration/node_modules/
   ```

4. **Create tests/.gitignore**:
   ```bash
   cat > tests/.gitignore << 'EOF'
   # Compiled artifacts
   *.js
   *.pyc
   __pycache__/
   *.py[cod]

   # Dependencies
   node_modules/
   dist/
   build/

   # Test outputs
   .coverage
   coverage/
   .pytest_cache/
   .jest/
   EOF
   ```

5. **Archive manual integration tests**:
   ```bash
   mkdir -p archive/tests/integration
   mv tests/integration/*.ts archive/tests/integration/
   mv tests/integration/*.sh archive/tests/integration/
   ```

6. **Update archive/tests/README.md**:
   - Document all archived files
   - Explain replacement with generated versions
   - Reference Sprint 3 transformation

### Deferred Actions (Phase 2/5/6/7)

Mark these files as temporary:
```bash
# Add header to each file explaining it's temporary
echo "# TEMPORARY: Manual file until Phase N generator is created" | \
  cat - tests/generators/syntax-validation.sh > temp && mv temp tests/generators/syntax-validation.sh
```

---

## Success Criteria (Post-Cleanup)

```bash
# tests/ should have:
find tests/ -type f -name "*.ncl" | wc -l
# Expected: ~29 files

# tests/ should NOT have:
find tests/ -type f \( -name "*.py" -o -name "*.ts" -o -name "*.js" \) ! -name "*.test.ncl" | wc -l
# Expected: 0 (except deferred Phase 2/5/6/7 files)

# No pollution:
find tests/ -name "node_modules" -o -name "__pycache__" -o -name "dist"
# Expected: empty
```

---

## Visual Comparison

### Current State (Shit Show)
```
tests/
├── *.ncl (29 files) ✅
├── mock-server/server.py (13KB) ❌ duplicate
├── run-contract-tests.sh ❌ duplicate
├── integration/
│   ├── *.ts (3 files) ❌ manual code
│   ├── *.js (3 files) ❌ compiled
│   ├── dist/ ❌ pollution
│   └── node_modules/ ❌ pollution
├── generators/*.sh (2 files) ⚠️ temporary
├── cross-lang/*.py ⚠️ temporary
├── regression/*.sh ⚠️ temporary
└── e2e/*.sh (2 files) ⚠️ temporary
```

### Target State (Nickel-First)
```
tests/
├── contracts/*.test.ncl ✅
├── unit/*.test.ncl ✅
├── integration/*.test.ncl ✅
├── cross-lang/*.test.ncl ✅
├── regression/*.test.ncl ✅
├── e2e/*.test.ncl ✅
├── generators/*.sh (⚠️ until Phase 2/5/6 complete)
└── .gitignore ✅

dist/tests/ (generated)
├── mock-server.py ✅
├── run-contract-tests.sh ✅
├── *.test.ts ✅
├── test_*.py ✅
└── node_modules/ ✅ (ok here)
```

---

## Impact Analysis

**Lines of code removed**: ~1,554 lines of manual Python/shell/TypeScript
**Lines of code added**: 0 (replaced by generators)
**Maintenance burden**: -100% for removed files
**Drift risk**: Eliminated for mock server, contract runner
**Test reliability**: Improved (zero-drift guarantee)

---

## References

- Sprint 3 status: `CANONICAL_TODOs.md` lines 1050-1150
- Test philosophy: `tests/CLAUDE.md`
- Generated artifacts: `dist/tests/`
- Previous archival: `archive/tests/README.md` (from Phase 4)
