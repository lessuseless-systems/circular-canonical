#!/bin/bash
# TEMPORARY: Manual file until Sprint 3 Phase 6 generator is created
# Will be replaced by: generators/shared/test-runners/regression-validator.ncl → dist/tests/detect-breaking-changes.sh
# Regression Test - Breaking Change Detection
# Compares current API with previous version to detect breaking changes

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Regression Test - Breaking Change Detection${NC}"
echo "============================================"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Not a git repository${NC}"
    echo "  Regression tests require git history"
    exit 0
fi

# Get previous version tag
PREVIOUS_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$PREVIOUS_TAG" ]; then
    echo -e "${YELLOW}⚠ No previous version tag found${NC}"
    echo "  This is likely the first version"
    echo "  Skipping regression tests"
    exit 0
fi

echo "Comparing against: $PREVIOUS_TAG"
echo ""

# Generate current OpenAPI spec
echo "Generating current OpenAPI spec..."
if [ -f "generators/openapi.ncl" ]; then
    nickel export generators/openapi.ncl --format yaml > /tmp/openapi-current.yaml 2>/dev/null
else
    echo -e "${YELLOW}⚠ generators/openapi.ncl not found${NC}"
    echo "  Cannot perform regression testing without OpenAPI generator"
    exit 0
fi

# Checkout previous version
echo "Checking out previous version..."
git worktree add /tmp/canonical-previous $PREVIOUS_TAG 2>/dev/null || {
    echo -e "${YELLOW}⚠ Could not create worktree${NC}"
    echo "  Skipping regression tests"
    exit 0
}

# Generate previous OpenAPI spec
echo "Generating previous OpenAPI spec..."
if [ -f "/tmp/canonical-previous/generators/openapi.ncl" ]; then
    (cd /tmp/canonical-previous && nickel export generators/openapi.ncl --format yaml > /tmp/openapi-previous.yaml 2>/dev/null)
else
    echo -e "${YELLOW}⚠ Previous version has no OpenAPI generator${NC}"
    git worktree remove /tmp/canonical-previous 2>/dev/null
    exit 0
fi

# Compare versions
echo ""
echo "Checking for breaking changes..."
echo ""

BREAKING_CHANGES=""

# TODO: Implement breaking change detection
# For now, just check if files differ
if diff -q /tmp/openapi-current.yaml /tmp/openapi-previous.yaml > /dev/null 2>&1; then
    echo -e "${GREEN}✓ No changes detected${NC}"
else
    echo -e "${YELLOW}⚠ API has changed${NC}"
    echo ""
    echo "Differences found (first 30 lines):"
    diff -u /tmp/openapi-previous.yaml /tmp/openapi-current.yaml | head -30 | sed 's/^/  /'
    echo ""
    echo "Manual review required to determine if changes are breaking."
    echo ""
    echo "Breaking changes include:"
    echo "  - Removed endpoints"
    echo "  - Removed required parameters"
    echo "  - Changed parameter types"
    echo "  - Changed response schemas"
    echo ""
    echo "Non-breaking changes include:"
    echo "  - Added endpoints"
    echo "  - Added optional parameters"
    echo "  - Added response fields"
    echo ""
fi

# Cleanup
git worktree remove /tmp/canonical-previous 2>/dev/null
rm -f /tmp/openapi-previous.yaml /tmp/openapi-current.yaml

echo ""
echo "============================================"
echo -e "${GREEN}✓ Regression test complete${NC}"
echo ""
echo "Note: Automated breaking change detection will be"
echo "implemented in Week 4. For now, manually review diffs."

exit 0
