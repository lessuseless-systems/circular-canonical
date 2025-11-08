# Fork Workflow for Circular Protocol Canonical

## Overview

This document describes the multi-repository workflow for syncing auto-generated code from `circular-canonical` to upstream repositories via lessuseless-systems forks.

## Architecture

```
lessuseless-systems (GitHub Organization)
├── Circular-Protocol-Canonical (monorepo)
│   ├── circular-canonical/ (git submodule)
│   ├── Canonical-Enterprise-APIs/ (git submodule - future)
│   └── forks/
│       ├── circular-js-npm/ (fork of circular-protocol/circular-js-npm)
│       └── circular-py/ (fork of circular-protocol/circular-py)
│
circular-canonical (this repo)
├── src/ (Nickel source - single source of truth)
├── generators/ (Nickel generators)
└── dist/ (generated code + submodules)
    ├── typescript/ (git submodule → lessuseless-systems/circular-js-npm)
    ├── python/ (git submodule → lessuseless-systems/circular-py)
    └── openapi/ (local generated files)
```

## Initial Setup

### Prerequisites

Install GitHub CLI (gh):

```bash
# macOS
brew install gh

# Linux
sudo apt install gh
# or
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Authenticate
gh auth login
```

### Automated Setup (Recommended)

**ONE COMMAND** to set up everything:

```bash
just setup-forks
```

This command will:
1. ✅ Fork `circular-protocol/circular-js-npm` → `lessuseless-systems/circular-js-npm`
2. ✅ Fork `circular-protocol/circular-py` → `lessuseless-systems/circular-py`
3. ✅ Clone forks and create `development` branches
4. ✅ Add forks as git submodules in `dist/typescript/` and `dist/python/`
5. ✅ Generate initial packages in submodules

Then commit the submodule configuration:

```bash
git add .gitmodules
git commit -m "chore: add fork submodules for generated code deployment"
```

**⚠️ IMPORTANT:** Do NOT use `git add dist/` - the submodules are already tracked via `.gitmodules`. Adding `dist/` would try to commit the submodule contents directly instead of the submodule reference.

### Manual Setup (If Preferred)

<details>
<summary>Click to expand manual setup instructions</summary>

#### Step 1: Fork Upstream Repositories

Using GitHub CLI:

```bash
gh repo fork circular-protocol/circular-js-npm --org lessuseless-systems --clone=false
gh repo fork circular-protocol/circular-py --org lessuseless-systems --clone=false
```

#### Step 2: Create Development Branches

```bash
# For TypeScript fork
git clone git@github.com:lessuseless-systems/circular-js-npm.git
cd circular-js-npm
git checkout -b development
git push -u origin development

# For Python fork
git clone git@github.com:lessuseless-systems/circular-py.git
cd circular-py
git checkout -b development
git push -u origin development
```

#### Step 3: Add Submodules

```bash
# In circular-canonical repo
rm -rf dist/typescript/* dist/python/*
git submodule add -b development git@github.com:lessuseless-systems/circular-js-npm.git dist/typescript
git submodule add -b development git@github.com:lessuseless-systems/circular-py.git dist/python
git submodule init
git submodule update

# Commit the submodule additions
git add .gitmodules dist/
git commit -m "chore: add fork submodules for generated code deployment"
```

</details>

## Daily Development Workflow

### 1. Make Changes to Nickel Source

Edit files in `src/` or `generators/`:

```bash
# Example: Update API definitions
vim src/api/wallet.ncl

# Example: Improve generator
vim generators/typescript/typescript-sdk.ncl
```

### 2. Generate and Validate

```bash
# Type check
just validate

# Generate all packages
just generate-packages
```

### 3. Sync to Submodules

Sync generated code to fork submodules:

```bash
# Sync both packages
just sync-all

# Or sync individually
just sync-typescript
just sync-python
```

**What this does:**
- Regenerates complete packages from Nickel source
- Copies files to `dist/typescript/` and `dist/python/` submodules
- Creates git commits in each submodule with auto-generated messages
- Shows commit summary

### 4. Review Changes

```bash
# Check what changed
cd dist/typescript
git status
git diff HEAD~1

cd ../python
git status
git diff HEAD~1
```

### 5. Push to Forks

Push development branches to lessuseless-systems:

```bash
# Push both forks
just push-forks
```

### 6. Create Pull Requests

**Automated (Recommended):**

```bash
# Create PRs for both repositories
just create-prs
```

This will:
- Create PR from `lessuseless-systems/circular-js-npm:development` → `circular-protocol/circular-js-npm:main`
- Create PR from `lessuseless-systems/circular-py:development` → `circular-protocol/circular-py:main`
- Auto-generate PR title with version number
- Auto-generate PR description with:
  - Summary of changes
  - Version and commit info
  - Testing checklist
  - Link to canonical repository

**Manual (If Preferred):**

<details>
<summary>Click to expand manual PR creation</summary>

Using GitHub CLI:

```bash
# TypeScript PR
cd dist/typescript
gh pr create \
  --repo circular-protocol/circular-js-npm \
  --base main \
  --head lessuseless-systems:development \
  --title "feat: sync generated SDK from canonical v2.0.0-alpha.1" \
  --body "Auto-generated from canonical Nickel source"

# Python PR
cd dist/python
gh pr create \
  --repo circular-protocol/circular-py \
  --base main \
  --head lessuseless-systems:development \
  --title "feat: sync generated SDK from canonical v2.0.0-alpha.1" \
  --body "Auto-generated from canonical Nickel source"
```

Or on GitHub Web UI:

1. Navigate to upstream repository
2. Click "Compare & pull request"
3. Set base and head branches
4. Fill in title and description

</details>

## Justfile Commands

### Setup Commands (One-Time)

```bash
just setup-forks            # Fork repos, create dev branches, add submodules
```

### Generation Commands

```bash
just generate-packages      # Generate complete TS + Python packages
just generate-ts-package    # Generate TypeScript package only
just generate-py-package    # Generate Python package only
```

### Sync Commands

```bash
just sync-all               # Sync both packages to submodules + commit
just sync-typescript        # Sync TypeScript package to submodule + commit
just sync-python            # Sync Python package to submodule + commit
```

### Deployment Commands

```bash
just push-forks             # Push development branches to lessuseless-systems
just create-prs             # Create pull requests to upstream circular-protocol
just check-submodules       # Check status of all submodules
```

### Full Automated Workflow

```bash
# Complete workflow: generate → sync → push → create PRs
just generate-packages && just sync-all && just push-forks && just create-prs
```

## Commit Message Format

Auto-generated commits follow this format:

```
chore: sync generated [TypeScript|Python] SDK from circular-canonical

Generated on: 2025-11-08 12:34:56 UTC
Generator version: 2.0.0-alpha.1

🤖 Auto-generated from Nickel source
📦 Ready for PR to upstream circular-protocol/[repo-name]
```

## Submodule Management

### Updating Submodules

If upstream repositories change:

```bash
# Pull latest from lessuseless-systems forks
cd dist/typescript
git pull origin development

cd ../python
git pull origin development
```

### Checking Submodule Status

```bash
# Quick status check
just check-submodules

# Detailed status
git submodule status
git submodule foreach git status
```

### Resetting Submodules

If submodules get out of sync:

```bash
# Reset to tracked commit
git submodule update --init --recursive

# Or reset to latest on development branch
cd dist/typescript
git checkout development
git pull origin development

cd ../python
git checkout development
git pull origin development
```

## Troubleshooting

### Problem: Submodule not tracking development branch

```bash
cd dist/typescript
git checkout development
git branch --set-upstream-to=origin/development development
```

### Problem: sync-* commands fail with "not a git submodule"

**Solution:** Ensure submodules are properly initialized:

```bash
git submodule init
git submodule update
cd dist/typescript && git checkout development
cd ../python && git checkout development
```

### Problem: Push fails with authentication error

**Solution:** Ensure SSH keys are configured for GitHub:

```bash
ssh -T git@github.com
# Should output: "Hi lessuseless-systems! You've successfully authenticated..."
```

### Problem: Merge conflicts in submodules

**Solution:** Reset submodule to clean state:

```bash
cd dist/typescript
git fetch origin
git reset --hard origin/development
git clean -fd
```

## Best Practices

### 1. Always Validate Before Syncing

```bash
# Always run validation first
just validate && just generate-packages && just sync-all
```

### 2. Review Generated Changes

Before pushing to forks, review what changed:

```bash
just sync-all
cd dist/typescript && git show HEAD
cd ../python && git show HEAD
```

### 3. Keep Forks Updated

Periodically sync your forks with upstream:

```bash
# Add upstream remote (once)
cd dist/typescript
git remote add upstream https://github.com/circular-protocol/circular-js-npm.git

# Fetch and merge upstream changes
git fetch upstream
git merge upstream/main
git push origin development
```

### 4. Test Before PR

Before creating PRs, test the generated packages:

```bash
# TypeScript
cd dist/typescript
npm install
npm run build
npm test

# Python
cd dist/python
pip install -e .
pytest
```

## Monorepo Structure (lessuseless-systems)

The lessuseless-systems organization hosts a monorepo that contains:

```
Circular-Protocol-Canonical/
├── circular-canonical/           # This repo as submodule
├── Canonical-Enterprise-APIs/    # Future: Enterprise APIs
└── forks/                        # Forks of upstream repos
    ├── circular-js-npm/
    ├── circular-py/
    ├── circular-dart/            # Future
    ├── circular-go/              # Future
    ├── circular-php/             # Future
    └── Java-Enterprise-APIs/     # Future
```

**Note:** The monorepo setup allows managing all Circular Protocol development in one place while keeping generated code deployable to individual upstream repositories.

## References

- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [GitHub Fork Workflow](https://docs.github.com/en/get-started/quickstart/fork-a-repo)
- [Justfile Command Runner](https://github.com/casey/just)
- [Nickel Language](https://nickel-lang.org/)

---

**Last Updated:** 2025-11-08
**Version:** 1.0.0
