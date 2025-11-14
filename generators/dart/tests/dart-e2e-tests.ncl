# Dart E2E Test Generator
# Generates Dart E2E tests that run against real NAG endpoints
# Tests only execute when required environment variables are present

let config = import "../../../src/config.ncl" in
let e2e_spec = import "../../../tests/L5-e2e/read-operations/queries.test.ncl" in
let write_spec = import "../../../tests/L5-e2e/write-operations/transactions.test.ncl" in

# Generate Dart method name from endpoint name (camelCase)
let to_camel_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  (std.string.lowercase first_char) ++ rest
in

# Generate assertion code based on operator
let generate_assertion = fun assertion =>
  let field_access = "result['" ++ assertion.field ++ "']" in

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
  else if assertion.operator == "greaterThan" then
    m%"      expect(%{field_access} as int, greaterThan(%{std.string.from_number assertion.value}));"%
  else if assertion.operator == "isHexString" then
    m%"      expect(%{field_access} is String && RegExp(r'^(0x)?[0-9a-fA-F]+$').hasMatch(%{field_access} as String), isTrue);"%
  else
    m%"      // Unknown operator: %{assertion.operator}"%
in

# Substitute environment variables in request template
# Escape $ characters so Dart doesn't try to interpolate them
let substitute_env_vars = fun template =>
  let json_str = std.serialize 'Json template in
  # Replace ${VAR} with \${VAR} to escape for Dart string interpolation
  let step1 = std.string.replace "${CIRCULAR_TEST_ADDRESS}" "\\${CIRCULAR_TEST_ADDRESS}" json_str in
  let step2 = std.string.replace "${CIRCULAR_TEST_BLOCKCHAIN}" "\\${CIRCULAR_TEST_BLOCKCHAIN}" step1 in
  let step3 = std.string.replace "${CIRCULAR_NAG_URL}" "\\${CIRCULAR_NAG_URL}" step2 in
  let step4 = std.string.replace "${CIRCULAR_API_KEY}" "\\${CIRCULAR_API_KEY}" step3 in
  step4
in

# Generate E2E test case
let generate_e2e_test = fun test_name test_def =>
  let method_name = to_camel_case test_def.endpoint in
  let request_template = substitute_env_vars test_def.request_template in
  let assertions = std.array.map generate_assertion test_def.assertions in

  m%"
  test('%{test_def.description}', () async {
    final requestJson = '''%{request_template}'''
        .replaceAll('\${CIRCULAR_TEST_ADDRESS}', Platform.environment['CIRCULAR_TEST_ADDRESS'] ?? '')
        .replaceAll('\${CIRCULAR_TEST_BLOCKCHAIN}', Platform.environment['CIRCULAR_TEST_BLOCKCHAIN'] ?? '%{e2e_spec.required_env_vars.blockchain.default}');

    final request = jsonDecode(requestJson) as Map<String, dynamic>;

    final result = await api.%{method_name}(request);

%{std.string.join "\n" assertions}

    print('  ✅ %{test_def.description}');
  }, timeout: Timeout(Duration(milliseconds: %{std.string.from_number e2e_spec.timeout_ms})));
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

# Count all tests
let wallet_count = std.array.length (std.record.to_array e2e_spec.wallet_tests) in
let transaction_count = std.array.length (std.record.to_array e2e_spec.transaction_tests) in
let asset_count = std.array.length (std.record.to_array e2e_spec.asset_tests) in
let network_count = std.array.length (std.record.to_array e2e_spec.network_tests) in
let block_count = std.array.length (std.record.to_array e2e_spec.block_tests) in
let domain_count = std.array.length (std.record.to_array e2e_spec.domain_tests) in
let contract_count = std.array.length (std.record.to_array e2e_spec.contract_tests) in

let total_tests = wallet_count + transaction_count + asset_count + network_count + block_count + domain_count + contract_count in

# Assemble complete test file
{
  test_code = m%"
/// Circular Protocol E2E Tests (Layer 5)
/// Tests against real NAG endpoints when environment variables are present
///
/// Required environment variables:
/// - CIRCULAR_TEST_ADDRESS: Wallet address for testing (required)
/// - CIRCULAR_TEST_BLOCKCHAIN: Blockchain hash or name (default: MainNet)
///
/// Optional:
/// - CIRCULAR_NAG_URL: Custom NAG endpoint URL
///
/// Usage:
/// ```bash
/// export CIRCULAR_TEST_ADDRESS="0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310"
/// export CIRCULAR_TEST_BLOCKCHAIN="MainNet"
/// dart test test/e2e_test.dart
/// ```
library e2e_test;

import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import '../lib/circular_protocol.dart';

late CircularProtocolAPI api;

void main() {
  // Check for required environment variables
  final testAddress = Platform.environment['CIRCULAR_TEST_ADDRESS'];

  if (testAddress == null || testAddress.isEmpty) {
    print('⏭️  Skipping E2E tests: CIRCULAR_TEST_ADDRESS not set');
    print('');
    print('To run E2E tests, set:');
    print('  export CIRCULAR_TEST_ADDRESS="0x..."');
    print('  export CIRCULAR_TEST_BLOCKCHAIN="MainNet"  # optional');
    return;
  }

  setUpAll(() {
    final nagUrl = Platform.environment['CIRCULAR_NAG_URL'] ??
                   'https://nag.circularlabs.io/NAG.php?cep=';

    api = CircularProtocolAPI(nagUrl: nagUrl);

    print('');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🌐 E2E Tests - Live NAG Endpoint');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Version: %{config.version}');
    print('Endpoint: $nagUrl');
    print('Test Address: $testAddress');
    print('Total tests: %{std.string.from_number total_tests}');
    print('');
  });

  tearDownAll(() {
    api.dispose();
  });

  group('Wallet Operations', () {
%{wallet_tests}
  });

  group('Transaction Operations', () {
%{transaction_tests}
  });

  group('Asset Operations', () {
%{asset_tests}
  });

  group('Network Operations', () {
%{network_tests}
  });

  group('Block Operations', () {
%{block_tests}
  });

  group('Domain Operations', () {
%{domain_tests}
  });

  group('Contract Operations', () {
%{contract_tests}
  });
}
"%,

  # Metadata
  metadata = {
    version = config.version,
    test_count = total_tests,
    language = "Dart",
    test_framework = "test",
    description = "E2E tests against real NAG endpoints (Layer 5)",
  },
}
