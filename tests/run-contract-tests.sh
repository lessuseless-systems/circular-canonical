#!/bin/bash
# Contract Validation Test Runner
# Runs all contract tests in tests/contracts/

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Running Contract Validation Tests${NC}"
echo "===================================="
echo ""

PASSED=0
FAILED=0
TOTAL=0

# Find all .test.ncl files
TEST_FILES=$(find tests/contracts -name "*.test.ncl" 2>/dev/null | sort)

if [ -z "$TEST_FILES" ]; then
    echo -e "${YELLOW}⚠ No test files found in tests/contracts/${NC}"
    echo "  Create test files: tests/contracts/*.test.ncl"
    exit 0
fi

# Run each test
for test_file in $TEST_FILES; do
    TOTAL=$((TOTAL + 1))
    test_name=$(basename "$test_file" .test.ncl)

    echo -n "Testing $test_name... "

    # Try to export the test file (this evaluates all contracts)
    if nickel export "$test_file" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}"
        echo ""
        echo "Error in $test_file:"
        nickel export "$test_file" 2>&1 | head -20
        echo ""
        FAILED=$((FAILED + 1))
    fi
done

# Summary
echo ""
echo "===================================="
echo -e "Contract Tests: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC} (Total: $TOTAL)"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
else
    echo ""
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
fi
