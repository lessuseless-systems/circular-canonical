# PHP E2E Test Generator
# Generates PHPUnit E2E tests that run against real NAG endpoints
# Tests only execute when required environment variables are present

let config = import "../../../src/config.ncl" in
let e2e_spec = import "../../../tests/L5-e2e/read-operations/queries.test.ncl" in
let write_spec = import "../../../tests/L5-e2e/write-operations/transactions.test.ncl" in

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
  else if assertion.operator == "isHexString" then
    m%"        $this->assertMatchesRegularExpression('/^(0x)?[0-9a-fA-F]+$/', %{field_access})"%
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
  let method_name = to_camel_case test_def.endpoint in
  let assertions = std.array.map generate_assertion test_def.assertions in

  m%"
    public function test%{std.string.uppercase (std.string.substring 0 1 test_name)}%{std.string.substring 1 (std.string.length test_name) test_name}(): void
    {
        $privateKey = getenv('CIRCULAR_PRIVATE_KEY');
        $publicKey = $this->api->getPublicKey($privateKey);
        $address = $this->api->hashString($publicKey);

        $blockchain = getenv('CIRCULAR_TEST_BLOCKCHAIN') ?: '%{write_spec.required_env_vars.blockchain.default}';
        $timestamp = gmdate('Y:m:d-H:i:s');

        %{if test_def.endpoint == "registerWallet" then
          m%"
        $accountName = 'E2E-Test-Wallet-' . time();
        $signaturePayload = $blockchain . $accountName . $publicKey;
        $signature = $this->api->signMessage($signaturePayload, $privateKey);

        $request = [
            'Blockchain' => $blockchain,
            'AccountName' => $accountName,
            'PublicKey' => $publicKey,
            'Signature' => $signature,
            'Version' => '%{config.version}'
        ];

        echo "  📝 Registering wallet: $accountName\n";
        $result = $this->api->%{method_name}($request);

%{std.string.join "\n" assertions}

        echo "  ✅ Wallet registered successfully\n";
        echo "  📍 Wallet Address: " . $result['Response']['WalletAddress'] . "\n";
        echo "  🔗 Transaction ID: " . $result['Response']['TransactionID'] . "\n";
          "%
        else if test_def.endpoint == "sendTransaction" then
          m%"
        $data = 'E2E Test Data Certification ' . time();
        $signaturePayload = $blockchain . $address . $address . '0' . 'C_TYPE_CERTIFICATE' . $timestamp . '' . $data;
        $signature = $this->api->signMessage($signaturePayload, $privateKey);

        $request = [
            'Blockchain' => $blockchain,
            'FromWallet' => $address,
            'ToWallet' => $address,
            'Amount' => '0',
            'TransactionType' => 'C_TYPE_CERTIFICATE',
            'Timestamp' => $timestamp,
            'Voucher' => '',
            'Data' => $data,
            'Signature' => $signature,
            'Version' => '%{config.version}'
        ];

        echo "  📝 Certifying data on blockchain...\n";
        $result = $this->api->%{method_name}($request);

%{std.string.join "\n" assertions}

        echo "  ✅ Data certified successfully\n";
        echo "  🔗 Transaction ID: " . $result['Response']['TransactionID'] . "\n";
        echo "  📄 Certified data: $data\n";
          "%
        else if test_def.endpoint == "callContract" then
          m%"
        $request = [
            'Blockchain' => $blockchain,
            'From' => $address,
            'Address' => '0x0000000000000000000000000000000000000000000000000000000000000000',
            'Request' => '0x74657374',
            'Timestamp' => $timestamp,
            'Version' => '%{config.version}'
        ];

        echo "  📝 Calling smart contract function...\n";
        $result = $this->api->%{method_name}($request);

%{std.string.join "\n" assertions}

        echo "  ✅ Contract call executed (may have failed if contract doesn't exist)\n";
        echo "  📊 Result: " . $result['Result'] . "\n";
          "%
        else
          m%"
        throw new \Exception('Unknown write operation: %{test_def.endpoint}');
          "%
        }
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
 * Required ENV vars (read operations):
 * - CIRCULAR_TEST_ADDRESS: Test wallet address (must exist on blockchain)
 *
 * Required ENV vars (write operations):
 * - CIRCULAR_PRIVATE_KEY: Private key for signing transactions (32-byte hex)
 *
 * Optional ENV vars:
 * - CIRCULAR_NAG_URL: NAG endpoint URL (default: %{e2e_spec.required_env_vars.nag_url.default})
 * - CIRCULAR_TEST_BLOCKCHAIN: Blockchain network (default: %{e2e_spec.required_env_vars.blockchain.default})
 * - CIRCULAR_API_KEY: Optional API key
 * - CIRCULAR_E2E_TIMEOUT: Request timeout in ms (default: 30000)
 *
 * Run read-only tests with:
 *   CIRCULAR_TEST_ADDRESS=0x... composer test:e2e
 *
 * Run write operation tests with:
 *   CIRCULAR_PRIVATE_KEY=... composer test:e2e
 *   ⚠️  WARNING: This will create real transactions on the blockchain!
 *
 * Or skip if ENV vars not present:
 *   composer test:e2e  # Will skip all tests
 */
class CircularProtocolE2ETest extends TestCase
{
    private CircularProtocolAPI $api;
    private static array $readEnvVars = ['CIRCULAR_TEST_ADDRESS'];
    private static array $writeEnvVars = ['CIRCULAR_PRIVATE_KEY'];
    private static bool $hasReadEnv;
    private static bool $hasWriteEnv;

    public static function setUpBeforeClass(): void
    {
        // Check for read-only test environment variables
        $missingReadVars = array_filter(self::$readEnvVars, fn($v) => !getenv($v));

        // Check for write test environment variables
        $missingWriteVars = array_filter(self::$writeEnvVars, fn($v) => !getenv($v));

        self::$hasReadEnv = empty($missingReadVars);
        self::$hasWriteEnv = empty($missingWriteVars);

        if (!self::$hasReadEnv && !self::$hasWriteEnv) {
            echo "⏭️  Skipping all E2E tests - missing required environment variables\n";
            echo "\nFor read-only tests:\n";
            echo "  CIRCULAR_TEST_ADDRESS=0x... composer test:e2e\n";
            echo "\nFor write operation tests:\n";
            echo "  CIRCULAR_PRIVATE_KEY=... composer test:e2e\n";
            echo "  ⚠️  WARNING: Write tests create real blockchain transactions!\n";
            self::markTestSkipped('Missing required environment variables');
        }

        $nagUrl = getenv('CIRCULAR_NAG_URL') ?: '%{e2e_spec.required_env_vars.nag_url.default}';
        $blockchain = getenv('CIRCULAR_TEST_BLOCKCHAIN') ?: '%{e2e_spec.required_env_vars.blockchain.default}';

        echo "\n🌐 Running E2E tests against: $nagUrl\n";
        if (self::$hasReadEnv) {
            echo "📍 Test address: " . getenv('CIRCULAR_TEST_ADDRESS') . "\n";
        }
        if (self::$hasWriteEnv) {
            echo "🔑 Private key: ***REDACTED***\n";
        }
        echo "⛓️  Blockchain: $blockchain\n\n";

        if (self::$hasWriteEnv) {
            fwrite(STDERR, "⚠️  WARNING: Write operation tests will create REAL transactions on the blockchain!\n");
            fwrite(STDERR, "⚠️  Ensure you are using a test blockchain and test funds.\n");
        }
    }

    protected function setUp(): void
    {
        $nagUrl = getenv('CIRCULAR_NAG_URL') ?: '%{e2e_spec.required_env_vars.nag_url.default}';
        $apiKey = getenv('CIRCULAR_API_KEY');
        $this->api = new CircularProtocolAPI($nagUrl, $apiKey);
    }

    // Wallet API E2E Tests (Read-Only)
%{wallet_tests}

    // Transaction API E2E Tests (Read-Only)
%{transaction_tests}

    // Asset API E2E Tests (Read-Only)
%{asset_tests}

    // Network API E2E Tests (Read-Only)
%{network_tests}

    // Block API E2E Tests (Read-Only)
%{block_tests}

    // Domain API E2E Tests (Read-Only)
%{domain_tests}

    // Contract API E2E Tests (Read-Only)
%{contract_tests}

    // ========================================
    // Write Operations E2E Tests (LIVE BLOCKCHAIN)
    // ========================================

%{wallet_write_tests}

%{transaction_write_tests}

%{contract_write_tests}
}
"%,
}
