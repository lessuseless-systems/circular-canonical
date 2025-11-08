# Development Workflow for Circular Protocol Canonical

Day-to-day development process, tooling, and best practices for working with the Canonical projects.

## Table of Contents

1. [Development Setup](#development-setup)
2. [Daily Workflow](#daily-workflow)
3. [IDE Integration](#ide-integration)
4. [Git Workflow](#git-workflow)
5. [Code Review Process](#code-review-process)
6. [Release Process](#release-process)
7. [Troubleshooting](#troubleshooting)
8. [Tips and Tricks](#tips-and-tricks)

---

## Development Setup

### Initial Environment Setup

```bash
# 1. Install Nickel
nix-shell -p nickel
# Or use the installer:
# curl -sSL https://get.nickel-lang.org | sh

# 2. Verify installation
nickel --version

# 3. Install development tools
npm install -g typescript ts-node prettier
pip install black mypy
sudo apt install openjdk-17-jdk  # or brew install openjdk@17

# 4. Clone repositories
git clone https://github.com/circular-protocol/circular-canonical.git
git clone https://github.com/circular-protocol/Canonical-Enterprise-APIs.git

# 5. Setup workspace
cd circular-canonical
just setup  # Creates output directories, installs hooks
```

### Project Structure Orientation

**Updated 2025-11-07**: Language-first organization

```
circular-canonical/
├── src/
│   ├── schemas/          # Type definitions, contracts
│   │   ├── types.ncl
│   │   ├── requests.ncl
│   │   └── responses.ncl
│   ├── api/              # API endpoint definitions
│   │   ├── wallet.ncl
│   │   ├── transaction.ncl
│   │   └── all.ncl
│   └── config.ncl        # Base configuration
│
├── generators/           # Language-first organization
│   ├── shared/           # Language-agnostic generators
│   │   ├── openapi.ncl
│   │   ├── helpers.ncl
│   │   └── test-data.ncl
│   ├── typescript/       # TypeScript SDK & tooling
│   │   ├── typescript-sdk.ncl
│   │   ├── tests/
│   │   ├── config/
│   │   ├── docs/
│   │   └── package-manifest/
│   └── python/           # Python SDK & tooling
│       ├── python-sdk.ncl
│       ├── tests/
│       ├── config/
│       └── package-manifest/
│
├── tests/               # Test files
│   ├── contracts/       # Contract validation tests
│   ├── generators/      # Generator output tests
│   └── integration/     # Integration tests
│
├── dist/                # Generated artifacts (gitignored)
│   ├── openapi/
│   ├── typescript/
│   ├── python/
│   └── java/
│
├── docs/                # Documentation
│   ├── WEEK_1_2_GUIDE.md
│   ├── NICKEL_PATTERNS.md
│   ├── TESTING_STRATEGY.md
│   └── DEVELOPMENT_WORKFLOW.md (this file)
│
├── CLAUDE.md            # Root guidance
└── justfile             # Build automation
```

### justfile Targets

```justfile
# justfile
.PHONY: all clean test generate validate watch help setup

help:
	@echo "Canonical Development Commands:"
	@echo "  just setup      - Initial project setup"
	@echo "  just validate   - Type check all Nickel files"
	@echo "  just test       - Run all tests"
	@echo "  just generate   - Generate all artifacts"
	@echo "  just watch      - Watch for changes and regenerate"
	@echo "  just clean      - Remove generated files"
	@echo "  just release    - Prepare release"

setup:
	@echo "Setting up development environment..."
	mkdir -p output/{typescript,python,java,openapi}
	chmod +x tests/*.sh
	cp hooks/pre-commit .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit
	@echo "✓ Setup complete"

validate:
	@echo "Type checking Nickel files..."
	@find src -name "*.ncl" -exec nickel typecheck {} \;
	@find generators -name "*.ncl" -exec nickel typecheck {} \;
	@echo "✓ All files type check"

test:
	@echo "Running test suite..."
	@./tests/run-contract-tests.sh
	@./tests/generators/syntax-validation.sh
	@echo "✓ All tests passed"

generate:
	@echo "Generating artifacts..."
	@nickel export generators/openapi.ncl --format yaml > output/openapi.yaml
	@nickel export generators/typescript-sdk.ncl > output/typescript/client.ts
	@nickel export generators/python-sdk.ncl > output/python/client.py
	@nickel export generators/mcp-server.ncl --format json > output/mcp-tools.json
	@echo "✓ Generation complete"

watch:
	@echo "Watching for changes (Ctrl+C to stop)..."
	@while true; do \
		inotifywait -qre modify src/ generators/; \
		just validate generate; \
	done

clean:
	@echo "Cleaning generated files..."
	@rm -rf output/*
	@echo "✓ Clean complete"

release:
	@echo "Preparing release..."
	@just validate
	@just test
	@just generate
	@echo "✓ Release ready"

.DEFAULT_GOAL := help
```

---

## Daily Workflow

### Morning Routine

```bash
# 1. Sync with upstream
git fetch origin
git status

# 2. Check for dependency updates
git log --oneline -10

# 3. Verify environment
just validate

# 4. Review open issues/PRs
gh pr list
gh issue list
```

### Making Changes

#### Workflow: Adding a New API Endpoint

**Step 1: Define the endpoint in Nickel**

```bash
# 1. Create or edit API file
code src/api/wallet.ncl

# 2. Add endpoint definition
# (See NICKEL_PATTERNS.md Pattern 3 for structure)

# 3. Type check
nickel typecheck src/api/wallet.ncl
```

**Step 2: Test the definition**

```bash
# 1. Create contract test
code tests/contracts/wallet.test.ncl

# 2. Run test
nickel export tests/contracts/wallet.test.ncl > /dev/null
```

**Step 3: Update generators**

```bash
# 1. Add endpoint to OpenAPI generator
code generators/openapi.ncl

# 2. Regenerate
just generate

# 3. Validate output
npx @apidevtools/swagger-cli validate output/openapi.yaml
```

**Step 4: Verify all outputs**

```bash
# Run full test suite
just test

# Generate all artifacts
just generate

# Check diffs
git diff output/
```

#### Workflow: Modifying a Type Definition

**Step 1: Update type definition**

```bash
# 1. Edit types
code src/schemas/types.ncl

# 2. Update dependent files
# - Update requests.ncl if needed
# - Update responses.ncl if needed
# - Update any API endpoints using the type

# 3. Type check everything
just validate
```

**Step 2: Update tests**

```bash
# 1. Update contract tests
code tests/contracts/types.test.ncl

# 2. Run tests
./tests/run-contract-tests.sh
```

**Step 3: Regenerate and verify**

```bash
# 1. Regenerate all
just generate

# 2. Run generator tests
./tests/generators/syntax-validation.sh

# 3. Check for breaking changes
./tests/regression/detect-breaking-changes.sh
```

#### Workflow: Creating a New Generator

**Step 1: Create generator file**

```bash
# 1. Create file
code generators/new-language.ncl

# 2. Import dependencies
# let types = import "../src/schemas/types.ncl" in
# let apis = import "../src/api/all.ncl" in

# 3. Implement transformation logic
# (See NICKEL_PATTERNS.md Generator Patterns)
```

**Step 2: Test generator**

```bash
# 1. Export and verify syntax
nickel export generators/new-language.ncl > /tmp/output.code

# 2. Validate with language tools
# For example:
# - TypeScript: tsc --noEmit
# - Python: python -m py_compile
# - Java: javac

# 3. Create generator test
code tests/generators/new-language.test.sh
```

**Step 3: Add to build**

```bash
# 1. Update justfile
code justfile

# Add to generate target:
# @nickel export generators/new-language.ncl > output/new-language/code.ext

# 2. Test build
just generate
```

### Evening Routine

```bash
# 1. Commit work
git add -A
git status
git commit -m "type: description"

# 2. Run final checks
just test

# 3. Push to remote
git push origin feature/branch-name

# 4. Create/update PR if ready
gh pr create --title "Feature: description" --body "Details..."
```

---

## IDE Integration

### VS Code Setup

**Install Extensions:**

```bash
# Nickel LSP support (when available)
code --install-extension nickel-lang.nickel

# General development
code --install-extension esbenp.prettier-vscode
code --install-extension ms-python.python
code --install-extension ms-vscode.vscode-typescript-next
```

**VS Code Settings (`.vscode/settings.json`):**

```json
{
  "files.associations": {
    "*.ncl": "nickel"
  },
  "editor.formatOnSave": true,
  "[nickel]": {
    "editor.tabSize": 2,
    "editor.insertSpaces": true
  },
  "editor.rulers": [80, 100],
  "files.exclude": {
    "**/output/**": true,
    "**/.git": true
  }
}
```

**Tasks (`.vscode/tasks.json`):**

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Nickel: Type Check Current File",
      "type": "shell",
      "command": "nickel typecheck ${file}",
      "group": "test",
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    },
    {
      "label": "Nickel: Export Current File",
      "type": "shell",
      "command": "nickel export ${file} --format json | jq .",
      "group": "build",
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    },
    {
      "label": "Make: Generate All",
      "type": "shell",
      "command": "just generate",
      "group": {
        "kind": "build",
        "isDefault": true
      }
    },
    {
      "label": "Make: Run Tests",
      "type": "shell",
      "command": "just test",
      "group": {
        "kind": "test",
        "isDefault": true
      }
    }
  ]
}
```

**Snippets (`.vscode/nickel.code-snippets`):**

```json
{
  "Nickel Endpoint": {
    "prefix": "nep",
    "body": [
      "${1:endpointName} = {",
      "  method = \"${2|GET,POST,PUT,DELETE|}\",",
      "  path = \"/${3:path}\",",
      "  summary = \"${4:Summary}\",",
      "  description = \"${5:Description}\",",
      "  ",
      "  parameters = {",
      "    ${6:param_name} = {",
      "      type = \"${7:string}\",",
      "      required = ${8|true,false|},",
      "      description = \"${9:param description}\",",
      "    },",
      "  },",
      "  ",
      "  response_schema = {",
      "    ${10:field} | ${11:Contract},",
      "  },",
      "},"
    ],
    "description": "Create API endpoint definition"
  },
  "Nickel Contract": {
    "prefix": "ncon",
    "body": [
      "${1:ContractName} = std.contract.from_predicate (fun value =>",
      "  ${2:validation_logic}",
      ")"
    ],
    "description": "Create custom contract"
  },
  "Nickel Import": {
    "prefix": "nimp",
    "body": [
      "let ${1:name} = import \"${2:path}.ncl\" in"
    ],
    "description": "Import Nickel file"
  }
}
```

### Vim/Neovim Setup

**vim-plug Configuration:**

```vim
" ~/.vimrc or ~/.config/nvim/init.vim

" Nickel syntax highlighting
Plug 'nickel-lang/vim-nickel'

" Auto-formatting
Plug 'dense-analysis/ale'

let g:ale_linters = {
\   'nickel': ['nickel'],
\}

let g:ale_fixers = {
\   'nickel': ['nickel'],
\}

" Keybindings
autocmd FileType nickel nnoremap <buffer> <leader>t :!nickel typecheck %<CR>
autocmd FileType nickel nnoremap <buffer> <leader>e :!nickel export % --format json \| jq .<CR>
autocmd FileType nickel setlocal tabstop=2 shiftwidth=2 expandtab
```

### Emacs Setup

```elisp
;; ~/.emacs or ~/.emacs.d/init.el

;; Nickel mode (if available)
(use-package nickel-mode
  :mode "\\.ncl\\'")

;; Keybindings
(defun nickel-typecheck ()
  "Type check current Nickel file"
  (interactive)
  (compile (concat "nickel typecheck " buffer-file-name)))

(defun nickel-export ()
  "Export current Nickel file"
  (interactive)
  (compile (concat "nickel export " buffer-file-name " --format json | jq .")))

(add-hook 'nickel-mode-hook
  (lambda ()
    (local-set-key (kbd "C-c C-t") 'nickel-typecheck)
    (local-set-key (kbd "C-c C-e") 'nickel-export)))
```

---

## Git Workflow

### Branch Strategy

```
main              ─────●─────●─────●──────  (releases only)
                        ↑     ↑     ↑
develop           ──●───┴──●──┴──●──┴──●──  (integration branch)
                    ↑      ↑     ↑     ↑
feature/wallet    ──┴──●───┘     │     │
feature/docs      ────────────●──┘     │
hotfix/bug-123    ──────────────────●──┘
```

### Branch Naming

```bash
# Features
git checkout -b feature/add-asset-api
git checkout -b feature/improve-docs

# Bug fixes
git checkout -b fix/contract-validation-error
git checkout -b fix/generator-output-formatting

# Hotfixes (for production)
git checkout -b hotfix/critical-security-issue

# Documentation
git checkout -b docs/update-readme
git checkout -b docs/add-examples
```

### Commit Message Format

Follow Conventional Commits:

```
type(scope): subject

body (optional)

footer (optional)
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**

```bash
# Feature
git commit -m "feat(api): add getAsset endpoint with contract validation"

# Fix
git commit -m "fix(generator): correct TypeScript type mapping for optional fields"

# Documentation
git commit -m "docs: add examples for custom contract creation"

# Breaking change
git commit -m "feat(types)!: change Address contract to require 0x prefix

BREAKING CHANGE: Address type now requires 0x prefix. Update all
existing addresses to include the prefix."
```

### Pull Request Process

**1. Create PR:**

```bash
# Via GitHub CLI
gh pr create \
  --title "feat(api): Add asset management endpoints" \
  --body "## Summary
Adds getAsset, getAssetList, and getAssetSupply endpoints.

## Changes
- Added asset.ncl with 3 new endpoints
- Updated OpenAPI generator
- Added contract validation tests
- Updated documentation

## Testing
- ✓ Contract tests pass
- ✓ Generator output validated
- ✓ Cross-language tests pass

## Checklist
- [x] Tests added/updated
- [x] Documentation updated
- [x] Breaking changes noted (if any)
- [x] CHANGELOG updated"
```

**2. PR Template (`.github/pull_request_template.md`):**

```markdown
## Summary
<!-- Brief description of changes -->

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Breaking change

## Changes Made
<!-- Detailed list of changes -->

## Testing
- [ ] Contract validation tests pass
- [ ] Generator output tests pass
- [ ] Cross-language tests pass
- [ ] Integration tests pass

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No breaking changes (or documented)
- [ ] CHANGELOG updated

## Related Issues
<!-- Link to related issues: Closes #123 -->
```

---

## Code Review Process

### As a Reviewer

**Review Checklist:**

```markdown
## Nickel Code Quality
- [ ] Type contracts properly defined
- [ ] Contract error messages are helpful
- [ ] No hardcoded values (use config)
- [ ] Imports are organized
- [ ] Code follows patterns in NICKEL_PATTERNS.md

## Generator Quality
- [ ] Generated code is syntactically valid
- [ ] Output matches expected format
- [ ] Idiomatic for target language
- [ ] No unnecessary whitespace/formatting issues

## Testing
- [ ] Adequate test coverage
- [ ] Tests actually test the changes
- [ ] Edge cases considered

## Documentation
- [ ] README updated if needed
- [ ] API changes documented
- [ ] Examples provided for new features

## Breaking Changes
- [ ] Breaking changes clearly marked
- [ ] Migration path documented
- [ ] Version bump appropriate
```

**Providing Feedback:**

```markdown
# Good feedback examples

## Specific and actionable
❌ "This contract doesn't look right"
✅ "The Address contract should validate hex characters. Suggest adding:
   `std.string.is_match \"^(0x)?[0-9a-fA-F]+$\" value`"

## Positive reinforcement
✅ "Great use of contract composition here! This makes the validation very clear."

## Questions not commands
❌ "Change this to use std.array.map"
✅ "Would std.array.map be clearer here? It might better express the intent."

## Offer alternatives
✅ "Consider using the pattern from NICKEL_PATTERNS.md Pattern 7 for consistency,
   or if there's a reason for the different approach, a comment would help."
```

### As a PR Author

**Responding to Reviews:**

```markdown
# When making changes
- Address each comment individually
- Mark conversations as "Resolved" after changes
- Reply with explanation if disagreeing

# Examples

## Accepting suggestion
"Good catch! Changed to use std.array.map in abc123."

## Explaining reasoning
"I considered that approach, but opted for explicit iteration here because
the validation logic is complex and benefits from the clarity. Happy to
change if you feel strongly."

## Requesting clarification
"Could you elaborate on what's unclear about this contract? I want to make
sure I address the root concern."
```

---

## Release Process

### Version Numbering

Follow Semantic Versioning (SemVer):

```
MAJOR.MINOR.PATCH

1.0.0 → 1.0.1  (patch: bug fixes)
1.0.1 → 1.1.0  (minor: new features, backward compatible)
1.1.0 → 2.0.0  (major: breaking changes)
```

### Pre-Release Checklist

```bash
# 1. Verify all tests pass
just test

# 2. Run regression tests
./tests/regression/compare-versions.sh

# 3. Generate all artifacts
just generate

# 4. Verify generated code builds
cd output/typescript && npm run build
cd output/python && python setup.py test
cd output/java && mvn clean package

# 5. Update version numbers
# - src/config.ncl: Version field
# - package.json (if exists)
# - CHANGELOG.md

# 6. Update documentation
# - README.md
# - API documentation
# - Migration guides (if breaking changes)

# 7. Create release commit
git add -A
git commit -m "chore(release): prepare v1.1.0"

# 8. Tag release
git tag -a v1.1.0 -m "Release v1.1.0: Add asset management endpoints"

# 9. Push
git push origin develop
git push origin v1.1.0
```

### Release Automation

**GitHub Actions (`.github/workflows/release.yml`):**

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    name: Create Release
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Nickel
        run: |
          curl -sSL https://get.nickel-lang.org | sh
          echo "$HOME/.nickel/bin" >> $GITHUB_PATH

      - name: Run tests
        run: just test

      - name: Generate artifacts
        run: just generate

      - name: Create release archives
        run: |
          tar -czf canonical-typescript-${GITHUB_REF#refs/tags/}.tar.gz output/typescript/
          tar -czf canonical-python-${GITHUB_REF#refs/tags/}.tar.gz output/python/
          tar -czf canonical-openapi-${GITHUB_REF#refs/tags/}.tar.gz output/openapi.yaml

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            canonical-*.tar.gz
          generate_release_notes: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Post-Release

```bash
# 1. Verify release on GitHub
gh release view v1.1.0

# 2. Announce release
# - Update project README
# - Post to community channels
# - Update circular-protocol website

# 3. Monitor for issues
# - Watch GitHub issues
# - Check CI/CD status
# - Review user feedback

# 4. Plan next version
# - Create milestone for next version
# - Triage issues
# - Update roadmap
```

---

## Troubleshooting

### Common Issues

#### Issue: Nickel contract fails with unclear error

**Symptom:**
```
error: contract broken by a value
  ┌─ src/api/wallet.ncl:10:5
  │
```

**Solution:**
```bash
# 1. Add detailed error messages to contracts
let Address = std.contract.from_predicate (fun value =>
  if not (std.is_string value) then
    std.contract.blame_with_message "Address must be a string" value
  else if std.string.length value != 64 && std.string.length value != 66 then
    std.contract.blame_with_message
      "Address must be 64 or 66 characters (got %{std.string.from_number (std.string.length value)})"
      value
  else
    true
)

# 2. Test in isolation
nickel repl
> let Address = ... in { test | Address = "0x123" }
```

#### Issue: Generator produces invalid syntax

**Symptom:**
```
Generated TypeScript has syntax error
```

**Solution:**
```bash
# 1. Test generator incrementally
nickel export generators/typescript-sdk.ncl > /tmp/output.ts

# 2. Check output manually
cat /tmp/output.ts

# 3. Validate with language tools
npx typescript /tmp/output.ts --noEmit

# 4. Add generator tests
# tests/generators/typescript-syntax.test.sh
```

#### Issue: Import path not found

**Symptom:**
```
error: file not found
```

**Solution:**
```bash
# 1. Use relative paths from current file
let types = import "../schemas/types.ncl" in

# 2. Or absolute from project root (if configured)
let types = import "src/schemas/types.ncl" in

# 3. Verify file exists
ls -la src/schemas/types.ncl
```

#### Issue: Merge conflicts in generated files

**Symptom:**
```
CONFLICT (content): Merge conflict in output/openapi.yaml
```

**Solution:**
```bash
# Don't commit generated files!
# Add to .gitignore:
echo "output/" >> .gitignore

# If already tracked:
git rm -r --cached output/
git commit -m "chore: remove generated files from git"

# Regenerate after merge:
just generate
```

### Getting Help

```bash
# 1. Check documentation
cat docs/NICKEL_PATTERNS.md
cat docs/WEEK_1_2_GUIDE.md

# 2. Search issues
gh issue list --search "your error message"

# 3. Use Nickel REPL for debugging
nickel repl
> import "src/schemas/types.ncl"

# 4. Ask for help
gh issue create --title "Question: ..." --label "question"
```

---

## Tips and Tricks

### Fast Iteration

```bash
# Watch mode for rapid development
while true; do
  inotifywait -e modify src/api/wallet.ncl
  nickel export generators/openapi.ncl --format yaml | yq . | head -50
done

# Or use just watch
just watch
```

### Debugging Contracts

```bash
# Use Nickel REPL
nickel repl

# Test contracts interactively
> let Address = std.string.NonEmpty in { test | Address = "value" }
> std.string.length "test"
> std.record.fields { a = 1, b = 2 }
```

### Quick Validation

```bash
# Type check without full export
nickel typecheck src/**/*.ncl

# Export and pretty print
nickel export file.ncl --format json | jq .

# Check specific field
nickel query src/api/wallet.ncl checkWallet
```

### Performance Optimization

```bash
# Profile generator performance
time nickel export generators/openapi.ncl

# Use caching for imports
# Nickel automatically caches imports

# Minimize generator complexity
# - Avoid deep recursion
# - Use built-in functions
# - Profile with time
```

### Documentation

```bash
# Generate documentation from Nickel definitions
nickel export generators/markdown-docs.ncl > docs/API.md

# Extract comments/docs
nickel query --field summary src/api/wallet.ncl checkWallet
```

---

## Next Steps

1. **Complete** initial setup: `just setup`
2. **Read** [WEEK_1_2_GUIDE.md](./WEEK_1_2_GUIDE.md) for implementation steps
3. **Reference** [NICKEL_PATTERNS.md](./NICKEL_PATTERNS.md) while coding
4. **Follow** [TESTING_STRATEGY.md](./TESTING_STRATEGY.md) for testing
5. **Review** [MIGRATION_PATH.md](./MIGRATION_PATH.md) for transition strategy

---

**Remember:** The goal is not perfection on first try, but rapid iteration with validation. Use the tools, lean on the tests, and don't hesitate to ask questions!
