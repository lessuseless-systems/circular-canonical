# Python Exceptions Generator
# Generates custom exception classes for the Circular Protocol API

let config = import "../../src/config.ncl" in

{
  exceptions_code = "\"\"\"
Custom exceptions for Circular Protocol API.

This module defines exception classes for error handling in the SDK.
\"\"\"

from typing import Optional, Dict, Any


class CircularProtocolError(Exception):
    \"\"\"Base exception class for all Circular Protocol API errors.\"\"\"

    def __init__(self, message: str, result_code: Optional[int] = None, response: Optional[Dict[str, Any]] = None):
        \"\"\"
        Initialize the exception.

        Args:
            message: Human-readable error message
            result_code: API result code (if available)
            response: Full API response (if available)
        \"\"\"
        super().__init__(message)
        self.message = message
        self.result_code = result_code
        self.response = response

    def __str__(self) -> str:
        if self.result_code:
            return f\"[{self.result_code}] {self.message}\"
        return self.message


class APIConnectionError(CircularProtocolError):
    \"\"\"Raised when unable to connect to the API server.\"\"\"
    pass


class APITimeoutError(CircularProtocolError):
    \"\"\"Raised when an API request times out.\"\"\"
    pass


class AuthenticationError(CircularProtocolError):
    \"\"\"Raised when API authentication fails.\"\"\"
    pass


class InvalidParameterError(CircularProtocolError):
    \"\"\"Raised when invalid parameters are provided to an API call.\"\"\"
    pass


class InvalidSignatureError(CircularProtocolError):
    \"\"\"Raised when a cryptographic signature is invalid (Result code 119).\"\"\"
    pass


class InvalidNonceError(CircularProtocolError):
    \"\"\"Raised when a transaction nonce is invalid (Result code 121).\"\"\"
    pass


class InvalidPayloadError(CircularProtocolError):
    \"\"\"Raised when a transaction payload is invalid (Result code 117).\"\"\"
    pass


class WalletNotFoundError(CircularProtocolError):
    \"\"\"Raised when a wallet address is not found on the blockchain.\"\"\"
    pass


class TransactionError(CircularProtocolError):
    \"\"\"Raised when a transaction fails.\"\"\"
    pass


class InsufficientBalanceError(CircularProtocolError):
    \"\"\"Raised when a wallet has insufficient balance for a transaction.\"\"\"
    pass


class RateLimitError(CircularProtocolError):
    \"\"\"Raised when API rate limits are exceeded.\"\"\"
    pass


class ValidationError(CircularProtocolError):
    \"\"\"Raised when input validation fails.\"\"\"
    pass
",
}
