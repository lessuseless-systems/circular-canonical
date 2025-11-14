# Python Helpers Module Generator
# Generates standalone utility functions for Circular Protocol API

{
  helpers_code = "\"\"\"
Utility functions for Circular Protocol API.

This module provides helper functions for encoding, configuration management,
and advanced operations. All functions are standalone (do not require self).
\"\"\"

from typing import Optional
from datetime import datetime


# ============================================================================
# Encoding Helpers
# ============================================================================

def hex_fix(hex_string: str) -> str:
    \"\"\"
    Normalize hex strings (remove 0x prefix if present)

    Args:
        hex_string: Hex string with or without 0x prefix

    Returns:
        Normalized hex string without 0x prefix
    \"\"\"
    if hex_string.startswith('0x') or hex_string.startswith('0X'):
        return hex_string[2:]
    return hex_string


def string_to_hex(string: str) -> str:
    \"\"\"
    Convert string to hex encoding

    Args:
        string: String to convert

    Returns:
        Hex-encoded string
    \"\"\"
    return string.encode('utf-8').hex()


def hex_to_string(hex_string: str) -> str:
    \"\"\"
    Convert hex encoding to string

    Args:
        hex_string: Hex-encoded string

    Returns:
        Decoded string
    \"\"\"
    normalized = hex_fix(hex_string)
    return bytes.fromhex(normalized).decode('utf-8')


def _pad_number(num: int) -> str:
    \"\"\"
    Pad number with leading zero if single digit

    Args:
        num: Number to pad

    Returns:
        Padded string
    \"\"\"
    return f'{num:02d}'


def pad_number(num: int, length: int = 2) -> str:
    \"\"\"
    Pad number with leading zeros to specified length

    Args:
        num: Number to pad
        length: Target length (default: 2)

    Returns:
        Padded string
    \"\"\"
    return str(num).zfill(length)


def get_formatted_timestamp() -> str:
    \"\"\"
    Get current timestamp in Circular Protocol format
    Format: YYYY:MM:DD-hh:mm:ss (UTC)

    Returns:
        Formatted timestamp string
    \"\"\"
    now = datetime.utcnow()
    year = now.year
    month = _pad_number(now.month)
    day = _pad_number(now.day)
    hours = _pad_number(now.hour)
    minutes = _pad_number(now.minute)
    seconds = _pad_number(now.second)

    return f'{year}:{month}:{day}-{hours}:{minutes}:{seconds}'


# ============================================================================
# Configuration Helpers (designed to work with client instance)
# ============================================================================

def set_nag_url(client, url: str) -> None:
    \"\"\"
    Set custom NAG endpoint URL

    Args:
        client: API client instance
        url: NAG endpoint URL
    \"\"\"
    client._nag_url = url


def get_nag_url(client) -> str:
    \"\"\"
    Get current NAG endpoint URL

    Args:
        client: API client instance

    Returns:
        Current NAG URL
    \"\"\"
    return client._nag_url


def set_nag_key(client, key: str) -> None:
    \"\"\"
    Set NAG API key for authenticated requests

    Args:
        client: API client instance
        key: API key
    \"\"\"
    client._nag_key = key


def get_nag_key(client) -> Optional[str]:
    \"\"\"
    Get current NAG API key

    Args:
        client: API client instance

    Returns:
        Current NAG key or None
    \"\"\"
    return getattr(client, '_nag_key', None)


# ============================================================================
# Advanced Helpers
# ============================================================================

def GetError(code: int) -> str:
    \"\"\"
    Get error message for result code

    Args:
        code: Result code

    Returns:
        Error message string
    \"\"\"
    error_codes = {
        100: 'Success',
        117: 'Invalid Payload',
        119: 'Invalid Signature',
        121: 'Invalid Nonce',
        404: 'Not Found',
        500: 'Internal Server Error',
    }
    return error_codes.get(code, f'Unknown error code: {code}')


def handle_error(result: dict) -> None:
    \"\"\"
    Handle API error responses by raising appropriate exceptions

    Args:
        result: API response dict with Result and Response fields

    Raises:
        CircularProtocolError: If result indicates an error
    \"\"\"
    from .exceptions import (
        CircularProtocolError,
        InvalidSignatureError,
        InvalidNonceError,
        InvalidPayloadError,
    )

    result_code = result.get('Result', 0)
    if result_code == 200:
        return  # Success, no error

    response = result.get('Response', 'Unknown error')
    error_msg = GetError(result_code)

    # Raise specific exception types based on error code
    if result_code == 119:
        raise InvalidSignatureError(error_msg, result_code, result)
    elif result_code == 121:
        raise InvalidNonceError(error_msg, result_code, result)
    elif result_code == 117:
        raise InvalidPayloadError(error_msg, result_code, result)
    else:
        raise CircularProtocolError(f'{error_msg}: {response}', result_code, result)


def get_transaction_outcome(
    client,
    blockchain: str,
    tx_id: str,
    start: str,
    end: str,
    timeout_sec: int = 120,
    interval_sec: int = 5
) -> dict:
    \"\"\"
    Poll for transaction confirmation

    Args:
        client: API client instance
        blockchain: Blockchain network (e.g., 'MainNet', 'testnet')
        tx_id: Transaction ID to monitor
        start: Start block number for search
        end: End block number for search
        timeout_sec: Maximum time to wait in seconds (default: 120)
        interval_sec: Polling interval in seconds (default: 5)

    Returns:
        Transaction response when confirmed

    Raises:
        Exception: If transaction fails or times out
    \"\"\"
    import time

    start_time = time.time()

    while True:
        # Check if timeout exceeded
        elapsed = time.time() - start_time
        if elapsed >= timeout_sec:
            error = f'Transaction {tx_id} timed out after {timeout_sec} seconds'
            raise Exception(error)

        try:
            # Check transaction status
            tx = client.get_transaction_by_id(
                blockchain=blockchain,
                transaction_id=tx_id,
                start_block=start,
                end_block=end
            )

            # Check if transaction is confirmed (has BlockNumber)
            if tx.get('Response') and tx['Response'].get('BlockNumber') and tx['Response']['BlockNumber'] > 0:
                # Transaction confirmed
                return tx

            # Still pending, wait before next check
            time.sleep(interval_sec)

        except Exception as error:
            # If error is not just \"pending\", rethrow
            if 'pending' not in str(error).lower():
                raise error

            # Otherwise, wait and retry
            time.sleep(interval_sec)
",
}
