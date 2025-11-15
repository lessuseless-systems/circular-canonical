# Dart CONTRIBUTING.md Generator
# Provides contribution guidelines for Dart SDK contributors

let config = import "../../../src/config.ncl" in

{
  contributing_content = m%"
# Contributing to Circular Protocol Dart SDK

Thank you for your interest in contributing to the Circular Protocol Dart SDK!

## Important: This is a Generated Repository

⚠️ **DO NOT edit generated files directly**. This SDK is automatically generated from canonical Nickel definitions in the [circular-canonical](https://github.com/lessuseless-systems/circular-canonical) repository.

### Where to Make Changes

| Type of Change | Location | Repository |
|----------------|----------|------------|
| API definitions, endpoints | `src/api/*.ncl` | circular-canonical |
| Type schemas, contracts | `src/schemas/*.ncl` | circular-canonical |
| Dart generator logic | `generators/dart/` | circular-canonical |
| Tests (templates) | `generators/dart/tests/` | circular-canonical |
| Documentation (templates) | `generators/dart/docs/` | circular-canonical |
| Bug reports, feature requests | Issues | This repository |

## Development Environment

### Prerequisites

- **Dart SDK**: 2.19 or higher (including Dart 3.x)
- **pub**: Included with Dart SDK
- **Nix** (optional, recommended): For reproducible development environment

### Setup

```bash
# Clone repository
git clone https://github.com/lessuseless-systems/circular-dart.git
cd circular-dart

# Get dependencies
dart pub get

# Run tests
dart test

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
just lint                # Run dart analyze
just format              # Format code with dart format
just coverage            # Run tests with coverage report

# Examples
just run-example basic   # Run basic usage example
just run-example wallet  # Run wallet operations example
```

## Testing

### Test Structure

We use a 3-layer testing approach:

**1. Unit Tests** (`test/unit_test.dart`)
- Fast, isolated tests with mocked HTTP client
- Test individual methods
- No external dependencies
- Run with: `dart test test/unit_test.dart` or `just test-unit`

**2. Integration Tests** (`test/integration_test.dart`)
- Test method interactions
- Use local mock API server
- No credentials required
- Run with: `dart test test/integration_test.dart` or `just test-integration`

**3. E2E Tests** (`test/e2e_test.dart`)
- Test against live Circular Protocol NAG API
- Require environment variables:
  - `CIRCULAR_NAG_API_URL`
  - `CIRCULAR_TEST_BLOCKCHAIN` (use SandBox: `0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5c8e73f`)
  - `CIRCULAR_TEST_ADDRESS`
  - `CIRCULAR_TEST_PRIVATE_KEY`
- Skipped if credentials missing
- Run with: `dart test test/e2e_test.dart` or `just test-e2e`

### Writing Tests

When adding tests, follow existing patterns:

```dart
import 'package:test/test.dart';
import 'package:circular_protocol/circular_protocol.dart';

void main() {
  group('CircularProtocolAPI', () {
    late CircularProtocolAPI api;

    setUp(() {
      api = CircularProtocolAPI('https://nag.circularlabs.io/NAG.php');
    });

    tearDown(() {
      api.dispose();
    });

    test('check wallet existence', () async {
      final result = await api.checkWallet('MainNet', testAddress);
      expect(result['Result'], equals(200));
      expect(result['Response'], contains('exists'));
    });
  });
}
```

## Code Style

### Dart Conventions

- **Naming**: lowerCamelCase for variables/methods, UpperCamelCase for classes
- **Null Safety**: Use null-safe code (required for Dart 2.12+)
- **Async**: Use async/await for asynchronous code
- **Comments**: Dartdoc comments for all public APIs
- **Errors**: Do NOT throw exceptions for non-200 Result codes (backwards compatibility)

### Formatting

All code must be formatted with dart format:
```bash
dart format .
```

Check formatting without changes:
```bash
dart format --set-exit-if-changed .
```

### Analysis

All code must pass dart analyze:
```bash
dart analyze
```

Configuration is in `analysis_options.yaml` following pub.dev best practices.

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
   - Update Dart generator
   - Regenerate SDK
   - Add tests
   - Submit PR to canonical repository

### PR Checklist

- [ ] All tests pass (`dart test`)
- [ ] Code is formatted (`dart format --set-exit-if-changed .`)
- [ ] Code passes analysis (`dart analyze`)
- [ ] New code has tests
- [ ] New methods have Dartdoc comments
- [ ] CHANGELOG.md updated (for user-facing changes)
- [ ] Commit messages follow Conventional Commits format
- [ ] pubspec.yaml version bumped (if applicable)

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(wallet): add getWalletHistory method
fix(transaction): correct date format in getTransactionByDate
docs(readme): update installation instructions
test(e2e): add SandBox blockchain tests
chore(deps): update dependencies
```

## Backwards Compatibility

This SDK maintains strict backwards compatibility with circular-js v1.0.8 (Dart equivalent).

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
4. Update `pubspec.yaml` version
5. Tag release: `git tag -a v{version} -m "Release v{version}"`
6. Push tags: `git push origin v{version}`
7. Publish to pub.dev: `dart pub publish`

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
