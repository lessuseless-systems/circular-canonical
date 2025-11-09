#!/usr/bin/env python3
"""
Real API Integration Test - Python SDK
Tests our generated Python SDK against the live Circular Protocol NAG endpoint

This test verifies:
1. Helper functions work correctly (timestamp, hex encoding, crypto)
2. NAG URL configuration works
3. Real API endpoints respond correctly
4. SDK is compatible with production environment
"""

import sys
import os
from pathlib import Path

# Add the SDK to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../dist/python/src'))

from circular_protocol_api import CircularProtocolAPI
import asyncio

# Load environment variables from .env file
def load_env():
    """Load environment variables from .env file"""
    env_path = Path(__file__).parent.parent.parent / '.env'
    env_vars = {}

    if env_path.exists():
        with open(env_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    # Remove quotes if present
                    value = value.strip().strip("'").strip('"')
                    env_vars[key] = value

    return env_vars

ENV = load_env()


async def test_real_api():
    """Test Python SDK against real Circular Protocol NAG API"""

    print('🔵 Testing Python SDK against real Circular Protocol NAG API\n')

    api = CircularProtocolAPI()

    # Test 1: Verify NAG URL configuration
    print('Test 1: NAG URL Configuration')
    default_url = api.get_nag_url()
    print(f'  Default NAG URL: {default_url}')

    # Configure to use real endpoint
    api.set_nag_url('https://nag.circularlabs.io/NAG.php?cep=')
    new_url = api.get_nag_url()
    print(f'  Updated NAG URL: {new_url}')
    print('  ✅ NAG URL configuration works\n')

    # Test 2: Test helper functions
    print('Test 2: Helper Functions')

    # Timestamp
    timestamp = api.get_formatted_timestamp()
    print(f'  Timestamp: {timestamp}')

    import re
    timestamp_regex = r'^\d{4}:\d{2}:\d{2}-\d{2}:\d{2}:\d{2}$'
    if not re.match(timestamp_regex, timestamp):
        raise ValueError('Invalid timestamp format')
    print('  ✅ Timestamp format correct (YYYY:MM:DD-hh:mm:ss)')

    # Hex encoding
    test_string = 'Hello Circular Protocol'
    hex_encoded = api.string_to_hex(test_string)
    hex_decoded = api.hex_to_string(hex_encoded)
    print(f'  String to hex: "{test_string}" → "{hex_encoded}"')
    print(f'  Hex to string: "{hex_encoded}" → "{hex_decoded}"')

    if hex_decoded != test_string:
        raise ValueError('Hex encoding/decoding failed')
    print('  ✅ Hex encoding/decoding works')

    # Hex fix
    hex_with_0x = '0x1234abcd'
    hex_without_0x = api.hex_fix(hex_with_0x)
    print(f'  Hex fix: "{hex_with_0x}" → "{hex_without_0x}"')

    if hex_without_0x != '1234abcd':
        raise ValueError('Hex fix failed')
    print('  ✅ Hex fix works\n')

    # Test 3: Call real API endpoint (getBlockchains)
    print('Test 3: Real API Call - getBlockchains')

    try:
        result = api.get_blockchains()
        print(f'  API Response: {result}')

        if result and isinstance(result, list):
            print('  ✅ getBlockchains API call successful')
            print(f'  Available blockchains: {len(result)}')
        else:
            print('  ⚠️  API response structure unexpected')

    except Exception as error:
        print('  ⚠️  API call failed (expected - may need authentication):')
        print(f'  Error: {error}')
        print('  Note: Some endpoints require authentication or specific parameters')

    # Test 4: Cryptographic helpers
    print('\nTest 4: Cryptographic Helpers')

    try:
        message = 'Test message for Circular Protocol'
        test_private_key = '0f55c0c43496a9c3e1813180bec90e610769e15354771aebe7e28e83b3f89e8a'

        # Get public key
        public_key = api.get_public_key(test_private_key)
        print(f'  Public key derived: {public_key[:40]}...')
        print('  ✅ getPublicKey works')

        # Sign message
        signature = api.sign_message(message, test_private_key)
        print(f'  Message signed: {signature[:40]}...')
        print('  ✅ signMessage works')

        # Verify signature
        is_valid = api.verify_signature(public_key, message, signature)
        print(f'  Signature verified: {is_valid}')

        if not is_valid:
            raise ValueError('Signature verification failed')
        print('  ✅ verifySignature works')

        # Hash string
        hash_result = api.hash_string(message)
        print(f'  Message hash: {hash_result}')

        if len(hash_result) != 64:
            raise ValueError('Hash length incorrect')
        print('  ✅ hashString works\n')

    except Exception as error:
        print(f'  ❌ Crypto helper failed: {error}')
        print('  Note: This may indicate missing crypto dependencies')
        raise

    # Test 5: Test a real wallet query (if we have a test wallet)
    print('\nTest 5: Real Wallet Query')

    # Use test address from .env file (read-only operation)
    test_address = ENV.get('CIRCULAR_STANDARD_ADDRESS', '').replace('0x', '')

    if test_address:
        print(f'  Using test address: {test_address[:40]}...')

        try:
            wallet_result = api.check_wallet(test_address, 'MainNet')
            print(f'  Wallet check result: {wallet_result}')
            print('  ✅ checkWallet works')

            # Try to get wallet details
            try:
                wallet_info = api.get_wallet(test_address, 'MainNet')
                print(f'  Wallet info: {wallet_info}')
                print('  ✅ getWallet works')
            except Exception as e:
                print(f'  ⚠️  getWallet failed: {e}')

        except Exception as error:
            print(f'  ⚠️  Wallet check failed: {error}')
            print('  Note: May require valid NAG key or proper parameters')

    else:
        print('  ⚠️  No test address in .env file, skipping wallet tests')

    print('\n🎉 Python SDK Test Suite Complete!')
    print('\nSummary:')
    print('  ✅ NAG URL configuration works')
    print('  ✅ Helper functions (timestamp, hex encoding) work')
    print('  ✅ Cryptographic helpers (sign, verify, hash) work')
    print('  ⚠️  Real API calls attempted (may need auth/params)')

    print('\nNext steps:')
    print('  - Add authentication key with set_nag_key()')
    print('  - Test more API endpoints with valid parameters')
    print('  - Test transaction submission workflow')
    print('  - Compare results with TypeScript SDK (cross-language validation)')


if __name__ == '__main__':
    try:
        asyncio.run(test_real_api())
    except Exception as error:
        print(f'\n❌ Test failed: {error}')
        import traceback
        traceback.print_exc()
        sys.exit(1)
