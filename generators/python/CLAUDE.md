# generators/python/CLAUDE.md

Guidance for working with Python SDK generators.

> **Parent Context**: See `generators/CLAUDE.md` for generator system overview.

## Directory Structure

```
generators/python/
├── CLAUDE.md                          # This file
├── python-sdk.ncl                     # Main SDK generator
├── tests/
│   ├── python-tests.ncl               # Integration test generator
│   └── python-unit-tests.ncl          # Unit test generator
├── config/
│   └── python-pytest-ini.todo.ncl     # pytest.ini config (TODO)
├── docs/
│   └── python-readme.todo.ncl         # README.md generator (TODO)
├── package-manifest/
│   ├── python-pyproject-toml.todo.ncl # pyproject.toml generator (TODO)
│   └── python-setup-py.todo.ncl       # setup.py generator (TODO)
├── metadata/
│   └── python-gitignore.todo.ncl      # .gitignore generator (TODO)
└── ci-cd/
    └── python-github-actions-test.todo.ncl  # GitHub Actions (TODO)
```

## Python SDK Generator

### Main SDK Structure

The Python SDK generator (`python-sdk.ncl`) produces:

```python
# Generated SDK structure
from typing import Dict, Any, Optional
import requests

class CircularProtocolAPI:
    def __init__(self, config: 'CircularProtocolConfig'):
        self.base_url = config.base_url
        self.headers = config.headers or {}

    # Wallet operations
    def check_wallet(self, address: str) -> 'WalletCheckResponse':
        """Check if wallet exists on blockchain"""
        pass

    def get_wallet(self, address: str) -> 'WalletResponse':
        """Get wallet details"""
        pass

    # ... more endpoints
```

### Type Mappings

Nickel types → Python types:

```nickel
let type_mapping = fun nickel_type =>
  if nickel_type == "string" then "str"
  else if nickel_type == "number" then "int"
  else if nickel_type == "boolean" then "bool"
  else if nickel_type == "array" then "List[Any]"
  else if nickel_type == "object" then "Dict[str, Any]"
  else "Any"
```

### Naming Conventions

- **Functions/Methods**: `snake_case` (e.g., `check_wallet`, `get_asset_list`)
- **Classes**: `PascalCase` (e.g., `CircularProtocolAPI`, `WalletResponse`)
- **Type Aliases**: `PascalCase` (e.g., `Address`, `Amount`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `DEFAULT_TIMEOUT`)
- **Private members**: `_leading_underscore` (e.g., `_make_request`)

### Async Patterns (Optional)

Python SDK can support both sync and async:

**Synchronous (default)**:
```python
def check_wallet(self, address: str) -> WalletCheckResponse:
    response = requests.get(f"{self.base_url}/checkWallet", params={'address': address})
    response.raise_for_status()
    return WalletCheckResponse(**response.json())
```

**Asynchronous (with aiohttp)**:
```python
async def check_wallet(self, address: str) -> WalletCheckResponse:
    async with aiohttp.ClientSession() as session:
        async with session.get(f"{self.base_url}/checkWallet", params={'address': address}) as response:
            response.raise_for_status()
            data = await response.json()
            return WalletCheckResponse(**data)
```

## Type Hints and Validation

### Type Hints

Python SDK uses type hints for all public APIs:

```python
from typing import Dict, List, Optional, Union, Literal

Blockchain = Literal['ethereum', 'polygon', 'bsc', 'avalanche']

class WalletResponse:
    address: str
    balance: str
    nonce: int
    blockchain: Blockchain
    status: str

    def __init__(self, **kwargs):
        self.address = kwargs['address']
        self.balance = kwargs['balance']
        # ...
```

### Runtime Validation (with Pydantic)

For stricter type safety, use Pydantic models:

```python
from pydantic import BaseModel, Field, validator

class Address(str):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v: str) -> str:
        if len(v) not in (64, 66):
            raise ValueError('Address must be 64 or 66 characters')
        if not all(c in '0123456789abcdefABCDEF' for c in v.replace('0x', '')):
            raise ValueError('Address must be hexadecimal')
        return v

class WalletResponse(BaseModel):
    address: Address
    balance: str
    nonce: int = Field(ge=0)
    blockchain: Blockchain
```

## Package Configuration

### pyproject.toml Generator

Generates modern Python package manifest:

```toml
[build-system]
requires = ["setuptools>=45", "wheel", "setuptools_scm>=6.2"]
build-backend = "setuptools.build_meta"

[project]
name = "circular-protocol-api"
version = "2.0.0a1"
description = "Official Python SDK for Circular Protocol blockchain"
readme = "README.md"
requires-python = ">=3.8"
license = {text = "MIT"}
authors = [
    {name = "Circular Protocol", email = "dev@circular.org"}
]
keywords = ["blockchain", "api", "sdk", "circular", "protocol"]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
]
dependencies = [
    "requests>=2.28.0",
    "pydantic>=2.0.0",
]

[project.optional-dependencies]
async = ["aiohttp>=3.8.0"]
dev = ["pytest>=7.0.0", "black>=22.0.0", "mypy>=0.990", "ruff>=0.0.270"]

[project.urls]
Homepage = "https://github.com/circular-protocol/circular-canonical"
Documentation = "https://docs.circular.org"
Repository = "https://github.com/circular-protocol/circular-canonical"
```

### setup.py Generator (Legacy)

For compatibility with older tools:

```python
from setuptools import setup, find_packages

setup(
    name="circular-protocol-api",
    version="2.0.0a1",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    python_requires=">=3.8",
    install_requires=[
        "requests>=2.28.0",
        "pydantic>=2.0.0",
    ],
)
```

## Test Generators

### Unit Tests (pytest)

Generates pytest unit tests:

```python
import pytest
from circular_protocol_api import CircularProtocolAPI

class TestCircularProtocolAPI:
    def test_check_wallet_exists(self):
        api = CircularProtocolAPI(base_url='http://test')
        result = api.check_wallet('0x1234...')
        assert result.exists is not None

    def test_check_wallet_invalid_address(self):
        api = CircularProtocolAPI(base_url='http://test')
        with pytest.raises(ValueError):
            api.check_wallet('invalid')

    @pytest.mark.parametrize('address', [
        '0x' + '0' * 64,
        '0' * 64,
        '0x' + 'f' * 64,
    ])
    def test_check_wallet_valid_addresses(self, address):
        api = CircularProtocolAPI(base_url='http://test')
        result = api.check_wallet(address)
        assert result is not None
```

### Integration Tests

```python
import pytest
import os

@pytest.mark.integration
class TestWalletIntegration:
    @pytest.fixture
    def api(self):
        return CircularProtocolAPI(
            base_url=os.getenv('API_URL', 'http://localhost:3000')
        )

    def test_full_wallet_workflow(self, api):
        # Register wallet
        address = api.register_wallet(params={'blockchain': 'ethereum'})

        # Get wallet
        wallet = api.get_wallet(address)
        assert wallet.address == address

        # Get balance
        balance = api.get_wallet_balance(address)
        assert balance.balance is not None
```

## Build Process

### Development Build

```bash
# Type check
just validate

# Generate Python SDK
just generate-py-sdk

# Install in development mode
cd dist/python
pip install -e .

# Run tests
pytest
```

### Production Build

```bash
# Generate
just generate

# Build wheel
cd dist/python
python -m build

# Verify
twine check dist/*
```

## Common Patterns

### Error Handling

```python
class CircularAPIError(Exception):
    def __init__(self, message: str, status_code: int, endpoint: str):
        super().__init__(message)
        self.status_code = status_code
        self.endpoint = endpoint

def check_wallet(self, address: str) -> WalletCheckResponse:
    try:
        response = requests.get(
            f"{self.base_url}/checkWallet",
            params={'address': address},
            headers=self.headers
        )
        response.raise_for_status()
        return WalletCheckResponse(**response.json())
    except requests.HTTPError as e:
        raise CircularAPIError(
            str(e),
            e.response.status_code if e.response else 0,
            '/checkWallet'
        )
    except requests.RequestException as e:
        raise CircularAPIError(str(e), 0, '/checkWallet')
```

### Context Manager Support

```python
class CircularProtocolAPI:
    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        # Cleanup if needed
        pass

# Usage
with CircularProtocolAPI(config) as api:
    wallet = api.check_wallet('0x1234...')
```

### Retry Logic

```python
from typing import TypeVar, Callable
import time

T = TypeVar('T')

def with_retry(
    func: Callable[..., T],
    max_retries: int = 3,
    backoff: float = 1.0
) -> T:
    for attempt in range(max_retries):
        try:
            return func()
        except requests.RequestException as e:
            if attempt == max_retries - 1:
                raise
            time.sleep(backoff * (2 ** attempt))
```

## Publishing to PyPI

### Pre-publish Checklist

1. ✅ All tests pass: `pytest`
2. ✅ Type check passes: `mypy src/`
3. ✅ Linting passes: `ruff check src/`
4. ✅ Formatting checked: `black --check src/`
5. ✅ README up to date
6. ✅ CHANGELOG updated
7. ✅ Version bumped in pyproject.toml

### Build and Publish

```bash
# Build
python -m build

# Check package
twine check dist/*

# Upload to TestPyPI
twine upload --repository testpypi dist/*

# Test installation
pip install --index-url https://test.pypi.org/simple/ circular-protocol-api

# Upload to PyPI
twine upload dist/*
```

## Code Quality Tools

### Type Checking (mypy)

```bash
mypy src/ --strict
```

### Linting (ruff)

```bash
ruff check src/
ruff format src/
```

### Testing (pytest)

```bash
# All tests
pytest

# With coverage
pytest --cov=circular_protocol_api --cov-report=html

# Specific test
pytest tests/test_wallet.py::TestCircularProtocolAPI::test_check_wallet
```

## Common Issues

### Import Errors

**Problem**: `ModuleNotFoundError: No module named 'circular_protocol_api'`
**Solution**: Install package in development mode: `pip install -e .`

### Type Hint Issues

**Problem**: mypy reports type errors
**Solution**: Add `# type: ignore` for unavoidable issues, or use `cast()`:
```python
from typing import cast
result = cast(WalletResponse, api.check_wallet('0x1234...'))
```

### Async/Sync Compatibility

**Problem**: Want both sync and async versions
**Solution**: Generate two separate classes or use `asyncio.run()` wrapper

## Cross-References

- Generator patterns: `generators/CLAUDE.md`
- Source schemas: `src/CLAUDE.md`
- TypeScript SDK comparison: `generators/typescript/CLAUDE.md`
