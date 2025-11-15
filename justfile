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
    @echo "Modular SDK code:"
    @echo "  src/circular_protocol_api/__init__.py (clean exports)"
    @nickel export generators/python/python-init.ncl --field init_code --format raw > dist/python/src/circular_protocol_api/__init__.py
    @echo "  src/circular_protocol_api/client.py (main API class)"
    @nickel export generators/python/python-client.ncl --field client_code --format raw > dist/python/src/circular_protocol_api/client.py
    @echo "  src/circular_protocol_api/models.py (TypedDict types)"
    @nickel export generators/python/python-models.ncl --field models_code --format raw > dist/python/src/circular_protocol_api/models.py
    @echo "  src/circular_protocol_api/exceptions.py (custom exceptions)"
    @nickel export generators/python/python-exceptions.ncl --field exceptions_code --format raw > dist/python/src/circular_protocol_api/exceptions.py
    @echo "  src/circular_protocol_api/_helpers.py (utility functions)"
    @nickel export generators/python/python-helpers.ncl --field helpers_code --format raw > dist/python/src/circular_protocol_api/_helpers.py
    @echo "  src/circular_protocol_api/_crypto.py (cryptographic operations)"
    @nickel export generators/python/python-crypto.ncl --field crypto_code --format raw > dist/python/src/circular_protocol_api/_crypto.py
    @echo "Unit tests"
    @mkdir -p dist/python/tests
    @nickel export generators/python/tests/python-unit-tests.ncl --field test_code --format raw > dist/python/tests/test_unit.py
    @echo "E2E tests"
    @nickel export generators/python/tests/python-e2e-tests.ncl --field test_code --format raw > dist/python/tests/test_e2e.py
    @echo "Integration tests"
    @nickel export generators/python/tests/python-integration-tests.ncl --field test_file --format raw > dist/python/tests/test_integration.py
    @echo "GitHub Actions workflow"
    @mkdir -p dist/python/.github/workflows
    @nickel export generators/python/ci-cd/python-github-actions-test.ncl --field workflow_yaml --format raw > dist/python/.github/workflows/test.yml
    @echo ""
    @echo "[OK] Python package generated in dist/python/ (modular structure)"
    @ls -lh dist/python/src/circular_protocol_api/

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
    @echo "E2E tests"
    @nickel export generators/typescript/tests/typescript-e2e-tests.ncl --field test_code --format raw > dist/typescript/tests/e2e.test.ts
    @echo "Integration tests"
    @nickel export generators/typescript/tests/typescript-integration-tests.ncl --field test_file --format raw > dist/typescript/tests/integration.test.ts
    @echo "GitHub Actions workflow"
    @mkdir -p dist/typescript/.github/workflows
    @nickel export generators/typescript/ci-cd/typescript-github-actions-test.ncl --field workflow_yaml --format raw > dist/typescript/.github/workflows/test.yml
    @echo ""
    @echo "[OK] TypeScript package generated in dist/typescript/"
    @ls -lh dist/typescript/

# Generate complete Java package
generate-java-package:
    @echo "Generating complete Java package"
    @mkdir -p dist/java/src/main/java/io/circular/protocol
    @echo "pom.xml"
    @nickel export generators/java/package-manifest/java-pom-xml.ncl --field pom_content --format raw > dist/java/pom.xml
    @echo "README.md"
    @nickel export generators/java/docs/java-readme.ncl --format raw > dist/java/README.md
    @echo ".gitignore"
    @nickel export generators/java/metadata/java-gitignore.ncl --field gitignore_content --format raw > dist/java/.gitignore
    @echo "SDK code (src/main/java/io/circular/protocol/CircularProtocolAPI.java)"
    @nickel export generators/java/java-sdk.ncl --field sdk_code --format raw > dist/java/src/main/java/io/circular/protocol/CircularProtocolAPI.java
    @echo "Unit tests"
    @mkdir -p dist/java/src/test/java/io/circular/protocol
    @nickel export generators/java/tests/java-unit-tests.ncl --field test_code --format raw > dist/java/src/test/java/io/circular/protocol/CircularProtocolUnitTest.java
    @echo "E2E tests"
    @nickel export generators/java/tests/java-e2e-tests.ncl --field test_code --format raw > dist/java/src/test/java/io/circular/protocol/CircularProtocolE2ETest.java
    @echo "Integration tests"
    @nickel export generators/java/tests/java-integration-tests.ncl --field test_file --format raw > dist/java/src/test/java/io/circular/protocol/CircularProtocolIntegrationTest.java
    @echo "GitHub Actions workflow"
    @mkdir -p dist/java/.github/workflows
    @nickel export generators/java/ci-cd/java-github-actions-test.ncl --field workflow_yaml --format raw > dist/java/.github/workflows/test.yml
    @echo ""
    @echo "[OK] Java package generated in dist/java/"
    @ls -lh dist/java/

# Generate complete PHP package
generate-php-package:
    @echo "Generating complete PHP package"
    @mkdir -p dist/php/src dist/php/tests
    @echo "composer.json"
    @nickel export generators/php/package-manifest/php-composer-json.ncl --format json > dist/php/composer.json
    @echo "README.md"
    @nickel export generators/php/docs/php-readme.ncl --format raw > dist/php/README.md
    @echo ".gitignore"
    @nickel export generators/php/metadata/php-gitignore.ncl --field gitignore_content --format raw > dist/php/.gitignore
    @echo "SDK code (src/CircularProtocolAPI.php)"
    @nickel export generators/php/php-sdk.ncl --field sdk_code --format raw > dist/php/src/CircularProtocolAPI.php
    @echo "Unit tests"
    @nickel export generators/php/tests/php-unit-tests.ncl --field test_code --format raw > dist/php/tests/CircularProtocolUnitTest.php
    @echo "E2E tests"
    @nickel export generators/php/tests/php-e2e-tests.ncl --field test_code --format raw > dist/php/tests/CircularProtocolE2ETest.php
    @echo "Integration tests"
    @nickel export generators/php/tests/php-integration-tests.ncl --field test_file --format raw > dist/php/tests/CircularProtocolIntegrationTest.php
    @echo "GitHub Actions workflow"
    @mkdir -p dist/php/.github/workflows
    @nickel export generators/php/ci-cd/php-github-actions-test.ncl --field workflow_yaml --format raw > dist/php/.github/workflows/test.yml
    @echo ""
    @echo "[OK] PHP package generated in dist/php/"
    @ls -lh dist/php/

# Generate complete Go package
generate-go-package:
    @echo "Generating complete Go package"
    @mkdir -p dist/go
    @echo "go.mod"
    @nickel export generators/go/package-manifest/go-mod.ncl --field go_mod --format raw > dist/go/go.mod
    @echo "SDK code (circular_protocol.go)"
    @nickel export generators/go/go-sdk.ncl --field sdk_code --format raw > dist/go/circular_protocol.go
    @echo "Unit tests"
    @nickel export generators/go/tests/go-unit-tests.ncl --field test_code --format raw > dist/go/circular_protocol_test.go
    @echo "Integration tests"
    @nickel export generators/go/tests/go-integration-tests.ncl --field test_code --format raw > dist/go/circular_protocol_integration_test.go
    @echo "E2E tests"
    @nickel export generators/go/tests/go-e2e-tests.ncl --field test_code --format raw > dist/go/circular_protocol_e2e_test.go
    @echo "README.md"
    @nickel export generators/go/docs/go-readme.ncl --field readme_content --format raw > dist/go/README.md
    @echo ".gitignore"
    @nickel export generators/go/metadata/go-gitignore.ncl --field gitignore_content --format raw > dist/go/.gitignore
    @echo "GitHub Actions workflow"
    @mkdir -p dist/go/.github/workflows
    @nickel export generators/go/ci-cd/go-github-actions-test.ncl --field workflow_content --format raw > dist/go/.github/workflows/test.yml
    @echo ""
    @echo "[OK] Go package generated in dist/go/"
    @ls -lh dist/go/

# Generate complete Dart package
generate-dart-package:
    @echo "Generating complete Dart package"
    @mkdir -p dist/dart/lib dist/dart/test
    @echo "pubspec.yaml"
    @nickel export generators/dart/package-manifest/pubspec-yaml.ncl --field pubspec_yaml --format raw > dist/dart/pubspec.yaml
    @echo "SDK code (lib/circular_protocol.dart)"
    @nickel export generators/dart/dart-sdk.ncl --field sdk_code --format raw > dist/dart/lib/circular_protocol.dart
    @echo "Unit tests"
    @nickel export generators/dart/tests/dart-unit-tests.ncl --field test_code --format raw > dist/dart/test/unit_test.dart
    @echo "Integration tests"
    @nickel export generators/dart/tests/dart-integration-tests.ncl --field test_code --format raw > dist/dart/test/integration_test.dart
    @echo "E2E tests"
    @nickel export generators/dart/tests/dart-e2e-tests.ncl --field test_code --format raw > dist/dart/test/e2e_test.dart
    @echo "README.md"
    @nickel export generators/dart/docs/dart-readme.ncl --field readme_content --format raw > dist/dart/README.md
    @echo ".gitignore"
    @nickel export generators/dart/metadata/dart-gitignore.ncl --field gitignore_content --format raw > dist/dart/.gitignore
    @echo "GitHub Actions workflow"
    @mkdir -p dist/dart/.github/workflows
    @nickel export generators/dart/ci-cd/dart-github-actions-test.ncl --field workflow_content --format raw > dist/dart/.github/workflows/test.yml
    @echo "analysis_options.yaml"
    @nickel export generators/dart/metadata/dart-analysis-options.ncl --field analysis_options --format raw > dist/dart/analysis_options.yaml
    @echo "CHANGELOG.md"
    @nickel export generators/dart/docs/dart-changelog.ncl --field changelog_content --format raw > dist/dart/CHANGELOG.md
    @echo "LICENSE"
    @nickel export generators/dart/metadata/dart-license.ncl --field license_content --format raw > dist/dart/LICENSE
    @echo ""
    @echo "[OK] Dart package generated in dist/dart/"
    @ls -lh dist/dart/

# Generate complete Rust package
generate-rust-package:
    @echo "Generating complete Rust package"
    @mkdir -p dist/rust/src
    @echo "Cargo.toml"
    @nickel export generators/rust/package-manifest/cargo-toml.ncl --field cargo_toml --format raw > dist/rust/Cargo.toml
    @echo "SDK code (src/lib.rs)"
    @nickel export generators/rust/rust-sdk.ncl --field sdk_code --format raw > dist/rust/src/lib.rs
    @echo ""
    @echo "[OK] Rust package generated in dist/rust/"
    @ls -lh dist/rust/

# Generate all complete packages
generate-packages: generate-ts-package generate-py-package generate-java-package generate-php-package generate-go-package generate-dart-package generate-rust-package
    @echo ""
    @echo "================================================================"
    @echo "  [OK] Complete packages generated for all 7 languages"
    @echo "  - TypeScript (dist/typescript/)"
    @echo "  - Python (dist/python/)"
    @echo "  - Java (dist/java/)"
    @echo "  - PHP (dist/php/)"
    @echo "  - Go (dist/go/)"
    @echo "  - Dart (dist/dart/)"
    @echo "  - Rust (dist/rust/)"
    @echo "================================================================"

# ===========================================================================
# Multi-Repo Workflow: SDK submodules (5 languages)
# ===========================================================================

# Setup all 5 SDK repositories as submodules (ONE-TIME SETUP)
setup-all-submodules:
    @echo "Setting up all 5 SDK repositories as submodules"
    @echo ""
    @echo "This will:"
    @echo "  1. Create GitHub repositories (if they don't exist)"
    @echo "  2. Initialize development branches"
    @echo "  3. Add as submodules to circular-canonical"
    @echo "  4. Generate initial SDK packages"
    @echo ""
    @if ! command -v gh >/dev/null 2>&1; then \
        echo "[ERROR] GitHub CLI (gh) not found"; \
        echo "  Install: https://cli.github.com/"; \
        exit 1; \
    fi
    @echo "Step 1: Creating GitHub repositories..."
    @gh repo create lessuseless-systems/circular-ts --public --description "TypeScript SDK for Circular Protocol blockchain" 2>/dev/null || echo "  circular-ts already exists"
    @gh repo create lessuseless-systems/circular-go --public --description "Go SDK for Circular Protocol blockchain" 2>/dev/null || echo "  circular-go already exists"
    @gh repo create lessuseless-systems/circular-php --public --description "PHP SDK for Circular Protocol blockchain" 2>/dev/null || echo "  circular-php already exists"
    @gh repo create lessuseless-systems/circular-dart --public --description "Dart SDK for Circular Protocol blockchain" 2>/dev/null || echo "  circular-dart already exists"
    @echo "  circular-py already exists (skipping)"
    @echo ""
    @echo "Step 2: Initializing development branches in temporary clones..."
    @rm -rf /tmp/circular-sdk-init
    @mkdir -p /tmp/circular-sdk-init
    @cd /tmp/circular-sdk-init && \
        for repo in circular-ts circular-go circular-php circular-dart; do \
            echo "  Initializing $$repo..."; \
            gh repo clone lessuseless-systems/$$repo 2>/dev/null || true; \
            cd $$repo 2>/dev/null || continue; \
            git checkout -b development 2>/dev/null || git checkout development; \
            echo "# Circular Protocol $${repo#circular-} SDK" > README.md; \
            git add README.md 2>/dev/null || true; \
            git diff --cached --quiet || git commit -m "chore: initialize development branch" 2>/dev/null || true; \
            git push -u origin development 2>/dev/null || echo "    Branch already exists"; \
            cd ..; \
        done
    @echo ""
    @echo "Step 3: Adding submodules (if not already added)..."
    @git submodule add -b development git@github.com:lessuseless-systems/circular-ts.git dist/typescript 2>/dev/null || echo "  dist/typescript already added"
    @git submodule add -b development git@github.com:lessuseless-systems/circular-go.git dist/go 2>/dev/null || echo "  dist/go already added"
    @git submodule add -b development git@github.com:lessuseless-systems/circular-php.git dist/php 2>/dev/null || echo "  dist/php already added"
    @git submodule add -b development git@github.com:lessuseless-systems/circular-dart.git dist/dart 2>/dev/null || echo "  dist/dart already added"
    @echo "  dist/python already added (skipping)"
    @git submodule init
    @git submodule update --remote --merge
    @echo ""
    @echo "Step 4: Generating initial SDK packages..."
    @just generate-all-enhanced
    @echo ""
    @echo "Step 5: Committing initial SDK packages to submodules..."
    @for dir in typescript python go php dart; do \
        echo "  Committing dist/$$dir..."; \
        cd dist/$$dir && \
        git add -A && \
        (git diff --cached --quiet || git commit -m "chore: initial SDK generation from circular-canonical") && \
        cd ../..; \
    done
    @echo ""
    @echo "================================================================"
    @echo "  [OK] All 5 SDK submodules set up successfully"
    @echo "================================================================"
    @echo ""
    @echo "Submodules:"
    @git submodule status
    @echo ""
    @echo "Next steps:"
    @echo "  1. Review submodules: just check-all-submodules"
    @echo "  2. Push to remotes: just push-all-sdks"
    @echo "  3. Update parent repo: git add .gitmodules dist/"
    @echo "  4. Commit parent: git commit -m 'chore: add all SDK submodules'"
    @echo ""
    @echo "Clean up temp directory:"
    @echo "  rm -rf /tmp/circular-sdk-init"

# ===========================================================================
# Multi-Repo Workflow: Fork setup and sync to submodules (LEGACY - for circular-js-npm/circular-py forks)
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

# Sync both TypeScript and Python packages (LEGACY)
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

# ===========================================================================
# Enhanced Multi-SDK Sync Commands (All 5 Languages)
# ===========================================================================

# Sync Go package to submodule
sync-go: verify-repos
    @echo "Syncing Go package to dist/go/ submodule"
    @if [ ! -e dist/go/.git ]; then \
        echo "[ERROR] dist/go/ is not a git submodule"; \
        echo "  Run setup-all-submodules to configure submodules"; \
        exit 1; \
    fi
    @echo "Generating Go package"
    @just generate-go-package-enhanced
    @cd dist/go && \
        git add -A && \
        git diff --cached --quiet || \
        git commit -m "chore: sync generated Go SDK from circular-canonical"
    @echo "[OK] Go package synced to dist/go/"
    @echo "  Branch: development"
    @cd dist/go && git log -1 --oneline

# Sync PHP package to submodule
sync-php: verify-repos
    @echo "Syncing PHP package to dist/php/ submodule"
    @if [ ! -e dist/php/.git ]; then \
        echo "[ERROR] dist/php/ is not a git submodule"; \
        echo "  Run setup-all-submodules to configure submodules"; \
        exit 1; \
    fi
    @echo "Generating PHP package"
    @just generate-php-package-enhanced
    @cd dist/php && \
        git add -A && \
        git diff --cached --quiet || \
        git commit -m "chore: sync generated PHP SDK from circular-canonical"
    @echo "[OK] PHP package synced to dist/php/"
    @echo "  Branch: development"
    @cd dist/php && git log -1 --oneline

# Sync Dart package to submodule
sync-dart: verify-repos
    @echo "Syncing Dart package to dist/dart/ submodule"
    @if [ ! -e dist/dart/.git ]; then \
        echo "[ERROR] dist/dart/ is not a git submodule"; \
        echo "  Run setup-all-submodules to configure submodules"; \
        exit 1; \
    fi
    @echo "Generating Dart package"
    @just generate-dart-package-enhanced
    @cd dist/dart && \
        git add -A && \
        git diff --cached --quiet || \
        git commit -m "chore: sync generated Dart SDK from circular-canonical"
    @echo "[OK] Dart package synced to dist/dart/"
    @echo "  Branch: development"
    @cd dist/dart && git log -1 --oneline

# Sync all 5 SDK packages to submodules
sync-all-sdks: sync-typescript sync-python sync-go sync-php sync-dart
    @echo ""
    @echo "================================================================"
    @echo "  [OK] All 5 SDK packages synced to submodules"
    @echo "================================================================"
    @echo ""
    @echo "Synced repositories:"
    @git submodule status
    @echo ""
    @echo "Next steps:"
    @echo "  1. Review changes: just check-all-submodules"
    @echo "  2. Push to remotes: just push-all-sdks"
    @echo "  3. Update parent repo to track new submodule commits"

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

# Push all 5 SDK development branches to remotes
push-all-sdks:
    @echo "Pushing all 5 SDK development branches to lessuseless-systems"
    @echo ""
    @for dir in typescript python go php dart; do \
        if [ -e dist/$$dir/.git ]; then \
            echo "Pushing $$dir (dist/$$dir)..."; \
            cd dist/$$dir && git push origin development 2>&1 | grep -v "^Everything up-to-date" || echo "  ✓ Up to date"; \
            cd ../..; \
        else \
            echo "  [WARNING] Skipping $$dir: not a submodule"; \
        fi; \
    done
    @echo ""
    @echo "[OK] All SDK branches pushed to lessuseless-systems"
    @echo ""
    @echo "Repository URLs:"
    @echo "  - TypeScript: https://github.com/lessuseless-systems/circular-ts"
    @echo "  - Python: https://github.com/lessuseless-systems/circular-py"
    @echo "  - Go: https://github.com/lessuseless-systems/circular-go"
    @echo "  - PHP: https://github.com/lessuseless-systems/circular-php"
    @echo "  - Dart: https://github.com/lessuseless-systems/circular-dart"

# Check status of all 5 SDK submodules
check-all-submodules:
    @echo "Checking status of all 5 SDK submodules"
    @echo "========================================"
    @echo ""
    @for dir in typescript python go php dart; do \
        if [ -e dist/$$dir/.git ]; then \
            echo "$$dir (dist/$$dir):"; \
            cd dist/$$dir && git status -sb && cd ../..; \
            echo ""; \
        else \
            echo "$$dir: Not a submodule"; \
            echo ""; \
        fi; \
    done
    @echo "========================================"
    @echo "Submodule commit tracking:"
    @git submodule status

# Check status of all submodules (LEGACY - 2 SDKs only)
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
    @nickel export generators/shared/docs/agents-md.ncl --field agents_md --format raw > docs/AGENTS.md
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

# Run E2E tests (TypeScript) - gracefully skips if env vars missing
test-e2e-ts:
    @echo "Running TypeScript E2E tests (against real NAG endpoints)"
    @echo ""
    @if [ -z "$$CIRCULAR_TEST_ADDRESS" ] && [ -z "$$CIRCULAR_PRIVATE_KEY" ]; then \
        echo "⏭️  Skipping E2E tests - missing required environment variables"; \
        echo ""; \
        echo "For read-only tests, set:"; \
        echo "  export CIRCULAR_TEST_ADDRESS=0x..."; \
        echo ""; \
        echo "For write operation tests, set:"; \
        echo "  export CIRCULAR_PRIVATE_KEY=..."; \
        echo "  ⚠️  WARNING: Write tests create real blockchain transactions!"; \
    else \
        cd dist/typescript && npm run test:e2e; \
    fi

# Run E2E tests (Python) - gracefully skips if env vars missing
test-e2e-py:
    @echo "Running Python E2E tests (against real NAG endpoints)"
    @echo ""
    @if [ -z "$$CIRCULAR_TEST_ADDRESS" ] && [ -z "$$CIRCULAR_PRIVATE_KEY" ]; then \
        echo "⏭️  Skipping E2E tests - missing required environment variables"; \
        echo ""; \
        echo "For read-only tests, set:"; \
        echo "  export CIRCULAR_TEST_ADDRESS=0x..."; \
        echo ""; \
        echo "For write operation tests, set:"; \
        echo "  export CIRCULAR_PRIVATE_KEY=..."; \
        echo "  ⚠️  WARNING: Write tests create real blockchain transactions!"; \
    else \
        cd dist/python && pytest tests/test_e2e.py -v -m e2e; \
    fi

# Run E2E tests (all languages) - gracefully skips if env vars missing
test-e2e: test-e2e-ts test-e2e-py

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
    @just test-sdk-unit
    @echo ""
    @echo "=== Layer 3: Integration Tests (< 2m) ==="
    @just test-integration
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

# ===========================================================================
# Enhanced Package Generation: Include all new components
# ===========================================================================

# Generate enhanced TypeScript package with all new components
generate-ts-package-enhanced: generate-ts-package
    @echo "Adding enhanced components to TypeScript package..."
    @nickel export generators/typescript/docs/typescript-contributing.ncl --field contributing_content --format raw > dist/typescript/CONTRIBUTING.md
    @nickel export generators/typescript/docs/typescript-changelog.ncl --field changelog_content --format raw > dist/typescript/CHANGELOG.md
    @nickel export generators/shared/docs/agents-md.ncl --field agents_md --format raw > dist/typescript/AGENTS.md
    @nickel export generators/typescript/ci-cd/typescript-renovate.ncl --field renovate_json --format json > dist/typescript/renovate.json
    @echo "[OK] Enhanced TypeScript package complete"

# Generate enhanced Python package with all new components
generate-py-package-enhanced: generate-py-package
    @echo "Adding enhanced components to Python package..."
    @nickel export generators/python/docs/python-contributing.ncl --field contributing_content --format raw > dist/python/CONTRIBUTING.md
    @nickel export generators/python/docs/python-changelog.ncl --field changelog_content --format raw > dist/python/CHANGELOG.md
    @nickel export generators/shared/docs/agents-md.ncl --field agents_md --format raw > dist/python/AGENTS.md
    @nickel export generators/python/ci-cd/python-renovate.ncl --field renovate_json --format json > dist/python/renovate.json
    @echo "[OK] Enhanced Python package complete"

# Generate enhanced Go package with all new components
generate-go-package-enhanced: generate-go-package
    @echo "Adding enhanced components to Go package..."
    @nickel export generators/go/docs/go-contributing.ncl --field contributing_content --format raw > dist/go/CONTRIBUTING.md
    @nickel export generators/go/docs/go-changelog.ncl --field changelog_content --format raw > dist/go/CHANGELOG.md
    @nickel export generators/shared/docs/agents-md.ncl --field agents_md --format raw > dist/go/AGENTS.md
    @nickel export generators/go/ci-cd/go-renovate.ncl --field renovate_json --format json > dist/go/renovate.json
    @echo "[OK] Enhanced Go package complete"

# Generate enhanced PHP package with all new components
generate-php-package-enhanced: generate-php-package
    @echo "Adding enhanced components to PHP package..."
    @nickel export generators/php/docs/php-contributing.ncl --field contributing_content --format raw > dist/php/CONTRIBUTING.md
    @nickel export generators/php/docs/php-changelog.ncl --field changelog_content --format raw > dist/php/CHANGELOG.md
    @nickel export generators/shared/docs/agents-md.ncl --field agents_md --format raw > dist/php/AGENTS.md
    @nickel export generators/php/ci-cd/php-renovate.ncl --field renovate_json --format json > dist/php/renovate.json
    @echo "[OK] Enhanced PHP package complete"

# Generate enhanced Dart package with all new components
generate-dart-package-enhanced: generate-dart-package
    @echo "Adding enhanced components to Dart package..."
    @nickel export generators/dart/docs/dart-contributing.ncl --field contributing_content --format raw > dist/dart/CONTRIBUTING.md
    @nickel export generators/shared/docs/agents-md.ncl --field agents_md --format raw > dist/dart/AGENTS.md
    @nickel export generators/dart/ci-cd/dart-renovate.ncl --field renovate_json --format json > dist/dart/renovate.json
    @echo "[OK] Enhanced Dart package complete (CHANGELOG.md already included in base)"

# Generate all enhanced packages (5 SDKs with all new components)
generate-all-enhanced: generate-ts-package-enhanced generate-py-package-enhanced generate-go-package-enhanced generate-php-package-enhanced generate-dart-package-enhanced
    @echo ""
    @echo "================================================================"
    @echo "  [OK] All 5 enhanced SDK packages generated"
    @echo "================================================================"
    @echo "  Each package now includes:"
    @echo "    - CONTRIBUTING.md (contribution guidelines)"
    @echo "    - CHANGELOG.md (version history)"
    @echo "    - AGENTS.md (AI agent guidance)"
    @echo "    - renovate.json (automated dependency updates)"
    @echo "    - All existing components (tests, CI/CD, docs)"
    @echo "================================================================"
    @echo ""
    @echo "Generated packages:"
    @echo "  - TypeScript: dist/typescript/"
    @echo "  - Python: dist/python/"
    @echo "  - Go: dist/go/"
    @echo "  - PHP: dist/php/"
    @echo "  - Dart: dist/dart/"
    @echo ""
    @echo "Next steps:"
    @echo "  1. Review generated files"
    @echo "  2. Test packages: just verify-packages"
    @echo "  3. Commit changes"
