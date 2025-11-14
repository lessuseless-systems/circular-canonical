# Java E2E Test Generator
# Generates JUnit E2E tests that run against real NAG endpoints
# Tests only execute when required environment variables are present

let config = import "../../../src/config.ncl" in
let e2e_spec = import "../../../tests/L5-e2e/read-operations/queries.test.ncl" in
let write_spec = import "../../../tests/L5-e2e/write-operations/transactions.test.ncl" in

# Generate Java method name from endpoint name (camelCase)
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
      "result.get(\"" ++ std.array.at 0 field_parts ++ "\")"
    else if std.array.length field_parts == 2 then
      "((Map<String, Object>) result.get(\"" ++ std.array.at 0 field_parts ++ "\")).get(\"" ++ std.array.at 1 field_parts ++ "\")"
    else
      "result.get(\"" ++ assertion.field ++ "\")"
  in

  if assertion.operator == "equals" then
    if std.is_number assertion.value then
      m%"        assertEquals(%{std.string.from_number assertion.value}, %{field_access})"%
    else if std.is_bool assertion.value then
      m%"        assertEquals(%{if assertion.value then "true" else "false"}, %{field_access})"%
    else
      m%"        assertEquals(\"%{assertion.value}\", %{field_access})"%
  else if assertion.operator == "isDefined" then
    m%"        assertNotNull(%{field_access})"%
  else if assertion.operator == "greaterThan" then
    m%"        assertTrue((Integer) %{field_access} > %{std.string.from_number assertion.value})"%
  else if assertion.operator == "isHexString" then
    m%"        assertTrue(%{field_access} instanceof String && ((String) %{field_access}).matches(\"^(0x)?[0-9a-fA-F]+$\"))"%
  else
    m%"        // Unknown operator: %{assertion.operator}"%
in

# Generate E2E test case
let generate_e2e_test = fun test_name test_def =>
  let method_name = to_camel_case test_def.endpoint in
  let request_template = std.serialize 'Json test_def.request_template in
  let assertions = std.array.map generate_assertion test_def.assertions in

  m%"
    @Test
    @DisplayName("%{test_def.description}")
    void test%{std.string.uppercase (std.string.substring 0 1 test_name)}%{std.string.substring 1 (std.string.length test_name) test_name}() throws Exception {
        String requestJson = """%{request_template}"""
            .replace("${CIRCULAR_TEST_ADDRESS}", System.getenv().getOrDefault("CIRCULAR_TEST_ADDRESS", ""))
            .replace("${CIRCULAR_TEST_BLOCKCHAIN}", System.getenv().getOrDefault("CIRCULAR_TEST_BLOCKCHAIN", "%{e2e_spec.required_env_vars.blockchain.default}"));

        ObjectMapper mapper = new ObjectMapper();
        Map<String, Object> request = mapper.readValue(requestJson, new TypeReference<Map<String, Object>>() {});

        Map<String, Object> result = api.%{method_name}(request).get();

%{std.string.join "\n" assertions}

        System.out.println("  ✅ %{test_def.description}");
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
    @Test
    @DisplayName("%{test_def.description}")
    void test%{std.string.uppercase (std.string.substring 0 1 test_name)}%{std.string.substring 1 (std.string.length test_name) test_name}() throws Exception {
        String privateKey = System.getenv("CIRCULAR_PRIVATE_KEY");
        String publicKey = api.getPublicKey(privateKey);
        String address = api.hashString(publicKey);

        String blockchain = System.getenv().getOrDefault("CIRCULAR_TEST_BLOCKCHAIN", "%{write_spec.required_env_vars.blockchain.default}");
        String timestamp = java.time.Instant.now().toString().replace("T", "-").replace("Z", "").substring(0, 19).replace("-", ":");

        %{if test_def.endpoint == "registerWallet" then
          m%"
        String accountName = "E2E-Test-Wallet-" + System.currentTimeMillis();
        String signaturePayload = blockchain + accountName + publicKey;
        String signature = api.signMessage(signaturePayload, privateKey);

        Map<String, Object> request = new java.util.HashMap<>();
        request.put("Blockchain", blockchain);
        request.put("AccountName", accountName);
        request.put("PublicKey", publicKey);
        request.put("Signature", signature);
        request.put("Version", "%{config.version}");

        System.out.println("  📝 Registering wallet: " + accountName);
        Map<String, Object> result = api.%{method_name}(request).get();

%{std.string.join "\n" assertions}

        System.out.println("  ✅ Wallet registered successfully");
        System.out.println("  📍 Wallet Address: " + ((Map) result.get("Response")).get("WalletAddress"));
        System.out.println("  🔗 Transaction ID: " + ((Map) result.get("Response")).get("TransactionID"));
          "%
        else if test_def.endpoint == "sendTransaction" then
          m%"
        String data = "E2E Test Data Certification " + System.currentTimeMillis();
        String signaturePayload = blockchain + address + address + "0" + "C_TYPE_CERTIFICATE" + timestamp + "" + data;
        String signature = api.signMessage(signaturePayload, privateKey);

        Map<String, Object> request = new java.util.HashMap<>();
        request.put("Blockchain", blockchain);
        request.put("FromWallet", address);
        request.put("ToWallet", address);
        request.put("Amount", "0");
        request.put("TransactionType", "C_TYPE_CERTIFICATE");
        request.put("Timestamp", timestamp);
        request.put("Voucher", "");
        request.put("Data", data);
        request.put("Signature", signature);
        request.put("Version", "%{config.version}");

        System.out.println("  📝 Certifying data on blockchain...");
        Map<String, Object> result = api.%{method_name}(request).get();

%{std.string.join "\n" assertions}

        System.out.println("  ✅ Data certified successfully");
        System.out.println("  🔗 Transaction ID: " + ((Map) result.get("Response")).get("TransactionID"));
        System.out.println("  📄 Certified data: " + data);
          "%
        else if test_def.endpoint == "callContract" then
          m%"
        Map<String, Object> request = new java.util.HashMap<>();
        request.put("Blockchain", blockchain);
        request.put("From", address);
        request.put("Address", "0x0000000000000000000000000000000000000000000000000000000000000000");
        request.put("Request", "0x74657374");
        request.put("Timestamp", timestamp);
        request.put("Version", "%{config.version}");

        System.out.println("  📝 Calling smart contract function...");
        Map<String, Object> result = api.%{method_name}(request).get();

%{std.string.join "\n" assertions}

        System.out.println("  ✅ Contract call executed (may have failed if contract doesn't exist)");
        System.out.println("  📊 Result: " + result.get("Result"));
          "%
        else
          m%"
        throw new UnsupportedOperationException("Unknown write operation: %{test_def.endpoint}");
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
package io.circular.protocol;

import org.junit.jupiter.api.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import static org.junit.jupiter.api.Assertions.*;
import static org.junit.jupiter.api.Assumptions.*;

import java.util.Map;
import java.util.Arrays;
import java.util.List;

/**
 * Circular Protocol Java SDK E2E Tests
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
 *   CIRCULAR_TEST_ADDRESS=0x... mvn test -Dtest=CircularProtocolE2ETest
 *
 * Run write operation tests with:
 *   CIRCULAR_PRIVATE_KEY=... mvn test -Dtest=CircularProtocolE2ETest
 *   ⚠️  WARNING: This will create real transactions on the blockchain!
 *
 * Or skip if ENV vars not present:
 *   mvn test -Dtest=CircularProtocolE2ETest  # Will skip all tests
 */
@DisplayName("E2E Tests - Real NAG Endpoints")
class CircularProtocolE2ETest {

    private static CircularProtocolAPI api;
    private static final List<String> READ_ENV_VARS = Arrays.asList("CIRCULAR_TEST_ADDRESS");
    private static final List<String> WRITE_ENV_VARS = Arrays.asList("CIRCULAR_PRIVATE_KEY");
    private static boolean hasReadEnv;
    private static boolean hasWriteEnv;

    @BeforeAll
    static void setUp() {
        // Check for read-only test environment variables
        List<String> missingReadVars = READ_ENV_VARS.stream()
            .filter(v -> System.getenv(v) == null)
            .toList();

        // Check for write test environment variables
        List<String> missingWriteVars = WRITE_ENV_VARS.stream()
            .filter(v -> System.getenv(v) == null)
            .toList();

        hasReadEnv = missingReadVars.isEmpty();
        hasWriteEnv = missingWriteVars.isEmpty();

        if (!hasReadEnv && !hasWriteEnv) {
            System.out.println("⏭️  Skipping all E2E tests - missing required environment variables");
            System.out.println("\nFor read-only tests:");
            System.out.println("  CIRCULAR_TEST_ADDRESS=0x... mvn test -Dtest=CircularProtocolE2ETest");
            System.out.println("\nFor write operation tests:");
            System.out.println("  CIRCULAR_PRIVATE_KEY=... mvn test -Dtest=CircularProtocolE2ETest");
            System.out.println("  ⚠️  WARNING: Write tests create real blockchain transactions!");
            assumeTrue(false, "Missing required environment variables");
        }

        String nagUrl = System.getenv().getOrDefault("CIRCULAR_NAG_URL", "%{e2e_spec.required_env_vars.nag_url.default}");
        String apiKey = System.getenv("CIRCULAR_API_KEY");

        api = new CircularProtocolAPI(nagUrl, apiKey);

        System.out.println("\n🌐 Running E2E tests against: " + nagUrl);
        if (hasReadEnv) {
            System.out.println("📍 Test address: " + System.getenv("CIRCULAR_TEST_ADDRESS"));
        }
        if (hasWriteEnv) {
            System.out.println("🔑 Private key: ***REDACTED***");
        }
        System.out.println("⛓️  Blockchain: " + System.getenv().getOrDefault("CIRCULAR_TEST_BLOCKCHAIN", "%{e2e_spec.required_env_vars.blockchain.default}"));
        System.out.println("");
    }

    @Nested
    @DisplayName("Wallet API E2E Tests (Read-Only)")
    class WalletAPIE2E {
        @BeforeAll
        static void checkEnv() {
            assumeTrue(hasReadEnv, "Skipped - CIRCULAR_TEST_ADDRESS not set");
        }
%{wallet_tests}
    }

    @Nested
    @DisplayName("Transaction API E2E Tests (Read-Only)")
    class TransactionAPIE2E {
        @BeforeAll
        static void checkEnv() {
            assumeTrue(hasReadEnv, "Skipped - CIRCULAR_TEST_ADDRESS not set");
        }
%{transaction_tests}
    }

    @Nested
    @DisplayName("Asset API E2E Tests (Read-Only)")
    class AssetAPIE2E {
        @BeforeAll
        static void checkEnv() {
            assumeTrue(hasReadEnv, "Skipped - CIRCULAR_TEST_ADDRESS not set");
        }
%{asset_tests}
    }

    @Nested
    @DisplayName("Network API E2E Tests (Read-Only)")
    class NetworkAPIE2E {
        @BeforeAll
        static void checkEnv() {
            assumeTrue(hasReadEnv, "Skipped - CIRCULAR_TEST_ADDRESS not set");
        }
%{network_tests}
    }

    @Nested
    @DisplayName("Block API E2E Tests (Read-Only)")
    class BlockAPIE2E {
        @BeforeAll
        static void checkEnv() {
            assumeTrue(hasReadEnv, "Skipped - CIRCULAR_TEST_ADDRESS not set");
        }
%{block_tests}
    }

    @Nested
    @DisplayName("Domain API E2E Tests (Read-Only)")
    class DomainAPIE2E {
        @BeforeAll
        static void checkEnv() {
            assumeTrue(hasReadEnv, "Skipped - CIRCULAR_TEST_ADDRESS not set");
        }
%{domain_tests}
    }

    @Nested
    @DisplayName("Contract API E2E Tests (Read-Only)")
    class ContractAPIE2E {
        @BeforeAll
        static void checkEnv() {
            assumeTrue(hasReadEnv, "Skipped - CIRCULAR_TEST_ADDRESS not set");
        }
%{contract_tests}
    }

    @Nested
    @DisplayName("⚠️  Write Operations E2E Tests (LIVE BLOCKCHAIN)")
    class WriteOperationsE2E {
        @BeforeAll
        static void checkEnv() {
            assumeTrue(hasWriteEnv, "Skipped - CIRCULAR_PRIVATE_KEY not set (write operations require private key)");
            System.err.println("⚠️  WARNING: Write operation tests will create REAL transactions on the blockchain!");
            System.err.println("⚠️  Ensure you are using a test blockchain and test funds.");
        }
%{wallet_write_tests}

%{transaction_write_tests}

%{contract_write_tests}
    }
}
"%,
}
