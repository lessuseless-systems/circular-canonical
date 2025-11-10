# PHP E2E Test Generator
# Generates PHPUnit E2E tests that run against real NAG endpoints
# Tests only execute when required environment variables are present

let config = import "../../../src/config.ncl" in
let e2e_spec = import "../../../tests/L5-e2e/e2e-tests.test.ncl" in

# Generate PHP method name from endpoint name (camelCase)
let to_camel_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  (std.string.lowercase first_char) ++ rest
in

# Generate assertion code based on operator
let generate_assertion = fun assertion =>
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
      m%"        $this->assertEquals(%{std.string.from_number assertion.value}, %{field_access})"%
    else if std.is_bool assertion.value then
      m%"        $this->assertEquals(%{if assertion.value then "true" else "false"}, %{field_access})"%
    else
      m%"        $this->assertEquals('%{assertion.value}', %{field_access})"%
  else if assertion.operator == "isDefined" then
    m%"        $this->assertNotNull(%{field_access})"%
  else if assertion.operator == "isArray" then
    m%"        $this->assertIsArray(%{field_access})"%
  else if assertion.operator == "greaterThan" then
    m%"        $this->assertGreaterThan(%{std.string.from_number assertion.value}, %{field_access})"%
  else
    m%"        // Unknown operator: %{assertion.operator}"%
in

# Generate E2E test case
let generate_e2e_test = fun test_name test_def =>
  let method_name = to_camel_case test_def.endpoint in
  let request_template = std.serialize 'Json test_def.request_template in
  let assertions = std.array.map generate_assertion test_def.assertions in

  m%"
    public function test%{std.string.uppercase (std.string.substring 0 1 test_name)}%{std.string.substring 1 (std.string.length test_name) test_name}(): void
    {
        $requestJson = '%{request_template}';
        $requestJson = str_replace('${CIRCULAR_TEST_ADDRESS}', getenv('CIRCULAR_TEST_ADDRESS') ?: '', $requestJson);
        $requestJson = str_replace('${CIRCULAR_TEST_BLOCKCHAIN}', getenv('CIRCULAR_TEST_BLOCKCHAIN') ?: 'MainNet', $requestJson);
        $request = json_decode($requestJson, true);

        $result = $this->api->%{method_name}($request);

%{std.string.join "\n" assertions}

        echo "  ✅ %{test_def.description}\n";
    }
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
<?php

namespace Circular\Protocol\Tests;

use Circular\Protocol\CircularProtocolAPI;
use Circular\Protocol\CircularProtocolException;
use PHPUnit\Framework\TestCase;

/**
 * Circular Protocol PHP SDK E2E Tests
 * Generated from Nickel E2E test specifications
 *
 * These tests run against REAL NAG endpoints.
 * They only execute when required environment variables are present.
 *
 * Required ENV vars:
 * - CIRCULAR_TEST_ADDRESS: Test wallet address (must exist on blockchain)
 *
 * Optional ENV vars:
 * - CIRCULAR_NAG_URL: NAG endpoint URL (default: %{e2e_spec.required_env_vars.nag_url.default})
 * - CIRCULAR_TEST_BLOCKCHAIN: Blockchain network (default: %{e2e_spec.required_env_vars.blockchain.default})
 * - CIRCULAR_API_KEY: Optional API key
 * - CIRCULAR_E2E_TIMEOUT: Request timeout in ms (default: 30000)
 *
 * Run with:
 *   CIRCULAR_TEST_ADDRESS=0x... composer test:e2e
 *
 * Or skip if ENV vars not present:
 *   composer test:e2e  # Will skip all tests
 */
class CircularProtocolE2ETest extends TestCase
{
    private CircularProtocolAPI $api;
    private static array $requiredEnvVars = ['CIRCULAR_TEST_ADDRESS'];

    public static function setUpBeforeClass(): void
    {
        // Check for required environment variables
        $missingVars = array_filter(self::$requiredEnvVars, fn($v) => !getenv($v));

        if (!empty($missingVars)) {
            echo "⏭️  Skipping E2E tests - missing required environment variables:\n";
            foreach ($missingVars as $v) {
                echo "   - $v\n";
            }
            echo "\nTo run E2E tests, set:\n";
            echo "  CIRCULAR_TEST_ADDRESS=0x... composer test:e2e\n";
            self::markTestSkipped('Missing required environment variables');
        }

        $nagUrl = getenv('CIRCULAR_NAG_URL') ?: '%{e2e_spec.required_env_vars.nag_url.default}';
        $testAddress = getenv('CIRCULAR_TEST_ADDRESS');
        $blockchain = getenv('CIRCULAR_TEST_BLOCKCHAIN') ?: 'MainNet';

        echo "\n🌐 Running E2E tests against: $nagUrl\n";
        echo "📍 Test address: $testAddress\n";
        echo "⛓️  Blockchain: $blockchain\n\n";
    }

    protected function setUp(): void
    {
        $nagUrl = getenv('CIRCULAR_NAG_URL') ?: '%{e2e_spec.required_env_vars.nag_url.default}';
        $apiKey = getenv('CIRCULAR_API_KEY');
        $this->api = new CircularProtocolAPI($nagUrl, $apiKey);
    }

    // Wallet API E2E Tests
%{wallet_tests}

    // Network API E2E Tests
%{network_tests}

    // Block API E2E Tests
%{block_tests}
}
"%,
}
