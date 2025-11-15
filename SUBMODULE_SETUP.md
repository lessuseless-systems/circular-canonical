# Multi-SDK Submodule Setup Guide

This guide explains how to set up all 5 SDK repositories as git submodules in the canonical repository.

## Repository Mapping

Each `dist/<language>` directory is a git submodule pointing to a separate SDK repository:

| Directory | Repository | Branch |
|-----------|------------|--------|
| `dist/typescript/` | `lessuseless-systems/circular-ts` | `development` |
| `dist/python/` | `lessuseless-systems/circular-py` | `development` |
| `dist/go/` | `lessuseless-systems/circular-go` | `development` |
| `dist/php/` | `lessuseless-systems/circular-php` | `development` |
| `dist/dart/` | `lessuseless-systems/circular-dart` | `development` |

## Prerequisites

1. GitHub CLI (`gh`) installed
2. SSH access to GitHub configured
3. Permissions to create repositories in `lessuseless-systems` organization

## One-Time Setup

### Option 1: Automated Setup (Recommended)

```bash
# This will create all repositories and set up submodules
just setup-all-submodules
```

This command will:
1. Create GitHub repositories (if they don't exist)
2. Initialize each repository with development branch
3. Add as submodules to circular-canonical
4. Generate initial SDK packages
5. Commit and push to each submodule

### Option 2: Manual Setup

If you prefer manual setup or need to troubleshoot:

#### Step 1: Create GitHub Repositories

```bash
# Create repositories in lessuseless-systems organization
gh repo create lessuseless-systems/circular-ts --public --description "TypeScript SDK for Circular Protocol blockchain"
gh repo create lessuseless-systems/circular-go --public --description "Go SDK for Circular Protocol blockchain"
gh repo create lessuseless-systems/circular-php --public --description "PHP SDK for Circular Protocol blockchain"
gh repo create lessuseless-systems/circular-dart --public --description "Dart SDK for Circular Protocol blockchain"

# Note: circular-py already exists
```

#### Step 2: Initialize Development Branches

For each new repository:

```bash
# Clone, create development branch, push
git clone git@github.com:lessuseless-systems/circular-ts.git /tmp/circular-ts
cd /tmp/circular-ts
git checkout -b development
echo "# Circular Protocol TypeScript SDK" > README.md
git add README.md
git commit -m "chore: initialize development branch"
git push -u origin development

# Repeat for circular-go, circular-php, circular-dart
```

#### Step 3: Add as Submodules

```bash
# In circular-canonical repository
cd /path/to/circular-canonical

# Add each SDK as a submodule
git submodule add -b development git@github.com:lessuseless-systems/circular-ts.git dist/typescript
git submodule add -b development git@github.com:lessuseless-systems/circular-go.git dist/go
git submodule add -b development git@github.com:lessuseless-systems/circular-php.git dist/php
git submodule add -b development git@github.com:lessuseless-systems/circular-dart.git dist/dart

# Initialize and update submodules
git submodule init
git submodule update

# Commit submodule configuration
git add .gitmodules dist/
git commit -m "chore: add Go, PHP, and Dart SDK submodules"
git push
```

#### Step 4: Generate Initial SDK Packages

```bash
# Generate all enhanced SDK packages
just generate-all-enhanced

# Each submodule will now contain the generated SDK
```

## Daily Workflow

### Regenerating SDKs

When you update canonical definitions and want to sync to SDK repositories:

```bash
# Generate all SDKs and sync to submodules
just sync-all-sdks

# Or sync individual SDKs
just sync-typescript
just sync-python
just sync-go
just sync-php
just sync-dart
```

### Pushing to SDK Repositories

```bash
# Push all submodules to their remote repositories
just push-all-sdks

# Or push individual SDKs
cd dist/typescript && git push origin development
cd dist/python && git push origin development
cd dist/go && git push origin development
cd dist/php && git push origin development
cd dist/dart && git push origin development
```

### Checking Status

```bash
# Check status of all submodules
just check-submodules

# Or manually
git submodule status
```

## Submodule Commands Reference

### Updating Submodules to Latest

```bash
# Update all submodules to latest commit on development branch
git submodule update --remote --merge

# Update specific submodule
git submodule update --remote --merge dist/typescript
```

### Committing in Submodules

When you make changes in a submodule:

```bash
# Navigate to submodule
cd dist/typescript

# Check status
git status

# Add and commit changes
git add .
git commit -m "feat: add new feature"

# Push to remote
git push origin development

# Return to parent repository
cd ../..

# Update parent to track new submodule commit
git add dist/typescript
git commit -m "chore: update TypeScript SDK submodule"
git push
```

### Cloning Repository with Submodules

For new contributors cloning the canonical repository:

```bash
# Option 1: Clone with submodules in one command
git clone --recurse-submodules git@github.com:lessuseless-systems/circular-canonical.git

# Option 2: Clone then initialize submodules
git clone git@github.com:lessuseless-systems/circular-canonical.git
cd circular-canonical
git submodule init
git submodule update

# Option 3: Clone specific submodules only
git clone git@github.com:lessuseless-systems/circular-canonical.git
cd circular-canonical
git submodule init dist/typescript dist/python  # Only init specific ones
git submodule update
```

## Common Issues & Troubleshooting

### Issue: Submodule Shows Modified but No Changes

```bash
# This can happen if you're on a different commit
cd dist/typescript
git status  # Check if you're on development branch
git checkout development
git pull origin development
cd ../..
git add dist/typescript
git commit -m "chore: update submodule to latest"
```

### Issue: Cannot Push to Submodule

```bash
# Ensure you're on development branch in submodule
cd dist/typescript
git checkout development
git pull origin development --rebase
# Make your changes
git push origin development
```

### Issue: Submodule Detached HEAD

```bash
# Submodules default to detached HEAD state
cd dist/typescript
git checkout development  # Switch to branch
git pull origin development
```

### Issue: Want to Remove a Submodule

```bash
# Remove from .gitmodules
git config -f .gitmodules --remove-section submodule.dist/typescript

# Remove from .git/config
git config -f .git/config --remove-section submodule.dist/typescript

# Remove from working tree and index
git rm --cached dist/typescript
rm -rf dist/typescript

# Remove from .git/modules
rm -rf .git/modules/dist/typescript

# Commit the removal
git commit -m "chore: remove TypeScript submodule"
```

## Repository URLs

All SDK repositories are in the `lessuseless-systems` organization:

- TypeScript: https://github.com/lessuseless-systems/circular-ts
- Python: https://github.com/lessuseless-systems/circular-py
- Go: https://github.com/lessuseless-systems/circular-go
- PHP: https://github.com/lessuseless-systems/circular-php
- Dart: https://github.com/lessuseless-systems/circular-dart

## Safety Notes

⚠️ **IMPORTANT**:
- Never use `git add dist` - This would add submodule contents instead of submodule reference
- Always use `git add .gitmodules dist/<specific-submodule>` when updating submodules
- Submodules track specific commits - remember to update parent repo after submodule changes
- All SDK repositories use `development` branch (not `main`)

## CI/CD Integration

Each SDK repository has its own CI/CD:
- GitHub Actions workflows in `.github/workflows/test.yml`
- Runs on push to development branch
- Tests against multiple language versions
- Publishes to package registries (npm, PyPI, pkg.go.dev, Packagist, pub.dev)

The canonical repository CI/CD:
- Validates Nickel definitions
- Generates all SDKs
- Runs cross-language validation tests
- Does NOT automatically push to submodules (manual `just sync-all-sdks` required)

---

*For more information, see: FORK_WORKFLOW.md and justfile commands*
