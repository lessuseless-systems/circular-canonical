# PHP CONTRIBUTING.md Generator
# Provides contribution guidelines for PHP SDK contributors

let config = import "../../../src/config.ncl" in

{
  contributing_content = m%"
# Contributing to Circular Protocol PHP SDK

Thank you for your interest in contributing to the Circular Protocol PHP SDK!

## Important: This is a Generated Repository

⚠️ **DO NOT edit generated files directly**. This SDK is automatically generated from canonical Nickel definitions in the [circular-canonical](https://github.com/lessuseless-systems/circular-canonical) repository.

### Where to Make Changes

| Type of Change | Location | Repository |
|----------------|----------|------------|
| API definitions, endpoints | `src/api/*.ncl` | circular-canonical |
| Type schemas, contracts | `src/schemas/*.ncl` | circular-canonical |
| PHP generator logic | `generators/php/` | circular-canonical |
| Tests (templates) | `generators/php/tests/` | circular-canonical |
| Documentation (templates) | `generators/php/docs/` | circular-canonical |
| Bug reports, feature requests | Issues | This repository |

## Development Environment

### Prerequisites

- **PHP**: 7.4, 8.0, 8.1, 8.2, or 8.3
- **Composer**: 2.x
- **Nix** (optional, recommended): For reproducible development environment

### Setup

```bash
# Clone repository
git clone https://github.com/lessuseless-systems/circular-php.git
cd circular-php

# Install dependencies
composer install

# Run tests
composer test

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
just lint                # Run PHP_CodeSniffer
just format              # Fix code style with phpcbf
just analyze             # Run PHPStan static analysis

# Examples
just run-example basic   # Run basic usage example
just run-example wallet  # Run wallet operations example
```

## Testing

### Test Structure

We use a 3-layer testing approach with PHPUnit:

**1. Unit Tests** (`tests/CircularProtocolUnitTest.php`)
- Fast, isolated tests with mocked HTTP client
- Test individual methods
- No external dependencies
- Run with: `composer test:unit` or `just test-unit`

**2. Integration Tests** (`tests/CircularProtocolIntegrationTest.php`)
- Test method interactions
- Use local mock API server
- No credentials required
- Run with: `composer test:integration` or `just test-integration`

**3. E2E Tests** (`tests/CircularProtocolE2ETest.php`)
- Test against live Circular Protocol NAG API
- Require environment variables:
  - `CIRCULAR_NAG_API_URL`
  - `CIRCULAR_TEST_BLOCKCHAIN` (use SandBox: `0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5c8e73f`)
  - `CIRCULAR_TEST_ADDRESS`
  - `CIRCULAR_TEST_PRIVATE_KEY`
- Skipped if credentials missing
- Run with: `composer test:e2e` or `just test-e2e`

### Writing Tests

When adding tests, follow existing patterns:

```php
<?php
use PHPUnit\Framework\TestCase;

class CircularProtocolTest extends TestCase {
    private $api;

    protected function setUp(): void {
        $this->api = new CircularProtocolAPI('https://nag.circularlabs.io/NAG.php');
    }

    protected function tearDown(): void {
        unset($this->api);
    }

    public function testCheckWallet(): void {
        $result = $this->api->checkWallet('MainNet', $testAddress);
        $this->assertEquals(200, $result['Result']);
        $this->assertArrayHasKey('exists', $result['Response']);
    }
}
```

## Code Style

### PHP Conventions

- **PSR-12**: Follow PSR-12 coding standard
- **Naming**: camelCase for methods, PascalCase for classes
- **Type Declarations**: Use type hints (PHP 7.4+)
- **DocBlocks**: PHPDoc for all public methods
- **Errors**: Do NOT throw exceptions for non-200 Result codes (backwards compatibility)

### Code Sniffer

All code must pass PHP_CodeSniffer:
```bash
composer lint
```

Fix auto-fixable issues:
```bash
composer format
```

### Static Analysis

All code must pass PHPStan (level 8):
```bash
composer analyze
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
   - Update PHP generator
   - Regenerate SDK
   - Add tests
   - Submit PR to canonical repository

### PR Checklist

- [ ] All tests pass (`composer test`)
- [ ] Code passes PSR-12 (`composer lint`)
- [ ] Code passes PHPStan (`composer analyze`)
- [ ] New code has tests
- [ ] New methods have PHPDoc blocks
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

This SDK maintains strict backwards compatibility with circular-js v1.0.8 (PHP equivalent).

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
4. Update `composer.json` version
5. Tag release: `git tag -a v{version} -m "Release v{version}"`
6. Push tags: `git push origin v{version}`
7. Submit to Packagist (or auto-update if webhook configured)

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
