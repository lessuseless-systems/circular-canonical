#!/usr/bin/env bash
# Generate OpenAPI specification from Nickel definitions
# Usage: ./scripts/generate.sh

set -e  # Exit on error

# Find Nickel binary
NICKEL_BIN=${NICKEL_BIN:-$(command -v nickel || echo "")}

if [ -z "$NICKEL_BIN" ]; then
  echo "Nickel not in PATH, using nix-shell..."
  NICKEL_CMD="nix-shell -p nickel --run"
  USE_NIX_SHELL=true
else
  NICKEL_CMD="$NICKEL_BIN"
  USE_NIX_SHELL=false
fi

echo "=== Circular Protocol Canonacle - OpenAPI Generation ==="
echo

# Helper function to run nickel export
nickel_export() {
  if [ "$USE_NIX_SHELL" = true ]; then
    nix-shell -p nickel --run "nickel export $1 --format json"
  else
    $NICKEL_CMD export "$1" --format json
  fi
}

# Step 1: Validate configuration
echo "1. Validating configuration..."
nickel_export "src/config.ncl" > /dev/null
echo "   ✓ Configuration valid"
echo

# Step 2: Run contract tests
echo "2. Running contract tests..."
nickel_export "tests/contracts/types.test.ncl" > /dev/null
echo "   ✓ Type contract tests (13 types) passed"

nickel_export "tests/endpoints/checkWallet.test.ncl" > /dev/null
nickel_export "tests/endpoints/getWallet.test.ncl" > /dev/null
nickel_export "tests/endpoints/getLatestTransactions.test.ncl" > /dev/null
nickel_export "tests/endpoints/getWalletBalance.test.ncl" > /dev/null
nickel_export "tests/endpoints/getWalletNonce.test.ncl" > /dev/null
nickel_export "tests/endpoints/registerWallet.test.ncl" > /dev/null
echo "   ✓ All 6 endpoint tests passed"

nickel_export "tests/validation/runtime-validation.test.ncl" > /dev/null
echo "   ✓ Runtime validation tests passed"
echo

# Step 3: Validate API definitions
echo "3. Validating API definitions..."
nickel_export "src/api/wallet.ncl" > /dev/null
echo "   ✓ Wallet API definitions valid"
echo

# Step 4: Generate OpenAPI specification
echo "4. Generating OpenAPI specification..."
mkdir -p dist
nickel_export "generators/openapi.ncl" > dist/openapi.json
echo "   ✓ OpenAPI spec generated: dist/openapi.json"
echo

# Step 5: Validate generated spec
echo "5. Validating generated specification..."
if command -v jq &> /dev/null; then
  # Check required top-level fields
  jq -e '.openapi, .info, .paths' dist/openapi.json > /dev/null

  # Check info section
  jq -e '.info.title, .info.version' dist/openapi.json > /dev/null

  # Count endpoints
  ENDPOINT_COUNT=$(jq '.paths | keys | length' dist/openapi.json)
  echo "   ✓ Valid OpenAPI 3.0 specification"
  echo "   ✓ Contains $ENDPOINT_COUNT endpoint(s)"
else
  echo "   ⚠ jq not found, skipping detailed validation"
fi
echo

echo "=== Generation Complete ==="
echo
echo "Generated files:"
echo "  - dist/openapi.json ($(wc -l < dist/openapi.json) lines, $(du -h dist/openapi.json | cut -f1))"
echo
echo "Next steps:"
echo "  - Review the generated OpenAPI spec: cat dist/openapi.json | jq ."
echo "  - View specific endpoint: cat dist/openapi.json | jq '.paths.\"/checkWallet\"'"
echo "  - Add more endpoints to src/api/wallet.ncl and regenerate"
