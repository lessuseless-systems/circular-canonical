# TypeScript E2E Test Generator
# Generates Jest E2E tests that run against real NAG endpoints
# Tests only execute when required environment variables are present

let config = import "../../../src/config.ncl" in
let e2e_spec = import "../../../tests/L5-e2e/read-operations/queries.test.ncl" in
let write_spec = import "../../../tests/L5-e2e/write-operations/transactions.test.ncl" in

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
  else if assertion.operator == "isHexString" then
    m%"    expect(typeof %{field_access} === 'string' && /^(0x)?[0-9a-fA-F]+$/.test(%{field_access})).toBe(true)"%
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

# Generate all transaction tests
let transaction_tests = std.string.join "\n\n" (
  std.array.map
    (fun kv => generate_e2e_test kv.field kv.value)
    (std.record.to_array e2e_spec.transaction_tests)
) in

# Generate all asset tests
let asset_tests = std.string.join "\n\n" (
  std.array.map
    (fun kv => generate_e2e_test kv.field kv.value)
    (std.record.to_array e2e_spec.asset_tests)
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

# Generate all domain tests
let domain_tests = std.string.join "\n\n" (
  std.array.map
    (fun kv => generate_e2e_test kv.field kv.value)
    (std.record.to_array e2e_spec.domain_tests)
) in

# Generate all contract tests
let contract_tests = std.string.join "\n\n" (
  std.array.map
    (fun kv => generate_e2e_test kv.field kv.value)
    (std.record.to_array e2e_spec.contract_tests)
) in

# Generate write operation test case
let generate_write_test = fun test_name test_def =>
  let method_name = to_camel_case test_def.endpoint in
  let assertions = std.array.map generate_assertion test_def.assertions in

  m%"
  test('%{test_def.description}', async () => {
    // Derive address and public key from private key
    const privateKey = process.env.CIRCULAR_PRIVATE_KEY!
    const publicKey = api.getPublicKey(privateKey)
    const address = api.hashString(publicKey)

    // Format timestamp
    const now = new Date()
    const timestamp = now.toISOString().replace(/T/, '-').replace(/\..+/, '').replace(/-/g, ':').substring(0, 19)

    const blockchain = process.env.CIRCULAR_TEST_BLOCKCHAIN || '%{write_spec.required_env_vars.blockchain.default}'

    %{if test_def.endpoint == "registerWallet" then
      m%"
    // Build registerWallet request
    const accountName = `E2E-Test-Wallet-${Date.now()}`
    const signaturePayload = blockchain + accountName + publicKey
    const signature = api.signMessage(signaturePayload, privateKey)

    const request = {
      Blockchain: blockchain,
      AccountName: accountName,
      PublicKey: publicKey,
      Signature: signature,
      Version: '%{config.version}'
    }

    console.log('  📝 Registering wallet:', accountName)
    const result = await api.%{method_name}(request)

%{std.string.join "\n" assertions}

    console.log('  ✅ Wallet registered successfully')
    console.log('  📍 Wallet Address:', result.Response?.WalletAddress)
    console.log('  🔗 Transaction ID:', result.Response?.TransactionID)
      "%
    else if test_def.endpoint == "sendTransaction" then
      m%"
    // Build certificate transaction request
    const fromWallet = address
    const toWallet = address
    const amount = '0'
    const transactionType = 'C_TYPE_CERTIFICATE'
    const voucher = ''
    const data = `E2E Test Data Certification ${Date.now()}`

    const signaturePayload = blockchain + fromWallet + toWallet + amount + transactionType + timestamp + voucher + data
    const signature = api.signMessage(signaturePayload, privateKey)

    const request = {
      Blockchain: blockchain,
      FromWallet: fromWallet,
      ToWallet: toWallet,
      Amount: amount,
      TransactionType: transactionType,
      Timestamp: timestamp,
      Voucher: voucher,
      Data: data,
      Signature: signature,
      Version: '%{config.version}'
    }

    console.log('  📝 Certifying data on blockchain...')
    const result = await api.%{method_name}(request)

%{std.string.join "\n" assertions}

    console.log('  ✅ Data certified successfully')
    console.log('  🔗 Transaction ID:', result.Response?.TransactionID)
    console.log('  📄 Certified data:', data)
      "%
    else if test_def.endpoint == "callContract" then
      m%"
    // Build callContract request
    const request = {
      Blockchain: blockchain,
      From: address,
      Address: '0x0000000000000000000000000000000000000000000000000000000000000000',
      Request: '0x74657374',
      Timestamp: timestamp,
      Version: '%{config.version}'
    }

    console.log('  📝 Calling smart contract function...')
    const result = await api.%{method_name}(request)

%{std.string.join "\n" assertions}

    console.log('  ✅ Contract call executed (may have failed if contract doesn\\'t exist)')
    console.log('  📊 Result:', result.Result)
      "%
    else
      m%"
    // Unknown write operation type
    throw new Error('Unknown write operation: %{test_def.endpoint}')
      "%
    }
  }, %{std.string.from_number write_spec.timeout_ms})
  "%
in

# Generate wallet write tests
let wallet_write_tests = std.string.join "\n\n" (
  std.array.map
    (fun kv => generate_write_test kv.field kv.value)
    (std.record.to_array write_spec.wallet_write_tests)
) in

# Generate transaction write tests
let transaction_write_tests = std.string.join "\n\n" (
  std.array.map
    (fun kv => generate_write_test kv.field kv.value)
    (std.record.to_array write_spec.transaction_write_tests)
) in

# Generate contract write tests
let contract_write_tests = std.string.join "\n\n" (
  std.array.map
    (fun kv => generate_write_test kv.field kv.value)
    (std.record.to_array write_spec.contract_write_tests)
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
 *   CIRCULAR_TEST_ADDRESS=0x... npm run test:e2e
 *
 * Run write operation tests with:
 *   CIRCULAR_PRIVATE_KEY=... npm run test:e2e
 *   ⚠️  WARNING: This will create real transactions on the blockchain!
 *
 * Or skip if ENV vars not present:
 *   npm run test:e2e  # Will skip all tests
 */

import { CircularProtocolAPI } from '../src/index'

// Check for read-only test environment variables
const READ_ENV_VARS = ['CIRCULAR_TEST_ADDRESS']
const missingReadEnvVars = READ_ENV_VARS.filter(v => !process.env[v])

// Check for write test environment variables
const WRITE_ENV_VARS = ['CIRCULAR_PRIVATE_KEY']
const missingWriteEnvVars = WRITE_ENV_VARS.filter(v => !process.env[v])

const hasReadEnv = missingReadEnvVars.length === 0
const hasWriteEnv = missingWriteEnvVars.length === 0

if (!hasReadEnv && !hasWriteEnv) {
  console.log('⏭️  Skipping all E2E tests - missing required environment variables')
  console.log('\nFor read-only tests:')
  console.log('  CIRCULAR_TEST_ADDRESS=0x... npm run test:e2e')
  console.log('\nFor write operation tests:')
  console.log('  CIRCULAR_PRIVATE_KEY=... npm run test:e2e')
  console.log('  ⚠️  WARNING: Write tests create real blockchain transactions!')
  process.exit(0)
}

describe('E2E Tests - Real NAG Endpoints', () => {
  let api: CircularProtocolAPI

  beforeAll(() => {
    const nagUrl = process.env.CIRCULAR_NAG_URL || '%{e2e_spec.required_env_vars.nag_url.default}'
    const apiKey = process.env.CIRCULAR_API_KEY || null

    api = new CircularProtocolAPI(nagUrl, apiKey)

    console.log('🌐 Running E2E tests against:', nagUrl)
    if (hasReadEnv) {
      console.log('📍 Test address:', process.env.CIRCULAR_TEST_ADDRESS)
    }
    if (hasWriteEnv) {
      console.log('🔑 Private key: ***REDACTED***')
    }
    console.log('⛓️  Blockchain:', process.env.CIRCULAR_TEST_BLOCKCHAIN || '%{e2e_spec.required_env_vars.blockchain.default}')
    console.log('')
  })

  // Read-only E2E tests (require CIRCULAR_TEST_ADDRESS)
  if (hasReadEnv) {
    describe('Wallet API E2E Tests (Read-Only)', () => {
%{wallet_tests}
    })

    describe('Transaction API E2E Tests (Read-Only)', () => {
%{transaction_tests}
    })

    describe('Asset API E2E Tests (Read-Only)', () => {
%{asset_tests}
    })

    describe('Network API E2E Tests (Read-Only)', () => {
%{network_tests}
    })

    describe('Block API E2E Tests (Read-Only)', () => {
%{block_tests}
    })

    describe('Domain API E2E Tests (Read-Only)', () => {
%{domain_tests}
    })

    describe('Contract API E2E Tests (Read-Only)', () => {
%{contract_tests}
    })
  } else {
    describe('Read-Only E2E Tests', () => {
      test.skip('Skipped - CIRCULAR_TEST_ADDRESS not set', () => {})
    })
  }

  // Write operation E2E tests (require CIRCULAR_PRIVATE_KEY)
  if (hasWriteEnv) {
    describe('⚠️  Write Operations E2E Tests (LIVE BLOCKCHAIN)', () => {
      console.warn('⚠️  WARNING: Write operation tests will create REAL transactions on the blockchain!')
      console.warn('⚠️  Ensure you are using a test blockchain and test funds.')

%{wallet_write_tests}

%{transaction_write_tests}

%{contract_write_tests}
    })
  } else {
    describe('Write Operations E2E Tests', () => {
      test.skip('Skipped - CIRCULAR_PRIVATE_KEY not set (write operations require private key)', () => {})
    })
  }
})
"%,
}
