# Circular Protocol Canonical - Go Integration Test Generator
# Generates Go integration tests from Nickel test specifications
# Input: tests/L3-integration/integration-tests.test.ncl
# Output: Go testing package test file for integration testing

let config = import "../../../src/config.ncl" in
let test_spec = import "../../../tests/L3-integration/integration-tests.test.ncl" in

# Generate Go function name from endpoint name (PascalCase for exported)
let to_pascal_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  (std.string.uppercase first_char) ++ rest
in

# Generate assertion code based on operator (Go testing style)
let generate_assertion = fun test_name assertion =>
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
		t.Errorf("Expected %{assertion.field} to be %{std.string.from_number assertion.value}, got %%v", %{field_access})
	}"%
    else if std.is_bool assertion.value then
      m%"	if %{field_access} != %{if assertion.value then "true" else "false"} {
		t.Errorf("Expected %{assertion.field} to be %{if assertion.value then "true" else "false"}, got %%v", %{field_access})
	}"%
    else
      m%"	if %{field_access} != "%{assertion.value}" {
		t.Errorf("Expected %{assertion.field} to be '%{assertion.value}', got %%v", %{field_access})
	}"%
  else if assertion.operator == "isDefined" then
    m%"	if %{field_access} == nil {
		t.Errorf("Expected %{assertion.field} to be defined")
	}"%
  else if assertion.operator == "isArray" then
    m%"	if _, ok := %{field_access}.([]interface{}); !ok {
		t.Errorf("Expected %{assertion.field} to be an array")
	}"%
  else if assertion.operator == "arrayContains" then
    m%"	arr, ok := %{field_access}.([]interface{})
	if !ok {
		t.Errorf("Expected %{assertion.field} to be an array")
	} else {
		found := false
		for _, item := range arr {
			if item == "%{assertion.value}" {
				found = true
				break
			}
		}
		if !found {
			t.Errorf("Expected array to contain '%{assertion.value}'")
		}
	}"%
  else if assertion.operator == "greaterThan" then
    m%"	if int(%{field_access}.(float64)) <= %{std.string.from_number assertion.value} {
		t.Errorf("Expected %{assertion.field} to be greater than %{std.string.from_number assertion.value}, got %%v", %{field_access})
	}"%
  else if assertion.operator == "greaterThanOrEqual" then
    m%"	if int(%{field_access}.(float64)) < %{std.string.from_number assertion.value} {
		t.Errorf("Expected %{assertion.field} to be >= %{std.string.from_number assertion.value}, got %%v", %{field_access})
	}"%
  else
    m%"	// Unknown operator: %{assertion.operator}"%
in

# Generate test case for normal API call
let generate_api_test = fun test_name test_def =>
  let method_name = to_pascal_case test_def.endpoint in
  let assertions = std.array.map (generate_assertion test_name) test_def.assertions in
  let timeout_seconds = test_spec.timeout_ms / 1000 in

  # Build request map manually from request fields
  let request_fields = std.record.fields test_def.request in
  let request_assigns = std.array.map (fun field_name =>
    let field_value = std.record.get field_name test_def.request in
    if std.is_string field_value then
      m%"	request["%{field_name}"] = "%{field_value}""%
    else if std.is_number field_value then
      m%"	request["%{field_name}"] = %{std.string.from_number field_value}"%
    else if std.is_bool field_value then
      m%"	request["%{field_name}"] = %{if field_value then "true" else "false"}"%
    else
      m%"	request["%{field_name}"] = "%{std.serialize 'Json field_value}""%
  ) request_fields in

  m%"
func Test_%{test_name}(t *testing.T) {
	// %{test_def.description}
	ctx, cancel := context.WithTimeout(context.Background(), %{std.string.from_number timeout_seconds}*time.Second)
	defer cancel()

	request := make(map[string]interface{})
%{std.string.join "\n" request_assigns}

	result, err := client.%{method_name}(ctx, request)
	if err != nil {
		t.Fatalf("API call failed: %%v", err)
	}

%{std.string.join "\n" assertions}

	t.Logf("  ✅ %{test_def.description}")
}
"%
in

# Generate test case for error handling
let generate_error_test = fun test_name test_def =>
  let method_name = to_pascal_case test_def.endpoint in
  let timeout_seconds = test_spec.timeout_ms / 1000 in

  # Build request map manually from request fields
  let request_fields = std.record.fields test_def.request in
  let request_assigns = std.array.map (fun field_name =>
    let field_value = std.record.get field_name test_def.request in
    if std.is_string field_value then
      m%"	request["%{field_name}"] = "%{field_value}""%
    else if std.is_number field_value then
      m%"	request["%{field_name}"] = %{std.string.from_number field_value}"%
    else if std.is_bool field_value then
      m%"	request["%{field_name}"] = %{if field_value then "true" else "false"}"%
    else
      m%"	request["%{field_name}"] = "%{std.serialize 'Json field_value}""%
  ) request_fields in

  if std.record.has_field "override_url" test_def then
    # Connection error test - use different API instance
    m%"
func Test_%{test_name}(t *testing.T) {
	// %{test_def.description}
	ctx, cancel := context.WithTimeout(context.Background(), %{std.string.from_number timeout_seconds}*time.Second)
	defer cancel()

	invalidClient := NewClient("%{test_def.override_url}", "")

	request := make(map[string]interface{})
%{std.string.join "\n" request_assigns}

	_, err := invalidClient.%{method_name}(ctx, request)
	if err == nil {
		t.Fatalf("Expected connection error, but call succeeded")
	}

	t.Logf("  ✅ %{test_def.description}")
}
"%
  else
    # API error test - expects error response from valid endpoint
    m%"
func Test_%{test_name}(t *testing.T) {
	// %{test_def.description}
	ctx, cancel := context.WithTimeout(context.Background(), %{std.string.from_number timeout_seconds}*time.Second)
	defer cancel()

	request := make(map[string]interface{})
%{std.string.join "\n" request_assigns}

	_, err := client.%{method_name}(ctx, request)
	if err == nil {
		t.Errorf("Expected API error, but call succeeded")
	}

	t.Logf("  ✅ %{test_def.description}")
}
"%
in

# Collect all tests from test_spec by domain
let wallet_tests_array = std.record.to_array test_spec.wallet_tests in
let transaction_tests_array = std.record.to_array test_spec.transaction_tests in
let asset_tests_array = std.record.to_array test_spec.asset_tests in
let network_tests_array = std.record.to_array test_spec.network_tests in
let block_tests_array = std.record.to_array test_spec.block_tests in
let domain_tests_array = std.record.to_array test_spec.domain_tests in
let contract_tests_array = std.record.to_array test_spec.contract_tests in
let error_tests = std.record.to_array test_spec.error_handling_tests in

# Combine all API tests
let all_api_tests = wallet_tests_array @ transaction_tests_array @ asset_tests_array @ network_tests_array @ block_tests_array @ domain_tests_array @ contract_tests_array in

# Generate test functions
let api_test_functions = std.array.map (fun kv =>
  generate_api_test kv.field kv.value
) all_api_tests in

let error_test_functions = std.array.map (fun kv =>
  generate_error_test kv.field kv.value
) error_tests in

# Assemble complete test file
{
  test_code = m%"
package circularprotocol_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/circular-protocol/circular-go/circularprotocol"
)

var (
	client     *circularprotocol.Client
	mockServer *httptest.Server
)

// TestMain sets up the mock server before running tests
func TestMain(m *testing.M) {
	// Create mock server
	mockServer = httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Mock server responds with success for all requests
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{
			"Result": 200,
			"Response": {
				"data": "mock_success",
				"array": ["item1", "item2"],
				"count": 10,
				"exists": true
			}
		}`))
	}))
	defer mockServer.Close()

	// Create client pointing to mock server
	client = circularprotocol.NewClient(mockServer.URL+"/", "mock-key")

	// Run tests
	m.Run()
}
%{std.string.join "\n" api_test_functions}
%{std.string.join "\n" error_test_functions}
"%,

  # Metadata
  metadata = {
    version = config.version,
    test_count = (std.array.length all_api_tests) + (std.array.length error_tests),
    language = "Go",
    test_framework = "testing",
    description = "Integration tests against mock server (Layer 3)",
  },
}
