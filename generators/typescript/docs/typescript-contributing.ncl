# TypeScript CONTRIBUTING.md Generator
# Provides contribution guidelines for TypeScript SDK contributors

let config = import "../../../src/config.ncl" in

{
  contributing_content = m%"
# Contributing to Circular Protocol TypeScript SDK

Thank you for your interest in contributing to the Circular Protocol TypeScript SDK!

## Important: This is a Generated Repository

⚠️ **DO NOT edit generated files directly**. This SDK is automatically generated from canonical Nickel definitions in the [circular-canonical](https://github.com/lessuseless-systems/circular-canonical) repository.

### Where to Make Changes

| Type of Change | Location | Repository |
|----------------|----------|------------|
| API definitions, endpoints | `src/api/*.ncl` | circular-canonical |
| Type schemas, contracts | `src/schemas/*.ncl` | circular-canonical |
| TypeScript generator logic | `generators/typescript/` | circular-canonical |
| Tests (templates) | `generators/typescript/tests/` | circular-canonical |
| Documentation (templates) | `generators/typescript/docs/` | circular-canonical |
| Bug reports, feature requests | Issues | This repository |

## Development Environment

### Prerequisites

- **Node.js**: 18.x or 20.x
- **npm**: 9.x or higher
- **Nix** (optional, recommended): For reproducible development environment

### Setup

```bash
# Clone repository
git clone https://github.com/lessuseless-systems/circular-ts.git
cd circular-ts

# Install dependencies
npm install

# Run tests
npm test

# Or using Nix + Just
nix develop
just test-unit
```

### Available Commands

```bash
# Development
just test-unit           # Run unit tests (fast, isolated)
just test-integration    # Run integration tests (mock server)
just test-e2e            # Run E2E tests (requires credentials)
just test                # Run all tests
just lint                # Run ESLint
just typecheck           # Run TypeScript compiler check
just build               # Build CommonJS and ESM bundles
just clean               # Clean build artifacts

# Examples
just run-example basic   # Run basic usage example
just run-example wallet  # Run wallet operations example
```

## Testing

### Test Structure

We use a 3-layer testing approach:

**1. Unit Tests** (`tests/*.test.ts`)
- Fast, isolated tests with mocked HTTP client
- Test individual methods
- No external dependencies
- Run with: `npm test` or `just test-unit`

**2. Integration Tests** (`tests/integration.test.ts`)
- Test method interactions
- Use local mock API server
- No credentials required
- Run with: `npm run test:integration` or `just test-integration`

**3. E2E Tests** (`tests/e2e.test.ts`)
- Test against live Circular Protocol NAG API
- Require environment variables:
  - `CIRCULAR_NAG_API_URL`
  - `CIRCULAR_TEST_BLOCKCHAIN` (use SandBox: `0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5c8e73f`)
  - `CIRCULAR_TEST_ADDRESS`
  - `CIRCULAR_TEST_PRIVATE_KEY`
- Skipped if credentials missing
- Run with: `npm run test:e2e` or `just test-e2e`

### Writing Tests

When adding tests, follow existing patterns:

```typescript
describe('CircularProtocolAPI', () => {
  let api: CircularProtocolAPI;

  beforeEach(() => {
    api = new CircularProtocolAPI('https://nag.circularlabs.io/NAG.php');
  });

  afterEach(() => {
    api.dispose();
  });

  it('should check wallet existence', async () => {
    const result = await api.checkWallet('MainNet', testAddress);
    expect(result.Result).toBe(200);
    expect(result.Response).toHaveProperty('exists');
  });
});
```

## Code Style

### TypeScript Conventions

- **Naming**: camelCase for functions/variables, PascalCase for classes/types
- **Async**: Use async/await (not callbacks or raw Promises)
- **Types**: Explicit return types for all public methods
- **Errors**: Do NOT throw for non-200 Result codes (backwards compatibility)

### ESLint

All code must pass ESLint:
```bash
npm run lint
```

Fix auto-fixable issues:
```bash
npm run lint:fix
```

### TypeScript Compiler

All code must type-check:
```bash
npm run typecheck
```

## Pull Request Process

### For Bug Fixes

1. **File an issue** in this repository describing the bug
2. **Report in canonical** if the bug is in generator logic
3. **Wait for triage** - maintainers will determine if fix goes here or in canonical
4. **Submit PR** to the appropriate repository

### For New Features

1. **Discuss first** - File an issue proposing the feature
2. **Canonical changes required** - New endpoints/methods must be defined in canonical source
3. **Follow the workflow**:
   - Define endpoint in `circular-canonical/src/api/*.ncl`
   - Update TypeScript generator
   - Regenerate SDK
   - Add tests
   - Submit PR to canonical repository

### PR Checklist

- [ ] All tests pass (`npm test`)
- [ ] Code passes linting (`npm run lint`)
- [ ] TypeScript compiler passes (`npm run typecheck`)
- [ ] New code has tests
- [ ] CHANGELOG.md updated (for user-facing changes)
- [ ] Commit messages follow Conventional Commits format

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(wallet): add getWalletHistory method
fix(transaction): correct date format in getTransactionbyDate
docs(readme): update installation instructions
test(e2e): add SandBox blockchain tests
chore(deps): update dependencies
```

## Backwards Compatibility

This SDK maintains strict backwards compatibility with circular-js v1.0.8.

### Breaking Changes NOT Allowed

- Changing method signatures
- Removing methods
- Throwing exceptions for non-200 Result codes
- Changing response structure

### Breaking Changes Process

If a breaking change is absolutely necessary:
1. Discuss in an issue first
2. Requires major version bump
3. Requires migration guide
4. Requires CHANGELOG entry
5. Requires deprecation notice period (minimum 1 minor version)

## Release Process

Releases are managed by maintainers:

1. Version bump in canonical `src/config.ncl`
2. Update CHANGELOG.md
3. Regenerate all SDKs
4. Tag release: `git tag -a v{version} -m "Release v{version}"`
5. Push tags: `git push origin v{version}`
6. GitHub Actions publishes to npm

## Questions?

- **Bug reports**: File an issue in this repository
- **Feature requests**: File an issue in circular-canonical
- **Generator bugs**: File an issue in circular-canonical
- **Questions**: Start a discussion in circular-canonical

## Code of Conduct

Be respectful, inclusive, and professional. We're all here to build great software together.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

*Generated from circular-canonical v%{config.version}*
"%,
}
