# Python Manual Test Generator
# Generates manual test scripts for write operations on live blockchain
# Input: tests/L5-manual/manual-tests.test.ncl
# Output: dist/tests/manual/manual-test-*.py scripts

let config = import "../../../src/config.ncl" in
let manual_tests = import "../../../tests/L5-manual/manual-tests.test.ncl" in
let convenience_methods = import "../../../src/api/convenience-methods.ncl" in

# Generate registerWallet manual test
let generate_register_wallet_test = fun test_spec =>
  m%"#!/usr/bin/env python3
\"\"\"
Manual Test: Register Wallet on Live Blockchain

⚠️  WARNING: This test writes to a LIVE blockchain.
⚠️  Only run on test networks (Circular SandBox).

%{test_spec.description}

Usage:
    export CIRCULAR_PRIVATE_KEY="your_private_key"
    export CIRCULAR_PUBLIC_KEY="your_public_key"
    export CIRCULAR_TEST_BLOCKCHAIN="0x8a20baa..."

    python3 manual-test-registerWallet.py

Expected Result:
    - Wallet registered on blockchain
    - Transaction ID returned
    - Wallet verifiable via checkWallet()
\"\"\"

import os
import sys
import json
from typing import Dict, Any

# Add SDK to path (assumes script is in dist/tests/manual/)
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../python/src'))

try:
    from circular_protocol_api import CircularProtocolAPI
except ImportError:
    print(\"❌ Error: Could not import CircularProtocolAPI\")
    print(\"   Make sure Python SDK is generated: just generate-py-package\")
    sys.exit(1)


def check_env_vars() -> Dict[str, str]:
    \"\"\"Verify required environment variables are set.\"\"\"
    required = %{std.string.replace_regex "'" "\"" (std.serialize 'Json (std.array.map (fun kv => kv.value.name) (std.record.to_array manual_tests.required_env_vars)))}

    missing = []
    env_vars = {}

    for var in required:
        value = os.getenv(var)
        if not value:
            missing.append(var)
        else:
            env_vars[var] = value

    if missing:
        print(f\"❌ Missing required environment variables: {', '.join(missing)}\")
        print()
        print(\"Please set:\")
        for var in missing:
            print(f\"  export {var}='...'\" )
        sys.exit(1)

    return env_vars


def verify_blockchain_whitelist(blockchain: str) -> bool:
    \"\"\"Verify blockchain is in safety whitelist.\"\"\"
    whitelist = %{std.string.replace_regex "'" "\"" (std.serialize 'Json manual_tests.safety.blockchain_whitelist)}

    if blockchain not in whitelist:
        print(f\"❌ Error: Blockchain {blockchain} is not in safety whitelist\")
        print(f\"   Allowed blockchains: {whitelist}\")
        return False

    return True


def check_write_tests_enabled() -> bool:
    \"\"\"Check if write tests are explicitly enabled via environment variable.\"\"\"
    enabled = os.getenv('CIRCULAR_ALLOW_WRITE_TESTS', '').lower() in ('1', 'true', 'yes')

    if not enabled:
        print(\"❌ Write tests are disabled\")
        print()
        print(\"To enable write tests (which write to LIVE blockchain):\")
        print(\"  export CIRCULAR_ALLOW_WRITE_TESTS=1\")
        print()
        print(\"⚠️  WARNING: Only enable on test networks (SandBox)\")
        return False

    return True


def test_register_wallet(api: CircularProtocolAPI, env: Dict[str, str]) -> None:
    \"\"\"Test registerWallet convenience method.\"\"\"
    blockchain = env.get('CIRCULAR_TEST_BLOCKCHAIN')
    public_key = env.get('CIRCULAR_PUBLIC_KEY')

    print(\"\\n\" + \"=\"*70)
    print(\"TEST: Register Wallet\")
    print(\"=\"*70)
    print(f\"Blockchain: {blockchain}\")
    print(f\"Public Key: {public_key[:32]}...{public_key[-32:]}\")
    print()

    # Derive expected address
    from circular_protocol_api.client import CircularProtocolAPI as API_class
    test_api = API_class()
    expected_address = test_api.hash_string(public_key)
    print(f\"Expected Address: {expected_address}\")
    print()

    # Check if wallet already exists
    print(\"Step 1: Checking if wallet already exists...\")
    try:
        check_result = api.check_wallet(
            blockchain=blockchain,
            address=expected_address
        )

        if check_result.get('Result') == 200:
            print(\"⚠️  Wallet already exists on blockchain!\")
            print(f\"   Result: {json.dumps(check_result, indent=2)}\")
            print()
            response = input(\"Continue anyway? (wallet may already be registered) [y/N]: \")
            if response.lower() != 'y':
                print(\"Test cancelled.\")
                return
    except Exception as e:
        print(f\"   Wallet does not exist yet (expected): {e}\")

    print()

    # Register wallet
    print(\"Step 2: Calling registerWallet()...\")
    try:
        result = api.register_wallet(blockchain, public_key)

        print(\"✅ registerWallet() call successful!\")
        print()
        print(\"Result:\")
        print(json.dumps(result, indent=2))
        print()

        # Verify transaction ID
        if result.get('Result') == 200:
            tx_id = result.get('Response', {}).get('TransactionID')
            if tx_id:
                print(f\"✅ Transaction ID: {tx_id}\")
                print(f\"   Length: {len(tx_id)} characters\")
                print()
            else:
                print(\"⚠️  Warning: No TransactionID in response\")
        else:
            print(f\"⚠️  Result code: {result.get('Result')} (expected 200)\")

    except Exception as e:
        print(f\"❌ Error calling registerWallet(): {e}\")
        import traceback
        traceback.print_exc()
        return

    # Verification steps
    print()
    print(\"Step 3: Verifying wallet registration...\")

    try:
        # Check wallet exists
        check_result = api.check_wallet(
            blockchain=blockchain,
            address=expected_address
        )

        if check_result.get('Result') == 200:
            print(\"✅ checkWallet() confirms wallet exists\")
        else:
            print(f\"⚠️  checkWallet() returned Result={check_result.get('Result')}\")

        # Get wallet details
        wallet_result = api.get_wallet(
            blockchain=blockchain,
            address=expected_address
        )

        if wallet_result.get('Result') == 200:
            print(\"✅ getWallet() successfully retrieved wallet details\")
            wallet_data = wallet_result.get('Response', {})
            print(f\"   Address: {wallet_data.get('Address', 'N/A')}\")
            print(f\"   Balance: {wallet_data.get('Balance', 'N/A')}\")
            print(f\"   Nonce: {wallet_data.get('Nonce', 'N/A')}\")
        else:
            print(f\"⚠️  getWallet() returned Result={wallet_result.get('Result')}\")

    except Exception as e:
        print(f\"⚠️  Verification step failed: {e}\")

    print()
    print(\"=\"*70)
    print(\"TEST COMPLETE\")
    print(\"=\"*70)


def main():
    \"\"\"Main test execution.\"\"\"
    print(\"\\n\" + \"#\"*70)
    print(\"# %{manual_tests.test_suite_name}\")
    print(\"# Version: %{manual_tests.version}\")
    print(\"#\"*70)

    # Check environment
    env = check_env_vars()
    print(\"✅ All required environment variables are set\")

    # Verify blockchain safety
    blockchain = env.get('CIRCULAR_TEST_BLOCKCHAIN')
    if not verify_blockchain_whitelist(blockchain):
        sys.exit(1)
    print(f\"✅ Blockchain {blockchain} is in safety whitelist\")

    # Check if write tests are enabled
    if not check_write_tests_enabled():
        sys.exit(1)
    print(\"✅ Write tests enabled (CIRCULAR_ALLOW_WRITE_TESTS=1)\")

    # Initialize API
    nag_url = env.get('CIRCULAR_NAG_URL', 'https://nag.circularlabs.io/NAG.php?cep=')
    api = CircularProtocolAPI(base_url=nag_url)

    print(f\"\\n✅ API initialized: {nag_url}\")

    # Run test
    test_register_wallet(api, env)


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print(\"\\n\\n❌ Test interrupted by user\")
        sys.exit(1)
    except Exception as e:
        print(f\"\\n❌ Unexpected error: {e}\")
        import traceback
        traceback.print_exc()
        sys.exit(1)
"%
in

{
  test_code = generate_register_wallet_test manual_tests.write_operation_tests.register_wallet,

  metadata = {
    version = config.version,
    test_type = "manual",
    category = "write_operations",
    safety_level = "requires_confirmation",
  },
}
