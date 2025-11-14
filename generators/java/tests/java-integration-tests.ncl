# Circular Protocol Canonical - Java Integration Test Generator
# Generates JUnit 5 integration tests from Nickel test specifications
# Input: tests/L3-integration/integration-tests.test.ncl
# Output: Java JUnit test file for integration testing

let config = import "../../../src/config.ncl" in
let test_spec = import "../../../tests/L3-integration/integration-tests.test.ncl" in

# Generate Java method name from endpoint name (camelCase)
let to_camel_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  (std.string.lowercase first_char) ++ rest
in

# Generate assertion code based on operator (JUnit style)
let generate_assertion = fun test_name assertion =>
  let field_parts = std.string.split "." assertion.field in
  let field_access =
    if std.array.length field_parts == 1 then
      "result.get(\"" ++ std.array.at 0 field_parts ++ "\")"
    else if std.array.length field_parts == 2 then
      "((Map<String, Object>) result.get(\"" ++ std.array.at 0 field_parts ++ "\")).get(\"" ++ std.array.at 1 field_parts ++ "\")"
    else
      "result.get(\"" ++ assertion.field ++ "\")"
  in

  if assertion.operator == "equals" then
    if std.is_number assertion.value then
      m%"        assertEquals(%{std.string.from_number assertion.value}, %{field_access});"%
    else if std.is_bool assertion.value then
      m%"        assertEquals(%{if assertion.value then "true" else "false"}, %{field_access});"%
    else
      m%"        assertEquals(\"%{assertion.value}\", %{field_access});"%
  else if assertion.operator == "isDefined" then
    m%"        assertNotNull(%{field_access});"%
  else if assertion.operator == "isArray" then
    m%"        assertTrue(%{field_access} instanceof List);"%
  else if assertion.operator == "arrayContains" then
    m%"        assertTrue(((List<?>) %{field_access}).contains(\"%{assertion.value}\"));"%
  else if assertion.operator == "greaterThan" then
    m%"        assertTrue((Integer) %{field_access} > %{std.string.from_number assertion.value});"%
  else if assertion.operator == "greaterThanOrEqual" then
    m%"        assertTrue((Integer) %{field_access} >= %{std.string.from_number assertion.value});"%
  else
    m%"        // Unknown operator: %{assertion.operator}"%
in

# Generate test case for normal API call
let generate_api_test = fun test_name test_def =>
  let method_name = to_camel_case test_def.endpoint in
  let assertions = std.array.map (generate_assertion test_name) test_def.assertions in
  let timeout_seconds = test_spec.timeout_ms / 1000 in

  # Build request map manually from request fields
  let request_fields = std.record.fields test_def.request in
  let request_puts = std.array.map (fun field_name =>
    let field_value = std.record.get field_name test_def.request in
    if std.is_string field_value then
      m%"        request.put("%{field_name}", "%{field_value}");"%
    else if std.is_number field_value then
      m%"        request.put("%{field_name}", %{std.string.from_number field_value});"%
    else if std.is_bool field_value then
      m%"        request.put("%{field_name}", %{if field_value then "true" else "false"});"%
    else
      m%"        request.put("%{field_name}", "%{std.serialize 'Json field_value}");"%
  ) request_fields in

  m%"
    @Test
    @Timeout(%{std.string.from_number timeout_seconds})
    void test_%{test_name}() throws Exception {
        // %{test_def.description}
        Map<String, Object> request = new java.util.HashMap<>();
%{std.string.join "\n" request_puts}

        Map<String, Object> result = api.%{method_name}(request).get();

%{std.string.join "\n" assertions}

        System.out.println("  ✅ %{test_def.description}");
    }
  "%
in

# Generate test case for error handling
let generate_error_test = fun test_name test_def =>
  let method_name = to_camel_case test_def.endpoint in
  let timeout_seconds = test_spec.timeout_ms / 1000 in

  # Build request map manually from request fields
  let request_fields = std.record.fields test_def.request in
  let request_puts = std.array.map (fun field_name =>
    let field_value = std.record.get field_name test_def.request in
    if std.is_string field_value then
      m%"        request.put("%{field_name}", "%{field_value}");"%
    else if std.is_number field_value then
      m%"        request.put("%{field_name}", %{std.string.from_number field_value});"%
    else if std.is_bool field_value then
      m%"        request.put("%{field_name}", %{if field_value then "true" else "false"});"%
    else
      m%"        request.put("%{field_name}", "%{std.serialize 'Json field_value}");"%
  ) request_fields in

  if std.record.has_field "override_url" test_def then
    # Connection error test - use different API instance
    m%"
    @Test
    @Timeout(%{std.string.from_number timeout_seconds})
    void test_%{test_name}() {
        // %{test_def.description}
        CircularProtocolAPI invalidApi = new CircularProtocolAPI("%{test_def.override_url}");

        Map<String, Object> request = new java.util.HashMap<>();
%{std.string.join "\n" request_puts}

        assertThrows(Exception.class, () -> {
            invalidApi.%{method_name}(request).get();
        });

        System.out.println("  ✅ %{test_def.description}");
    }
  "%
  else
    # Validation error test - expect error from API
    m%"
    @Test
    @Timeout(%{std.string.from_number timeout_seconds})
    void test_%{test_name}() {
        // %{test_def.description}
        Map<String, Object> request = new java.util.HashMap<>();
%{std.string.join "\n" request_puts}

        assertThrows(Exception.class, () -> {
            api.%{method_name}(request).get();
        });

        System.out.println("  ✅ %{test_def.description}");
    }
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
package io.circular.protocol;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

import java.util.*;
import java.util.concurrent.TimeUnit;

/**
 * Circular Protocol Java SDK Integration Tests
 * Generated from tests/L3-integration/integration-tests.test.ncl
 *
 * These tests validate SDK functionality against a mock API server.
 * They test real HTTP requests, response parsing, and error handling.
 *
 * Requirements:
 * - Mock server running on http://localhost:8080
 * - Start with: python3 dist/tests/mock-server.py
 *
 * Run tests:
 *   mvn test -Dtest=CircularProtocolIntegrationTest
 */
public class CircularProtocolIntegrationTest {
    private static final String API_URL = System.getenv().getOrDefault("CIRCULAR_API_URL", "%{test_spec.mock_server_url}");
    private static final String API_VERSION = "%{config.version}";
    private static CircularProtocolAPI api;

    @BeforeAll
    static void setUp() {
        api = new CircularProtocolAPI(API_URL);
    }

    @Nested
    @DisplayName("Network API")
    class NetworkAPITests {
%{generate_test_category "network_tests" test_spec.network_tests generate_api_test}
    }

    @Nested
    @DisplayName("Wallet API")
    class WalletAPITests {
%{generate_test_category "wallet_tests" test_spec.wallet_tests generate_api_test}
    }

    @Nested
    @DisplayName("Transaction API")
    class TransactionAPITests {
%{generate_test_category "transaction_tests" test_spec.transaction_tests generate_api_test}
    }

    @Nested
    @DisplayName("Asset API")
    class AssetAPITests {
%{generate_test_category "asset_tests" test_spec.asset_tests generate_api_test}
    }

    @Nested
    @DisplayName("Block API")
    class BlockAPITests {
%{generate_test_category "block_tests" test_spec.block_tests generate_api_test}
    }

    @Nested
    @DisplayName("Smart Contract API")
    class SmartContractAPITests {
%{generate_test_category "contract_tests" test_spec.contract_tests generate_api_test}
    }

    @Nested
    @DisplayName("Domain API")
    class DomainAPITests {
%{generate_test_category "domain_tests" test_spec.domain_tests generate_api_test}
    }

    @Nested
    @DisplayName("Error Handling")
    class ErrorHandlingTests {
%{generate_test_category "error_handling" test_spec.error_handling_tests generate_error_test}
    }
}
  "%,
}
