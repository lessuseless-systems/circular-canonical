# Python CONTRIBUTING.md Generator
# Provides contribution guidelines for Python SDK contributors

let config = import "../../../src/config.ncl" in

{
  contributing_content = m%"
# Contributing to Circular Protocol Python SDK

Thank you for your interest in contributing to the Circular Protocol Python SDK!

## Important: This is a Generated Repository

⚠️ **DO NOT edit generated files directly**. This SDK is automatically generated from canonical Nickel definitions in the [circular-canonical](https://github.com/lessuseless-systems/circular-canonical) repository.

### Where to Make Changes

| Type of Change | Location | Repository |
|----------------|----------|------------|
| API definitions, endpoints | `src/api/*.ncl` | circular-canonical |
| Type schemas, contracts | `src/schemas/*.ncl` | circular-canonical |
| Python generator logic | `generators/python/` | circular-canonical |
| Tests (templates) | `generators/python/tests/` | circular-canonical |
| Documentation (templates) | `generators/python/docs/` | circular-canonical |
| Bug reports, feature requests | Issues | This repository |

## Development Environment

### Prerequisites

- **Python**: 3.8, 3.9, 3.10, 3.11, or 3.12
- **pip**: Latest version
- **Nix** (optional, recommended): For reproducible development environment

### Setup

```bash
# Clone repository
git clone https://github.com/lessuseless-systems/circular-py.git
cd circular-py

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -e ".[dev]"

# Run tests
pytest

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
just lint                # Run ruff linter
just format              # Format code with black
just typecheck           # Run mypy type checker
just build               # Build distribution packages

# Examples
just run-example basic   # Run basic usage example
just run-example wallet  # Run wallet operations example
```

## Testing

### Test Structure

We use a 3-layer testing approach:

**1. Unit Tests** (`tests/test_unit.py`)
- Fast, isolated tests with mocked HTTP client
- Test individual methods
- No external dependencies
- Run with: `pytest tests/test_unit.py` or `just test-unit`

**2. Integration Tests** (`tests/test_integration.py`)
- Test method interactions
- Use local mock API server
- No credentials required
- Run with: `pytest tests/test_integration.py` or `just test-integration`

**3. E2E Tests** (`tests/test_e2e.py`)
- Test against live Circular Protocol NAG API
- Require environment variables:
  - `CIRCULAR_NAG_API_URL`
  - `CIRCULAR_TEST_BLOCKCHAIN` (use SandBox: `0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5c8e73f`)
  - `CIRCULAR_TEST_ADDRESS`
  - `CIRCULAR_TEST_PRIVATE_KEY`
- Skipped if credentials missing
- Run with: `pytest tests/test_e2e.py` or `just test-e2e`

### Writing Tests

When adding tests, follow existing patterns:

```python
import pytest
from circular_protocol_api import CircularProtocolAPI

class TestCircularProtocolAPI:
    def setup_method(self):
        self.api = CircularProtocolAPI('https://nag.circularlabs.io/NAG.php')

    def teardown_method(self):
        self.api.close()

    def test_check_wallet(self):
        result = self.api.check_wallet('MainNet', test_address)
        assert result['Result'] == 200
        assert 'exists' in result['Response']
```

## Code Style

### Python Conventions

- **Naming**: snake_case for functions/variables, PascalCase for classes
- **Type Hints**: Use type hints for all public methods (Python 3.8+ syntax)
- **Docstrings**: Google-style docstrings for all public methods
- **Errors**: Do NOT raise exceptions for non-200 Result codes (backwards compatibility)

### Linting and Formatting

All code must pass ruff and be formatted with black:

```bash
# Check linting
ruff check .

# Auto-fix linting issues
ruff check --fix .

# Format code
black .

# Check formatting without changes
black --check .
```

### Type Checking

All code must pass mypy:
```bash
mypy src/
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
   - Update Python generator
   - Regenerate SDK
   - Add tests
   - Submit PR to canonical repository

### PR Checklist

- [ ] All tests pass (`pytest`)
- [ ] Code passes linting (`ruff check .`)
- [ ] Code is formatted (`black --check .`)
- [ ] Type hints pass (`mypy src/`)
- [ ] New code has tests
- [ ] New methods have docstrings
- [ ] CHANGELOG.md updated (for user-facing changes)
- [ ] Commit messages follow Conventional Commits format

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(wallet): add get_wallet_history method
fix(transaction): correct date format in get_transaction_by_date
docs(readme): update installation instructions
test(e2e): add sandbox blockchain tests
chore(deps): update dependencies
```

## Backwards Compatibility

This SDK maintains strict backwards compatibility with circular-js v1.0.8 (Python equivalent).

### Breaking Changes NOT Allowed

- Changing method signatures
- Removing methods
- Raising exceptions for non-200 Result codes
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
4. Update `pyproject.toml` version
5. Build: `python -m build`
6. Tag release: `git tag -a v{version} -m "Release v{version}"`
7. Push tags: `git push origin v{version}`
8. GitHub Actions publishes to PyPI

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
