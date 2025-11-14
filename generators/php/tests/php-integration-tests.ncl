# Circular Protocol Canonical - PHP Integration Test Generator
# Generates PHPUnit integration tests from Nickel test specifications
# Input: tests/L3-integration/integration-tests.test.ncl
# Output: PHP PHPUnit test file for integration testing

let config = import "../../../src/config.ncl" in
let test_spec = import "../../../tests/L3-integration/integration-tests.test.ncl" in

# Generate PHP method name from endpoint name (camelCase)
let to_camel_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  (std.string.lowercase first_char) ++ rest
in

# Generate assertion code based on operator (PHPUnit style)
let generate_assertion = fun test_name assertion =>
  let field_parts = std.string.split "." assertion.field in
  let field_access =
    if std.array.length field_parts == 1 then
      "$result['" ++ std.array.at 0 field_parts ++ "']"
    else if std.array.length field_parts == 2 then
      "$result['" ++ std.array.at 0 field_parts ++ "']['" ++ std.array.at 1 field_parts ++ "']"
    else
      "$result['" ++ assertion.field ++ "']"
  in

  if assertion.operator == "equals" then
    if std.is_number assertion.value then
      m%"        $this->assertEquals(%{std.string.from_number assertion.value}, %{field_access});"%
    else if std.is_bool assertion.value then
      m%"        $this->assertEquals(%{if assertion.value then "true" else "false"}, %{field_access});"%
    else
      m%"        $this->assertEquals('%{assertion.value}', %{field_access});"%
  else if assertion.operator == "isDefined" then
    m%"        $this->assertNotNull(%{field_access});"%
  else if assertion.operator == "isArray" then
    m%"        $this->assertIsArray(%{field_access});"%
  else if assertion.operator == "arrayContains" then
    m%"        $this->assertContains('%{assertion.value}', %{field_access});"%
  else if assertion.operator == "greaterThan" then
    m%"        $this->assertGreaterThan(%{std.string.from_number assertion.value}, %{field_access});"%
  else if assertion.operator == "greaterThanOrEqual" then
    m%"        $this->assertGreaterThanOrEqual(%{std.string.from_number assertion.value}, %{field_access});"%
  else
    m%"        // Unknown operator: %{assertion.operator}"%
in

# Generate test case for normal API call
let generate_api_test = fun test_name test_def =>
  let method_name = to_camel_case test_def.endpoint in
  let assertions = std.array.map (generate_assertion test_name) test_def.assertions in
  let timeout_seconds = test_spec.timeout_ms / 1000 in

  # Build request array manually from request fields
  let request_fields = std.record.fields test_def.request in
  let request_assigns = std.array.map (fun field_name =>
    let field_value = std.record.get field_name test_def.request in
    if std.is_string field_value then
      m%"            '%{field_name}' => '%{field_value}',"%
    else if std.is_number field_value then
      m%"            '%{field_name}' => %{std.string.from_number field_value},"%
    else if std.is_bool field_value then
      m%"            '%{field_name}' => %{if field_value then "true" else "false"},"%
    else
      m%"            '%{field_name}' => '%{std.serialize 'Json field_value}',"%
  ) request_fields in

  m%"
    /**
     * @test
     * @group integration
     * %{test_def.description}
     */
    public function test_%{test_name}(): void
    {
        $request = [
%{std.string.join "\n" request_assigns}
        ];

        $result = $this->api->%{method_name}($request);

%{std.string.join "\n" assertions}

        echo "  ✅ %{test_def.description}\n";
    }
  "%
in

# Generate test case for error handling
let generate_error_test = fun test_name test_def =>
  let method_name = to_camel_case test_def.endpoint in
  let timeout_seconds = test_spec.timeout_ms / 1000 in

  # Build request array manually from request fields
  let request_fields = std.record.fields test_def.request in
  let request_assigns = std.array.map (fun field_name =>
    let field_value = std.record.get field_name test_def.request in
    if std.is_string field_value then
      m%"            '%{field_name}' => '%{field_value}',"%
    else if std.is_number field_value then
      m%"            '%{field_name}' => %{std.string.from_number field_value},"%
    else if std.is_bool field_value then
      m%"            '%{field_name}' => %{if field_value then "true" else "false"},"%
    else
      m%"            '%{field_name}' => '%{std.serialize 'Json field_value}',"%
  ) request_fields in

  if std.record.has_field "override_url" test_def then
    # Connection error test - use different API instance
    m%"
    /**
     * @test
     * @group integration
     * %{test_def.description}
     */
    public function test_%{test_name}(): void
    {
        $invalidApi = new CircularProtocolAPI('%{test_def.override_url}');

        $request = [
%{std.string.join "\n" request_assigns}
        ];

        $this->expectException(\Exception::class);
        $invalidApi->%{method_name}($request);

        echo "  ✅ %{test_def.description}\n";
    }
  "%
  else
    # Validation error test - expect error from API
    m%"
    /**
     * @test
     * @group integration
     * %{test_def.description}
     */
    public function test_%{test_name}(): void
    {
        $request = [
%{std.string.join "\n" request_assigns}
        ];

        $this->expectException(\Exception::class);
        $this->api->%{method_name}($request);

        echo "  ✅ %{test_def.description}\n";
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
<?php

namespace CircularProtocol\Tests;

use PHPUnit\Framework\TestCase;
use CircularProtocol\CircularProtocolAPI;

/**
 * Circular Protocol PHP SDK Integration Tests
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
 *   composer test:integration
 *   or: vendor/bin/phpunit tests/CircularProtocolIntegrationTest.php
 */
class CircularProtocolIntegrationTest extends TestCase
{
    private static CircularProtocolAPI $api;
    private const API_URL = '%{test_spec.mock_server_url}';
    private const API_VERSION = '%{config.version}';

    public static function setUpBeforeClass(): void
    {
        $apiUrl = getenv('CIRCULAR_API_URL') ?: self::API_URL;
        self::$api = new CircularProtocolAPI($apiUrl);
    }

    protected function setUp(): void
    {
        $this->api = self::$api;
    }

    // ========== Network API ==========
%{generate_test_category "network_tests" test_spec.network_tests generate_api_test}

    // ========== Wallet API ==========
%{generate_test_category "wallet_tests" test_spec.wallet_tests generate_api_test}

    // ========== Transaction API ==========
%{generate_test_category "transaction_tests" test_spec.transaction_tests generate_api_test}

    // ========== Asset API ==========
%{generate_test_category "asset_tests" test_spec.asset_tests generate_api_test}

    // ========== Block API ==========
%{generate_test_category "block_tests" test_spec.block_tests generate_api_test}

    // ========== Smart Contract API ==========
%{generate_test_category "contract_tests" test_spec.contract_tests generate_api_test}

    // ========== Domain API ==========
%{generate_test_category "domain_tests" test_spec.domain_tests generate_api_test}

    // ========== Error Handling ==========
%{generate_test_category "error_handling" test_spec.error_handling_tests generate_error_test}
}
  "%,
}
