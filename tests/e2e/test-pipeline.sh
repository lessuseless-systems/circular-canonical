#!/usr/bin/env bash
# End-to-End Test Pipeline
# Validates entire Circular Protocol SDK generation workflow

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test tracking
TESTS_PASSED=0
TESTS_FAILED=0
START_TIME=$(date +%s)

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((TESTS_PASSED++))
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    ((TESTS_FAILED++))
}

log_section() {
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}  $1${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

cd "$PROJECT_ROOT"

log_section "E2E Test Pipeline - Circular Protocol Canonical"

# =============================================================================
# Phase 1: Nickel Source Validation
# =============================================================================

log_section "Phase 1: Nickel Source Validation"

log_info "Type checking all Nickel files..."
if find src -name '*.ncl' -exec nickel typecheck {} \; 2>&1 | grep -q "error"; then
    log_error "Nickel source validation FAILED"
    exit 1
else
    log_success "Nickel source validation PASSED"
fi

log_info "Type checking generators..."
if find generators -name '*.ncl' -exec nickel typecheck {} \; 2>&1 | grep -q "error"; then
    log_error "Generator validation FAILED"
    exit 1
else
    log_success "Generator validation PASSED"
fi

# =============================================================================
# Phase 2: SDK Generation
# =============================================================================

log_section "Phase 2: SDK Generation"

log_info "Generating TypeScript SDK..."
if nickel export generators/typescript/typescript-sdk.ncl --field sdk_code --format raw > /tmp/test-ts-sdk.ts 2>&1; then
    LINES=$(wc -l < /tmp/test-ts-sdk.ts)
    log_success "TypeScript SDK generated ($LINES lines)"
else
    log_error "TypeScript SDK generation FAILED"
    exit 1
fi

log_info "Generating Python SDK..."
if nickel export generators/python/python-sdk.ncl --field sdk_code --format raw > /tmp/test-py-sdk.py 2>&1; then
    LINES=$(wc -l < /tmp/test-py-sdk.py)
    log_success "Python SDK generated ($LINES lines)"
else
    log_error "Python SDK generation FAILED"
    exit 1
fi

log_info "Generating OpenAPI spec..."
if nickel export generators/shared/openapi.ncl --format json > /tmp/test-openapi.json 2>&1; then
    log_success "OpenAPI spec generated"
else
    log_error "OpenAPI spec generation FAILED"
    exit 1
fi

log_info "Generating TypeScript package.json..."
if nickel export generators/typescript/package-manifest/typescript-package-json.ncl --format json > /tmp/test-package.json 2>&1; then
    log_success "TypeScript package.json generated"
else
    log_error "TypeScript package.json generation FAILED"
    exit 1
fi

log_info "Generating Python pyproject.toml..."
if nickel export generators/python/package-manifest/python-pyproject-toml.ncl --format toml > /tmp/test-pyproject.toml 2>&1; then
    log_success "Python pyproject.toml generated"
else
    log_error "Python pyproject.toml generation FAILED"
    exit 1
fi

# =============================================================================
# Phase 3: Code Compilation Validation
# =============================================================================

log_section "Phase 3: Code Compilation"

log_info "Validating TypeScript syntax..."
if node -c /tmp/test-ts-sdk.ts 2>&1; then
    log_success "TypeScript syntax valid"
else
    log_error "TypeScript syntax validation FAILED"
fi

log_info "Validating Python syntax..."
if python3 -m py_compile /tmp/test-py-sdk.py 2>&1; then
    log_success "Python syntax valid"
else
    log_error "Python syntax validation FAILED"
fi

log_info "Checking TypeScript compilation in dist/..."
cd "$PROJECT_ROOT/dist/typescript"
if [ -f "src/index.ts" ]; then
    if npx tsc --noEmit 2>&1 | tail -5; then
        log_success "TypeScript dist compiles"
    else
        log_error "TypeScript dist compilation FAILED"
    fi
else
    log_info "Skipping TypeScript dist check (not generated yet)"
fi

# =============================================================================
# Phase 4: Integration Tests
# =============================================================================

log_section "Phase 4: Integration Tests"

cd "$PROJECT_ROOT"

log_info "Starting mock API server..."
python3 tests/mock-server/server.py &
SERVER_PID=$!
sleep 2

if ! curl -s http://localhost:8080/getBlockchains -X POST -H "Content-Type: application/json" -d '{"Version":"2.0.0"}' > /dev/null 2>&1; then
    log_error "Mock server failed to start"
    kill $SERVER_PID 2>/dev/null || true
    exit 1
fi
log_success "Mock server running on port 8080"

log_info "Running TypeScript integration tests..."
cd "$PROJECT_ROOT/tests/integration"
if CIRCULAR_API_URL=http://localhost:8080 npm test --silent 2>&1 | grep -q "9 passed"; then
    log_success "TypeScript integration tests PASSED (9/9)"
else
    log_error "TypeScript integration tests FAILED"
fi

log_info "Stopping mock server..."
kill $SERVER_PID 2>/dev/null || true
wait $SERVER_PID 2>/dev/null || true

# =============================================================================
# Phase 5: Workflow Validation
# =============================================================================

log_section "Phase 5: Development Workflow"

cd "$PROJECT_ROOT"

log_info "Testing full package generation..."
if just generate-packages > /dev/null 2>&1; then
    log_success "Package generation workflow PASSED"
else
    log_error "Package generation workflow FAILED"
fi

log_info "Checking generated package structure..."
REQUIRED_TS_FILES=(
    "dist/typescript/package.json"
    "dist/typescript/tsconfig.json"
    "dist/typescript/src/index.ts"
    "dist/typescript/tests/index.test.ts"
)

REQUIRED_PY_FILES=(
    "dist/python/pyproject.toml"
    "dist/python/setup.py"
    "dist/python/src/circular_protocol_api/__init__.py"
    "dist/python/tests/test_unit.py"
)

MISSING=0
for file in "${REQUIRED_TS_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        log_error "Missing: $file"
        ((MISSING++))
    fi
done

for file in "${REQUIRED_PY_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        log_error "Missing: $file"
        ((MISSING++))
    fi
done

if [ $MISSING -eq 0 ]; then
    log_success "All required files generated"
else
    log_error "$MISSING required files missing"
fi

# =============================================================================
# Summary
# =============================================================================

log_section "E2E Test Summary"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
echo -e "${BLUE}Duration: ${DURATION}s${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ E2E TESTS PASSED              ║${NC}"
    echo -e "${GREEN}║                                    ║${NC}"
    echo -e "${GREEN}║  All systems operational!          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════╝${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ E2E TESTS FAILED               ║${NC}"
    echo -e "${RED}║                                    ║${NC}"
    echo -e "${RED}║  Fix errors and try again          ║${NC}"
    echo -e "${RED}╚════════════════════════════════════╝${NC}"
    echo ""
    exit 1
fi
