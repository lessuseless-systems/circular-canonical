# hooks/CLAUDE.md

Guidance for working with git hooks in the `hooks/` directory.

> **Parent Context**: See `/CLAUDE.md` for project overview and essential commands.

## Purpose

The `hooks/` directory contains git hook scripts that are **automatically installed** when you enter the Nix development environment (`nix develop`).

**Key principle**: Hooks enforce quality and prevent common mistakes BEFORE code reaches the repository.

## Hooks Configuration

Hooks are defined in `git-hooks.nix` and configured in `flake.nix`. They are installed automatically via the Nix flake.

### Installation
```bash
# Enter Nix environment (auto-installs hooks)
nix develop

# Verify hooks are installed
ls -la .git/hooks/
```

## Pre-Commit Hooks

**When they run**: Before every `git commit`
**Purpose**: Catch issues early, maintain code quality
**Can be skipped**: Yes, with `--no-verify` (NOT RECOMMENDED)

### Active Pre-Commit Hooks

#### 1. Nickel Type Checking
**What it does**: Validates all `.ncl` files with `nickel typecheck`
**Why**: Catches type errors before commit
**Example failure**:
```
[FAIL] nickel typecheck src/api/wallet.ncl
Error: type mismatch, expected string, got number
```

**Fix**: Resolve type errors in Nickel files

#### 2. Secrets Detection
**What it does**: Scans for API keys, private keys, passwords
**Why**: Prevents committing sensitive data
**Example failure**:
```
[FAIL] Detected possible secret:
  File: config.json
  Line 12: "api_key": "sk_live_abc123..."
```

**Fix**: Remove secrets, use environment variables

#### 3. Large File Check
**What it does**: Blocks files larger than 500KB
**Why**: Keeps repository lightweight
**Example failure**:
```
[FAIL] File too large: dist/bundle.js (2.3MB)
```

**Fix**: Add large files to `.gitignore`, use Git LFS if necessary

#### 4. Trailing Whitespace Fix
**What it does**: Automatically removes trailing whitespace
**Why**: Prevents noisy diffs

#### 5. End-of-File Fixer
**What it does**: Ensures files end with newline
**Why**: POSIX compliance, cleaner diffs

#### 6. JSON/YAML Validation
**What it does**: Validates syntax of `.json` and `.yaml` files
**Why**: Catches invalid configuration files
**Example failure**:
```
[FAIL] Invalid JSON: package.json
  Expecting ',' delimiter: line 15 column 3
```

**Fix**: Fix JSON/YAML syntax errors

#### 7. Markdown Linting
**What it does**: Enforces markdown style (via markdownlint)
**Why**: Consistent documentation formatting
**Example failure**:
```
[FAIL] README.md:23 MD013/line-length Line length exceeds 120 characters
```

**Fix**: Follow markdown style guide

## Pre-Push Hooks

**When they run**: Before every `git push`
**Purpose**: Prevent pushing to wrong repositories
**Can be skipped**: Yes, with `--no-verify` (STRONGLY DISCOURAGED)

### Active Pre-Push Hooks

#### 1. Repository URL Validation
**What it does**: Checks remote URL against whitelist
**Why**: Prevents accidental pushes to numbered test repos or typos

**Allowed repositories**:
- `git@github.com:lessuseless-systems/circular-canonical.git`
- `git@github.com:lessuseless-systems/circular-js-npm.git`
- `git@github.com:lessuseless-systems/circular-py.git`

**Blocked patterns**:
- `circular-canonicle` (typo)
- `circular-py-1`, `circular-py-2` (numbered test repos)
- `circular-js-npm-1`, `circular-js-npm-2` (numbered test repos)

**Example failure**:
```
[FAIL] Push blocked!
Remote URL: git@github.com:lessuseless-systems/circular-canonical-test.git
This appears to be a test repository.

Allowed repositories:
  - circular-canonical (main source of truth)
  - circular-js-npm (TypeScript SDK)
  - circular-py (Python SDK)
```

**Fix**: Verify remote URL, update if wrong:
```bash
git remote -v
git remote set-url origin git@github.com:lessuseless-systems/circular-canonical.git
```

## Skipping Hooks (Emergency Use Only)

### When to Skip

**Valid reasons**:
- Emergency hotfix (fix in production, clean up later)
- Fixing the hooks themselves (testing hook changes)
- Rebasing with amended commits (hooks already ran)

**Invalid reasons**:
- "Hooks are slow" → Fix the underlying issue
- "I'll fix it later" → Fix it now
- "Tests are failing" → Fix the tests

### How to Skip

```bash
# Skip pre-commit hooks (emergency only)
git commit --no-verify -m "message"

# Skip pre-push hooks (VERY dangerous)
git push --no-verify
```

**WARNING**: Skipping hooks can lead to:
- Breaking changes in main branch
- Secrets leaked to repository
- Invalid code merged
- Push to wrong repository

## Development Workflow with Hooks

### Normal Commit Flow

```bash
# 1. Make changes
echo "new feature" >> src/api/wallet.ncl

# 2. Stage changes
git add src/api/wallet.ncl

# 3. Commit (hooks run automatically)
git commit -m "feat(api): add new wallet endpoint"

# Hooks run:
# ✅ Nickel typecheck
# ✅ Secrets detection
# ✅ Large file check
# ✅ Trailing whitespace
# ✅ End-of-file fixer
# ✅ JSON/YAML validation
# ✅ Markdown linting

# 4. Push (pre-push hooks run)
git push origin develop

# Hooks run:
# ✅ Repository URL check
```

### Fixing Hook Failures

If hooks fail:

1. **Read the error message** carefully
2. **Fix the issue** in your working directory
3. **Stage the fix**: `git add <file>`
4. **Try commit again**: `git commit -m "message"`

Example:
```bash
# Commit fails due to type error
git commit -m "feat: add endpoint"
# [FAIL] nickel typecheck src/api/wallet.ncl

# Fix the type error
vim src/api/wallet.ncl

# Stage the fix
git add src/api/wallet.ncl

# Commit again (hooks pass this time)
git commit -m "feat: add endpoint"
# ✅ All hooks passed
```

## Customizing Hooks

### Modifying Hook Behavior

**File to edit**: `git-hooks.nix` (in root directory)

Example:
```nix
{
  pre-commit = {
    hooks = {
      # Add new hook
      my-custom-check = {
        enable = true;
        name = "Custom validation";
        entry = "${pkgs.bash}/bin/bash ./hooks/my-check.sh";
        files = "\\.ncl$";
      };

      # Disable hook
      trailing-whitespace.enable = false;
    };
  };
}
```

After modifying `git-hooks.nix`:
```bash
# Exit Nix environment
exit

# Re-enter to reinstall hooks
nix develop

# Verify new hook
ls -la .git/hooks/pre-commit
```

### Adding Custom Hook Scripts

1. Create script in `hooks/my-check.sh`
2. Make executable: `chmod +x hooks/my-check.sh`
3. Add to `git-hooks.nix`
4. Re-enter Nix environment

## Hook Performance

### Current Performance

Pre-commit hooks:
- Nickel typecheck: ~2-3 seconds (8 API files)
- Secrets detection: ~500ms
- Other hooks: <100ms each
- **Total**: ~3-5 seconds

Pre-push hooks:
- Repository URL check: ~50ms
- **Total**: <100ms

### Optimization Tips

If hooks become slow:

1. **Nickel typecheck**: Only check modified `.ncl` files
2. **Secrets detection**: Exclude large generated files
3. **Markdown lint**: Only check modified `.md` files

## Troubleshooting

### Hooks Not Running

**Problem**: Commits succeed without hooks running
**Cause**: Not in Nix environment or hooks not installed
**Solution**:
```bash
nix develop
ls -la .git/hooks/  # Verify hooks exist
```

### Hooks Fail on CI/CD

**Problem**: Hooks pass locally but fail on CI
**Cause**: Different environment or missing dependencies
**Solution**: Ensure CI uses same Nix environment:
```yaml
# .github/workflows/test.yml
- name: Setup Nix
  uses: cachix/install-nix-action@v22
- name: Run checks
  run: nix develop --command just test
```

### False Positives (Secrets Detection)

**Problem**: Hook detects false positive (e.g., example keys)
**Solution**: Add to `.gitignore` or exclude in `git-hooks.nix`:
```nix
secrets-detection = {
  exclude = "^examples/.*\\.json$";
};
```

## Cross-References

- Hook configuration: `git-hooks.nix` (root)
- Git workflow: `docs/DEVELOPMENT_WORKFLOW.md`
- Nix environment: `flake.nix` (root)
- Repository URLs: Root `CLAUDE.md` (Official Repositories section)
