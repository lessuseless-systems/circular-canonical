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

    register_wallet = {
      description = "Should register a new wallet",
      endpoint = "registerWallet",
      request = {
        Blockchain = 'MainNet,
        Address = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
        PublicKey = "0x04abcdef1234567890",
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["success", "address"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.success", operator = "equals", value = true },
      ],
    },
  },

  # Transaction API Tests (6 tests)
  transaction_tests = {
    send_transaction = {
      description = "Should submit a transaction to blockchain",
      endpoint = "sendTransaction",
      request = {
        ID = "0xaabbccdd11223344",
        From = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        To = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
        Timestamp = "1234567890",
        Type = "transfer",
        Payload = "0x1234",
        Nonce = 1,
        Signature = "0xsignature",
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["transaction_id"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.transaction_id", operator = "isDefined", value = true },
      ],
    },

    get_pending_transaction = {
      description = "Should get pending transactions",
      endpoint = "getPendingTransaction",
      request = {
        Blockchain = 'MainNet,
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["transactions"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.transactions", operator = "isArray", value = true },
      ],
    },

    get_transaction_by_id = {
      description = "Should get transaction by ID",
      endpoint = "getTransactionbyID",
      request = {
        Blockchain = 'MainNet,
        TransactionID = "0xaabbccdd11223344",
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["transaction"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.transaction", operator = "isDefined", value = true },
      ],
    },

    get_transaction_by_node = {
      description = "Should get transactions by node",
      endpoint = "getTransactionbyNode",
      request = {
        Blockchain = 'MainNet,
        Node = "0xnode123",
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["transactions"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.transactions", operator = "isArray", value = true },
      ],
    },

    get_transaction_by_address = {
      description = "Should get transactions by address",
      endpoint = "getTransactionbyAddress",
      request = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["transactions"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.transactions", operator = "isArray", value = true },
      ],
    },

    get_transaction_by_date = {
      description = "Should get transactions by date range",
      endpoint = "getTransactionbyDate",
      request = {
        Blockchain = 'MainNet,
        StartDate = "2024-01-01",
        EndDate = "2024-12-31",
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

  # Asset API Tests (4 tests)
  asset_tests = {
    get_asset_list = {
      description = "Should get list of all assets",
      endpoint = "getAssetList",
      request = {
        Blockchain = 'MainNet,
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["assets"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.assets", operator = "isArray", value = true },
      ],
    },

    get_asset = {
      description = "Should get asset details",
      endpoint = "getAsset",
      request = {
        Blockchain = 'MainNet,
        Asset = "0xC123",
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["asset", "name", "symbol"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.asset", operator = "isDefined", value = true },
      ],
    },

    get_asset_supply = {
      description = "Should get asset supply information",
      endpoint = "getAssetSupply",
      request = {
        Blockchain = 'MainNet,
        Asset = "0xC123",
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["total_supply", "circulating_supply"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.total_supply", operator = "isDefined", value = true },
      ],
    },

    get_voucher = {
      description = "Should get voucher details",
      endpoint = "getVoucher",
      request = {
        Blockchain = 'MainNet,
        VoucherID = "0xvoucher123",
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["voucher"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.voucher", operator = "isDefined", value = true },
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

  # Block API Tests (4 tests)
  block_tests = {
    get_block = {
      description = "Should get block by number",
      endpoint = "getBlock",
      request = {
        Blockchain = 'MainNet,
        Block = 12345,
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["block", "transactions"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.block", operator = "isDefined", value = true },
      ],
    },

    get_block_range = {
      description = "Should get range of blocks",
      endpoint = "getBlockRange",
      request = {
        Blockchain = 'MainNet,
        StartBlock = 10000,
        EndBlock = 10010,
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["blocks"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.blocks", operator = "isArray", value = true },
      ],
    },

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

    get_analytics = {
      description = "Should get blockchain analytics",
      endpoint = "getAnalytics",
      request = {
        Blockchain = 'MainNet,
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["analytics"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.analytics", operator = "isDefined", value = true },
      ],
    },
  },

  # Smart Contract API Tests (2 tests)
  contract_tests = {
    test_contract = {
      description = "Should test contract execution (dry run)",
      endpoint = "testContract",
      request = {
        Blockchain = 'MainNet,
        ContractAddress = "0xcontract123",
        Method = "transfer",
        Parameters = ["0xrecipient", "1000"],
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["result", "gas_estimate"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.result", operator = "isDefined", value = true },
      ],
    },

    call_contract = {
      description = "Should call contract method",
      endpoint = "callContract",
      request = {
        Blockchain = 'MainNet,
        ContractAddress = "0xcontract123",
        Method = "balanceOf",
        Parameters = ["0xwallet123"],
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["result"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.result", operator = "isDefined", value = true },
      ],
    },
  },

  # Domain API Tests (1 test)
  domain_tests = {
    get_domain = {
      description = "Should resolve domain to address",
      endpoint = "getDomain",
      request = {
        Blockchain = 'MainNet,
        Domain = "myname.circular",
        Version = config.version,
      },
      expected_result = 200,
      expected_fields = ["address"],
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.address", operator = "isDefined", value = true },
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

  # Test execution order (grouped by API domain)
  test_order = [
    # Network
    "network_tests.get_blockchains",
    # Wallet
    "wallet_tests.check_wallet",
    "wallet_tests.get_wallet",
    "wallet_tests.get_wallet_balance",
    "wallet_tests.get_wallet_nonce",
    "wallet_tests.get_latest_transactions",
    "wallet_tests.register_wallet",
    # Transaction
    "transaction_tests.send_transaction",
    "transaction_tests.get_pending_transaction",
    "transaction_tests.get_transaction_by_id",
    "transaction_tests.get_transaction_by_node",
    "transaction_tests.get_transaction_by_address",
    "transaction_tests.get_transaction_by_date",
    # Asset
    "asset_tests.get_asset_list",
    "asset_tests.get_asset",
    "asset_tests.get_asset_supply",
    "asset_tests.get_voucher",
    # Block
    "block_tests.get_block",
    "block_tests.get_block_range",
    "block_tests.get_block_count",
    "block_tests.get_analytics",
    # Contract
    "contract_tests.test_contract",
    "contract_tests.call_contract",
    # Domain
    "domain_tests.get_domain",
    # Error Handling
    "error_handling_tests.invalid_address",
    "error_handling_tests.connection_error",
  ],

  # Total expected tests (24 endpoint tests + 2 error handling tests)
  total_tests = 26,
}
