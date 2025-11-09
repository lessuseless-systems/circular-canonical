# Circular Protocol Canonical - TypeScript Integration Test Generator
# Generates Jest integration tests from Nickel test specifications
# Input: tests/L3-integration/integration-tests.test.ncl
# Output: TypeScript Jest test file for integration testing

let config = import "../../../src/config.ncl" in
let test_spec = import "../../../tests/L3-integration/integration-tests.test.ncl" in

# Generate TypeScript method name from endpoint name (camelCase)
let to_camel_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  (std.string.lowercase first_char) ++ rest
in

# Generate assertion code based on operator
let generate_assertion = fun test_name assertion =>
  let path_parts = std.string.split "." assertion.field in
  let field_access =
    if std.array.length path_parts == 1 then
      "result." ++ std.array.at 0 path_parts
    else if std.array.length path_parts == 2 then
      "result." ++ std.array.at 0 path_parts ++ "?." ++ std.array.at 1 path_parts
    else
      "result." ++ assertion.field
  in

  if assertion.operator == "equals" then
    if std.is_number assertion.value then
      m%"    expect(%{field_access}).toBe(%{std.string.from_number assertion.value})"%
    else if std.is_bool assertion.value then
      m%"    expect(%{field_access}).toBe(%{if assertion.value then "true" else "false"})"%
    else
      m%"    expect(%{field_access}).toBe('%{assertion.value}')"%
  else if assertion.operator == "isDefined" then
    m%"    expect(%{field_access}).toBeDefined()"%
  else if assertion.operator == "isArray" then
    m%"    expect(Array.isArray(%{field_access})).toBe(true)"%
  else if assertion.operator == "arrayContains" then
    m%"    expect(%{field_access}).toContain('%{assertion.value}')"%
  else if assertion.operator == "greaterThan" then
    m%"    expect(%{field_access}).toBeGreaterThan(%{std.string.from_number assertion.value})"%
  else if assertion.operator == "greaterThanOrEqual" then
    m%"    expect(%{field_access}).toBeGreaterThanOrEqual(%{std.string.from_number assertion.value})"%
  else
    m%"    // Unknown operator: %{assertion.operator}"%
in

# Generate test case for normal API call
let generate_api_test = fun test_name test_def =>
  let method_name = to_camel_case test_def.endpoint in
  let request_json = std.serialize 'Json test_def.request in
  let assertions = std.array.map (generate_assertion test_name) test_def.assertions in
  m%"
  test('%{test_def.description}', async () => {
    const result = await api.%{method_name}(%{request_json})

%{std.string.join "\n" assertions}

    console.log('  ✅ %{test_def.description}')
  }, %{std.string.from_number test_spec.timeout_ms})
  "%
in

# Generate test case for error handling
let generate_error_test = fun test_name test_def =>
  let method_name = to_camel_case test_def.endpoint in
  let request_json = std.serialize 'Json test_def.request in

  if std.record.has_field "override_url" test_def then
    # Connection error test - use different API instance
    m%"
  test('%{test_def.description}', async () => {
    const invalidApi = new CircularProtocolAPI('%{test_def.override_url}')

    await expect(invalidApi.%{method_name}(%{request_json}))
      .rejects
      .toThrow()

    console.log('  ✅ %{test_def.description}')
  }, %{std.string.from_number test_spec.timeout_ms})
  "%
  else
    # Validation error test - expect error from API
    m%"
  test('%{test_def.description}', async () => {
    await expect(api.%{method_name}(%{request_json}))
      .rejects
      .toThrow()

    console.log('  ✅ %{test_def.description}')
  }, %{std.string.from_number test_spec.timeout_ms})
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
/**
 * Circular Protocol TypeScript SDK Integration Tests
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
 *   cd tests/L3-integration
 *   npm test
 */

import { CircularProtocolAPI } from '../../dist/typescript/src/index'

const API_URL = process.env.CIRCULAR_API_URL || '%{test_spec.mock_server_url}'
const API_VERSION = '%{config.version}'

describe('%{test_spec.test_suite_name}', () => {
  let api: CircularProtocolAPI

  beforeAll(() => {
    api = new CircularProtocolAPI(API_URL)
  })

  describe('Network API', () => {
%{generate_test_category "network_tests" test_spec.network_tests generate_api_test}
  })

  describe('Wallet API', () => {
%{generate_test_category "wallet_tests" test_spec.wallet_tests generate_api_test}
  })

  describe('Block API', () => {
%{generate_test_category "block_tests" test_spec.block_tests generate_api_test}
  })

  describe('Error Handling', () => {
%{generate_test_category "error_handling" test_spec.error_handling_tests generate_error_test}
  })
})
  "%,
}
