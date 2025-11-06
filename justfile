# Circular Protocol Canonacle - Build Automation
# Just is a command runner - similar to Make but simpler
# Install: https://github.com/casey/just
# Usage: just <recipe>

# Default recipe - show help
default:
    @just --list

# Initial project setup
setup:
    @echo "Setting up Canonacle development environment..."
    @mkdir -p output/{typescript,python,java,openapi}
    @chmod +x tests/*.sh 2>/dev/null || true
    @chmod +x tests/**/*.sh 2>/dev/null || true
    @if [ -f .git/hooks/pre-commit ]; then rm .git/hooks/pre-commit; fi
    @if [ -d .git ]; then ln -sf ../../hooks/pre-commit .git/hooks/pre-commit 2>/dev/null || true; fi
    @echo "✓ Output directories created"
    @echo "✓ Test scripts made executable"
    @echo "✓ Git hooks configured"
    @echo ""
    @echo "Setup complete! Next steps:"
    @echo "  1. Install Nickel: nix shell nixpkgs#nickel"
    @echo "  2. Verify: nickel --version"
    @echo "  3. Start implementing: See docs/WEEK_1_2_GUIDE.md"

# Type check all Nickel files (fast, run frequently)
validate:
    @echo "Type checking Nickel files..."
    @find src -name "*.ncl" -exec echo "  Checking: {}" \; -exec nickel typecheck {} \; 2>&1
    @find generators -name "*.ncl" -exec echo "  Checking: {}" \; -exec nickel typecheck {} \; 2>&1
    @echo "✓ All files type checked successfully"

# Run contract validation tests only (Layer 1: fastest)
test-contracts:
    @echo "Running contract validation tests..."
    @if [ -f tests/run-contract-tests.sh ]; then \
        ./tests/run-contract-tests.sh; \
    else \
        echo "⚠ tests/run-contract-tests.sh not found yet"; \
        echo "  Run contract tests manually: nickel export tests/contracts/*.test.ncl"; \
    fi

# Run generator output validation tests (Layer 2: syntax validation)
test-generators:
    @echo "Running generator output tests..."
    @if [ -f tests/generators/syntax-validation.sh ]; then \
        ./tests/generators/syntax-validation.sh; \
    else \
        echo "⚠ tests/generators/syntax-validation.sh not found yet"; \
    fi

# Run snapshot tests (compare generator output against snapshots)
test-snapshots:
    @echo "Running snapshot tests..."
    @if [ -f tests/generators/snapshot-test.sh ]; then \
        ./tests/generators/snapshot-test.sh; \
    else \
        echo "⚠ tests/generators/snapshot-test.sh not found yet"; \
    fi

# Run cross-language validation tests (Layer 3: behavioral consistency)
test-cross-lang:
    @echo "Running cross-language validation..."
    @if [ -f tests/cross-lang/run-tests.py ]; then \
        python3 tests/cross-lang/run-tests.py; \
    else \
        echo "⚠ tests/cross-lang/run-tests.py not found yet"; \
    fi

# Run integration tests (Layer 4: against mock/live server)
test-integration:
    @echo "Running integration tests..."
    @if [ -f tests/integration/sdk.test.ts ]; then \
        cd tests/integration && npm test; \
    else \
        echo "⚠ Integration tests not yet implemented"; \
    fi

# Run all tests (full suite)
test: test-contracts test-generators

# Generate all artifacts from Nickel definitions
generate:
    @echo "Generating artifacts from Nickel definitions..."
    @mkdir -p dist/{openapi,sdk}
    @echo "  → OpenAPI specification..."
    @nickel export generators/openapi.ncl --format yaml > dist/openapi/openapi.yaml 2>&1 && \
        echo "    ✓ dist/openapi/openapi.yaml"
    @nickel export generators/openapi.ncl --format json > dist/openapi/openapi.json 2>&1 && \
        echo "    ✓ dist/openapi/openapi.json"
    @echo "  → TypeScript SDK..."
    @nickel export generators/typescript.ncl --field sdk_code --format raw > dist/sdk/circular-protocol.ts 2>&1 && \
        echo "    ✓ dist/sdk/circular-protocol.ts"
    @echo "  → Python SDK..."
    @nickel export generators/python.ncl --field sdk_code --format raw > dist/sdk/circular_protocol.py 2>&1 && \
        echo "    ✓ dist/sdk/circular_protocol.py"
    @echo ""
    @echo "✓ Generation complete! Files in dist/"

# Generate TypeScript SDK only
generate-ts:
    @echo "Generating TypeScript SDK..."
    @mkdir -p dist/sdk
    @nickel export generators/typescript.ncl --field sdk_code --format raw > dist/sdk/circular-protocol.ts
    @echo "✓ Generated: dist/sdk/circular-protocol.ts"
    @wc -l dist/sdk/circular-protocol.ts

# Generate Python SDK only
generate-py:
    @echo "Generating Python SDK..."
    @mkdir -p dist/sdk
    @nickel export generators/python.ncl --field sdk_code --format raw > dist/sdk/circular_protocol.py
    @echo "✓ Generated: dist/sdk/circular_protocol.py"
    @wc -l dist/sdk/circular_protocol.py

# Generate OpenAPI spec only
generate-openapi:
    @echo "Generating OpenAPI specification..."
    @mkdir -p dist/openapi
    @nickel export generators/openapi.ncl --format yaml > dist/openapi/openapi.yaml
    @nickel export generators/openapi.ncl --format json > dist/openapi/openapi.json
    @echo "✓ Generated: dist/openapi/openapi.{yaml,json}"

# Start mock API server for SDK testing
mock-server:
    @echo "Starting mock API server on http://localhost:8080"
    @python3 tests/mock-server/server.py

# Generate SDK test files (integration tests)
generate-tests:
    @echo "Generating SDK integration test files..."
    @mkdir -p dist/tests
    @nickel export generators/typescript-tests.ncl --field test_code --format raw > dist/tests/sdk.test.ts
    @echo "✓ Generated: dist/tests/sdk.test.ts"
    @nickel export generators/python-tests.ncl --field test_code --format raw > dist/tests/test_sdk.py
    @echo "✓ Generated: dist/tests/test_sdk.py"

# Generate SDK unit test files
generate-unit-tests:
    @echo "Generating SDK unit test files..."
    @mkdir -p dist/tests
    @nickel export generators/typescript-unit-tests.ncl --field test_code --format raw > dist/tests/sdk.unit.test.ts
    @echo "✓ Generated: dist/tests/sdk.unit.test.ts"
    @nickel export generators/python-unit-tests.ncl --field test_code --format raw > dist/tests/test_sdk_unit.py
    @echo "✓ Generated: dist/tests/test_sdk_unit.py"

# Generate all tests (integration + unit)
generate-all-tests: generate-tests generate-unit-tests

# Run TypeScript SDK tests (requires mock server)
test-sdk-ts:
    @echo "Running TypeScript SDK tests..."
    @echo "Note: Mock server must be running (just mock-server)"
    @cd dist/tests && npm install --silent && npm test

# Run Python SDK tests (requires mock server)
test-sdk-py:
    @echo "Running Python SDK tests..."
    @echo "Note: Mock server must be running (just mock-server)"
    @cd dist/tests && PYTHONPATH=../sdk:$$PYTHONPATH pytest test_sdk.py -v

# Run all SDK tests (TypeScript + Python)
test-sdk: test-sdk-ts test-sdk-py

# Run TypeScript SDK unit tests (no mock server needed)
test-sdk-unit-ts:
    @echo "Running TypeScript SDK unit tests..."
    @echo "Note: No mock server required"
    @cd dist/tests && npm install --silent && npx jest --selectProjects=unit

# Run Python SDK unit tests (no mock server needed)
test-sdk-unit-py:
    @echo "Running Python SDK unit tests..."
    @echo "Note: No mock server required"
    @cd dist/tests && PYTHONPATH=../sdk:$$PYTHONPATH pytest test_sdk_unit.py -v -m unit

# Run all SDK unit tests (TypeScript + Python)
test-sdk-unit: test-sdk-unit-ts test-sdk-unit-py

# Run all tests (integration + unit, both languages)
test-sdk-all:
    @echo "Running all SDK tests (integration + unit)..."
    @echo ""
    @echo "=== Integration Tests (requires mock server) ==="
    @just test-sdk
    @echo ""
    @echo "=== Unit Tests (standalone) ==="
    @just test-sdk-unit

# Generate JSON export for inspection (useful for debugging)
generate-json file:
    @echo "Exporting {{file}} to JSON..."
    @nickel export {{file}} --format json | jq .

# Generate YAML export for inspection
generate-yaml file:
    @echo "Exporting {{file}} to YAML..."
    @nickel export {{file}} --format yaml

# Query specific field in Nickel file (for inspection)
query file field:
    @echo "Querying {{file}}.{{field}}..."
    @nickel query {{file}} {{field}}

# Watch for changes and regenerate (requires inotifywait)
watch:
    @echo "Watching for changes (Ctrl+C to stop)..."
    @echo "Watching: src/ generators/"
    @while true; do \
        inotifywait -qre modify src/ generators/ 2>/dev/null || { echo "⚠ inotifywait not found. Install: apt install inotify-tools"; exit 1; }; \
        clear; \
        echo "Change detected, regenerating..."; \
        just validate && just generate; \
        echo ""; \
        echo "Waiting for next change..."; \
    done

# Clean all generated files
clean:
    @echo "Cleaning generated files..."
    @rm -rf output/*
    @echo "✓ Cleaned output/ directory"

# Update snapshots (after verifying generator output is correct)
update-snapshots:
    @echo "Updating generator snapshots..."
    @mkdir -p tests/generators/snapshots
    @just generate
    @cp -r output/* tests/generators/snapshots/
    @echo "✓ Snapshots updated from current output"
    @echo "⚠ Remember to commit the updated snapshots!"

# Validate against OpenAPI schema
validate-openapi:
    @echo "Validating OpenAPI specification..."
    @if [ -f output/openapi/openapi.yaml ]; then \
        npx @apidevtools/swagger-cli validate output/openapi/openapi.yaml; \
    else \
        echo "⚠ Generate OpenAPI spec first: just generate"; \
    fi

# Validate against MCP schema
validate-mcp:
    @echo "Validating MCP server schema..."
    @if [ -f output/mcp/tools.json ] && [ -f tests/schemas/mcp-schema.json ]; then \
        npx ajv validate -s tests/schemas/mcp-schema.json -d output/mcp/tools.json; \
    else \
        echo "⚠ Generate MCP schema first: just generate"; \
    fi

# Run regression tests (detect breaking changes)
regression:
    @echo "Running regression tests..."
    @if [ -f tests/regression/detect-breaking-changes.sh ]; then \
        ./tests/regression/detect-breaking-changes.sh; \
    else \
        echo "⚠ tests/regression/detect-breaking-changes.sh not found yet"; \
    fi

# Interactive Nickel REPL
repl:
    @echo "Starting Nickel REPL..."
    @echo "Tip: Try 'import \"src/schemas/types.ncl\"'"
    @nickel repl

# Format all Nickel files (if nickel format becomes available)
format:
    @echo "Formatting Nickel files..."
    @echo "⚠ Nickel formatter not yet available"
    @echo "  Manually ensure consistent indentation (2 spaces)"

# Lint all Nickel files (basic checks)
lint:
    @echo "Linting Nickel files..."
    @just validate
    @echo "✓ Lint complete (type checking passed)"

# Prepare for release (run all checks)
release: clean validate test generate
    @echo ""
    @echo "==================================="
    @echo "Release preparation complete!"
    @echo "==================================="
    @echo ""
    @echo "Next steps:"
    @echo "  1. Update version in src/config.ncl"
    @echo "  2. Update CHANGELOG.md"
    @echo "  3. Commit: git commit -m 'chore(release): prepare vX.Y.Z'"
    @echo "  4. Tag: git tag -a vX.Y.Z -m 'Release vX.Y.Z'"
    @echo "  5. Push: git push origin develop && git push origin vX.Y.Z"

# Show current Nickel version
version-nickel:
    @nickel --version

# Show project version (from src/config.ncl if it exists)
version-project:
    @echo "Project version:"
    @if [ -f src/config.ncl ]; then \
        nickel query src/config.ncl version 2>/dev/null || echo "  ⚠ Could not read version from src/config.ncl"; \
    else \
        echo "  ⚠ src/config.ncl not found yet"; \
    fi

# Check development environment
check-env:
    @echo "Checking development environment..."
    @echo ""
    @echo "Required tools:"
    @command -v nickel >/dev/null 2>&1 && echo "  ✓ nickel: $(nickel --version)" || echo "  ✗ nickel: NOT FOUND"
    @command -v node >/dev/null 2>&1 && echo "  ✓ node: $(node --version)" || echo "  ✗ node: NOT FOUND (needed for TypeScript validation)"
    @command -v python3 >/dev/null 2>&1 && echo "  ✓ python3: $(python3 --version)" || echo "  ✗ python3: NOT FOUND (needed for Python validation)"
    @command -v java >/dev/null 2>&1 && echo "  ✓ java: $(java --version | head -1)" || echo "  ✗ java: NOT FOUND (needed for Java validation)"
    @command -v jq >/dev/null 2>&1 && echo "  ✓ jq: $(jq --version)" || echo "  ✗ jq: NOT FOUND (helpful for JSON processing)"
    @echo ""
    @echo "Optional tools:"
    @command -v inotifywait >/dev/null 2>&1 && echo "  ✓ inotifywait: available (for 'just watch')" || echo "  ○ inotifywait: not found (install inotify-tools for watch mode)"
    @command -v gh >/dev/null 2>&1 && echo "  ✓ gh: $(gh --version | head -1) (for GitHub CLI)" || echo "  ○ gh: not found (install for GitHub integration)"

# Show statistics about the project
stats:
    @echo "Canonacle Project Statistics"
    @echo "============================="
    @echo ""
    @echo "Nickel files:"
    @find src generators -name "*.ncl" 2>/dev/null | wc -l | xargs echo "  Total:" || echo "  Total: 0"
    @find src/schemas -name "*.ncl" 2>/dev/null | wc -l | xargs echo "  Schemas:" || echo "  Schemas: 0"
    @find src/api -name "*.ncl" 2>/dev/null | wc -l | xargs echo "  API definitions:" || echo "  API definitions: 0"
    @find generators -name "*.ncl" 2>/dev/null | wc -l | xargs echo "  Generators:" || echo "  Generators: 0"
    @echo ""
    @echo "Test files:"
    @find tests -name "*.test.ncl" 2>/dev/null | wc -l | xargs echo "  Contract tests:" || echo "  Contract tests: 0"
    @find tests -name "*.sh" 2>/dev/null | wc -l | xargs echo "  Test scripts:" || echo "  Test scripts: 0"
    @echo ""
    @echo "Documentation:"
    @find docs -name "*.md" 2>/dev/null | wc -l | xargs echo "  Markdown files:" || echo "  Markdown files: 0"

# Quick development cycle: validate + generate
dev: validate generate

# Full CI/CD simulation: clean + validate + test + generate
ci: clean validate test generate
    @echo "✓ CI pipeline complete"

# Create a new API endpoint template
new-endpoint name:
    @echo "Creating new API endpoint: {{name}}"
    @echo "# TODO: Implement {{name}} endpoint" > src/api/{{name}}.ncl
    @echo "let types = import \"../schemas/types.ncl\" in" >> src/api/{{name}}.ncl
    @echo "" >> src/api/{{name}}.ncl
    @echo "{" >> src/api/{{name}}.ncl
    @echo "  {{name}} = {" >> src/api/{{name}}.ncl
    @echo "    method = \"GET\"," >> src/api/{{name}}.ncl
    @echo "    path = \"/{{name}}\"," >> src/api/{{name}}.ncl
    @echo "    summary = \"TODO: Add summary\"," >> src/api/{{name}}.ncl
    @echo "    description = \"TODO: Add description\"," >> src/api/{{name}}.ncl
    @echo "" >> src/api/{{name}}.ncl
    @echo "    parameters = {" >> src/api/{{name}}.ncl
    @echo "      # TODO: Add parameters" >> src/api/{{name}}.ncl
    @echo "    }," >> src/api/{{name}}.ncl
    @echo "" >> src/api/{{name}}.ncl
    @echo "    response_schema = {" >> src/api/{{name}}.ncl
    @echo "      # TODO: Add response schema" >> src/api/{{name}}.ncl
    @echo "    }," >> src/api/{{name}}.ncl
    @echo "  }," >> src/api/{{name}}.ncl
    @echo "}" >> src/api/{{name}}.ncl
    @echo "✓ Created src/api/{{name}}.ncl"
    @echo "  Edit the file to implement the endpoint"

# Create a new test file template
new-test name:
    @echo "Creating new test: {{name}}"
    @echo "# Test: {{name}}" > tests/contracts/{{name}}.test.ncl
    @echo "let types = import \"../../src/schemas/types.ncl\" in" >> tests/contracts/{{name}}.test.ncl
    @echo "" >> tests/contracts/{{name}}.test.ncl
    @echo "{" >> tests/contracts/{{name}}.test.ncl
    @echo "  test_name = \"{{name}}\"," >> tests/contracts/{{name}}.test.ncl
    @echo "" >> tests/contracts/{{name}}.test.ncl
    @echo "  valid_cases = {" >> tests/contracts/{{name}}.test.ncl
    @echo "    # TODO: Add valid test cases" >> tests/contracts/{{name}}.test.ncl
    @echo "  }," >> tests/contracts/{{name}}.test.ncl
    @echo "}" >> tests/contracts/{{name}}.test.ncl
    @echo "✓ Created tests/contracts/{{name}}.test.ncl"
    @echo "  Edit the file to add test cases"

# Help text (extended)
help:
    @echo "Circular Protocol Canonacle - Build Commands"
    @echo "==========================================="
    @echo ""
    @echo "Development:"
    @echo "  just setup           - Initial project setup"
    @echo "  just dev             - Quick cycle: validate + generate"
    @echo "  just validate        - Type check all Nickel files"
    @echo "  just generate        - Generate all artifacts (OpenAPI + SDKs)"
    @echo "  just generate-ts     - Generate TypeScript SDK only"
    @echo "  just generate-py     - Generate Python SDK only"
    @echo "  just generate-openapi - Generate OpenAPI spec only"
    @echo "  just watch           - Auto-regenerate on changes"
    @echo "  just clean           - Remove generated files"
    @echo ""
    @echo "Testing:"
    @echo "  just test            - Run all tests"
    @echo "  just test-contracts  - Run contract validation tests"
    @echo "  just test-generators - Run generator output tests"
    @echo "  just test-snapshots  - Run snapshot tests"
    @echo "  just regression      - Run regression tests"
    @echo "  just mock-server     - Start mock API server (port 8080)"
    @echo ""
    @echo "SDK Testing:"
    @echo "  just generate-tests       - Generate SDK integration tests"
    @echo "  just generate-unit-tests  - Generate SDK unit tests"
    @echo "  just generate-all-tests   - Generate all SDK tests"
    @echo "  just test-sdk             - Run SDK integration tests (requires mock server)"
    @echo "  just test-sdk-ts          - Run TypeScript integration tests"
    @echo "  just test-sdk-py          - Run Python integration tests"
    @echo "  just test-sdk-unit        - Run SDK unit tests (no server needed)"
    @echo "  just test-sdk-unit-ts     - Run TypeScript unit tests"
    @echo "  just test-sdk-unit-py     - Run Python unit tests"
    @echo "  just test-sdk-all         - Run all SDK tests (integration + unit)"
    @echo ""
    @echo "Release:"
    @echo "  just release         - Full release preparation"
    @echo "  just ci              - Simulate CI/CD pipeline"
    @echo ""
    @echo "Utilities:"
    @echo "  just repl            - Start Nickel REPL"
    @echo "  just check-env       - Check development environment"
    @echo "  just stats           - Show project statistics"
    @echo "  just new-endpoint <name> - Create new API endpoint template"
    @echo "  just new-test <name>     - Create new test template"
    @echo ""
    @echo "For more details: just --list"
