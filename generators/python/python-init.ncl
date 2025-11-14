# Python __init__.py Generator
# Generates the package initialization file with clean exports

let config = import "../../src/config.ncl" in

{
  init_code = "\"\"\"
Circular Protocol Python SDK.

Official Python SDK for Circular Protocol blockchain API.
Provides typed access to all blockchain operations including wallet management,
transactions, assets, blocks, contracts, domains, and network queries.

Version: %{config.version}

Example:
    >>> from circular_protocol_api import CircularProtocolAPI
    >>> api = CircularProtocolAPI()
    >>> result = api.check_wallet(
    ...     blockchain='MainNet',
    ...     address='0x...'
    ... )
    >>> print(result)
    {'Result': 200, 'Response': {...}}

For more information, visit: https://docs.circular.org
\"\"\"

from .client import CircularProtocolAPI
from .exceptions import (
    CircularProtocolError,
    APIConnectionError,
    APITimeoutError,
    AuthenticationError,
    InvalidParameterError,
    InvalidSignatureError,
    InvalidNonceError,
    InvalidPayloadError,
    WalletNotFoundError,
    TransactionError,
    InsufficientBalanceError,
    RateLimitError,
    ValidationError,
)

# Re-export crypto functions for convenience
from ._crypto import sign_message, verify_signature, get_public_key, hash_string

# Re-export helper functions for convenience
from ._helpers import (
    hex_fix,
    string_to_hex,
    hex_to_string,
    pad_number,
    get_formatted_timestamp,
)

__version__ = '%{config.version}'
__author__ = 'Circular Protocol'
__license__ = 'MIT'

__all__ = [
    # Main API client
    'CircularProtocolAPI',

    # Exceptions
    'CircularProtocolError',
    'APIConnectionError',
    'APITimeoutError',
    'AuthenticationError',
    'InvalidParameterError',
    'InvalidSignatureError',
    'InvalidNonceError',
    'InvalidPayloadError',
    'WalletNotFoundError',
    'TransactionError',
    'InsufficientBalanceError',
    'RateLimitError',
    'ValidationError',

    # Crypto functions
    'sign_message',
    'verify_signature',
    'get_public_key',
    'hash_string',

    # Helper functions
    'hex_fix',
    'string_to_hex',
    'hex_to_string',
    'pad_number',
    'get_formatted_timestamp',

    # Metadata
    '__version__',
    '__author__',
    '__license__',
]
",
}
