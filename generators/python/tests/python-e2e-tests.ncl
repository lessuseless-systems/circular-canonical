# Python E2E Test Generator
# Generates pytest E2E tests that run against real NAG endpoints
# Tests only execute when required environment variables are present

let config = import "../../../src/config.ncl" in
let e2e_spec = import "../../../tests/L5-e2e/e2e-tests.test.ncl" in

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

{
  test_code = m%"
# Circular Protocol Python SDK E2E Tests
# Generated from Nickel E2E test specifications
#
# These tests run against REAL NAG endpoints.
# They only execute when required environment variables are present.
#
# Required ENV vars:
# - CIRCULAR_TEST_ADDRESS: Test wallet address (must exist on blockchain)
#
# Optional ENV vars:
# - CIRCULAR_NAG_URL: NAG endpoint URL (default: %{e2e_spec.required_env_vars.nag_url.default})
# - CIRCULAR_TEST_BLOCKCHAIN: Blockchain network (default: %{e2e_spec.required_env_vars.blockchain.default})
# - CIRCULAR_API_KEY: Optional API key
# - CIRCULAR_E2E_TIMEOUT: Request timeout in ms (default: 30000)
#
# Run with:
#   CIRCULAR_TEST_ADDRESS=0x... pytest tests/test_e2e.py -v
#
# Or skip if ENV vars not present:
#   pytest tests/test_e2e.py -v  # Will skip all tests

import pytest
import os
import sys
# Add src to path to import canonical SDK
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))
from circular_protocol_api import CircularProtocolAPI

# Check for required environment variables
REQUIRED_ENV_VARS = ['CIRCULAR_TEST_ADDRESS']
missing_env_vars = [v for v in REQUIRED_ENV_VARS if not os.getenv(v)]

if missing_env_vars:
    print('⏭️  Skipping E2E tests - missing required environment variables:')
    for v in missing_env_vars:
        print(f'   - {v}')
    print('\\nTo run E2E tests, set:')
    print('  CIRCULAR_TEST_ADDRESS=0x... pytest tests/test_e2e.py -v')
    pytest.skip('Missing required environment variables', allow_module_level=True)


@pytest.fixture(scope='module')
def api():
    # Fixture providing API client configured for real NAG endpoints
    nag_url = os.getenv('CIRCULAR_NAG_URL', '%{e2e_spec.required_env_vars.nag_url.default}')
    api_key = os.getenv('CIRCULAR_API_KEY')

    print(f'\\n🌐 Running E2E tests against: {nag_url}')
    print(f'📍 Test address: {os.getenv("CIRCULAR_TEST_ADDRESS")}')
    print(f'⛓️  Blockchain: {os.getenv("CIRCULAR_TEST_BLOCKCHAIN", "%{e2e_spec.required_env_vars.blockchain.default}")}')
    print('')

    return CircularProtocolAPI(nag_url, api_key)


@pytest.mark.e2e
class TestWalletAPIE2E:
    # E2E tests for Wallet API methods
    %{wallet_tests}


@pytest.mark.e2e
class TestNetworkAPIE2E:
    # E2E tests for Network API methods
    %{network_tests}


@pytest.mark.e2e
class TestBlockAPIE2E:
    # E2E tests for Block API methods
    %{block_tests}
"%,
}
