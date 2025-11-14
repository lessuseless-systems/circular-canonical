# docs/CLAUDE.md

Guidance for working with documentation in the `docs/` directory.

> **Parent Context**: See `/CLAUDE.md` for project overview and essential commands.

## Directory Structure

```
docs/
├── CLAUDE.md                   # This file
├── WEEK_1_2_GUIDE.md          # Day-by-day implementation plan (Weeks 1-2)
├── DEVELOPMENT_WORKFLOW.md    # Git workflow, PR process, IDE setup
├── TESTING_STRATEGY.md        # Four-layer testing approach
├── MIGRATION_PATH.md          # 24-week migration strategy
├── NICKEL_PATTERNS.md         # Nickel syntax, contracts, patterns
└── SDK_GUIDE.md               # Generated SDK usage guide
```

## Documentation Philosophy

### Single Source of Truth

Documentation should be **generated** from Nickel definitions where possible:

- ✅ **API Reference**: Generated from `src/api/*.ncl` (OpenAPI → Markdown)
- ✅ **Type Definitions**: Generated from `src/schemas/types.ncl`
- ✅ **SDK Examples**: Generated from `example_request`/`example_response` fields
- ❌ **Manual docs**: Only for context, architecture, workflows (this directory)

### When to Create Manual Documentation

**Do write manual docs for**:
- Architecture decisions (WHY, not WHAT)
- Development workflows (git, PR process)
- Migration strategies and planning
- Design patterns and best practices
- Troubleshooting guides

**Don't write manual docs for**:
- API endpoint specifications (use OpenAPI generation)
- Type definitions (use schema generation)
- SDK usage examples (generate from Nickel)
- Configuration options (generate from config.ncl)

## Key Documentation Files

### WEEK_1_2_GUIDE.md
**Purpose**: Day-by-day implementation plan for first 2 weeks
**Audience**: Developers starting work on circular-canonical
**Update when**:
- Sprint goals change
- New phases are completed
- Timeline adjustments needed

**Structure**:
```markdown
## Week 1: Foundation
### Day 1: Environment Setup
- [ ] Task 1
- [ ] Task 2

### Day 2: Schema Definition
...
```

### DEVELOPMENT_WORKFLOW.md
**Purpose**: Git workflow, PR process, release process
**Audience**: All contributors
**Update when**:
- Git hooks change (git-hooks.nix)
- PR requirements change
- Release process changes
- New IDE setup instructions

**Key sections**:
- Branch naming conventions
- Commit message format (Conventional Commits)
- Pre-commit/pre-push hooks
- PR checklist
- Release versioning

### TESTING_STRATEGY.md
**Purpose**: Four-layer testing approach
**Audience**: Developers writing tests
**Update when**:
- Test layers change
- New test types added
- Performance targets change

**Structure**:
```markdown
## Layer 1: Contract Validation (< 5s)
## Layer 2: Unit Tests (< 30s)
## Layer 3: Integration Tests (< 2m)
## Layer 4: Cross-Language & Regression (< 5m)
```

### MIGRATION_PATH.md
**Purpose**: 24-week migration from circular-js to canonical
**Audience**: Project managers, stakeholders
**Update when**:
- Migration milestones reached
- Timeline adjustments
- New blockers identified

### NICKEL_PATTERNS.md
**Purpose**: Comprehensive Nickel language guide
**Audience**: Developers writing .ncl files
**Update when**:
- New patterns discovered
- Best practices evolve
- Common issues identified

**Key sections**:
- Contracts (validation)
- Merging (composition)
- Custom types
- String interpolation
- Import paths
- 10+ real-world examples

### SDK_GUIDE.md
**Purpose**: How to use generated SDKs
**Audience**: SDK consumers (external developers)
**Update when**:
- SDK API surface changes
- New languages added
- Installation process changes

**NOTE**: Consider generating this from Nickel in future.

## Documentation Standards

### Markdown Style

**Headers**:
```markdown
# Top-level title (H1 - only one per file)
## Major sections (H2)
### Subsections (H3)
#### Details (H4)
```

**Code blocks**: Always specify language
```markdown
```nickel
# Nickel code here
```

```typescript
// TypeScript code here
```

**Links**:
- Use relative links for internal docs: `[Testing Strategy](TESTING_STRATEGY.md)`
- Use absolute links for external resources: `[Nickel Lang](https://nickel-lang.org/)`

**Lists**:
- Use `-` for unordered lists
- Use `1.` for ordered lists (auto-numbering)
- Use `- [ ]` for task lists

### Documentation Review Checklist

Before committing documentation:

- [ ] Spell check (pre-commit hook runs markdown linter)
- [ ] Links work (relative paths correct)
- [ ] Code examples are valid (copy-paste testable)
- [ ] Reflects current implementation (not outdated)
- [ ] Cross-references updated (other docs mentioning this topic)
- [ ] Conventional filename (SCREAMING_SNAKE_CASE.md)

### Generated Documentation

**OpenAPI Specification**:
```bash
# Generated from src/api/*.ncl
just generate-openapi

# Output: dist/openapi/openapi.yaml
# Can be viewed with Swagger UI, Redocly, etc.
```

**SDK Documentation**:
```bash
# Generated from src/api/*.ncl
just generate-ts-sdk  # Includes JSDoc comments
just generate-py-sdk  # Includes docstrings

# TypeScript: Use TypeDoc
cd dist/circular-ts && npm run docs

# Python: Use Sphinx
cd dist/circular-py && make docs
```

## Documentation Maintenance

### Quarterly Review

Every 3 months, review all docs for:
1. **Accuracy**: Does it match current implementation?
2. **Completeness**: Are new features documented?
3. **Clarity**: Are examples still clear?
4. **Dead links**: Are external links still valid?

### When Code Changes

**API changes** (src/api/*.ncl):
- ✅ OpenAPI auto-updates (generated)
- ✅ SDK docs auto-update (generated)
- ⚠️ Update MIGRATION_PATH.md if breaking change
- ⚠️ Update CHANGELOG.md

**Generator changes** (generators/*.ncl):
- ⚠️ Update NICKEL_PATTERNS.md if new pattern
- ⚠️ Update relevant generator CLAUDE.md files

**Test changes** (tests/*.ncl):
- ⚠️ Update TESTING_STRATEGY.md if layer changes
- ⚠️ Update tests/CLAUDE.md if philosophy changes

**Workflow changes** (git-hooks.nix, justfile):
- ⚠️ Update DEVELOPMENT_WORKFLOW.md
- ⚠️ Update root CLAUDE.md if essential commands change

## Writing Effective Documentation

### Architecture Decision Records (ADRs)

When making significant architectural decisions:

```markdown
# ADR-001: Why Nickel as Single Source of Truth

## Status
Accepted

## Context
We need a way to define APIs once and generate multiple SDKs...

## Decision
We will use Nickel as the canonical source...

## Consequences
### Positive
- Zero drift between SDKs
- Contract validation at build time

### Negative
- Team needs to learn Nickel
- Build step required
```

### Problem-Solution Documentation

Structure troubleshooting docs as:
```markdown
## Problem: Test fails with "contract violation"

**Symptoms**:
- Error message shows: "contract `Address` violated"
- Happens during `nickel export`

**Cause**:
Address format validation expects 64 or 66 characters

**Solution**:
Ensure address includes "0x" prefix:
```nickel
{ Address = "0x742d35..." }  # Correct (66 chars)
```
```

### Step-by-Step Guides

Use numbered steps with clear outcomes:
```markdown
## Adding a New API Endpoint

1. **Define in src/api/<domain>.ncl**:
   ```nickel
   newEndpoint = { ... }
   ```
   Expected: Endpoint definition with contracts

2. **Validate syntax**:
   ```bash
   nickel typecheck src/api/<domain>.ncl
   ```
   Expected: No type errors

3. **Generate outputs**:
   ```bash
   just generate
   ```
   Expected: dist/ contains updated SDKs
```

## Cross-References

- Generated API docs: OpenAPI spec in `dist/openapi/`
- Implementation guidance: `src/CLAUDE.md`, `generators/CLAUDE.md`
- Test documentation: `tests/CLAUDE.md`
- Git workflow details: `DEVELOPMENT_WORKFLOW.md`
- Nickel language patterns: `NICKEL_PATTERNS.md`

## External Documentation Resources

- [Nickel Language Docs](https://nickel-lang.org/): Official Nickel documentation
- [OpenAPI 3.0 Spec](https://spec.openapis.org/oas/v3.0.0): OpenAPI specification
- [Conventional Commits](https://www.conventionalcommits.org/): Commit message format
- [Semantic Versioning](https://semver.org/): Version numbering rules
- [CommonMark Spec](https://commonmark.org/): Markdown specification
