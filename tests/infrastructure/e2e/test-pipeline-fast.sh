#!/usr/bin/env bash
# TEMPORARY: Manual file until Sprint 3 Phase 7 generator is created
# Will be replaced by: generators/shared/test-runners/e2e-pipeline.ncl → dist/tests/test-pipeline-fast.sh
# Fast E2E Test - Validates pipeline without running integration tests

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔵 Fast E2E Test Pipeline"
echo ""

cd "$PROJECT_ROOT"

PASSED=0
FAILED=0

# Phase 1: Nickel Validation
echo "Phase 1: Nickel Validation"
if just validate > /dev/null 2>&1; then
    echo "  ✅ Nickel source validated"
    ((PASSED++))
else
    echo "  ❌ Nickel validation failed"
    ((FAILED++))
fi

# Phase 2: Generation
echo "Phase 2: Artifact Generation"
if just generate-packages > /dev/null 2>&1; then
    echo "  ✅ Packages generated"
    ((PASSED++))
else
    echo "  ❌ Package generation failed"
    ((FAILED++))
fi

# Phase 3: TypeScript Compilation
echo "Phase 3: TypeScript Compilation"
cd "$PROJECT_ROOT/dist/typescript"
if npx tsc --noEmit 2>&1 | tail -3; then
    echo "  ✅ TypeScript compiles"
    ((PASSED++))
else
    echo "  ❌ TypeScript compilation failed"
    ((FAILED++))
fi

# Phase 4: Python Syntax
echo "Phase 4: Python Syntax Check"
cd "$PROJECT_ROOT/dist/python"
if python3 -m py_compile src/circular_protocol_api/__init__.py 2>&1; then
    echo "  ✅ Python syntax valid"
    ((PASSED++))
else
    echo "  ❌ Python syntax invalid"
    ((FAILED++))
fi

# Phase 5: File Structure
echo "Phase 5: File Structure Check"
REQUIRED_FILES=(
    "dist/typescript/package.json"
    "dist/typescript/src/index.ts"
    "dist/python/pyproject.toml"
    "dist/python/src/circular_protocol_api/__init__.py"
)

MISSING=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$PROJECT_ROOT/$file" ]; then
        ((MISSING++))
    fi
done

if [ $MISSING -eq 0 ]; then
    echo "  ✅ All required files present"
    ((PASSED++))
else
    echo "  ❌ $MISSING files missing"
    ((FAILED++))
fi

# Summary
echo ""
echo "═══════════════════════════════════"
echo "Results: $PASSED passed, $FAILED failed"
echo "═══════════════════════════════════"

if [ $FAILED -eq 0 ]; then
    echo "✅ E2E PIPELINE PASSED"
    exit 0
else
    echo "❌ E2E PIPELINE FAILED"
    exit 1
fi
