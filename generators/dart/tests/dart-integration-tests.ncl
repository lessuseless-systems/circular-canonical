# Circular Protocol Canonical - Dart Integration Test Generator
# Generates Dart integration tests from Nickel test specifications
# Input: tests/L3-integration/integration-tests.test.ncl
# Output: Dart test file for integration testing

let config = import "../../../src/config.ncl" in
let test_spec = import "../../../tests/L3-integration/integration-tests.test.ncl" in

# Generate Dart method name from endpoint name (camelCase)
let to_camel_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  (std.string.lowercase first_char) ++ rest
in

# Generate assertion code based on operator (Dart test style)
let generate_assertion = fun test_name assertion =>
  let field_parts = std.string.split "." assertion.field in
  let field_access =
    if std.array.length field_parts == 1 then
      "result['" ++ std.array.at 0 field_parts ++ "']"
    else if std.array.length field_parts == 2 then
      "(result['" ++ std.array.at 0 field_parts ++ "'] as Map<String, dynamic>)['" ++ std.array.at 1 field_parts ++ "']"
    else
      "result['" ++ assertion.field ++ "']"
  in

  if assertion.operator == "equals" then
    if std.is_number assertion.value then
      m%"      expect(%{field_access}, equals(%{std.string.from_number assertion.value}));"%
    else if std.is_bool assertion.value then
      m%"      expect(%{field_access}, equals(%{if assertion.value then "true" else "false"}));"%
    else
      m%"      expect(%{field_access}, equals('%{assertion.value}'));"%
  else if assertion.operator == "isDefined" then
    m%"      expect(%{field_access}, isNotNull);"%
  else if assertion.operator == "isArray" then
    m%"      expect(%{field_access}, isA<List>());"%
  else if assertion.operator == "arrayContains" then
    m%"      expect(%{field_access} as List, contains('%{assertion.value}'));"%
  else if assertion.operator == "greaterThan" then
    m%"      expect(%{field_access} as int, greaterThan(%{std.string.from_number assertion.value}));"%
  else if assertion.operator == "greaterThanOrEqual" then
    m%"      expect(%{field_access} as int, greaterThanOrEqualTo(%{std.string.from_number assertion.value}));"%
  else
    m%"      // Unknown operator: %{assertion.operator}"%
in

# Generate test case for normal API call
let generate_api_test = fun test_name test_def =>
  let method_name = to_camel_case test_def.endpoint in
  let assertions = std.array.map (generate_assertion test_name) test_def.assertions in
  let timeout_seconds = test_spec.timeout_ms / 1000 in

  # Build request map manually from request fields
  let request_fields = std.record.fields test_def.request in
  let request_assigns = std.array.map (fun field_name =>
    let field_value = std.record.get field_name test_def.request in
    if std.is_string field_value then
      m%"'%{field_name}': '%{field_value}',"%
    else if std.is_number field_value then
      m%"'%{field_name}': %{std.string.from_number field_value},"%
    else if std.is_bool field_value then
      m%"'%{field_name}': %{if field_value then "true" else "false"},"%
    else if std.is_array field_value then
      # Arrays: serialize without quotes to create Dart list literal
      m%"'%{field_name}': %{std.serialize 'Json field_value},"%
    else
      # Objects/records: serialize without quotes to create Dart map literal
      m%"'%{field_name}': %{std.serialize 'Json field_value},"%
  ) request_fields in

  m%"
  test('%{test_def.description}', () async {
    final request = {
%{std.string.join "\n" request_assigns}
    };

    final result = await client.%{method_name}(request);

%{std.string.join "\n" assertions}
  }, timeout: Timeout(Duration(seconds: %{std.string.from_number timeout_seconds})));
"%
in

# Generate test case for error handling
let generate_error_test = fun test_name test_def =>
  let method_name = to_camel_case test_def.endpoint in
  let timeout_seconds = test_spec.timeout_ms / 1000 in

  # Build request map manually from request fields
  let request_fields = std.record.fields test_def.request in
  let request_assigns = std.array.map (fun field_name =>
    let field_value = std.record.get field_name test_def.request in
    if std.is_string field_value then
      m%"'%{field_name}': '%{field_value}',"%
    else if std.is_number field_value then
      m%"'%{field_name}': %{std.string.from_number field_value},"%
    else if std.is_bool field_value then
      m%"'%{field_name}': %{if field_value then "true" else "false"},"%
    else if std.is_array field_value then
      # Arrays: serialize without quotes to create Dart list literal
      m%"'%{field_name}': %{std.serialize 'Json field_value},"%
    else
      # Objects/records: serialize without quotes to create Dart map literal
      m%"'%{field_name}': %{std.serialize 'Json field_value},"%
  ) request_fields in

  if std.record.has_field "override_url" test_def then
    # Connection error test - use different API instance
    m%"
  test('%{test_def.description}', () async {
    final invalidClient = CircularProtocolAPI(nagUrl: '%{test_def.override_url}');

    final request = {
%{std.string.join "\n" request_assigns}
    };

    expect(
      () => invalidClient.%{method_name}(request),
      throwsA(isA<CircularAPIException>()),
    );
  }, timeout: Timeout(Duration(seconds: %{std.string.from_number timeout_seconds})));
"%
  else
    # API error test - expects error response from valid endpoint
    m%"
  test('%{test_def.description}', () async {
    final request = {
%{std.string.join "\n" request_assigns}
    };

    expect(
      () => client.%{method_name}(request),
      throwsA(isA<CircularAPIException>()),
    );
  }, timeout: Timeout(Duration(seconds: %{std.string.from_number timeout_seconds})));
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
import 'dart:io';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import '../lib/circular_protocol.dart';

late CircularProtocolAPI client;
late MockClient mockClient;

void main() {
  setUpAll(() {
    // Create mock HTTP client that responds with success for all requests
    mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'Result': 200,
          'Response': {
            'data': 'mock_success',
            'array': ['item1', 'item2'],
            'count': 10,
            'exists': true,
          }
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    // Create client with mock HTTP client
    client = CircularProtocolAPI(
      nagUrl: 'https://mock.test/',
      nagKey: 'mock-key',
      httpClient: mockClient,
    );
  });

  tearDownAll(() {
    client.dispose();
  });

  group('Integration Tests (Layer 3)', () {
%{std.string.join "\n" api_test_functions}
%{std.string.join "\n" error_test_functions}
  });
}
"%,

  # Metadata
  metadata = {
    version = config.version,
    test_count = (std.array.length all_api_tests) + (std.array.length error_tests),
    language = "Dart",
    test_framework = "test",
    description = "Integration tests against mock server (Layer 3)",
  },
}
