# Integration Test Specifications
# Layer 3: Integration tests for generated SDKs against mock API server
# Input: Test scenarios for key API endpoints
# Output: Used by generators to create TypeScript/Python integration tests

let config = import "../../src/config.ncl" in
let types = import "../../src/schemas/types.ncl" in

{
  test_suite_name = "Circular Protocol SDK Integration Tests",
  description = "Integration tests for TypeScript and Python SDKs against mock API server",
  version = config.version,

  # Test address (64 chars without 0x prefix)
  test_address = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
  test_address_with_prefix = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",

  # Invalid address for error handling tests
  invalid_address = "invalid",

  # Test configuration
  mock_server_url = "http://localhost:8080",
  timeout_ms = 10000,

  # Wallet API Tests (5 tests)
  wallet_tests = {
    check_wallet = {
      description = "Should successfully check if wallet exists",
      endpoint = "checkWallet",
      request = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["exists", "address"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.exists", operator = "equals", value = true },
      ],
    },

    get_wallet = {
      description = "Should retrieve wallet details",
      endpoint = "getWallet",
      request = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["address", "balance", "nonce"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.address", operator = "isDefined", value = true },
      ],
    },

    get_wallet_balance = {
      description = "Should get wallet balance for specific asset",
      endpoint = "getWalletBalance",
      request = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Asset = "0xC123",
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["balance", "asset"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.balance", operator = "isDefined", value = true },
      ],
    },

    get_wallet_nonce = {
      description = "Should get current wallet nonce",
      endpoint = "getWalletNonce",
      request = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["nonce"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.nonce", operator = "greaterThanOrEqual", value = 0 },
      ],
    },

    get_latest_transactions = {
      description = "Should fetch recent transactions for wallet",
      endpoint = "getLatestTransactions",
      request = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Limit = 10,
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["transactions"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.transactions", operator = "isArray", value = true },
      ],
    },
  },

  # Network API Tests (1 test)
  network_tests = {
    get_blockchains = {
      description = "Should list supported blockchains",
      endpoint = "getBlockchains",
      request = {
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["blockchains"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.blockchains", operator = "isArray", value = true },
        { field = "Response.blockchains", operator = "arrayContains", value = "MainNet" },
      ],
    },
  },

  # Block API Tests (1 test)
  block_tests = {
    get_block_count = {
      description = "Should get current blockchain height",
      endpoint = "getBlockCount",
      request = {
        Blockchain = 'MainNet,
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["count"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.count", operator = "greaterThan", value = 0 },
      ],
    },
  },

  # Error Handling Tests (2 tests)
  error_handling_tests = {
    invalid_address = {
      description = "Should handle invalid address gracefully",
      endpoint = "checkWallet",
      request = {
        Blockchain = 'MainNet,
        Address = "invalid",
        Version = config.version,
      },
      expect_error = true,
      error_type = "ValidationError",
      error_message_contains = "invalid",
    },

    connection_error = {
      description = "Should handle network connection errors gracefully",
      endpoint = "checkWallet",
      # Use invalid URL to simulate connection error
      override_url = "http://localhost:9999",
      request = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Version = config.version,
      },
      expect_error = true,
      error_type = "NetworkError",
    },
  },

  # Test execution order
  test_order = [
    "network_tests.get_blockchains",
    "wallet_tests.check_wallet",
    "wallet_tests.get_wallet",
    "wallet_tests.get_wallet_balance",
    "wallet_tests.get_wallet_nonce",
    "wallet_tests.get_latest_transactions",
    "block_tests.get_block_count",
    "error_handling_tests.invalid_address",
    "error_handling_tests.connection_error",
  ],

  # Total expected tests
  total_tests = 9,
}
