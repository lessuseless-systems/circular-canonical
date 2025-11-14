# Python E2E Test Generator
# Generates pytest E2E tests that run against real NAG endpoints
# Tests only execute when required environment variables are present

let config = import "../../../src/config.ncl" in
let e2e_spec = import "../../../tests/L5-e2e/read-operations/queries.test.ncl" in
let write_spec = import "../../../tests/L5-e2e/write-operations/transactions.test.ncl" in

# Generate Python method name from endpoint name (snake_case)
let to_snake_case = fun str =>
  # Convert camelCase to snake_case by adding _ before uppercase letters
  let chars = std.string.characters str in
  let converted = std.array.fold_left
    (fun acc char =>
      if std.string.uppercase char == char && char != std.string.lowercase char then
        # Uppercase letter - add underscore and lowercase it
        acc ++ "_" ++ std.string.lowercase char
      else
        acc ++ char
    )
    ""
    chars
  in
  # Remove leading underscore if present and ensure first char is lowercase
  let trimmed = if std.string.substring 0 1 converted == "_" then
    std.string.substring 1 (std.string.length converted) converted
  else
    converted
  in
  trimmed
in

# Generate assertion code based on operator
let generate_assertion = fun assertion =>
  let field_parts = std.string.split "." assertion.field in
  let field_access =
    if std.array.length field_parts == 1 then
      "result['" ++ std.array.at 0 field_parts ++ "']"
    else if std.array.length field_parts == 2 then
      "result['" ++ std.array.at 0 field_parts ++ "']['" ++ std.array.at 1 field_parts ++ "']"
    else
      "result['" ++ assertion.field ++ "']"
  in

  if assertion.operator == "equals" then
    if std.is_number assertion.value then
      m%"        assert %{field_access} == %{std.string.from_number assertion.value}"%
    else if std.is_bool assertion.value then
      m%"        assert %{field_access} == %{if assertion.value then "True" else "False"}"%
    else
      m%"        assert %{field_access} == '%{assertion.value}'"%
  else if assertion.operator == "isDefined" then
    m%"        assert %{field_access} is not None"%
  else if assertion.operator == "isArray" then
    m%"        assert isinstance(%{field_access}, list)"%
  else if assertion.operator == "greaterThan" then
    m%"        assert %{field_access} > %{std.string.from_number assertion.value}"%
  else if assertion.operator == "isHexString" then
    m%"        assert isinstance(%{field_access}, str) and all(c in '0123456789abcdefABCDEF' for c in %{field_access}.replace('0x', ''))"%
  else
    m%"        # Unknown operator: %{assertion.operator}"%
in

# Substitute environment variables in request template
let substitute_env_vars = fun template =>
  let json_str = std.serialize 'Json template in
  json_str
in

# Generate E2E test case
let generate_e2e_test = fun test_name test_def =>
  let method_name = to_snake_case test_def.endpoint in
  let request_template = substitute_env_vars test_def.request_template in
  let assertions = std.string.join "\n" (std.array.map generate_assertion test_def.assertions) in

  m%"
    def test_%{test_name}(self, api):
        """%{test_def.description}"""
        import json
        request_str = '''%{request_template}'''
        request_str = request_str.replace('${CIRCULAR_TEST_ADDRESS}', os.getenv('CIRCULAR_TEST_ADDRESS', ''))
        request_str = request_str.replace('${CIRCULAR_TEST_BLOCKCHAIN}', os.getenv('CIRCULAR_TEST_BLOCKCHAIN', '%{e2e_spec.required_env_vars.blockchain.default}'))
        request = json.loads(request_str)

        # Convert request keys to snake_case kwargs (Address -> address, BlockNumber -> block_number)
        kwargs = {k[0].lower() + k[1:] if not any(c.isupper() for c in k[1:]) else ''.join(['_' + c.lower() if c.isupper() else c for c in k]).lstrip('_'): v for k, v in request.items() if k not in ['Version']}

        result = api.%{method_name}(**kwargs)

        %{assertions}

        print(f'  ✅ %{test_def.description}')
  "%
in

# Generate all wallet tests
let wallet_tests = std.string.join "\n" (
  std.array.map
    (fun kv => generate_e2e_test kv.field kv.value)
    (std.record.to_array e2e_spec.wallet_tests)
) in

# Generate all transaction tests
let transaction_tests = std.string.join "\n" (
  std.array.map
    (fun kv => generate_e2e_test kv.field kv.value)
    (std.record.to_array e2e_spec.transaction_tests)
) in

# Generate all asset tests
let asset_tests = std.string.join "\n" (
  std.array.map
    (fun kv => generate_e2e_test kv.field kv.value)
    (std.record.to_array e2e_spec.asset_tests)
) in

# Generate all network tests
let network_tests = std.string.join "\n" (
  std.array.map
    (fun kv => generate_e2e_test kv.field kv.value)
    (std.record.to_array e2e_spec.network_tests)
) in

# Generate all block tests
let block_tests = std.string.join "\n" (
  std.array.map
    (fun kv => generate_e2e_test kv.field kv.value)
    (std.record.to_array e2e_spec.block_tests)
) in

# Generate all domain tests
let domain_tests = std.string.join "\n" (
  std.array.map
    (fun kv => generate_e2e_test kv.field kv.value)
    (std.record.to_array e2e_spec.domain_tests)
) in

# Generate all contract tests
let contract_tests = std.string.join "\n" (
  std.array.map
    (fun kv => generate_e2e_test kv.field kv.value)
    (std.record.to_array e2e_spec.contract_tests)
) in

# Generate write operation test case
let generate_write_test = fun test_name test_def =>
  let method_name = to_snake_case test_def.endpoint in
  let assertions = std.string.join "\n" (std.array.map generate_assertion test_def.assertions) in

  m%"
    def test_%{test_name}(self, api):
        """%{test_def.description}"""
        import time
        from datetime import datetime
        from circular_protocol_api._crypto import get_public_key, sign_message, hash_string

        # Derive address and public key from private key
        private_key = os.getenv('CIRCULAR_PRIVATE_KEY')
        public_key = get_public_key(private_key)
        address = hash_string(public_key)

        # Format timestamp
        timestamp = datetime.utcnow().strftime('%%Y:%%m:%%d-%%H:%%M:%%S')

        blockchain = os.getenv('CIRCULAR_TEST_BLOCKCHAIN', '%{write_spec.required_env_vars.blockchain.default}')

        %{if test_def.endpoint == "registerWallet" then
          m%"
        # Build registerWallet request
        account_name = f'E2E-Test-Wallet-{int(time.time())}'
        signature_payload = blockchain + account_name + public_key
        signature = sign_message(signature_payload, private_key)

        request = {
            'Blockchain': blockchain,
            'AccountName': account_name,
            'PublicKey': public_key,
            'Signature': signature,
            'Version': '%{config.version}'
        }

        print(f'  📝 Registering wallet: {account_name}')
        result = api.%{method_name}(**{k.lower(): v for k, v in request.items()})

        %{assertions}

        print(f'  ✅ Wallet registered successfully')
        print(f'  📍 Wallet Address: {result.get("Response", {}).get("WalletAddress")}')
        print(f'  🔗 Transaction ID: {result.get("Response", {}).get("TransactionID")}')
          "%
        else if test_def.endpoint == "sendTransaction" then
          m%"
        # Build certificate transaction request
        from_wallet = address
        to_wallet = address
        amount = '0'
        transaction_type = 'C_TYPE_CERTIFICATE'
        voucher = ''
        data = f'E2E Test Data Certification {int(time.time())}'

        signature_payload = blockchain + from_wallet + to_wallet + amount + transaction_type + timestamp + voucher + data
        signature = sign_message(signature_payload, private_key)

        request = {
            'Blockchain': blockchain,
            'FromWallet': from_wallet,
            'ToWallet': to_wallet,
            'Amount': amount,
            'TransactionType': transaction_type,
            'Timestamp': timestamp,
            'Voucher': voucher,
            'Data': data,
            'Signature': signature,
            'Version': '%{config.version}'
        }

        print(f'  📝 Certifying data on blockchain...')
        result = api.%{method_name}(**{k.lower(): v for k, v in request.items()})

        %{assertions}

        print(f'  ✅ Data certified successfully')
        print(f'  🔗 Transaction ID: {result.get("Response", {}).get("TransactionID")}')
        print(f'  📄 Certified data: {data}')
          "%
        else if test_def.endpoint == "callContract" then
          m%"
        # Build callContract request
        request = {
            'Blockchain': blockchain,
            'From': address,
            'Address': '0x0000000000000000000000000000000000000000000000000000000000000000',
            'Request': '0x74657374',
            'Timestamp': timestamp,
            'Version': '%{config.version}'
        }

        print(f'  📝 Calling smart contract function...')
        result = api.%{method_name}(**{k.lower(): v for k, v in request.items()})

        %{assertions}

        print(f'  ✅ Contract call executed (may have failed if contract doesn\\'t exist)')
        print(f'  📊 Result: {result.get("Result")}')
          "%
        else
          m%"
        # Unknown write operation type
        raise NotImplementedError(f'Unknown write operation: %{test_def.endpoint}')
          "%
        }
  "%
in

# Generate wallet write tests
let wallet_write_tests = std.string.join "\n" (
  std.array.map
    (fun kv => generate_write_test kv.field kv.value)
    (std.record.to_array write_spec.wallet_write_tests)
) in

# Generate transaction write tests
let transaction_write_tests = std.string.join "\n" (
  std.array.map
    (fun kv => generate_write_test kv.field kv.value)
    (std.record.to_array write_spec.transaction_write_tests)
) in

# Generate contract write tests
let contract_write_tests = std.string.join "\n" (
  std.array.map
    (fun kv => generate_write_test kv.field kv.value)
    (std.record.to_array write_spec.contract_write_tests)
) in

{
  test_code = m%"
# Circular Protocol Python SDK E2E Tests
# Generated from Nickel E2E test specifications
#
# These tests run against REAL NAG endpoints.
# They only execute when required environment variables are present.
#
# Required ENV vars (read operations):
# - CIRCULAR_TEST_ADDRESS: Test wallet address (must exist on blockchain)
#
# Required ENV vars (write operations):
# - CIRCULAR_PRIVATE_KEY: Private key for signing transactions (32-byte hex)
#
# Optional ENV vars:
# - CIRCULAR_NAG_URL: NAG endpoint URL (default: %{e2e_spec.required_env_vars.nag_url.default})
# - CIRCULAR_TEST_BLOCKCHAIN: Blockchain network (default: %{e2e_spec.required_env_vars.blockchain.default})
# - CIRCULAR_API_KEY: Optional API key
# - CIRCULAR_E2E_TIMEOUT: Request timeout in ms (default: 30000)
#
# Run read-only tests with:
#   CIRCULAR_TEST_ADDRESS=0x... pytest tests/test_e2e.py -v
#
# Run write operation tests with:
#   CIRCULAR_PRIVATE_KEY=... pytest tests/test_e2e.py -v
#   ⚠️  WARNING: This will create real transactions on the blockchain!
#
# Or skip if ENV vars not present:
#   pytest tests/test_e2e.py -v  # Will skip all tests

import pytest
import os
import sys
import warnings
# Add src to path to import canonical SDK
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))
from circular_protocol_api import CircularProtocolAPI

# Check for read-only test environment variables
READ_ENV_VARS = ['CIRCULAR_TEST_ADDRESS']
missing_read_env_vars = [v for v in READ_ENV_VARS if not os.getenv(v)]

# Check for write test environment variables
WRITE_ENV_VARS = ['CIRCULAR_PRIVATE_KEY']
missing_write_env_vars = [v for v in WRITE_ENV_VARS if not os.getenv(v)]

has_read_env = len(missing_read_env_vars) == 0
has_write_env = len(missing_write_env_vars) == 0

if not has_read_env and not has_write_env:
    print('⏭️  Skipping all E2E tests - missing required environment variables')
    print('\\nFor read-only tests:')
    print('  CIRCULAR_TEST_ADDRESS=0x... pytest tests/test_e2e.py -v')
    print('\\nFor write operation tests:')
    print('  CIRCULAR_PRIVATE_KEY=... pytest tests/test_e2e.py -v')
    print('  ⚠️  WARNING: Write tests create real blockchain transactions!')
    pytest.skip('Missing required environment variables', allow_module_level=True)


@pytest.fixture(scope='module')
def api():
    # Fixture providing API client configured for real NAG endpoints
    nag_url = os.getenv('CIRCULAR_NAG_URL', '%{e2e_spec.required_env_vars.nag_url.default}')
    api_key = os.getenv('CIRCULAR_API_KEY')

    print(f'\\n🌐 Running E2E tests against: {nag_url}')
    if has_read_env:
        print(f'📍 Test address: {os.getenv("CIRCULAR_TEST_ADDRESS")}')
    if has_write_env:
        print(f'🔑 Private key: ***REDACTED***')
    print(f'⛓️  Blockchain: {os.getenv("CIRCULAR_TEST_BLOCKCHAIN", "%{e2e_spec.required_env_vars.blockchain.default}")}')
    print('')

    return CircularProtocolAPI(nag_url, api_key)


# Read-only E2E tests (require CIRCULAR_TEST_ADDRESS)
if has_read_env:
    @pytest.mark.e2e
    class TestWalletAPIE2E:
        # E2E tests for Wallet API methods (Read-Only)
        %{wallet_tests}


    @pytest.mark.e2e
    class TestTransactionAPIE2E:
        # E2E tests for Transaction API methods (Read-Only)
        %{transaction_tests}


    @pytest.mark.e2e
    class TestAssetAPIE2E:
        # E2E tests for Asset API methods (Read-Only)
        %{asset_tests}


    @pytest.mark.e2e
    class TestNetworkAPIE2E:
        # E2E tests for Network API methods (Read-Only)
        %{network_tests}


    @pytest.mark.e2e
    class TestBlockAPIE2E:
        # E2E tests for Block API methods (Read-Only)
        %{block_tests}


    @pytest.mark.e2e
    class TestDomainAPIE2E:
        # E2E tests for Domain API methods (Read-Only)
        %{domain_tests}


    @pytest.mark.e2e
    class TestContractAPIE2E:
        # E2E tests for Contract API methods (Read-Only)
        %{contract_tests}


# Write operation E2E tests (require CIRCULAR_PRIVATE_KEY)
if has_write_env:
    @pytest.mark.e2e
    @pytest.mark.write
    class TestWriteOperationsE2E:
        """
        ⚠️  WARNING: Write operation tests will create REAL transactions on the blockchain!
        Ensure you are using a test blockchain and test funds.
        """
        %{wallet_write_tests}

        %{transaction_write_tests}

        %{contract_write_tests}
"%,
}
