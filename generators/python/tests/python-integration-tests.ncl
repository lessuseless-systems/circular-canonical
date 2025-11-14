# Circular Protocol Canonical - Python Integration Test Generator
# Generates pytest integration tests from Nickel test specifications
# Input: tests/L3-integration/integration-tests.test.ncl
# Output: Python pytest test file for integration testing

let config = import "../../../src/config.ncl" in
let test_spec = import "../../../tests/L3-integration/integration-tests.test.ncl" in

# Generate Python method name from endpoint name (snake_case)
let to_snake_case = fun str =>
  # Convert camelCase/PascalCase to snake_case
  # For now, assume the endpoint names are already close to desired format
  # Just convert first char to lowercase
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  (std.string.lowercase first_char) ++ rest
in

# Generate assertion code based on operator (pytest style)
let generate_assertion = fun test_name assertion =>
  let field_parts = std.string.split "." assertion.field in
  let field_access =
    if std.array.length field_parts == 1 then
      "result['" ++ std.array.at 0 field_parts ++ "']"
    else if std.array.length field_parts == 2 then
      "result.get('" ++ std.array.at 0 field_parts ++ "', {}).get('" ++ std.array.at 1 field_parts ++ "')"
    else
      "result['" ++ assertion.field ++ "']"
  in

  if assertion.operator == "equals" then
    if std.is_number assertion.value then
      m%"        assert %{field_access} == %{std.string.from_number assertion.value}"%
    else if std.is_bool assertion.value then
      m%"        assert %{field_access} is %{if assertion.value then "True" else "False"}"%
    else
      m%"        assert %{field_access} == '%{assertion.value}'"%
  else if assertion.operator == "isDefined" then
    m%"        assert %{field_access} is not None"%
  else if assertion.operator == "isArray" then
    m%"        assert isinstance(%{field_access}, list)"%
  else if assertion.operator == "arrayContains" then
    m%"        assert '%{assertion.value}' in %{field_access}"%
  else if assertion.operator == "greaterThan" then
    m%"        assert %{field_access} > %{std.string.from_number assertion.value}"%
  else if assertion.operator == "greaterThanOrEqual" then
    m%"        assert %{field_access} >= %{std.string.from_number assertion.value}"%
  else
    m%"        # Unknown operator: %{assertion.operator}"%
in

# Generate test case for normal API call
let generate_api_test = fun test_name test_def =>
  let method_name = to_snake_case test_def.endpoint in
  let request_dict = std.serialize 'Json test_def.request in
  let assertions = std.array.map (generate_assertion test_name) test_def.assertions in
  let timeout_seconds = test_spec.timeout_ms / 1000 in
  m%"
    @pytest.mark.timeout(%{std.string.from_number timeout_seconds})
    def test_%{test_name}(self, api):
        """%{test_def.description}"""
        result = api.%{method_name}(**%{request_dict})

%{std.string.join "\n" assertions}

        print(f'  ✅ %{test_def.description}')
  "%
in

# Generate test case for error handling
let generate_error_test = fun test_name test_def =>
  let method_name = to_snake_case test_def.endpoint in
  let request_dict = std.serialize 'Json test_def.request in
  let timeout_seconds = test_spec.timeout_ms / 1000 in

  if std.record.has_field "override_url" test_def then
    # Connection error test - use different API instance
    m%"
    @pytest.mark.timeout(%{std.string.from_number timeout_seconds})
    def test_%{test_name}(self):
        """%{test_def.description}"""
        invalid_api = CircularProtocolAPI('%{test_def.override_url}')

        with pytest.raises(Exception):
            invalid_api.%{method_name}(**%{request_dict})

        print(f'  ✅ %{test_def.description}')
  "%
  else
    # Validation error test - expect error from API
    m%"
    @pytest.mark.timeout(%{std.string.from_number timeout_seconds})
    def test_%{test_name}(self, api):
        """%{test_def.description}"""
        with pytest.raises(Exception):
            api.%{method_name}(**%{request_dict})

        print(f'  ✅ %{test_def.description}')
  "%
in

# Generate all tests from a test category
let generate_test_category = fun category_name tests generate_fn =>
  let test_cases = std.record.fields tests in
  let generated = std.array.map (fun test_name =>
    let test_def = std.record.get test_name tests in
    generate_fn test_name test_def
  ) test_cases in
  std.string.join "\n" generated
in

# Main integration test file
{
  test_file = m%"
"""
Circular Protocol Python SDK Integration Tests
Generated from tests/L3-integration/integration-tests.test.ncl

These tests validate SDK functionality against a mock API server.
They test real HTTP requests, response parsing, and error handling.

Requirements:
- Mock server running on http://localhost:8080
- Start with: python3 dist/tests/mock-server.py

Run tests:
  cd tests/L3-integration
  pytest test_integration.py -v
"""

import pytest
import os
from circular_protocol_api import CircularProtocolAPI

API_URL = os.getenv('CIRCULAR_API_URL', '%{test_spec.mock_server_url}')
API_VERSION = '%{config.version}'


class TestCircularProtocolIntegration:
    """Integration test suite for Circular Protocol SDK"""

    @pytest.fixture
    def api(self):
        """Create API instance for testing"""
        return CircularProtocolAPI(API_URL)


class TestNetworkAPI(TestCircularProtocolIntegration):
    """Test Network API endpoints"""
%{generate_test_category "network_tests" test_spec.network_tests generate_api_test}


class TestWalletAPI(TestCircularProtocolIntegration):
    """Test Wallet API endpoints"""
%{generate_test_category "wallet_tests" test_spec.wallet_tests generate_api_test}


class TestTransactionAPI(TestCircularProtocolIntegration):
    """Test Transaction API endpoints"""
%{generate_test_category "transaction_tests" test_spec.transaction_tests generate_api_test}


class TestAssetAPI(TestCircularProtocolIntegration):
    """Test Asset API endpoints"""
%{generate_test_category "asset_tests" test_spec.asset_tests generate_api_test}


class TestBlockAPI(TestCircularProtocolIntegration):
    """Test Block API endpoints"""
%{generate_test_category "block_tests" test_spec.block_tests generate_api_test}


class TestSmartContractAPI(TestCircularProtocolIntegration):
    """Test Smart Contract API endpoints"""
%{generate_test_category "contract_tests" test_spec.contract_tests generate_api_test}


class TestDomainAPI(TestCircularProtocolIntegration):
    """Test Domain API endpoints"""
%{generate_test_category "domain_tests" test_spec.domain_tests generate_api_test}


class TestErrorHandling(TestCircularProtocolIntegration):
    """Test error handling and edge cases"""
%{generate_test_category "error_handling" test_spec.error_handling_tests generate_error_test}
  "%,
}
