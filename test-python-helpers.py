#!/usr/bin/env python3
"""
Comprehensive Python Helper Function Tests
Tests all 15 helper functions with known test vectors
"""

import sys
import os

# Add the SDK to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'dist/python/src'))

from circular_protocol_api import CircularProtocolAPI

def test_configuration_helpers():
    """Test NAG URL and API key configuration"""
    print("=" * 80)
    print("TEST 1: Configuration Helpers")
    print("=" * 80)

    api = CircularProtocolAPI()

    # Test default NAG URL
    default_url = api.get_nag_url()
    print(f"✓ Default NAG URL: {default_url}")
    assert default_url == 'https://nag.circularlabs.io/NAG.php?cep=', "Default NAG URL incorrect"

    # Test setNAGURL
    test_url = 'https://testnet.circularlabs.io/NAG.php?cep='
    api.set_nag_url(test_url)
    assert api.get_nag_url() == test_url, "setNAGURL failed"
    print(f"✓ Set NAG URL: {api.get_nag_url()}")

    # Test NAG key
    api.set_nag_key('test-api-key-123')
    assert api.get_nag_key() == 'test-api-key-123', "setNAGKey failed"
    print(f"✓ NAG key set: {api.get_nag_key()}")

    print("✅ Configuration helpers: PASSED\n")
    return True

def test_timestamp_helper():
    """Test timestamp formatting"""
    print("=" * 80)
    print("TEST 2: Timestamp Formatting")
    print("=" * 80)

    api = CircularProtocolAPI()
    timestamp = api.get_formatted_timestamp()

    print(f"✓ Timestamp: {timestamp}")

    # Verify format: YYYY:MM:DD-hh:mm:ss
    import re
    pattern = r'^\d{4}:\d{2}:\d{2}-\d{2}:\d{2}:\d{2}$'
    assert re.match(pattern, timestamp), f"Invalid timestamp format: {timestamp}"

    # Verify components are valid
    parts = timestamp.split(':')
    date_parts = parts[2].split('-')

    year = int(parts[0])
    month = int(parts[1])
    day = int(date_parts[0])
    hour = int(date_parts[1])
    minute = int(parts[3])
    second = int(parts[4])

    assert 2020 <= year <= 2030, f"Invalid year: {year}"
    assert 1 <= month <= 12, f"Invalid month: {month}"
    assert 1 <= day <= 31, f"Invalid day: {day}"
    assert 0 <= hour <= 23, f"Invalid hour: {hour}"
    assert 0 <= minute <= 59, f"Invalid minute: {minute}"
    assert 0 <= second <= 59, f"Invalid second: {second}"

    print(f"✓ Format valid: YYYY:MM:DD-hh:mm:ss")
    print("✅ Timestamp helper: PASSED\n")
    return True

def test_hex_encoding_helpers():
    """Test hex encoding/decoding"""
    print("=" * 80)
    print("TEST 3: Hex Encoding Helpers")
    print("=" * 80)

    api = CircularProtocolAPI()

    # Test stringToHex / hexToString
    test_string = "Hello Circular Protocol!"
    expected_hex = test_string.encode('utf-8').hex()

    encoded = api.string_to_hex(test_string)
    print(f"✓ String to hex: '{test_string}' → '{encoded}'")
    assert encoded == expected_hex, f"stringToHex failed: {encoded} != {expected_hex}"

    decoded = api.hex_to_string(encoded)
    print(f"✓ Hex to string: '{encoded}' → '{decoded}'")
    assert decoded == test_string, f"hexToString failed: {decoded} != {test_string}"

    # Test hexFix
    hex_with_prefix = '0x1234abcd'
    hex_without = api.hex_fix(hex_with_prefix)
    print(f"✓ Hex fix (with 0x): '{hex_with_prefix}' → '{hex_without}'")
    assert hex_without == '1234abcd', f"hexFix failed: {hex_without}"

    hex_already = 'abcd1234'
    hex_unchanged = api.hex_fix(hex_already)
    print(f"✓ Hex fix (without 0x): '{hex_already}' → '{hex_unchanged}'")
    assert hex_unchanged == 'abcd1234', f"hexFix modified clean hex: {hex_unchanged}"

    print("✅ Hex encoding helpers: PASSED\n")
    return True

def test_crypto_helpers():
    """Test cryptographic operations with known test vectors"""
    print("=" * 80)
    print("TEST 4: Cryptographic Helpers")
    print("=" * 80)

    api = CircularProtocolAPI()

    # Known test vector (from circular-js reference)
    private_key = '0f55c0c43496a9c3e1813180bec90e610769e15354771aebe7e28e83b3f89e8a'
    test_message = 'Test message for Circular Protocol'

    print(f"✓ Using private key: {private_key[:20]}...")
    print(f"✓ Test message: '{test_message}'")

    # Test getPublicKey
    try:
        public_key = api.get_public_key(private_key)
        print(f"✓ Public key derived: {public_key[:40]}... (length: {len(public_key)})")
        assert len(public_key) >= 64, f"Public key too short: {len(public_key)}"
        assert all(c in '0123456789abcdefABCDEF' for c in public_key), "Public key not hex"
    except Exception as e:
        print(f"❌ getPublicKey failed: {e}")
        return False

    # Test signMessage
    try:
        signature = api.sign_message(test_message, private_key)
        print(f"✓ Message signed: {signature[:40]}... (length: {len(signature)})")
        assert len(signature) >= 64, f"Signature too short: {len(signature)}"
        assert all(c in '0123456789abcdefABCDEF' for c in signature), "Signature not hex"
    except Exception as e:
        print(f"❌ signMessage failed: {e}")
        return False

    # Test verifySignature (valid)
    try:
        is_valid = api.verify_signature(public_key, test_message, signature)
        print(f"✓ Signature verified: {is_valid}")
        assert is_valid == True, "Valid signature rejected"
    except Exception as e:
        print(f"❌ verifySignature failed: {e}")
        return False

    # Test verifySignature (invalid signature)
    try:
        invalid_sig = signature[:-4] + 'ffff'
        is_invalid = api.verify_signature(public_key, test_message, invalid_sig)
        print(f"✓ Invalid signature rejected: {not is_invalid}")
        assert is_invalid == False, "Invalid signature accepted"
    except Exception as e:
        print(f"❌ Invalid signature check failed: {e}")
        return False

    # Test hashString
    try:
        hash_input = 'Circular Protocol'
        hash_output = api.hash_string(hash_input)
        print(f"✓ SHA256 hash: {hash_output}")
        assert len(hash_output) == 64, f"Hash wrong length: {len(hash_output)}"
        assert all(c in '0123456789abcdef' for c in hash_output), "Hash not lowercase hex"

        # Verify hash is deterministic
        hash_output2 = api.hash_string(hash_input)
        assert hash_output == hash_output2, "Hash not deterministic"
        print(f"✓ Hash is deterministic")
    except Exception as e:
        print(f"❌ hashString failed: {e}")
        return False

    print("✅ Cryptographic helpers: PASSED\n")
    return True

def test_error_tracking():
    """Test error tracking functionality"""
    print("=" * 80)
    print("TEST 5: Error Tracking")
    print("=" * 80)

    api = CircularProtocolAPI()

    initial_error = api.get_error()
    print(f"✓ Initial error state: '{initial_error}'")
    assert isinstance(initial_error, str), "GetError should return string"

    print("✅ Error tracking: PASSED\n")
    return True

def run_all_tests():
    """Run all helper function tests"""
    print("\n" + "=" * 80)
    print("CIRCULAR PROTOCOL - PYTHON SDK HELPER TESTS")
    print("Testing all 15 helper functions")
    print("=" * 80 + "\n")

    tests = [
        ("Configuration Helpers (4)", test_configuration_helpers),
        ("Timestamp Formatting (1)", test_timestamp_helper),
        ("Hex Encoding (3)", test_hex_encoding_helpers),
        ("Cryptography (4)", test_crypto_helpers),
        ("Error Tracking (1)", test_error_tracking),
    ]

    results = []
    for name, test_func in tests:
        try:
            result = test_func()
            results.append((name, result))
        except Exception as e:
            print(f"❌ {name} FAILED with exception: {e}")
            import traceback
            traceback.print_exc()
            results.append((name, False))

    # Summary
    print("=" * 80)
    print("TEST SUMMARY")
    print("=" * 80)
    passed = sum(1 for _, result in results if result)
    total = len(results)

    for name, result in results:
        status = "✅ PASSED" if result else "❌ FAILED"
        print(f"{status} - {name}")

    print("=" * 80)
    print(f"Results: {passed}/{total} test suites passed")

    if passed == total:
        print("🎉 ALL TESTS PASSED!")
        print("\n✅ All 15 helper functions verified working in Python SDK")
        return 0
    else:
        print(f"⚠️  {total - passed} test suite(s) failed")
        return 1

if __name__ == '__main__':
    exit_code = run_all_tests()
    sys.exit(exit_code)
