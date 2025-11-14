# Go CONTRIBUTING.md Generator
# Provides contribution guidelines for Go SDK contributors

let config = import "../../../src/config.ncl" in

{
  contributing_content = m%"
# Contributing to Circular Protocol Go SDK

Thank you for your interest in contributing to the Circular Protocol Go SDK!

## Important: This is a Generated Repository

⚠️ **DO NOT edit generated files directly**. This SDK is automatically generated from canonical Nickel definitions in the [circular-canonical](https://github.com/lessuseless-systems/circular-canonical) repository.

### Where to Make Changes

| Type of Change | Location | Repository |
|----------------|----------|------------|
| API definitions, endpoints | `src/api/*.ncl` | circular-canonical |
| Type schemas, contracts | `src/schemas/*.ncl` | circular-canonical |
| Go generator logic | `generators/go/` | circular-canonical |
| Tests (templates) | `generators/go/tests/` | circular-canonical |
| Documentation (templates) | `generators/go/docs/` | circular-canonical |
| Bug reports, feature requests | Issues | This repository |

## Development Environment

### Prerequisites

- **Go**: 1.19, 1.20, or 1.21
- **go mod**: Included with Go
- **Nix** (optional, recommended): For reproducible development environment

### Setup

```bash
# Clone repository
git clone https://github.com/lessuseless-systems/circular-go.git
cd circular-go

# Download dependencies
go mod download

# Run tests
go test -v

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
just lint                # Run golangci-lint
just format              # Format code with gofmt
just build               # Build the library
just coverage            # Run tests with coverage report

# Examples
just run-example basic   # Run basic usage example
just run-example wallet  # Run wallet operations example
```

## Testing

### Test Structure

We use a 3-layer testing approach:

**1. Unit Tests** (`circular_protocol_test.go`)
- Fast, isolated tests with mocked HTTP client
- Test individual methods
- No external dependencies
- Run with: `go test -run TestUnit` or `just test-unit`

**2. Integration Tests** (`circular_protocol_integration_test.go`)
- Test method interactions
- Use local mock API server
- No credentials required
- Run with: `go test -run TestIntegration` or `just test-integration`

**3. E2E Tests** (`circular_protocol_e2e_test.go`)
- Test against live Circular Protocol NAG API
- Require environment variables:
  - `CIRCULAR_NAG_API_URL`
  - `CIRCULAR_TEST_BLOCKCHAIN` (use SandBox: `0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5c8e73f`)
  - `CIRCULAR_TEST_ADDRESS`
  - `CIRCULAR_TEST_PRIVATE_KEY`
- Skipped if credentials missing
- Run with: `go test -run TestE2E` or `just test-e2e`

### Writing Tests

When adding tests, follow existing patterns:

```go
func TestCheckWallet(t *testing.T) {
    api := NewCircularProtocolAPI("https://nag.circularlabs.io/NAG.php")
    defer api.Close()

    result, err := api.CheckWallet("MainNet", testAddress)
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }

    if result.Result != 200 {
        t.Errorf("expected Result 200, got %d", result.Result)
    }
}
```

## Code Style

### Go Conventions

- **Naming**: camelCase for private, PascalCase for exported
- **Comments**: Godoc format for all exported functions
- **Errors**: Return error values (do NOT panic for non-200 Result codes)
- **Context**: Use context.Context for cancellation support

### Formatting

All code must be formatted with gofmt:
```bash
gofmt -w .
```

### Linting

All code must pass golangci-lint:
```bash
golangci-lint run
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
   - Update Go generator
   - Regenerate SDK
   - Add tests
   - Submit PR to canonical repository

### PR Checklist

- [ ] All tests pass (`go test -v`)
- [ ] Code is formatted (`gofmt -d . | wc -l` returns 0)
- [ ] Code passes linting (`golangci-lint run`)
- [ ] New code has tests
- [ ] New functions have Godoc comments
- [ ] CHANGELOG.md updated (for user-facing changes)
- [ ] Commit messages follow Conventional Commits format

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(wallet): add GetWalletHistory method
fix(transaction): correct date format in GetTransactionByDate
docs(readme): update installation instructions
test(e2e): add SandBox blockchain tests
chore(deps): update dependencies
```

## Backwards Compatibility

This SDK maintains strict backwards compatibility with circular-js v1.0.8 (Go equivalent).

### Breaking Changes NOT Allowed

- Changing method signatures
- Removing exported functions
- Panicking for non-200 Result codes (return errors instead)
- Changing response structure

### Breaking Changes Process

If a breaking change is absolutely necessary:
1. Discuss in an issue first
2. Requires major version bump (v2.0.0)
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
6. Go proxy automatically indexes new version

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
