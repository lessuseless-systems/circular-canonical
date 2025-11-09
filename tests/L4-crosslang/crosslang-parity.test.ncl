# Cross-Language Parity Test Specifications
# Layer 4a: Validates that TypeScript and Python SDKs produce identical behavior
# Input: Test scenarios for verifying SDK parity across languages
# Output: Used by cross-lang validator generator

let config = import "../../src/config.ncl" in
let types = import "../../src/schemas/types.ncl" in

{
  test_suite_name = "Cross-Language SDK Parity Tests",
  description = "Validates TypeScript and Python SDKs produce identical results for same inputs",
  version = config.version,

  # Test configuration
  mock_server_url = "http://localhost:8080",
  timeout_ms = 10000,

  # Test wallet addresses
  test_address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",

  # Parity test scenarios - each test runs in BOTH TypeScript and Python
  # Results must be identical for test to pass
  parity_tests = {
    wallet_check_parity = {
      description = "checkWallet returns identical results in TS and Python",
      endpoint = "checkWallet",
      method_name_ts = "checkWallet",
      method_name_py = "check_wallet",
      request = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Version = config.version,
      },
      compare_fields = ["Result", "Response.exists", "Response.address"],
    },

    get_wallet_parity = {
      description = "getWallet returns identical results in TS and Python",
      endpoint = "getWallet",
      method_name_ts = "getWallet",
      method_name_py = "get_wallet",
      request = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Version = config.version,
      },
      compare_fields = ["Result", "Response.address", "Response.balance", "Response.nonce"],
    },

    get_wallet_balance_parity = {
      description = "getWalletBalance returns identical results in TS and Python",
      endpoint = "getWalletBalance",
      method_name_ts = "getWalletBalance",
      method_name_py = "get_wallet_balance",
      request = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Asset = "0xC123",
        Version = config.version,
      },
      compare_fields = ["Result", "Response.balance", "Response.asset"],
    },

    get_wallet_nonce_parity = {
      description = "getWalletNonce returns identical results in TS and Python",
      endpoint = "getWalletNonce",
      method_name_ts = "getWalletNonce",
      method_name_py = "get_wallet_nonce",
      request = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Version = config.version,
      },
      compare_fields = ["Result", "Response.nonce"],
    },

    get_latest_transactions_parity = {
      description = "getLatestTransactions returns identical results in TS and Python",
      endpoint = "getLatestTransactions",
      method_name_ts = "getLatestTransactions",
      method_name_py = "get_latest_transactions",
      request = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Limit = 10,
        Version = config.version,
      },
      compare_fields = ["Result", "Response.transactions"],
    },

    get_blockchains_parity = {
      description = "getBlockchains returns identical results in TS and Python",
      endpoint = "getBlockchains",
      method_name_ts = "getBlockchains",
      method_name_py = "get_blockchains",
      request = {
        Version = config.version,
      },
      compare_fields = ["Result", "Response.blockchains"],
    },

    get_block_count_parity = {
      description = "getBlockCount returns identical results in TS and Python",
      endpoint = "getBlockCount",
      method_name_ts = "getBlockCount",
      method_name_py = "get_block_count",
      request = {
        Blockchain = 'MainNet,
        Version = config.version,
      },
      compare_fields = ["Result", "Response.count"],
    },

    get_asset_parity = {
      description = "getAsset returns identical results in TS and Python",
      endpoint = "getAsset",
      method_name_ts = "getAsset",
      method_name_py = "get_asset",
      request = {
        Blockchain = 'MainNet,
        Asset = "0xC123",
        Version = config.version,
      },
      compare_fields = ["Result", "Response.asset", "Response.name", "Response.symbol"],
    },

    get_block_parity = {
      description = "getBlock returns identical results in TS and Python",
      endpoint = "getBlock",
      method_name_ts = "getBlock",
      method_name_py = "get_block",
      request = {
        Blockchain = 'MainNet,
        Block = 12345,
        Version = config.version,
      },
      compare_fields = ["Result", "Response.block", "Response.transactions"],
    },
  },

  # Test execution configuration
  languages = ["typescript", "python"],

  # Expected test results
  total_tests = 9,

  # Comparison strictness
  comparison_mode = "deep_equals",  # Options: "deep_equals", "structural", "fuzzy"

  # Fields to ignore in comparison (e.g., timestamps that vary)
  ignore_fields = [],
}
