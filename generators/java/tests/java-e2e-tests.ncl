# Java E2E Test Generator
# Generates JUnit E2E tests that run against real NAG endpoints
# Tests only execute when required environment variables are present

let config = import "../../../src/config.ncl" in
let e2e_spec = import "../../../tests/L5-e2e/e2e-tests.test.ncl" in

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
            .replace("${CIRCULAR_TEST_BLOCKCHAIN}", System.getenv().getOrDefault("CIRCULAR_TEST_BLOCKCHAIN", "MainNet"));

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
 * Required ENV vars:
 * - CIRCULAR_TEST_ADDRESS: Test wallet address (must exist on blockchain)
 *
 * Optional ENV vars:
 * - CIRCULAR_NAG_URL: NAG endpoint URL (default: %{e2e_spec.required_env_vars.nag_url.default})
 * - CIRCULAR_TEST_BLOCKCHAIN: Blockchain network (default: MainNet)
 * - CIRCULAR_API_KEY: Optional API key
 * - CIRCULAR_E2E_TIMEOUT: Request timeout in ms (default: 30000)
 *
 * Run with:
 *   CIRCULAR_TEST_ADDRESS=0x... mvn test -Dtest=CircularProtocolE2ETest
 *
 * Or skip if ENV vars not present:
 *   mvn test -Dtest=CircularProtocolE2ETest  # Will skip all tests
 */
@DisplayName("E2E Tests - Real NAG Endpoints")
class CircularProtocolE2ETest {

    private static CircularProtocolAPI api;
    private static final List<String> REQUIRED_ENV_VARS = Arrays.asList("CIRCULAR_TEST_ADDRESS");

    @BeforeAll
    static void setUp() {
        // Check for required environment variables
        List<String> missingVars = REQUIRED_ENV_VARS.stream()
            .filter(v -> System.getenv(v) == null)
            .toList();

        if (!missingVars.isEmpty()) {
            System.out.println("⏭️  Skipping E2E tests - missing required environment variables:");
            missingVars.forEach(v -> System.out.println("   - " + v));
            System.out.println("\nTo run E2E tests, set:");
            System.out.println("  CIRCULAR_TEST_ADDRESS=0x... mvn test -Dtest=CircularProtocolE2ETest");
            assumeTrue(false, "Missing required environment variables");
        }

        String nagUrl = System.getenv().getOrDefault("CIRCULAR_NAG_URL", "%{e2e_spec.required_env_vars.nag_url.default}");
        String apiKey = System.getenv("CIRCULAR_API_KEY");

        api = new CircularProtocolAPI(nagUrl, apiKey);

        System.out.println("\n🌐 Running E2E tests against: " + nagUrl);
        System.out.println("📍 Test address: " + System.getenv("CIRCULAR_TEST_ADDRESS"));
        System.out.println("⛓️  Blockchain: " + System.getenv().getOrDefault("CIRCULAR_TEST_BLOCKCHAIN", "MainNet"));
        System.out.println("");
    }

    @Nested
    @DisplayName("Wallet API E2E Tests")
    class WalletAPIE2E {
%{wallet_tests}
    }

    @Nested
    @DisplayName("Network API E2E Tests")
    class NetworkAPIE2E {
%{network_tests}
    }

    @Nested
    @DisplayName("Block API E2E Tests")
    class BlockAPIE2E {
%{block_tests}
    }
}
"%,
}
