#!/bin/bash
# TEMPORARY: Manual file until Sprint 3 Phase 2 generator is created
# Will be replaced by: generators/shared/test-runners/snapshot-validator.ncl → dist/tests/snapshot-test.sh
# Snapshot Test Script
# Compares current generator output against known-good snapshots

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Generator Snapshot Tests${NC}"
echo "========================"
echo ""

SNAPSHOT_DIR="tests/generators/snapshots"
OUTPUT_DIR="output"

# Check if snapshots exist
if [ ! -d "$SNAPSHOT_DIR" ] || [ -z "$(ls -A $SNAPSHOT_DIR 2>/dev/null)" ]; then
    echo -e "${YELLOW}⚠ No snapshots found in $SNAPSHOT_DIR${NC}"
    echo ""
    echo "Create snapshots by running:"
    echo "  1. just generate"
    echo "  2. Verify output is correct"
    echo "  3. just update-snapshots"
    echo ""
    exit 0
fi

# Generate current outputs
echo "Generating current outputs..."
mkdir -p "$OUTPUT_DIR"

# Run generators (quietly)
if [ -f generators/openapi.ncl ]; then
    nickel export generators/openapi.ncl --format yaml > "$OUTPUT_DIR/openapi.yaml" 2>/dev/null || true
fi

if [ -f generators/typescript-sdk.ncl ]; then
    nickel export generators/typescript-sdk.ncl > "$OUTPUT_DIR/typescript-sdk.ts" 2>/dev/null || true
fi

if [ -f generators/python-sdk.ncl ]; then
    nickel export generators/python-sdk.ncl > "$OUTPUT_DIR/python-sdk.py" 2>/dev/null || true
fi

if [ -f generators/mcp-server.ncl ]; then
    nickel export generators/mcp-server.ncl --format json > "$OUTPUT_DIR/mcp-server.json" 2>/dev/null || true
fi

echo ""

# Compare outputs with snapshots
PASSED=0
FAILED=0
CHANGED_FILES=""

for snapshot in "$SNAPSHOT_DIR"/*; do
    if [ ! -f "$snapshot" ]; then
        continue
    fi

    filename=$(basename "$snapshot")
    output_file="$OUTPUT_DIR/$filename"

    echo -n "Comparing $filename... "

    if [ ! -f "$output_file" ]; then
        echo -e "${YELLOW}⚠ Missing${NC}"
        echo "  Output file not generated: $output_file"
        FAILED=$((FAILED + 1))
        CHANGED_FILES="$CHANGED_FILES\n  - $filename (missing)"
        continue
    fi

    # Compare files
    if diff -q "$snapshot" "$output_file" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Match${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗ Changed${NC}"
        FAILED=$((FAILED + 1))
        CHANGED_FILES="$CHANGED_FILES\n  - $filename"

        # Show diff (first 20 lines)
        echo ""
        echo "  Diff (first 20 lines):"
        diff -u "$snapshot" "$output_file" | head -20 | sed 's/^/    /'
        echo ""
    fi
done

# Summary
TOTAL=$((PASSED + FAILED))
echo ""
echo "========================"
echo -e "Snapshot Tests: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}✗ Generator output differs from snapshots${NC}"
    echo ""
    echo "Changed files:"
    echo -e "$CHANGED_FILES"
    echo ""
    echo "If these changes are intentional:"
    echo "  1. Review the differences carefully"
    echo "  2. Run: just update-snapshots"
    echo "  3. Commit the updated snapshots"
    echo ""
    exit 1
else
    echo ""
    echo -e "${GREEN}✓ All generator outputs match snapshots!${NC}"
    exit 0
fi
