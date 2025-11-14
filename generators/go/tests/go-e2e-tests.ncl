# Go E2E Test Generator
# Generates Go E2E tests that run against real NAG endpoints
# Tests only execute when required environment variables are present

let config = import "../../../src/config.ncl" in
let e2e_spec = import "../../../tests/L5-e2e/read-operations/queries.test.ncl" in

# Generate Go method name from endpoint name (PascalCase)
let to_pascal_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  (std.string.uppercase first_char) ++ rest
in

# Generate assertion code based on operator
let generate_assertion = fun assertion =>
  let field_parts = std.string.split "." assertion.field in
  let field_access =
    if std.array.length field_parts == 1 then
      "result[\"" ++ std.array.at 0 field_parts ++ "\"]"
    else if std.array.length field_parts == 2 then
      "result[\"" ++ std.array.at 0 field_parts ++ "\"].(map[string]interface{})[\"" ++ std.array.at 1 field_parts ++ "\"]"
    else
      "result[\"" ++ assertion.field ++ "\"]"
  in

  if assertion.operator == "equals" then
    if std.is_number assertion.value then
      m%"	if %{field_access} != float64(%{std.string.from_number assertion.value}) {
		t.Errorf("Expected %{assertion.field} to equal %{std.string.from_number assertion.value}, got %%v", %{field_access})
	}"%
    else if std.is_bool assertion.value then
      m%"	if %{field_access} != %{if assertion.value then "true" else "false"} {
		t.Errorf("Expected %{assertion.field} to equal %{if assertion.value then "true" else "false"}, got %%v", %{field_access})
	}"%
    else
      m%"	if %{field_access} != "%{assertion.value}" {
		t.Errorf("Expected %{assertion.field} to equal %{assertion.value}, got %%v", %{field_access})
	}"%
  else if assertion.operator == "isDefined" then
    m%"	if %{field_access} == nil {
		t.Errorf("Expected %{assertion.field} to be defined")
	}"%
  else if assertion.operator == "isArray" then
    m%"	if _, ok := %{field_access}.([]interface{}); !ok {
		t.Errorf("Expected %{assertion.field} to be an array")
	}"%
  else if assertion.operator == "greaterThan" then
    m%"	if val, ok := %{field_access}.(float64); !ok || val <= %{std.string.from_number assertion.value} {
		t.Errorf("Expected %{assertion.field} > %{std.string.from_number assertion.value}, got %%v", %{field_access})
	}"%
  else
    m%"	// Unknown operator: %{assertion.operator}"%
in

# Generate E2E test case
let generate_e2e_test = fun test_name test_def =>
  let method_name = to_pascal_case test_def.endpoint in
  let request_template = std.serialize 'Json test_def.request_template in
  let assertions = std.array.map generate_assertion test_def.assertions in

  m%"
func Test%{to_pascal_case test_name}(t *testing.T) {
	client := setupClient(t)

	requestJSON := `%{request_template}`
	requestJSON = strings.ReplaceAll(requestJSON, "$${CIRCULAR_TEST_ADDRESS}", os.Getenv("CIRCULAR_TEST_ADDRESS"))
	requestJSON = strings.ReplaceAll(requestJSON, "$${CIRCULAR_TEST_BLOCKCHAIN}", getEnvOrDefault("CIRCULAR_TEST_BLOCKCHAIN", "%{e2e_spec.required_env_vars.blockchain.default}"))

	var request map[string]interface{}
	if err := json.Unmarshal([]byte(requestJSON), &request); err != nil {
		t.Fatalf("Failed to unmarshal request: %%v", err)
	}

	result, err := client.%{method_name}(context.Background(), request)
	if err != nil {
		t.Fatalf("API call failed: %%v", err)
	}

%{std.string.join "\n" assertions}

	t.Logf("✅ %{test_def.description}")
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
package circularprotocol_test

import (
	"context"
	"encoding/json"
	"os"
	"strings"
	"testing"

	"github.com/circular-protocol/circular-go"
)

// Circular Protocol Go SDK E2E Tests
// Generated from Nickel E2E test specifications
//
// These tests run against REAL NAG endpoints.
// They only execute when required environment variables are present.
//
// Required ENV vars:
// - CIRCULAR_TEST_ADDRESS: Test wallet address (must exist on blockchain)
//
// Optional ENV vars:
// - CIRCULAR_NAG_URL: NAG endpoint URL (default: %{e2e_spec.required_env_vars.nag_url.default})
// - CIRCULAR_TEST_BLOCKCHAIN: Blockchain network (default: %{e2e_spec.required_env_vars.blockchain.default})
// - CIRCULAR_API_KEY: Optional API key
// - CIRCULAR_E2E_TIMEOUT: Request timeout in seconds (default: 30)
//
// Run with:
//   CIRCULAR_TEST_ADDRESS=0x... go test -v -tags=e2e
//
// Or skip if ENV vars not present:
//   go test -v -tags=e2e  # Will skip all tests

var requiredEnvVars = []string{"CIRCULAR_TEST_ADDRESS"}

func TestMain(m *testing.M) {
	// Check for required environment variables
	missingVars := []string{}
	for _, v := range requiredEnvVars {
		if os.Getenv(v) == "" {
			missingVars = append(missingVars, v)
		}
	}

	if len(missingVars) > 0 {
		println("⏭️  Skipping E2E tests - missing required environment variables:")
		for _, v := range missingVars {
			println("   -", v)
		}
		println("\nTo run E2E tests, set:")
		println("  CIRCULAR_TEST_ADDRESS=0x... go test -v -tags=e2e")
		os.Exit(0)
	}

	nagURL := getEnvOrDefault("CIRCULAR_NAG_URL", "%{e2e_spec.required_env_vars.nag_url.default}")
	testAddress := os.Getenv("CIRCULAR_TEST_ADDRESS")
	blockchain := getEnvOrDefault("CIRCULAR_TEST_BLOCKCHAIN", "%{e2e_spec.required_env_vars.blockchain.default}")

	println("\n🌐 Running E2E tests against:", nagURL)
	println("📍 Test address:", testAddress)
	println("⛓️  Blockchain:", blockchain)
	println()

	os.Exit(m.Run())
}

func setupClient(t *testing.T) *circularprotocol.Client {
	nagURL := getEnvOrDefault("CIRCULAR_NAG_URL", "%{e2e_spec.required_env_vars.nag_url.default}")
	apiKey := os.Getenv("CIRCULAR_API_KEY")
	return circularprotocol.NewClient(nagURL, apiKey)
}

func getEnvOrDefault(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// Wallet API E2E Tests
%{wallet_tests}

// Network API E2E Tests
%{network_tests}

// Block API E2E Tests
%{block_tests}
"%,
}
