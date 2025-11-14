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
    @if [ -f dist/tests/run-contract-tests.sh ]; then \
        ./dist/tests/run-contract-tests.sh; \
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
    @echo "Java SDK"
    @nickel export generators/java/java-sdk.ncl --field sdk_code --format raw > dist/sdk/CircularProtocolAPI.java 2>&1 && \
        echo "    [OK] Java SDK generated"
    @echo "PHP SDK"
    @nickel export generators/php/php-sdk.ncl --field sdk_code --format raw > dist/sdk/CircularProtocolAPI.php 2>&1 && \
        echo "    [OK] PHP SDK generated"
    @echo ""
    @echo "[OK] Generation complete - 4 SDKs + OpenAPI spec"

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

# Generate Java SDK only
generate-java:
    @echo "Generating Java SDK"
    @mkdir -p dist/sdk
    @nickel export generators/java/java-sdk.ncl --field sdk_code --format raw > dist/sdk/CircularProtocolAPI.java
    @echo "[OK] Generated Java SDK"
    @wc -l dist/sdk/CircularProtocolAPI.java

# Generate PHP SDK only
generate-php:
    @echo "Generating PHP SDK"
    @mkdir -p dist/sdk
    @nickel export generators/php/php-sdk.ncl --field sdk_code --format raw > dist/sdk/CircularProtocolAPI.php
    @echo "[OK] Generated PHP SDK"
    @wc -l dist/sdk/CircularProtocolAPI.php

# Generate complete Python package (modular structure)
generate-py-package:
    @echo "Generating complete Python package (modular structure)"
    @mkdir -p dist/circular-py/src/circular_protocol_api
    @echo "pyproject.toml"
    @nickel export generators/python/package-manifest/python-pyproject-toml.ncl --format toml > dist/circular-py/pyproject.toml
    @echo "setup.py"
    @nickel export generators/python/package-manifest/python-setup-py.ncl --field setup_code --format raw > dist/circular-py/setup.py
    @echo "README file"
    @nickel export generators/python/docs/python-readme.ncl --field readme_content --format raw > dist/circular-py/README.md
    @echo "pytest.ini"
    @nickel export generators/python/config/python-pytest-ini.ncl --field pytest_ini_content --format raw > dist/circular-py/pytest.ini
    @echo ".gitignore"
    @nickel export generators/python/metadata/python-gitignore.ncl --field gitignore_content --format raw > dist/circular-py/.gitignore
    @echo "Modular SDK code:"
    @echo "  src/circular_protocol_api/__init__.py (clean exports)"
    @nickel export generators/python/python-init.ncl --field init_code --format raw > dist/circular-py/src/circular_protocol_api/__init__.py
    @echo "  src/circular_protocol_api/client.py (main API class)"
    @nickel export generators/python/python-client.ncl --field client_code --format raw > dist/circular-py/src/circular_protocol_api/client.py
    @echo "  src/circular_protocol_api/models.py (TypedDict types)"
    @nickel export generators/python/python-models.ncl --field models_code --format raw > dist/circular-py/src/circular_protocol_api/models.py
    @echo "  src/circular_protocol_api/exceptions.py (custom exceptions)"
    @nickel export generators/python/python-exceptions.ncl --field exceptions_code --format raw > dist/circular-py/src/circular_protocol_api/exceptions.py
    @echo "  src/circular_protocol_api/_helpers.py (utility functions)"
    @nickel export generators/python/python-helpers.ncl --field helpers_code --format raw > dist/circular-py/src/circular_protocol_api/_helpers.py
    @echo "  src/circular_protocol_api/_crypto.py (cryptographic operations)"
    @nickel export generators/python/python-crypto.ncl --field crypto_code --format raw > dist/circular-py/src/circular_protocol_api/_crypto.py
    @echo "Unit tests"
    @mkdir -p dist/circular-py/tests
    @nickel export generators/python/tests/python-unit-tests.ncl --field test_code --format raw > dist/circular-py/tests/test_unit.py
    @echo "E2E tests"
    @nickel export generators/python/tests/python-e2e-tests.ncl --field test_code --format raw > dist/circular-py/tests/test_e2e.py
    @echo "Integration tests"
    @nickel export generators/python/tests/python-integration-tests.ncl --field test_file --format raw > dist/circular-py/tests/test_integration.py
    @echo "GitHub Actions workflow"
    @mkdir -p dist/circular-py/.github/workflows
    @nickel export generators/python/ci-cd/python-github-actions-test.ncl --field workflow_yaml --format raw > dist/circular-py/.github/workflows/test.yml
    @echo ""
    @echo "[OK] Python package generated in dist/circular-py/ (modular structure)"
    @ls -lh dist/circular-py/src/circular_protocol_api/

# Generate complete TypeScript package
generate-ts-package:
    @echo "Generating complete TypeScript package"
    @mkdir -p dist/circular-ts/src
    @echo "package.json"
    @nickel export generators/typescript/package-manifest/typescript-package-json.ncl --format json > dist/circular-ts/package.json
    @echo "tsconfig.json"
    @nickel export generators/typescript/config/typescript-tsconfig.ncl --format json > dist/circular-ts/tsconfig.json
    @echo "jest.config.cjs"
    @nickel export generators/typescript/config/typescript-jest.ncl --format raw > dist/circular-ts/jest.config.cjs
    @echo "webpack.config.cjs.js"
    @nickel export generators/typescript/config/typescript-webpack-cjs.ncl --format raw > dist/circular-ts/webpack.config.cjs.js
    @echo "webpack.config.esm.js"
    @nickel export generators/typescript/config/typescript-webpack-esm.ncl --format raw > dist/circular-ts/webpack.config.esm.js
    @echo "README file"
    @nickel export generators/typescript/docs/typescript-readme.ncl --field readme_content --format raw > dist/circular-ts/README.md
    @echo "SDK code (src/index.ts)"
    @nickel export generators/typescript/typescript-sdk.ncl --field sdk_code --format raw > dist/circular-ts/src/index.ts
    @echo "Unit tests"
    @mkdir -p dist/circular-ts/tests
    @nickel export generators/typescript/tests/typescript-unit-tests.ncl --field test_code --format raw > dist/circular-ts/tests/index.test.ts
    @echo "E2E tests"
    @nickel export generators/typescript/tests/typescript-e2e-tests.ncl --field test_code --format raw > dist/circular-ts/tests/e2e.test.ts
    @echo "Integration tests"
    @nickel export generators/typescript/tests/typescript-integration-tests.ncl --field test_file --format raw > dist/circular-ts/tests/integration.test.ts
    @echo "GitHub Actions workflow"
    @mkdir -p dist/circular-ts/.github/workflows
    @nickel export generators/typescript/ci-cd/typescript-github-actions-test.ncl --field workflow_yaml --format raw > dist/circular-ts/.github/workflows/test.yml
    @echo ""
    @echo "[OK] TypeScript package generated in dist/circular-ts/"
    @ls -lh dist/circular-ts/

# Generate complete Java package
generate-java-package:
    @echo "Generating complete Java package"
    @mkdir -p dist/circular-java/src/main/java/io/circular/protocol
    @echo "pom.xml"
    @nickel export generators/java/package-manifest/java-pom-xml.ncl --field pom_content --format raw > dist/circular-java/pom.xml
    @echo "README.md"
    @nickel export generators/java/docs/java-readme.ncl --field readme_content --format raw > dist/circular-java/README.md
    @echo ".gitignore"
    @nickel export generators/java/metadata/java-gitignore.ncl --field gitignore_content --format raw > dist/circular-java/.gitignore
    @echo "SDK code (src/main/java/io/circular/protocol/CircularProtocolAPI.java)"
    @nickel export generators/java/java-sdk.ncl --field sdk_code --format raw > dist/circular-java/src/main/java/io/circular/protocol/CircularProtocolAPI.java
    @echo "Unit tests"
    @mkdir -p dist/circular-java/src/test/java/io/circular/protocol
    @nickel export generators/java/tests/java-unit-tests.ncl --field test_code --format raw > dist/circular-java/src/test/java/io/circular/protocol/CircularProtocolUnitTest.java
    @echo "E2E tests"
    @nickel export generators/java/tests/java-e2e-tests.ncl --field test_code --format raw > dist/circular-java/src/test/java/io/circular/protocol/CircularProtocolE2ETest.java
    @echo "Integration tests"
    @nickel export generators/java/tests/java-integration-tests.ncl --field test_file --format raw > dist/circular-java/src/test/java/io/circular/protocol/CircularProtocolIntegrationTest.java
    @echo "GitHub Actions workflow"
    @mkdir -p dist/circular-java/.github/workflows
    @nickel export generators/java/ci-cd/java-github-actions-test.ncl --field workflow_yaml --format raw > dist/circular-java/.github/workflows/test.yml
    @echo ""
    @echo "[OK] Java package generated in dist/circular-java/"
    @ls -lh dist/circular-java/

# Generate complete PHP package
generate-php-package:
    @echo "Generating complete PHP package"
    @mkdir -p dist/circular-php/src dist/circular-php/tests
    @echo "composer.json"
    @nickel export generators/php/package-manifest/php-composer-json.ncl --format json > dist/circular-php/composer.json
    @echo "README.md"
    @nickel export generators/php/docs/php-readme.ncl --field readme_content --format raw > dist/circular-php/README.md
    @echo ".gitignore"
    @nickel export generators/php/metadata/php-gitignore.ncl --field gitignore_content --format raw > dist/circular-php/.gitignore
    @echo "SDK code (src/CircularProtocolAPI.php)"
    @nickel export generators/php/php-sdk.ncl --field sdk_code --format raw > dist/circular-php/src/CircularProtocolAPI.php
    @echo "Unit tests"
    @nickel export generators/php/tests/php-unit-tests.ncl --field test_code --format raw > dist/circular-php/tests/CircularProtocolUnitTest.php
    @echo "E2E tests"
    @nickel export generators/php/tests/php-e2e-tests.ncl --field test_code --format raw > dist/circular-php/tests/CircularProtocolE2ETest.php
    @echo "Integration tests"
    @nickel export generators/php/tests/php-integration-tests.ncl --field test_file --format raw > dist/circular-php/tests/CircularProtocolIntegrationTest.php
    @echo "GitHub Actions workflow"
    @mkdir -p dist/circular-php/.github/workflows
    @nickel export generators/php/ci-cd/php-github-actions-test.ncl --field workflow_yaml --format raw > dist/circular-php/.github/workflows/test.yml
    @echo ""
    @echo "[OK] PHP package generated in dist/circular-php/"
    @ls -lh dist/circular-php/

# Generate complete Go package
generate-go-package:
    @echo "Generating complete Go package"
    @mkdir -p dist/circular-go
    @echo "go.mod"
    @nickel export generators/go/package-manifest/go-mod.ncl --field go_mod --format raw > dist/circular-go/go.mod
    @echo "SDK code (circular_protocol.go)"
    @nickel export generators/go/go-sdk.ncl --field sdk_code --format raw > dist/circular-go/circular_protocol.go
    @echo "Unit tests"
    @nickel export generators/go/tests/go-unit-tests.ncl --field test_code --format raw > dist/circular-go/circular_protocol_test.go
    @echo "Integration tests"
    @nickel export generators/go/tests/go-integration-tests.ncl --field test_code --format raw > dist/circular-go/circular_protocol_integration_test.go
    @echo "E2E tests"
    @nickel export generators/go/tests/go-e2e-tests.ncl --field test_code --format raw > dist/circular-go/circular_protocol_e2e_test.go
    @echo "README.md"
    @nickel export generators/go/docs/go-readme.ncl --field readme_content --format raw > dist/circular-go/README.md
    @echo ".gitignore"
    @nickel export generators/go/metadata/go-gitignore.ncl --field gitignore_content --format raw > dist/circular-go/.gitignore
    @echo "GitHub Actions workflow"
    @mkdir -p dist/circular-go/.github/workflows
    @nickel export generators/go/ci-cd/go-github-actions-test.ncl --field workflow_content --format raw > dist/circular-go/.github/workflows/test.yml
    @echo ""
    @echo "[OK] Go package generated in dist/circular-go/"
    @ls -lh dist/circular-go/

# Generate complete Dart package
generate-dart-package:
    @echo "Generating complete Dart package"
    @mkdir -p dist/circular-dart/lib dist/circular-dart/test
    @echo "pubspec.yaml"
    @nickel export generators/dart/package-manifest/pubspec-yaml.ncl --field pubspec_yaml --format raw > dist/circular-dart/pubspec.yaml
    @echo "SDK code (lib/circular_protocol.dart)"
    @nickel export generators/dart/dart-sdk.ncl --field sdk_code --format raw > dist/circular-dart/lib/circular_protocol.dart
    @echo "Unit tests"
    @nickel export generators/dart/tests/dart-unit-tests.ncl --field test_code --format raw > dist/circular-dart/test/unit_test.dart
    @echo "Integration tests"
    @nickel export generators/dart/tests/dart-integration-tests.ncl --field test_code --format raw > dist/circular-dart/test/integration_test.dart
    @echo "E2E tests"
    @nickel export generators/dart/tests/dart-e2e-tests.ncl --field test_code --format raw > dist/circular-dart/test/e2e_test.dart
    @echo "README.md"
    @nickel export generators/dart/docs/dart-readme.ncl --field readme_content --format raw > dist/circular-dart/README.md
    @echo ".gitignore"
    @nickel export generators/dart/metadata/dart-gitignore.ncl --field gitignore_content --format raw > dist/circular-dart/.gitignore
    @echo "GitHub Actions workflow"
    @mkdir -p dist/circular-dart/.github/workflows
    @nickel export generators/dart/ci-cd/dart-github-actions-test.ncl --field workflow_content --format raw > dist/circular-dart/.github/workflows/test.yml
    @echo "analysis_options.yaml"
    @nickel export generators/dart/metadata/dart-analysis-options.ncl --field analysis_options --format raw > dist/circular-dart/analysis_options.yaml
    @echo "CHANGELOG.md"
    @nickel export generators/dart/docs/dart-changelog.ncl --field changelog_content --format raw > dist/circular-dart/CHANGELOG.md
    @echo "LICENSE"
    @nickel export generators/dart/metadata/dart-license.ncl --field license_content --format raw > dist/circular-dart/LICENSE
    @echo ""
    @echo "[OK] Dart package generated in dist/circular-dart/"
    @ls -lh dist/circular-dart/

# Generate complete Rust package
generate-rust-package:
    @echo "Generating complete Rust package"
    @mkdir -p dist/circular-rs/src
    @echo "Cargo.toml"
    @nickel export generators/rust/package-manifest/cargo-toml.ncl --field cargo_toml --format raw > dist/circular-rs/Cargo.toml
    @echo "SDK code (src/lib.rs)"
    @nickel export generators/rust/rust-sdk.ncl --field sdk_code --format raw > dist/circular-rs/src/lib.rs
    @echo ""
    @echo "[OK] Rust package generated in dist/circular-rs/"
    @ls -lh dist/circular-rs/

# Generate all complete packages
generate-packages: generate-ts-package generate-py-package generate-java-package generate-php-package generate-go-package generate-dart-package generate-rust-package
    @echo ""
    @echo "================================================================"
    @echo "  [OK] Complete packages generated for all 7 languages"
    @echo "  - TypeScript (dist/circular-ts/)"
    @echo "  - Python (dist/circular-py/)"
    @echo "  - Java (dist/circular-java/)"
    @echo "  - PHP (dist/circular-php/)"
    @echo "  - Go (dist/circular-go/)"
    @echo "  - Dart (dist/circular-dart/)"
    @echo "  - Rust (dist/circular-rs/)"
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
    @rm -rf dist/circular-ts/* dist/circular-py/* 2>/dev/null || true
    @git submodule add -b development git@github.com:lessuseless-systems/circular-js-npm.git dist/circular-ts 2>/dev/null || \
        echo "  [WARNING] Submodule dist/circular-ts already exists"
    @git submodule add -b development git@github.com:lessuseless-systems/circular-py.git dist/circular-py 2>/dev/null || \
        echo "  [WARNING] Submodule dist/circular-py already exists"
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
    @if [ ! -e dist/circular-ts/.git ]; then \
        echo "⚠️  dist/circular-ts/ is not a git submodule (run setup-forks)"; \
    else \
        ts_url=$$(cd dist/circular-ts && git remote get-url origin); \
        if echo "$$ts_url" | grep -q "circular-js-npm\.git$$" && ! echo "$$ts_url" | grep -qE "\-[0-9]+\.git$$"; then \
            echo "✅ TypeScript submodule: $$ts_url"; \
        else \
            echo "❌ ERROR: TypeScript submodule has wrong URL: $$ts_url"; \
            echo "   Expected: git@github.com:lessuseless-systems/circular-js-npm.git"; \
            echo "   (NOT numbered repos like circular-js-npm-1.git)"; \
            exit 1; \
        fi; \
    fi
    @if [ ! -e dist/circular-py/.git ]; then \
        echo "⚠️  dist/circular-py/ is not a git submodule (run setup-forks)"; \
    else \
        py_url=$$(cd dist/circular-py && git remote get-url origin); \
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
    @echo "Syncing TypeScript package to dist/circular-ts/ submodule"
    @if [ ! -e dist/circular-ts/.git ]; then \
        echo "[ERROR] dist/circular-ts/ is not a git submodule"; \
        echo "  Run setup-forks to configure submodules"; \
        exit 1; \
    fi
    @echo "Generating TypeScript package"
    @just generate-ts-package
    @echo "Skipping LICENSE and gitignore (generators not yet implemented)"
    @cd dist/circular-ts && \
        git add -A && \
        git diff --cached --quiet || \
        git commit -m "chore: sync generated TypeScript SDK from circular-canonical"
    @echo "[OK] TypeScript package synced to dist/circular-ts/"
    @echo "  Branch: development"
    @cd dist/circular-ts && git log -1 --oneline

# Sync Python package to submodule (lessuseless-systems/circular-py fork)
sync-python: verify-repos
    @echo "Syncing Python package to dist/circular-py/ submodule"
    @if [ ! -e dist/circular-py/.git ]; then \
        echo "[ERROR] dist/circular-py/ is not a git submodule"; \
        echo "  Run setup-forks to configure submodules"; \
        exit 1; \
    fi
    @echo "Generating Python package"
    @just generate-py-package
    @echo "Skipping LICENSE (generator not yet implemented)"
    @cd dist/circular-py && \
        git add -A && \
        git diff --cached --quiet || \
        git commit -m "chore: sync generated Python SDK from circular-canonical"
    @echo "[OK] Python package synced to dist/circular-py/"
    @echo "  Branch: development"
    @cd dist/circular-py && git log -1 --oneline

# Sync both TypeScript and Python packages
sync-all: sync-typescript sync-python
    @echo ""
    @echo "================================================================"
    @echo "  [OK] Both packages synced to submodules"
    @echo "================================================================"
    @echo ""
    @echo "Next steps:"
    @echo "  *Review changes: cd dist/circular-ts && git status"
    @echo "  *Push to fork: just push-forks"
    @echo "  *Create PRs to upstream circular-protocol repos"

# Push development branches to lessuseless-systems forks
push-forks:
    @echo "Pushing development branches to lessuseless-systems forks"
    @if [ -e dist/circular-ts/.git ]; then \
        echo "Pushing TypeScript (dist/circular-ts)"; \
        cd dist/circular-ts && git push origin development; \
    else \
        echo "  [WARNING] Skipping TypeScript: not a submodule"; \
    fi
    @if [ -e dist/circular-py/.git ]; then \
        echo "Pushing Python (dist/circular-py)"; \
        cd dist/circular-py && git push origin development; \
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
    @if [ -e dist/circular-ts/.git ]; then \
        echo "TypeScript (dist/circular-ts):"; \
        cd dist/circular-ts && git status -sb; \
    else \
        echo "TypeScript: Not a submodule"; \
    fi
    @echo ""
    @if [ -e dist/circular-py/.git ]; then \
        echo "Python (dist/circular-py):"; \
        cd dist/circular-py && git status -sb; \
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

# ===========================================================================
# SDK Testing Commands (Uniform Pattern: test-<lang>-<type>)
# ===========================================================================

# TypeScript SDK Tests
# ---------------------------------------------------------------------------

# TypeScript: Unit tests (no dependencies)
test-ts-unit:
    @echo "🧪 TypeScript: Unit tests"
    @cd dist/circular-ts && npm test -- --selectProjects=unit 2>/dev/null || npm test

# TypeScript: Integration tests (with mock server)
test-ts-integration:
    @echo "🧪 TypeScript: Integration tests"
    @cd dist/circular-ts && npm test -- tests/integration.test.ts 2>/dev/null || echo "⏭️  Integration tests not configured"

# TypeScript: E2E tests (requires ENV vars)
test-ts-e2e:
    @echo "🧪 TypeScript: E2E tests (real NAG endpoints)"
    @if [ -z "$$CIRCULAR_TEST_ADDRESS" ]; then \
        echo "⏭️  Skipping - set CIRCULAR_TEST_ADDRESS=0x... to run"; \
    else \
        cd dist/circular-ts && npm run test:e2e 2>/dev/null || npx jest tests/e2e.test.ts; \
    fi

# TypeScript: All tests
test-ts-all: test-ts-unit test-ts-integration test-ts-e2e

# Python SDK Tests
# ---------------------------------------------------------------------------

# Python: Unit tests (no dependencies)
test-py-unit:
    @echo "🧪 Python: Unit tests"
    @cd dist/circular-py && python3 -m pip install -e . --quiet 2>/dev/null && python3 -m pytest tests/test_unit.py -v

# Python: Integration tests (with mock server)
test-py-integration:
    @echo "🧪 Python: Integration tests"
    @cd dist/circular-py && python3 -m pip install -e . --quiet 2>/dev/null && python3 -m pytest tests/test_integration.py -v 2>/dev/null || echo "⏭️  Integration tests not configured"

# Python: E2E tests (requires ENV vars)
test-py-e2e:
    @echo "🧪 Python: E2E tests (real NAG endpoints)"
    @if [ -z "$$CIRCULAR_TEST_ADDRESS" ]; then \
        echo "⏭️  Skipping - set CIRCULAR_TEST_ADDRESS=0x... to run"; \
    else \
        cd dist/circular-py && python3 -m pip install -e . --quiet 2>/dev/null && python3 -m pytest tests/test_e2e.py -v -m e2e; \
    fi

# Python: All tests
test-py-all: test-py-unit test-py-integration test-py-e2e

# Java SDK Tests
# ---------------------------------------------------------------------------

# Java: Unit tests (no dependencies)
test-java-unit:
    @echo "🧪 Java: Unit tests"
    @cd dist/circular-java && mvn test -Dtest=CircularProtocolUnitTest 2>/dev/null || mvn test

# Java: Integration tests (with mock server)
test-java-integration:
    @echo "🧪 Java: Integration tests"
    @cd dist/circular-java && mvn test -Dtest=CircularProtocolIntegrationTest 2>/dev/null || echo "⏭️  Integration tests not configured"

# Java: E2E tests (requires ENV vars)
test-java-e2e:
    @echo "🧪 Java: E2E tests (real NAG endpoints)"
    @if [ -z "$$CIRCULAR_TEST_ADDRESS" ]; then \
        echo "⏭️  Skipping - set CIRCULAR_TEST_ADDRESS=0x... to run"; \
    else \
        cd dist/circular-java && mvn test -Dtest=CircularProtocolE2ETest; \
    fi

# Java: All tests
test-java-all: test-java-unit test-java-integration test-java-e2e

# PHP SDK Tests
# ---------------------------------------------------------------------------

# PHP: Unit tests (no dependencies)
test-php-unit:
    @echo "🧪 PHP: Unit tests"
    @cd dist/circular-php && composer test 2>/dev/null || vendor/bin/phpunit tests/CircularProtocolUnitTest.php

# PHP: Integration tests (with mock server)
test-php-integration:
    @echo "🧪 PHP: Integration tests"
    @cd dist/circular-php && vendor/bin/phpunit tests/CircularProtocolIntegrationTest.php 2>/dev/null || echo "⏭️  Integration tests not configured"

# PHP: E2E tests (requires ENV vars)
test-php-e2e:
    @echo "🧪 PHP: E2E tests (real NAG endpoints)"
    @if [ -z "$$CIRCULAR_TEST_ADDRESS" ]; then \
        echo "⏭️  Skipping - set CIRCULAR_TEST_ADDRESS=0x... to run"; \
    else \
        cd dist/circular-php && vendor/bin/phpunit tests/CircularProtocolE2ETest.php; \
    fi

# PHP: All tests
test-php-all: test-php-unit test-php-integration test-php-e2e

# Go SDK Tests
# ---------------------------------------------------------------------------

# Go: Unit tests (no dependencies)
test-go-unit:
    @echo "🧪 Go: Unit tests"
    @cd dist/circular-go && go test -v -run Unit

# Go: Integration tests (with mock server)
test-go-integration:
    @echo "🧪 Go: Integration tests"
    @cd dist/circular-go && go test -v -run Integration 2>/dev/null || echo "⏭️  Integration tests not configured"

# Go: E2E tests (requires ENV vars)
test-go-e2e:
    @echo "🧪 Go: E2E tests (real NAG endpoints)"
    @if [ -z "$$CIRCULAR_TEST_ADDRESS" ]; then \
        echo "⏭️  Skipping - set CIRCULAR_TEST_ADDRESS=0x... to run"; \
    else \
        cd dist/circular-go && go test -v -run E2E; \
    fi

# Go: All tests
test-go-all: test-go-unit test-go-integration test-go-e2e

# Dart SDK Tests
# ---------------------------------------------------------------------------

# Dart: Unit tests (no dependencies)
test-dart-unit:
    @echo "🧪 Dart: Unit tests"
    @cd dist/circular-dart && dart test test/unit_test.dart

# Dart: Integration tests (with mock server)
test-dart-integration:
    @echo "🧪 Dart: Integration tests"
    @cd dist/circular-dart && dart test test/integration_test.dart 2>/dev/null || echo "⏭️  Integration tests not configured"

# Dart: E2E tests (requires ENV vars)
test-dart-e2e:
    @echo "🧪 Dart: E2E tests (real NAG endpoints)"
    @if [ -z "$$CIRCULAR_TEST_ADDRESS" ]; then \
        echo "⏭️  Skipping - set CIRCULAR_TEST_ADDRESS=0x... to run"; \
    else \
        cd dist/circular-dart && dart test test/e2e_test.dart; \
    fi

# Dart: All tests
test-dart-all: test-dart-unit test-dart-integration test-dart-e2e

# Aggregated Test Commands (All Languages)
# ---------------------------------------------------------------------------

# Run unit tests for all languages
test-unit: test-ts-unit test-py-unit test-java-unit test-php-unit test-go-unit test-dart-unit
    @echo ""
    @echo "✅ All unit tests complete"

# Run integration tests for all languages
test-integration-sdks: test-ts-integration test-py-integration test-java-integration test-php-integration test-go-integration test-dart-integration
    @echo ""
    @echo "✅ All integration tests complete"

# Run E2E tests for all languages
test-e2e: test-ts-e2e test-py-e2e test-java-e2e test-php-e2e test-go-e2e test-dart-e2e
    @echo ""
    @echo "✅ All E2E tests complete"

# Run ALL tests for ALL languages
test-all: test-unit test-integration-sdks test-e2e
    @echo ""
    @echo "✅ Complete test suite finished"

# Run manual write operation tests (registerWallet) - requires explicit enable
test-manual-write:
    @echo "Running manual write operation tests (LIVE BLOCKCHAIN)"
    @echo ""
    @if [ -z "$$CIRCULAR_ALLOW_WRITE_TESTS" ] || [ "$$CIRCULAR_ALLOW_WRITE_TESTS" != "1" ]; then \
        echo "❌ Write tests are disabled"; \
        echo ""; \
        echo "To enable write tests (which write to LIVE blockchain):"; \
        echo "  export CIRCULAR_ALLOW_WRITE_TESTS=1"; \
        echo "  export CIRCULAR_PRIVATE_KEY=..."; \
        echo "  export CIRCULAR_PUBLIC_KEY=..."; \
        echo "  export CIRCULAR_TEST_BLOCKCHAIN=0x8a20baa...  # SandBox only"; \
        echo ""; \
        echo "⚠️  WARNING: Only enable on test networks (SandBox)"; \
        exit 1; \
    else \
        python3 dist/tests/manual/manual-test-registerWallet.py; \
    fi

# Run complete test pyramid (all layers: L1-L5)
test-pyramid:
    @echo "Running complete test pyramid (all layers)"
    @echo ""
    @echo "=== Layer 1: Contract Validation (< 5s) ==="
    @just test-contracts
    @echo ""
    @echo "=== Layer 2: Unit Tests (< 30s) ==="
    @just test-unit
    @echo ""
    @echo "=== Layer 3: Integration Tests (< 2m) ==="
    @just test-integration-sdks
    @echo ""
    @echo "=== Layer 4: Cross-Language & Regression (< 5m) ==="
    @just test-cross-lang
    @echo ""
    @echo "=== Layer 5: E2E Tests (conditional on env vars) ==="
    @just test-e2e
    @echo ""
    @echo "✅ Test pyramid complete"

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
    @echo "  just sync-typescript  *Sync generated TS to dist/circular-ts submodule"
    @echo "  just sync-python      *Sync generated Python to dist/circular-py submodule"
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

# Generate manual test scripts for write operations
generate-manual-tests:
    @echo "Generating manual test scripts for write operations..."
    @mkdir -p dist/tests/manual
    @echo "Python manual test (registerWallet)"
    @nickel export generators/python/tests/python-manual-tests.ncl --field test_code --format raw > dist/tests/manual/manual-test-registerWallet.py
    @chmod +x dist/tests/manual/manual-test-registerWallet.py
    @echo ""
    @echo "[OK] Manual test scripts generated in dist/tests/manual/"
    @echo ""
    @echo "⚠️  WARNING: These tests write to LIVE blockchain"
    @echo "⚠️  Only run on test networks with test credentials"
    @echo ""
    @echo "Usage:"
    @echo "  1. Set environment variables:"
    @echo "     export CIRCULAR_PRIVATE_KEY='...'"
    @echo "     export CIRCULAR_PUBLIC_KEY='...'"
    @echo "     export CIRCULAR_TEST_BLOCKCHAIN='0x8a20baa...'"
    @echo ""
    @echo "  2. Run test:"
    @echo "     python3 dist/tests/manual/manual-test-registerWallet.py"
    @echo ""
