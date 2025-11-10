# TypeScript E2E Test Generator
# Generates Jest E2E tests that run against real NAG endpoints
# Tests only execute when required environment variables are present

let config = import "../../../src/config.ncl" in
let e2e_spec = import "../../../tests/L5-e2e/e2e-tests.test.ncl" in

# Generate TypeScript method name from endpoint name (camelCase)
let to_camel_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  (std.string.lowercase first_char) ++ rest
in

# Generate assertion code based on operator
let generate_assertion = fun assertion =>
  let field_access = "result." ++ assertion.field in

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
  else if assertion.operator == "greaterThan" then
    m%"    expect(%{field_access}).toBeGreaterThan(%{std.string.from_number assertion.value})"%
  else
    m%"    // Unknown operator: %{assertion.operator}"%
in

# Substitute environment variables in request template
let substitute_env_vars = fun template =>
  let json_str = std.serialize 'Json template in
  json_str
in

# Generate E2E test case
let generate_e2e_test = fun test_name test_def =>
  let method_name = to_camel_case test_def.endpoint in
  let request_template = substitute_env_vars test_def.request_template in
  let assertions = std.array.map generate_assertion test_def.assertions in
  let env_checks = std.array.map (fun env => m%"process.env.%{env}"%  ) test_def.requires_env in

  m%"
  test('%{test_def.description}', async () => {
    const request = JSON.parse(`%{request_template}`.replace(
      /\$\{CIRCULAR_TEST_ADDRESS\}/g, process.env.CIRCULAR_TEST_ADDRESS || ''
    ).replace(
      /\$\{CIRCULAR_TEST_BLOCKCHAIN\}/g, process.env.CIRCULAR_TEST_BLOCKCHAIN || '%{e2e_spec.required_env_vars.blockchain.default}'
    ))

    const result = await api.%{method_name}(request)

%{std.string.join "\n" assertions}

    console.log('  ✅ %{test_def.description}')
  }, %{std.string.from_number e2e_spec.timeout_ms})
  "%
in

# Generate all wallet tests
let wallet_tests = std.string.join "\n\n" (
  std.array.map
    (fun kv => generate_e2e_test kv.field kv.value)
    (std.record.to_array e2e_spec.wallet_tests)
) in

# Generate all network tests
let network_tests = std.string.join "\n\n" (
  std.array.map
    (fun kv => generate_e2e_test kv.field kv.value)
    (std.record.to_array e2e_spec.network_tests)
) in

# Generate all block tests
let block_tests = std.string.join "\n\n" (
  std.array.map
    (fun kv => generate_e2e_test kv.field kv.value)
    (std.record.to_array e2e_spec.block_tests)
) in

{
  test_code = m%"
/**
 * Circular Protocol TypeScript SDK E2E Tests
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
 *   CIRCULAR_TEST_ADDRESS=0x... npm run test:e2e
 *
 * Or skip if ENV vars not present:
 *   npm run test:e2e  # Will skip all tests
 */

import { CircularProtocolAPI } from '../src/index'

// Check for required environment variables
const REQUIRED_ENV_VARS = ['CIRCULAR_TEST_ADDRESS']
const missingEnvVars = REQUIRED_ENV_VARS.filter(v => !process.env[v])

if (missingEnvVars.length > 0) {
  console.log('⏭️  Skipping E2E tests - missing required environment variables:')
  missingEnvVars.forEach(v => console.log(`   - ${v}`))
  console.log('\nTo run E2E tests, set:')
  console.log('  CIRCULAR_TEST_ADDRESS=0x... npm run test:e2e')
  process.exit(0)
}

describe('E2E Tests - Real NAG Endpoints', () => {
  let api: CircularProtocolAPI

  beforeAll(() => {
    const nagUrl = process.env.CIRCULAR_NAG_URL || '%{e2e_spec.required_env_vars.nag_url.default}'
    const apiKey = process.env.CIRCULAR_API_KEY || null

    api = new CircularProtocolAPI(nagUrl, apiKey)

    console.log('🌐 Running E2E tests against:', nagUrl)
    console.log('📍 Test address:', process.env.CIRCULAR_TEST_ADDRESS)
    console.log('⛓️  Blockchain:', process.env.CIRCULAR_TEST_BLOCKCHAIN || '%{e2e_spec.required_env_vars.blockchain.default}')
    console.log('')
  })

  describe('Wallet API E2E Tests', () => {
%{wallet_tests}
  })

  describe('Network API E2E Tests', () => {
%{network_tests}
  })

  describe('Block API E2E Tests', () => {
%{block_tests}
  })
})
"%,
}
