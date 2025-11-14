# Python Crypto Module Generator
# Generates standalone cryptographic operations for Circular Protocol API

{
  crypto_code = "\"\"\"
Cryptographic operations for Circular Protocol API.

This module provides standalone functions for signing, verification, and key derivation
using secp256k1 elliptic curve cryptography. All functions are standalone (do not require self).
\"\"\"

import hashlib
from ecdsa import SigningKey, VerifyingKey, SECP256k1
from ecdsa.util import sigencode_der, sigdecode_der


def hex_fix(hex_string: str) -> str:
    \"\"\"Remove 0x prefix from hex string if present.\"\"\"
    if hex_string.startswith('0x') or hex_string.startswith('0X'):
        return hex_string[2:]
    return hex_string


def sign_message(message: str, private_key: str) -> str:
    \"\"\"
    Sign a message using secp256k1 with DER encoding

    Args:
        message: Message to sign (will be SHA256 hashed)
        private_key: Private key in hex format (with or without '0x' prefix)

    Returns:
        DER-encoded signature as hex string
    \"\"\"
    # Remove 0x prefix if present
    clean_key = hex_fix(private_key)

    # Create signing key
    private_key_bytes = bytes.fromhex(clean_key)
    sk = SigningKey.from_string(private_key_bytes, curve=SECP256k1)

    # Hash the message
    message_hash = hashlib.sha256(message.encode()).digest()

    # Sign with DER encoding (matching circular-js behavior)
    signature_bytes = sk.sign_digest(message_hash, sigencode=sigencode_der)
    return signature_bytes.hex()


def verify_signature(public_key: str, message: str, signature: str) -> bool:
    \"\"\"
    Verify a DER-encoded signature

    Args:
        public_key: Public key in hex format (uncompressed, 64 bytes without 0x04 prefix)
        message: Original message that was signed
        signature: DER-encoded signature in hex format

    Returns:
        True if signature is valid, False otherwise
    \"\"\"
    try:
        # Parse public key
        public_key_bytes = bytes.fromhex(hex_fix(public_key))
        # Add uncompressed point prefix if needed (0x04)
        if len(public_key_bytes) == 64:
            public_key_bytes = b'\\x04' + public_key_bytes

        vk = VerifyingKey.from_string(public_key_bytes[1:], curve=SECP256k1)

        # Hash the message
        message_hash = hashlib.sha256(message.encode()).digest()

        # Verify DER-encoded signature
        signature_bytes = bytes.fromhex(hex_fix(signature))
        vk.verify_digest(signature_bytes, message_hash, sigdecode=sigdecode_der)
        return True
    except Exception:
        return False


def get_public_key(private_key: str) -> str:
    \"\"\"
    Derive public key from private key

    Args:
        private_key: Private key in hex format (with or without '0x' prefix)

    Returns:
        Public key in uncompressed hex format (64 bytes, without 0x04 prefix)
    \"\"\"
    # Remove 0x prefix if present
    clean_key = hex_fix(private_key)

    # Create signing key
    private_key_bytes = bytes.fromhex(clean_key)
    sk = SigningKey.from_string(private_key_bytes, curve=SECP256k1)

    # Get public key
    vk = sk.get_verifying_key()
    public_key_bytes = vk.to_string()  # Returns 64 bytes without 0x04 prefix

    return public_key_bytes.hex()


def hash_string(string: str) -> str:
    \"\"\"
    Compute SHA256 hash of a string

    Args:
        string: String to hash

    Returns:
        SHA256 hash as hex string
    \"\"\"
    return hashlib.sha256(string.encode()).hexdigest()
",
}
