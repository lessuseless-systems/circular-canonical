# Python Package Structure - Standard Conventions

## Current Issues

Our generated Python package has several structural problems:

1. **Duplicate directories**: Both `circular_protocol_api/` and `src/circular_protocol_api/` exist
2. **Monolithic file**: 1250 lines in single `__init__.py` file
3. **Mixed layouts**: Confusing combination of flat and src layouts
4. **No module separation**: All code (models, client, helpers, crypto) in one file

## Standard Python Package Layout

### Option 1: Src Layout (Recommended - PyPA Best Practice)

```
circular-protocol-python/
├── src/
│   └── circular_protocol_api/
│       ├── __init__.py              # Public API exports only
│       ├── client.py                # CircularProtocolAPI class
│       ├── models.py                # TypedDict response models
│       ├── exceptions.py            # CircularAPIError, etc.
│       ├── _helpers.py              # Private helper functions
│       ├── _crypto.py               # Cryptographic utilities
│       └── resources/               # Optional: Resource-based organization
│           ├── __init__.py
│           ├── wallet.py
│           ├── transaction.py
│           ├── asset.py
│           └── block.py
├── tests/
│   ├── __init__.py
│   ├── test_client.py
│   ├── test_wallet.py
│   ├── test_crypto.py
│   └── test_e2e.py
├── docs/
│   ├── conf.py
│   ├── index.md
│   └── api.md
├── pyproject.toml                   # Modern package config (PEP 517/518/621)
├── setup.py                         # Legacy fallback (optional)
├── README.md
├── LICENSE
├── CHANGELOG.md
├── .gitignore
└── pytest.ini
```

### Option 2: Flat Layout (Simpler, but less recommended)

```
circular-protocol-python/
├── circular_protocol_api/
│   ├── __init__.py
│   ├── client.py
│   ├── models.py
│   └── ...
├── tests/
├── pyproject.toml
└── README.md
```

**Why src layout is better:**
- Forces proper installation even in development
- Prevents importing from source directory accidentally
- Clearer separation between source code and package metadata
- Industry standard (used by requests, black, pytest, etc.)

## Module Organization

### Current (Bad): Monolithic `__init__.py`

```python
# src/circular_protocol_api/__init__.py (1250 lines!)
class CheckWalletResponse(TypedDict): ...
class GetWalletResponse(TypedDict): ...
# ... 50 more TypedDict classes ...
class CircularProtocolAPI: ...
    def check_wallet(...): ...
    def get_wallet(...): ...
    # ... 24 API methods ...
    def sign_message(...): ...
    def hex_fix(...): ...
    # ... 10 helper methods ...
```

### Recommended: Modular Structure

#### `src/circular_protocol_api/__init__.py` (Clean public API)
```python
"""
Circular Protocol Python SDK
Official Python client for Circular Protocol blockchain.
"""

__version__ = "1.0.8"

from .client import CircularProtocolAPI
from .exceptions import (
    CircularAPIError,
    InvalidAddressError,
    InvalidNonceError,
    InvalidSignatureError,
)
from .models import (
    WalletResponse,
    TransactionResponse,
    BlockResponse,
    # ... other public models
)

__all__ = [
    "CircularProtocolAPI",
    "CircularAPIError",
    "InvalidAddressError",
    "WalletResponse",
    "TransactionResponse",
    # ... other exports
]
```

#### `src/circular_protocol_api/client.py` (Main API client)
```python
"""Main Circular Protocol API client."""

from typing import Optional
import requests

from .models import WalletResponse, TransactionResponse
from .exceptions import CircularAPIError
from ._helpers import HelperMixin
from ._crypto import CryptoMixin


class CircularProtocolAPI(HelperMixin, CryptoMixin):
    """
    Circular Protocol API client.

    Example:
        >>> api = CircularProtocolAPI()
        >>> wallet = api.check_wallet(
        ...     address="0x...",
        ...     blockchain="0x..."
        ... )
    """

    def __init__(
        self,
        base_url: Optional[str] = None,
        api_key: Optional[str] = None,
        timeout: int = 30
    ):
        self.base_url = base_url or "https://nag.circularlabs.io/NAG.php"
        self.api_key = api_key
        self.timeout = timeout
        self.version = "1.0.8"
        self._session = requests.Session()

    def check_wallet(
        self,
        address: str,
        blockchain: str
    ) -> WalletResponse:
        """Check if wallet exists on blockchain."""
        data = {
            "Address": self.hex_fix(address),
            "Blockchain": self.hex_fix(blockchain),
            "Version": self.version,
        }
        return self._make_request("Circular_CheckWallet_", data)

    # ... more API methods ...

    def _make_request(self, endpoint: str, data: dict) -> dict:
        """Internal request handler."""
        url = f"{self.base_url}?cep={endpoint}"
        response = self._session.post(url, json=data, timeout=self.timeout)
        response.raise_for_status()
        return response.json()
```

#### `src/circular_protocol_api/models.py` (Response models)
```python
"""Response type definitions."""

from typing import TypedDict, List, Optional


class WalletResponseData(TypedDict):
    """Wallet check response data."""
    exists: bool
    blockchain: str


class WalletResponse(TypedDict):
    """Wallet check response."""
    Result: int
    Response: WalletResponseData
    Node: str


class TransactionResponseData(TypedDict):
    """Transaction response data."""
    TxID: str
    Timestamp: str


class TransactionResponse(TypedDict):
    """Transaction submission response."""
    Result: int
    Response: TransactionResponseData
    Node: str


# ... more models ...
```

#### `src/circular_protocol_api/exceptions.py` (Custom exceptions)
```python
"""Circular Protocol API exceptions."""


class CircularAPIError(Exception):
    """Base exception for Circular Protocol API errors."""

    def __init__(
        self,
        message: str,
        result_code: Optional[int] = None,
        endpoint: Optional[str] = None
    ):
        super().__init__(message)
        self.result_code = result_code
        self.endpoint = endpoint


class InvalidAddressError(CircularAPIError):
    """Invalid wallet address format."""
    pass


class InvalidNonceError(CircularAPIError):
    """Invalid transaction nonce."""
    pass


class InvalidSignatureError(CircularAPIError):
    """Invalid transaction signature."""
    pass


class NetworkError(CircularAPIError):
    """Network communication error."""
    pass
```

#### `src/circular_protocol_api/_helpers.py` (Private helpers)
```python
"""
Helper utilities for Circular Protocol SDK.

Note: Functions prefixed with _ are private and not part of public API.
"""

import hashlib
from datetime import datetime


class HelperMixin:
    """Mixin providing helper methods to the main API client."""

    def hex_fix(self, hex_string: str) -> str:
        """
        Normalize hex strings (remove 0x prefix if present).

        Args:
            hex_string: Hex string with or without 0x prefix

        Returns:
            Normalized hex string without 0x prefix
        """
        if hex_string.startswith('0x') or hex_string.startswith('0X'):
            return hex_string[2:]
        return hex_string

    def string_to_hex(self, string: str) -> str:
        """Convert string to hex encoding."""
        return string.encode('utf-8').hex()

    def hex_to_string(self, hex_string: str) -> str:
        """Convert hex encoding to string."""
        normalized = self.hex_fix(hex_string)
        return bytes.fromhex(normalized).decode('utf-8')

    def get_formatted_timestamp(self) -> str:
        """
        Get current timestamp in Circular Protocol format.
        Format: YYYY:MM:DD-HH:MM:SS (UTC)
        """
        now = datetime.utcnow()
        return f"{now.year}:{now.month:02d}:{now.day:02d}-{now.hour:02d}:{now.minute:02d}:{now.second:02d}"
```

#### `src/circular_protocol_api/_crypto.py` (Crypto utilities)
```python
"""
Cryptographic utilities for Circular Protocol SDK.

Note: Functions prefixed with _ are private and not part of public API.
"""

import hashlib
from ecdsa import SigningKey, VerifyingKey, SECP256k1
from ecdsa.util import sigencode_der, sigdecode_der


class CryptoMixin:
    """Mixin providing cryptographic methods to the main API client."""

    def sign_message(self, message: str, private_key: str) -> str:
        """
        Sign a message using secp256k1 with DER encoding.

        Args:
            message: Message to sign (will be SHA256 hashed)
            private_key: Private key in hex format (with or without 0x prefix)

        Returns:
            DER-encoded signature as hex string
        """
        clean_key = self.hex_fix(private_key)
        private_key_bytes = bytes.fromhex(clean_key)
        sk = SigningKey.from_string(private_key_bytes, curve=SECP256k1)

        message_hash = hashlib.sha256(message.encode()).digest()
        signature_bytes = sk.sign_digest(message_hash, sigencode=sigencode_der)
        return signature_bytes.hex()

    def verify_signature(
        self,
        public_key: str,
        message: str,
        signature: str
    ) -> bool:
        """Verify a DER-encoded signature."""
        try:
            public_key_bytes = bytes.fromhex(self.hex_fix(public_key))
            if len(public_key_bytes) == 64:
                public_key_bytes = b'\x04' + public_key_bytes

            vk = VerifyingKey.from_string(public_key_bytes[1:], curve=SECP256k1)
            message_hash = hashlib.sha256(message.encode()).digest()
            signature_bytes = bytes.fromhex(self.hex_fix(signature))
            vk.verify_digest(signature_bytes, message_hash, sigdecode=sigdecode_der)
            return True
        except Exception:
            return False

    def get_public_key(self, private_key: str) -> str:
        """Derive public key from private key."""
        clean_key = self.hex_fix(private_key)
        private_key_bytes = bytes.fromhex(clean_key)
        sk = SigningKey.from_string(private_key_bytes, curve=SECP256k1)
        vk = sk.get_verifying_key()
        return vk.to_string().hex()

    def calculate_transaction_id(
        self,
        blockchain: str,
        from_address: str,
        to_address: str,
        payload: str,
        nonce: str,
        timestamp: str
    ) -> str:
        """Calculate transaction ID from components."""
        input_str = (
            self.hex_fix(blockchain) +
            self.hex_fix(from_address) +
            self.hex_fix(to_address) +
            self.hex_fix(payload) +
            nonce +
            timestamp
        )
        return hashlib.sha256(input_str.encode()).hexdigest()
```

## File Naming Conventions

### Python Standard (PEP 8)
- **Package names**: `lowercase_with_underscores`
- **Module names**: `lowercase_with_underscores.py`
- **Class names**: `PascalCase`
- **Function names**: `snake_case`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Private members**: `_leading_underscore`
- **Dunder methods**: `__double_underscore__`

### Examples
```
✅ Good:
- circular_protocol_api/          (package name)
- client.py                        (module name)
- class CircularProtocolAPI        (class name)
- def check_wallet()               (function name)
- _make_request()                  (private function)
- API_VERSION = "1.0.8"            (constant)

❌ Bad:
- CircularProtocolAPI/             (should be lowercase)
- Client.py                        (should be lowercase)
- class circularProtocolAPI        (should be PascalCase)
- def CheckWallet()                (should be snake_case)
- make_request() as public         (should be _make_request if private)
```

## Import Style

### Good: Explicit imports in `__init__.py`
```python
from .client import CircularProtocolAPI
from .models import WalletResponse, TransactionResponse
from .exceptions import CircularAPIError

__all__ = [
    "CircularProtocolAPI",
    "WalletResponse",
    "CircularAPIError",
]
```

### Bad: Star imports
```python
from .client import *  # Don't do this
from .models import *  # Hard to track what's exported
```

## Type Hints

All public APIs should have type hints (PEP 484):

```python
from typing import Optional, Dict, List

def check_wallet(
    self,
    address: str,
    blockchain: str,
    timeout: Optional[int] = None
) -> WalletResponse:
    """Check if wallet exists."""
    ...
```

## Documentation

### Docstring Style (Google/NumPy format)
```python
def check_wallet(self, address: str, blockchain: str) -> WalletResponse:
    """
    Check if a wallet exists on the specified blockchain.

    Args:
        address: Wallet address (hex format, with or without 0x prefix)
        blockchain: Blockchain ID (hex format)

    Returns:
        WalletResponse containing existence status and blockchain info

    Raises:
        InvalidAddressError: If address format is invalid
        NetworkError: If API request fails

    Example:
        >>> api = CircularProtocolAPI()
        >>> result = api.check_wallet(
        ...     address="0x1234...",
        ...     blockchain="0xabcd..."
        ... )
        >>> print(result['Response']['exists'])
        True
    """
    ...
```

## Package Configuration

### Modern: `pyproject.toml` (PEP 621)
```toml
[build-system]
requires = ["setuptools>=45", "wheel", "setuptools_scm>=6.2"]
build-backend = "setuptools.build_meta"

[project]
name = "circular-protocol-api"
version = "1.0.8"
description = "Official Python SDK for Circular Protocol blockchain"
readme = "README.md"
requires-python = ">=3.8"
license = {text = "MIT"}
authors = [
    {name = "Circular Protocol", email = "dev@circular.org"}
]
keywords = ["blockchain", "api", "sdk"]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]

dependencies = [
    "requests>=2.28.0",
    "ecdsa>=0.18.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "black>=22.0.0",
    "mypy>=1.0.0",
    "ruff>=0.1.0",
]

[project.urls]
Homepage = "https://github.com/circular-protocol/circular-python"
Documentation = "https://docs.circular.org/python"
Repository = "https://github.com/circular-protocol/circular-python"
Changelog = "https://github.com/circular-protocol/circular-python/blob/main/CHANGELOG.md"

[tool.setuptools.packages.find]
where = ["src"]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.ruff]
line-length = 100
target-version = "py38"

[tool.black]
line-length = 100
target-version = ['py38', 'py39', 'py310', 'py311']
```

## Comparison Table

| Aspect | Current | Standard |
|--------|---------|----------|
| **Layout** | Mixed (both flat + src) | Src layout only |
| **File Size** | 1250 lines in `__init__.py` | Split into 5-10 modules |
| **Module Organization** | Monolithic | Modular (client, models, exceptions, helpers) |
| **Private Functions** | No underscore prefix | `_` prefix for private |
| **Imports** | All in one file | Explicit exports in `__init__.py` |
| **Type Hints** | Partial (TypedDict only) | Full type hints everywhere |
| **Dependencies** | `cryptography` | `ecdsa` (lighter, DER support) |

## Migration Plan

1. **Reorganize structure**: Move to src layout exclusively
2. **Split monolithic file**: Separate into client, models, exceptions, helpers, crypto
3. **Add proper exports**: Clean `__init__.py` with `__all__`
4. **Update imports**: Fix import paths after restructure
5. **Add type hints**: Complete type coverage
6. **Update generators**: Modify Nickel generators to produce modular structure
7. **Test**: Verify imports work: `from circular_protocol_api import CircularProtocolAPI`

## Example Usage After Restructure

```python
# Clean, professional API
from circular_protocol_api import (
    CircularProtocolAPI,
    CircularAPIError,
    WalletResponse,
)

# Create client
api = CircularProtocolAPI()

# Use typed methods
try:
    wallet: WalletResponse = api.check_wallet(
        address="0x1234...",
        blockchain="0xabcd..."
    )
    print(f"Wallet exists: {wallet['Response']['exists']}")
except CircularAPIError as e:
    print(f"API error: {e.result_code} - {e}")
```

## References

- [Python Packaging User Guide](https://packaging.python.org/)
- [PEP 8 - Style Guide](https://peps.python.org/pep-0008/)
- [PEP 621 - pyproject.toml](https://peps.python.org/pep-0621/)
- [Src Layout vs Flat Layout](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/)
- Examples: requests, httpx, stripe-python, boto3
