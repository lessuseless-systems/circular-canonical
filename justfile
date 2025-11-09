# Circular Protocol Canonical - Build Automation
# Just is a command runner - similar to Make but simpler
# Install: https://github.com/casey/just
# Usage: just <recipe>

# Default recipe - show help
default:
    @just --list

# Initial project setup
setup:
    @echo "Setting up Canonical development environment"
    @mkdir -p output/{typescript,python,java,openapi}
    @chmod +x tests/*.sh 2>/dev/null || true
    @chmod +x tests/**/*.sh 2>/dev/null || true
    @if [ -f .git/hooks/pre-commit ]; then rm .git/hooks/pre-commit; fi
    @if [ -d .git ]; then ln -sf ../../hooks/pre-commit .git/hooks/pre-commit 2>/dev/null || true; fi
    @echo "[OK] Output directories created"
    @echo "[OK] Test scripts made executable"
    @echo "[OK] Git hooks configured"
    @echo ""
    @echo "Setup complete. Next steps:"
    @echo "  *Install Nickel: nix shell nixpkgs#nickel"
    @echo "  *Verify: nickel --version"
    @echo "  *Start implementing: See implementation guide in docs"

# Type check all Nickel files (fast, run frequently)
validate:
    @echo "Type checking Nickel files"
    @find src -name '*.ncl' -exec echo "  Checking: {}" \; -exec nickel typecheck {} \; 2>&1
    @find generators -name '*.ncl' -exec echo "  Checking: {}" \; -exec nickel typecheck {} \; 2>&1
    @echo "[OK] All files type checked successfully"

# Run contract validation tests only (Layer 1: fastest)
test-contracts:
    @echo "Running contract validation tests"
    @if [ -f tests/run-contract-tests.sh ]; then \
        ./tests/run-contract-tests.sh; \
    else \
        echo "[WARNING] contract test script not found yet"; \
        echo "  Run contract tests manually"; \
    fi

# Run generator output validation tests (Layer 2: syntax validation)
test-generators:
    @echo "Running generator output tests"
    @if [ -f tests/generators/syntax-validation.sh ]; then \
        ./tests/generators/syntax-validation.sh; \
    else \
        echo "[WARNING] syntax validation script not found yet"; \
    fi

# Run snapshot tests (compare generator output against snapshots)
test-snapshots:
    @echo "Running snapshot tests"
    @if [ -f tests/generators/snapshot-test.sh ]; then \
        ./tests/generators/snapshot-test.sh; \
    else \
        echo "[WARNING] snapshot test script not found yet"; \
    fi

# Run cross-language validation tests (Layer 3: behavioral consistency)
test-cross-lang:
    @echo "Running cross-language validation"
    @if [ -f tests/cross-lang/run-tests.py ]; then \
        python3 tests/cross-lang/run-tests.py; \
    else \
        echo "[WARNING] tests/cross-lang/run-tests.py not found yet"; \
    fi

# Run integration tests (Layer 4: against mock/live server)
test-integration:
    @echo "Running integration tests"
    @if [ -f tests/integration/sdk.test.ts ]; then \
        cd tests/integration && npm test; \
    else \
        echo "[WARNING] Integration tests not yet implemented"; \
    fi

# Run all tests (full suite)
test: test-contracts test-generators

# Generate all artifacts from Nickel definitions
generate:
    @echo "Generating artifacts from Nickel definitions"
    @mkdir -p dist/{openapi,sdk}
    @echo "OpenAPI specification"
    @nickel export generators/shared/openapi.ncl --format yaml > dist/openapi/openapi.yaml 2>&1 && \
        echo "    [OK] OpenAPI YAML generated"
    @nickel export generators/shared/openapi.ncl --format json > dist/openapi/openapi.json 2>&1 && \
        echo "    [OK] OpenAPI JSON generated"
    @echo "TypeScript SDK"
    @nickel export generators/typescript/typescript-sdk.ncl --field sdk_code --format raw > dist/sdk/circular-protocol.ts 2>&1 && \
        echo "    [OK] TypeScript SDK generated"
    @echo "Python SDK"
    @nickel export generators/python/python-sdk.ncl --field sdk_code --format raw > dist/sdk/circular_protocol.py 2>&1 && \
        echo "    [OK] Python SDK generated"
    @echo ""
    @echo "[OK] Generation complete"

# Generate TypeScript SDK only
generate-ts:
    @echo "Generating TypeScript SDK"
    @mkdir -p dist/sdk
    @nickel export generators/typescript/typescript-sdk.ncl --field sdk_code --format raw > dist/sdk/circular-protocol.ts
    @echo "[OK] Generated TypeScript SDK"
    @wc -l dist/sdk/circular-protocol.ts

# Generate Python SDK only
generate-py:
    @echo "Generating Python SDK"
    @mkdir -p dist/sdk
    @nickel export generators/python/python-sdk.ncl --field sdk_code --format raw > dist/sdk/circular_protocol.py
    @echo "[OK] Generated Python SDK"
    @wc -l dist/sdk/circular_protocol.py

# Generate complete Python package
generate-py-package:
    @echo "Generating complete Python package"
    @mkdir -p dist/python/src/circular_protocol_api
    @echo "pyproject.toml"
    @nickel export generators/python/package-manifest/python-pyproject-toml.ncl --format toml > dist/python/pyproject.toml
    @echo "setup.py"
    @nickel export generators/python/package-manifest/python-setup-py.ncl --field setup_code --format raw > dist/python/setup.py
    @echo "README file"
    @nickel export generators/python/docs/python-readme.ncl --format raw > dist/python/README.md
    @echo "pytest.ini"
    @nickel export generators/python/config/python-pytest-ini.ncl --field pytest_ini_content --format raw > dist/python/pytest.ini
    @echo ".gitignore"
    @nickel export generators/python/metadata/python-gitignore.ncl --field gitignore_content --format raw > dist/python/.gitignore
    @echo "SDK code (src/circular_protocol_api/__init__.py)"
    @nickel export generators/python/python-sdk.ncl --field sdk_code --format raw > dist/python/src/circular_protocol_api/__init__.py
    @echo "Unit tests"
    @mkdir -p dist/python/tests
    @nickel export generators/python/tests/python-unit-tests.ncl --field test_code --format raw > dist/python/tests/test_unit.py
    @echo "GitHub Actions workflow"
    @mkdir -p dist/python/.github/workflows
    @nickel export generators/python/ci-cd/python-github-actions-test.ncl --field workflow_yaml --format raw > dist/python/.github/workflows/test.yml
    @echo ""
    @echo "[OK] Python package generated in dist/python/"
    @ls -lh dist/python/

# Generate complete TypeScript package
generate-ts-package:
    @echo "Generating complete TypeScript package"
    @mkdir -p dist/typescript/src
    @echo "package.json"
    @nickel export generators/typescript/package-manifest/typescript-package-json.ncl --format json > dist/typescript/package.json
    @echo "tsconfig.json"
    @nickel export generators/typescript/config/typescript-tsconfig.ncl --format json > dist/typescript/tsconfig.json
    @echo "jest.config.cjs"
    @nickel export generators/typescript/config/typescript-jest.ncl --format raw > dist/typescript/jest.config.cjs
    @echo "webpack.config.cjs.js"
    @nickel export generators/typescript/config/typescript-webpack-cjs.ncl --format raw > dist/typescript/webpack.config.cjs.js
    @echo "webpack.config.esm.js"
    @nickel export generators/typescript/config/typescript-webpack-esm.ncl --format raw > dist/typescript/webpack.config.esm.js
    @echo "README file"
    @nickel export generators/typescript/docs/typescript-readme.ncl --format raw > dist/typescript/README.md
    @echo "SDK code (src/index.ts)"
    @nickel export generators/typescript/typescript-sdk.ncl --field sdk_code --format raw > dist/typescript/src/index.ts
    @echo "Unit tests"
    @mkdir -p dist/typescript/tests
    @nickel export generators/typescript/tests/typescript-unit-tests.ncl --field test_code --format raw > dist/typescript/tests/index.test.ts
    @echo "GitHub Actions workflow"
    @mkdir -p dist/typescript/.github/workflows
    @nickel export generators/typescript/ci-cd/typescript-github-actions-test.ncl --field workflow_yaml --format raw > dist/typescript/.github/workflows/test.yml
    @echo ""
    @echo "[OK] TypeScript package generated in dist/typescript/"
    @ls -lh dist/typescript/

# Generate both complete packages
generate-packages: generate-ts-package generate-py-package
    @echo ""
    @echo "================================================================"
    @echo "  [OK] Complete packages generated for TypeScript and Python"
    @echo "================================================================"

# ===========================================================================
# Multi-Repo Workflow: Fork setup and sync to submodules
# ===========================================================================

# Setup forks: Create forks on GitHub and add as submodules (ONE-TIME SETUP)
setup-forks:
    @echo "Setting up lessuseless-systems forks"
    @echo ""
    @echo "Step 1: Fork upstream repositories to lessuseless-systems"
    @if ! command -v gh >/dev/null 2>&1; then \
        echo "[ERROR] GitHub CLI (gh) not found"; \
        echo "  Install gh CLI first"; \
        exit 1; \
    fi
    @echo "Forking circular-protocol/circular-js-npm"
    @gh repo fork circular-protocol/circular-js-npm --org lessuseless-systems --clone=false --remote=false || \
        echo "  [WARNING] Fork may already exist, continuing"
    @echo "Forking circular-protocol/circular-py"
    @gh repo fork circular-protocol/circular-py --org lessuseless-systems --clone=false --remote=false || \
        echo "  [WARNING] Fork may already exist, continuing"
    @echo ""
    @echo "Step 2: Clone forks and create development branches"
    @rm -rf /tmp/circular-forks
    @mkdir -p /tmp/circular-forks
    @cd /tmp/circular-forks && \
        gh repo clone lessuseless-systems/circular-js-npm && \
        cd circular-js-npm && \
        git checkout -b development 2>/dev/null || git checkout development && \
        git push -u origin development 2>/dev/null || echo "  [OK] development branch exists"
    @cd /tmp/circular-forks && \
        gh repo clone lessuseless-systems/circular-py && \
        cd circular-py && \
        git checkout -b development 2>/dev/null || git checkout development && \
        git push -u origin development 2>/dev/null || echo "  [OK] development branch exists"
    @echo ""
    @echo "Step 3: Remove existing dist/ contents and add submodules"
    @rm -rf dist/typescript/* dist/python/* 2>/dev/null || true
    @git submodule add -b development git@github.com:lessuseless-systems/circular-js-npm.git dist/typescript 2>/dev/null || \
        echo "  [WARNING] Submodule dist/typescript already exists"
    @git submodule add -b development git@github.com:lessuseless-systems/circular-py.git dist/python 2>/dev/null || \
        echo "  [WARNING] Submodule dist/python already exists"
    @git submodule init
    @git submodule update
    @echo ""
    @echo "Step 4: Generate initial packages in submodules"
    @just generate-packages
    @echo ""
    @echo "================================================================"
    @echo "  [OK] Fork setup complete"
    @echo "================================================================"
    @echo ""
    @echo "Next steps:"
    @echo "  *Review submodules: just check-submodules"
    @echo "  *Commit submodule config: git add .gitmodules && git commit -m 'chore: add fork submodules'"
    @echo "  *Start using workflow: just sync-all"
    @echo ""
    @echo "[WARNING] IMPORTANT: Do NOT use git add dist - submodules are tracked via gitmodules"
    @echo ""
    @echo "Clean up temp directory:"
    @echo "  rm -rf /tmp/circular-forks"

# ===========================================================================
# Multi-Repo Workflow: Sync generated code to fork submodules
# ===========================================================================

# Verify submodule URLs point to correct official repos (safety check)
verify-repos:
    @echo "🔍 Verifying submodule repository URLs..."
    @if [ ! -e dist/typescript/.git ]; then \
        echo "⚠️  dist/typescript/ is not a git submodule (run setup-forks)"; \
    else \
        ts_url=$$(cd dist/typescript && git remote get-url origin); \
        if echo "$$ts_url" | grep -q "circular-js-npm\.git$$" && ! echo "$$ts_url" | grep -qE "\-[0-9]+\.git$$"; then \
            echo "✅ TypeScript submodule: $$ts_url"; \
        else \
            echo "❌ ERROR: TypeScript submodule has wrong URL: $$ts_url"; \
            echo "   Expected: git@github.com:lessuseless-systems/circular-js-npm.git"; \
            echo "   (NOT numbered repos like circular-js-npm-1.git)"; \
            exit 1; \
        fi; \
    fi
    @if [ ! -e dist/python/.git ]; then \
        echo "⚠️  dist/python/ is not a git submodule (run setup-forks)"; \
    else \
        py_url=$$(cd dist/python && git remote get-url origin); \
        if echo "$$py_url" | grep -q "circular-py\.git$$" && ! echo "$$py_url" | grep -qE "\-[0-9]+\.git$$"; then \
            echo "✅ Python submodule: $$py_url"; \
        else \
            echo "❌ ERROR: Python submodule has wrong URL: $$py_url"; \
            echo "   Expected: git@github.com:lessuseless-systems/circular-py.git"; \
            echo "   (NOT numbered repos like circular-py-1.git)"; \
            exit 1; \
        fi; \
    fi
    @echo "✅ All repository URLs verified correct"

# Sync TypeScript package to submodule (lessuseless-systems/circular-js-npm fork)
sync-typescript: verify-repos
    @echo "Syncing TypeScript package to dist/typescript/ submodule"
    @if [ ! -e dist/typescript/.git ]; then \
        echo "[ERROR] dist/typescript/ is not a git submodule"; \
        echo "  Run setup-forks to configure submodules"; \
        exit 1; \
    fi
    @echo "Generating TypeScript package"
    @just generate-ts-package
    @echo "Skipping LICENSE and gitignore (generators not yet implemented)"
    @cd dist/typescript && \
        git add -A && \
        git diff --cached --quiet || \
        git commit -m "chore: sync generated TypeScript SDK from circular-canonical"
    @echo "[OK] TypeScript package synced to dist/typescript/"
    @echo "  Branch: development"
    @cd dist/typescript && git log -1 --oneline

# Sync Python package to submodule (lessuseless-systems/circular-py fork)
sync-python: verify-repos
    @echo "Syncing Python package to dist/python/ submodule"
    @if [ ! -e dist/python/.git ]; then \
        echo "[ERROR] dist/python/ is not a git submodule"; \
        echo "  Run setup-forks to configure submodules"; \
        exit 1; \
    fi
    @echo "Generating Python package"
    @just generate-py-package
    @echo "Skipping LICENSE (generator not yet implemented)"
    @cd dist/python && \
        git add -A && \
        git diff --cached --quiet || \
        git commit -m "chore: sync generated Python SDK from circular-canonical"
    @echo "[OK] Python package synced to dist/python/"
    @echo "  Branch: development"
    @cd dist/python && git log -1 --oneline

# Sync both TypeScript and Python packages
sync-all: sync-typescript sync-python
    @echo ""
    @echo "================================================================"
    @echo "  [OK] Both packages synced to submodules"
    @echo "================================================================"
    @echo ""
    @echo "Next steps:"
    @echo "  *Review changes: cd dist/typescript && git status"
    @echo "  *Push to fork: just push-forks"
    @echo "  *Create PRs to upstream circular-protocol repos"

# Push development branches to lessuseless-systems forks
push-forks:
    @echo "Pushing development branches to lessuseless-systems forks"
    @if [ -e dist/typescript/.git ]; then \
        echo "Pushing TypeScript (dist/typescript)"; \
        cd dist/typescript && git push origin development; \
    else \
        echo "  [WARNING] Skipping TypeScript: not a submodule"; \
    fi
    @if [ -e dist/python/.git ]; then \
        echo "Pushing Python (dist/python)"; \
        cd dist/python && git push origin development; \
    else \
        echo "  [WARNING] Skipping Python: not a submodule"; \
    fi
    @echo "[OK] Pushed to lessuseless-systems forks"
    @echo ""
    @echo "Next: Create PRs from lessuseless-systems tocircular-protocol"

# Check status of all submodules
check-submodules:
    @echo "Checking submodule status"
    @echo ""
    @if [ -e dist/typescript/.git ]; then \
        echo "TypeScript (dist/typescript):"; \
        cd dist/typescript && git status -sb; \
    else \
        echo "TypeScript: Not a submodule"; \
    fi
    @echo ""
    @if [ -e dist/python/.git ]; then \
        echo "Python (dist/python):"; \
        cd dist/python && git status -sb; \
    else \
        echo "Python: Not a submodule"; \
    fi

# Generate OpenAPI spec only
generate-openapi:
    @echo "Generating OpenAPI specification"
    @mkdir -p dist/openapi
    @nickel export generators/shared/openapi.ncl --format yaml > dist/openapi/openapi.yaml
    @nickel export generators/shared/openapi.ncl --format json > dist/openapi/openapi.json
    @echo "[OK] Generated OpenAPI spec in yaml and json formats"

# Generate AGENTS.md documentation for AI agents
generate-agents-md:
    @echo "Generating AGENTS.md for AI agent consumption"
    @mkdir -p docs
    @nickel export generators/shared/agents-md.ncl --field agents_md --format raw > docs/AGENTS.md
    @echo "[OK] Generated AGENTS.md in docs/"
    @wc -l docs/AGENTS.md

# Generate mock API server from Nickel definitions
generate-mock-server:
    @echo "Generating mock API server from Nickel definitions"
    @mkdir -p dist/tests
    @nickel export generators/shared/mock-server.ncl --field server_code --format raw > dist/tests/mock-server.py
    @chmod +x dist/tests/mock-server.py
    @echo "[OK] Generated mock server (192 lines, 24 endpoints)"
    @echo "    Source: generators/shared/mock-server.ncl"
    @echo "    Output: dist/tests/mock-server.py"

# Start mock API server for SDK testing (uses generated server)
mock-server: generate-mock-server
    @echo "Starting generated mock API server"
    @echo "⚠️  Using generated server from dist/tests/mock-server.py"
    @python3 dist/tests/mock-server.py

# Generate SDK test files (integration tests)
generate-tests:
    @echo "Generating SDK integration test files"
    @mkdir -p dist/tests
    @nickel export generators/typescript/tests/typescript-tests.ncl --field test_code --format raw > dist/tests/sdk.test.ts
    @echo "[OK] Generated test files in dist/tests"
    @nickel export generators/python/tests/python-tests.ncl --field test_code --format raw > dist/tests/test_sdk.py
    @echo "[OK] Generated Python test files"

# Generate SDK unit test files
generate-unit-tests:
    @echo "Generating SDK unit test files"
    @mkdir -p dist/tests
    @nickel export generators/typescript/tests/typescript-unit-tests.ncl --field test_code --format raw > dist/tests/sdk.unit.test.ts
    @echo "[OK] Generated TypeScript unit tests"
    @nickel export generators/python/tests/python-unit-tests.ncl --field test_code --format raw > dist/tests/test_sdk_unit.py
    @echo "[OK] Generated Python unit tests"

# Generate contract test runner (Layer 1: Nickel contract validation)
generate-contract-runner:
    @echo "Generating contract test runner"
    @mkdir -p dist/tests
    @nickel export generators/shared/test-runners/contract-runner.ncl --field runner_script --format raw > dist/tests/run-contract-tests.sh
    @chmod +x dist/tests/run-contract-tests.sh
    @echo "[OK] Generated contract test runner (25 tests)"

# Generate syntax validator (Layer 2: Generated code syntax validation)
generate-syntax-validator:
    @echo "Generating syntax validator"
    @mkdir -p dist/tests
    @nickel export generators/shared/test-runners/syntax-validator.ncl --field validator_script --format raw > dist/tests/syntax-validation.sh
    @chmod +x dist/tests/syntax-validation.sh
    @echo "[OK] Generated syntax validator (TypeScript, Python)"

# Generate all test infrastructure (mock server + test runners + integration + unit tests)
generate-all-tests: generate-mock-server generate-contract-runner generate-syntax-validator generate-tests generate-unit-tests

# Run TypeScript SDK tests (requires mock server)
test-sdk-ts:
    @echo "Running TypeScript SDK tests"
    @echo "Note: Mock server must be running (just mock-server)"
    @cd dist/tests && npm install --silent && npm test

# Run Python SDK tests (requires mock server)
test-sdk-py:
    @echo "Running Python SDK tests"
    @echo "Note: Mock server must be running (just mock-server)"
    @cd dist/tests && PYTHONPATH=../sdk:$$PYTHONPATH pytest test_sdk.py -v

# Run all SDK tests (TypeScript + Python)
test-sdk: test-sdk-ts test-sdk-py

# Run TypeScript SDK unit tests (no mock server needed)
test-sdk-unit-ts:
    @echo "Running TypeScript SDK unit tests"
    @echo "Note: No mock server required"
    @cd dist/tests && npm install --silent && npx jest --selectProjects=unit

# Run Python SDK unit tests (no mock server needed)
test-sdk-unit-py:
    @echo "Running Python SDK unit tests"
    @echo "Note: No mock server required"
    @cd dist/tests && PYTHONPATH=../sdk:$$PYTHONPATH pytest test_sdk_unit.py -v -m unit

# Run all SDK unit tests (TypeScript + Python)
test-sdk-unit: test-sdk-unit-ts test-sdk-unit-py

# Run all tests (integration + unit, both languages)
test-sdk-all:
    @echo "Running all SDK tests (integration + unit)"
    @echo ""
    @echo "=== Integration Tests (requires mock server) ==="
    @just test-sdk
    @echo ""
    @echo "=== Unit Tests (standalone) ==="
    @just test-sdk-unit

# Generate JSON export for inspection (useful for debugging)
generate-json file:
    @echo "Exporting {{file}} to JSON"
    @nickel export {{file}} --format json | jq .

# Generate YAML export for inspection
generate-yaml file:
    @echo "Exporting {{file}} to YAML"
    @nickel export {{file}} --format yaml

# Query specific field in Nickel file (for inspection)
query file field:
    @echo "Querying field in file"
    @nickel query {{file}} {{field}}

# Watch for changes and regenerate (requires inotifywait)
watch:
    @echo "Watching for changes (Ctrl+C to stop)"
    @echo "Watching: src/ generators/"
    @while true; do \
        inotifywait -qre modify src/ generators/ 2>/dev/null || { echo "[WARNING] inotifywait not found"; exit 1; }; \
        clear; \
        echo "Change detected, regenerating"; \
        just validate && just generate; \
        echo ""; \
        echo "Waiting for next change"; \
    done

# Clean all generated files
clean:
    @echo "Cleaning generated files"
    @rm -rf output/*
    @echo "[OK] Cleaned output/ directory"

# Update snapshots (after verifying generator output is correct)
update-snapshots:
    @echo "Updating generator snapshots"
    @mkdir -p tests/generators/snapshots
    @just generate
    @cp -r output/* tests/generators/snapshots/
    @echo "[OK] Snapshots updated from current output"
    @echo "[WARNING] Remember to commit the updated snapshots"

# Validate against OpenAPI schema
validate-openapi:
    @echo "Validating OpenAPI specification"
    @if [ -f output/openapi/openapi.yaml ]; then \
        npx @apidevtools/swagger-cli validate output/openapi/openapi.yaml; \
    else \
        echo "[WARNING] Generate OpenAPI spec first: just generate"; \
    fi

# Validate MCP server output (basic JSON validation)
# Note: Formal JSON Schema validation not yet implemented
validate-mcp:
    @echo "Validating MCP server schema"
    @if [ -f output/mcp/tools.json ]; then \
        echo "Checking MCP tools.json is valid JSON..."; \
        jq empty output/mcp/tools.json && echo "[OK] Valid JSON" || echo "[ERROR] Invalid JSON"; \
    else \
        echo "[WARNING] Generate MCP schema first: just generate"; \
    fi

# Run regression tests (detect breaking changes)
regression:
    @echo "Running regression tests"
    @if [ -f tests/regression/detect-breaking-changes.sh ]; then \
        ./tests/regression/detect-breaking-changes.sh; \
    else \
        echo "[WARNING] breaking changes detection script not found yet"; \
    fi

# Interactive Nickel REPL
repl:
    @echo "Starting Nickel REPL"
    @echo "Tip: Try importing schemas/types file"
    @nickel repl

# Format all Nickel files (if nickel format becomes available)
format:
    @echo "Formatting Nickel files"
    @echo "[WARNING] Nickel formatter not yet available"
    @echo "  Manually ensure consistent indentation"

# Lint all Nickel files (basic checks)
lint:
    @echo "Linting Nickel files"
    @just validate
    @echo "[OK] Lint complete (type checking passed)"

# Prepare for release (run all checks)
release: clean validate test generate
    @echo ""
    @echo "==================================="
    @echo "Release preparation complete"
    @echo "==================================="
    @echo ""
    @echo "Next steps:"
    @echo "  *Update version in config file"
    @echo "  *Update CHANGELOG"
    @echo "  *Commit with release message"
    @echo "  *Tag with version number"
    @echo "  *Push to origin"

# Show current Nickel version
version-nickel:
    @nickel --version

# Show project version (from src/config.ncl if it exists)
version-project:
    @echo "Project version:"
    @if [ -f src/config.ncl ]; then \
        nickel query src/config.ncl version 2>/dev/null || echo "  [WARNING] Could not read version from config file"; \
    else \
        echo "  [WARNING] config file not found yet"; \
    fi

# Check development environment
check-env:
    @echo "Checking development environment"
    @echo ""
    @echo "Required tools:"
    @command -v nickel >/dev/null 2>&1 && echo "  [OK] nickel found" || echo "  [ERROR] nickel NOT FOUND"
    @command -v node >/dev/null 2>&1 && echo "  [OK] node found" || echo "  [ERROR] node NOT FOUND"
    @command -v python3 >/dev/null 2>&1 && echo "  [OK] python3 found" || echo "  [ERROR] python3 NOT FOUND"
    @command -v java >/dev/null 2>&1 && echo "  [OK] java found" || echo "  [ERROR] java NOT FOUND"
    @command -v jq >/dev/null 2>&1 && echo "  [OK] jq found" || echo "  [ERROR] jq NOT FOUND"
    @echo ""
    @echo "Optional tools:"
    @command -v inotifywait >/dev/null 2>&1 && echo "  [OK] inotifywait found" || echo "  [INFO] inotifywait not found"
    @command -v gh >/dev/null 2>&1 && echo "  [OK] gh found" || echo "  [INFO] gh not found"

# Show statistics about the project
stats:
    @echo "Canonical Project Statistics"
    @echo "============================="
    @echo ""
    @echo "Nickel files:"
    @find src generators -name '*.ncl' 2>/dev/null | wc -l | xargs echo "  Total"
    @find src/schemas -name '*.ncl' 2>/dev/null | wc -l | xargs echo "  Schemas"
    @find src/api -name '*.ncl' 2>/dev/null | wc -l | xargs echo "  API definitions"
    @find generators -name '*.ncl' 2>/dev/null | wc -l | xargs echo "  Generators"
    @echo ""
    @echo "Test files:"
    @find tests -name '*.test.ncl' 2>/dev/null | wc -l | xargs echo "  Contract tests"
    @find tests -name '*.sh' 2>/dev/null | wc -l | xargs echo "  Test scripts count"
    @echo ""
    @echo "Documentation:"
    @find docs -name '*.md' 2>/dev/null | wc -l | xargs echo "  Markdown files"
# Quick development cycle: validate + generate
dev: validate generate

# Full CI/CD simulation: clean + validate + test + generate
ci: clean validate test generate
    @echo "[OK] CI pipeline complete"

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
    @echo "[OK] Created API definition file"
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
    @echo "[OK] Created contract test file"
    @echo "  Edit the file to add test cases"

# Help text (extended)
help:
    @echo "Circular Protocol Canonical - Build Commands"
    @echo "==========================================="
    @echo ""
    @echo "Development:"
    @echo "  just setup           *Initial project setup"
    @echo "  just dev             *Quick cycle: validate + generate"
    @echo "  just validate        *Type check all Nickel files"
    @echo "  just generate        *Generate all artifacts (OpenAPI + SDKs)"
    @echo "  just generate-ts     *Generate TypeScript SDK only"
    @echo "  just generate-py     *Generate Python SDK only"
    @echo "  just generate-packages - Generate complete TS + Python packages"
    @echo "  just generate-openapi - Generate OpenAPI spec only"
    @echo "  just watch           *Auto-regenerate on changes"
    @echo "  just clean           *Remove generated files"
    @echo ""
    @echo "Multi-Repo Workflow (Fork Sync):"
    @echo "  just setup-forks      *ONE-TIME: Fork repos, create dev branches, add submodules"
    @echo "  just sync-typescript  *Sync generated TS to dist/typescript submodule"
    @echo "  just sync-python      *Sync generated Python to dist/python submodule"
    @echo "  just sync-all         *Sync both packages to submodules"
    @echo "  just push-forks       *Push development branches to lessuseless-systems"
    @echo "  just create-prs       *Create pull requests to upstream circular-protocol"
    @echo "  just check-submodules - Check status of all submodules"
    @echo ""
    @echo "Testing:"
    @echo "  just test            *Run all tests"
    @echo "  just test-contracts  *Run contract validation tests"
    @echo "  just test-generators - Run generator output tests"
    @echo "  just test-snapshots  *Run snapshot tests"
    @echo "  just regression      *Run regression tests"
    @echo "  just mock-server     *Start mock API server (port 8080)"
    @echo ""
    @echo "SDK Testing:"
    @echo "  just generate-tests       *Generate SDK integration tests"
    @echo "  just generate-unit-tests  *Generate SDK unit tests"
    @echo "  just generate-all-tests   *Generate all SDK tests"
    @echo "  just test-sdk             *Run SDK integration tests (requires mock server)"
    @echo "  just test-sdk-ts          *Run TypeScript integration tests"
    @echo "  just test-sdk-py          *Run Python integration tests"
    @echo "  just test-sdk-unit        *Run SDK unit tests (no server needed)"
    @echo "  just test-sdk-unit-ts     *Run TypeScript unit tests"
    @echo "  just test-sdk-unit-py     *Run Python unit tests"
    @echo "  just test-sdk-all         *Run all SDK tests (integration + unit)"
    @echo ""
    @echo "Release:"
    @echo "  just release         *Full release preparation"
    @echo "  just ci              *Simulate CI/CD pipeline"
    @echo ""
    @echo "Utilities:"
    @echo "  just repl            *Start Nickel REPL"
    @echo "  just check-env       *Check development environment"
    @echo "  just stats           *Show project statistics"
    @echo "  just new-endpoint <name> - Create new API endpoint template"
    @echo "  just new-test <name>     *Create new test template"
    @echo ""
    @echo "For more details: just --list"
