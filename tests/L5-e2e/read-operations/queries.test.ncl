# E2E Test Specifications
# Layer 5: End-to-end tests against real NAG endpoints
# Only runs when required environment variables are present
# Input: Test scenarios for read-only NAG operations
# Output: Used by generators to create TypeScript/Python/Java/PHP E2E tests

let config = import "../../../src/config.ncl" in
let types = import "../../../src/schemas/types.ncl" in

{
  test_suite_name = "Circular Protocol E2E Tests",
  description = "End-to-end tests against real NAG endpoints (read-only operations)",
  version = config.version,

  # Required environment variables
  required_env_vars = {
    nag_url = {
      name = "CIRCULAR_NAG_URL",
      description = "NAG endpoint URL (e.g., https://nag.circularlabs.io/NAG.php?cep=)",
      default = "https://nag.circularlabs.io/NAG.php?cep=",
    },
    test_address = {
      name = "CIRCULAR_TEST_ADDRESS",
      description = "Test wallet address (must exist on blockchain)",
      required = true,
    },
    blockchain = {
      name = "CIRCULAR_TEST_BLOCKCHAIN",
      description = "Blockchain network to test against (default: Circular SandBox for testing)",
      default = "0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5ad72b2",
    },
  },

  # Optional environment variables
  optional_env_vars = {
    api_key = {
      name = "CIRCULAR_API_KEY",
      description = "Optional API key for authenticated requests",
    },
    timeout_ms = {
      name = "CIRCULAR_E2E_TIMEOUT",
      description = "Request timeout in milliseconds",
      default = "30000",
    },
  },

  # Test configuration
  timeout_ms = 30000,
  retry_attempts = 2,
  retry_delay_ms = 1000,

  # E2E Tests (read-only operations only)
  wallet_tests = {
    check_wallet = {
      description = "E2E: Check if test wallet exists on blockchain",
      endpoint = "checkWallet",
      requires_env = ["CIRCULAR_TEST_ADDRESS"],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        Address = "${CIRCULAR_TEST_ADDRESS}",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "May return Result 200 (exists) or error (wallet not found) - both prove SDK works",
    },

    get_wallet = {
      description = "E2E: Retrieve wallet details from blockchain",
      endpoint = "getWallet",
      requires_env = ["CIRCULAR_TEST_ADDRESS"],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        Address = "${CIRCULAR_TEST_ADDRESS}",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "May return Result 200 (data) or error (wallet not found) - both prove SDK works",
    },

    get_wallet_balance = {
      description = "E2E: Get wallet balance from blockchain",
      endpoint = "getWalletBalance",
      requires_env = ["CIRCULAR_TEST_ADDRESS"],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        Address = "${CIRCULAR_TEST_ADDRESS}",
        Asset = "CIRX",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "May return Result 200 (balance data) or error (wallet not found) - both prove SDK works",
    },

    get_wallet_nonce = {
      description = "E2E: Get wallet nonce from blockchain",
      endpoint = "getWalletNonce",
      requires_env = ["CIRCULAR_TEST_ADDRESS"],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        Address = "${CIRCULAR_TEST_ADDRESS}",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "May return Result 200 (nonce data) or error (wallet not found) - both prove SDK works",
    },

    get_latest_transactions = {
      description = "E2E: Get latest transactions for wallet",
      endpoint = "getLatestTransactions",
      requires_env = ["CIRCULAR_TEST_ADDRESS"],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        Address = "${CIRCULAR_TEST_ADDRESS}",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "May return empty array (no transactions) or populated array - both valid",
    },
  },

  # Transaction API E2E Tests (read-only query operations)
  transaction_tests = {
    get_transaction_by_id = {
      description = "E2E: Get transaction by transaction ID",
      endpoint = "getTransactionbyID",
      requires_env = [],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        TransactionID = "0x0000000000000000000000000000000000000000000000000000000000000000",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "Test with dummy transaction ID - may return 404, which proves SDK works",
    },

    get_transaction_by_node = {
      description = "E2E: Get transactions by node ID",
      endpoint = "getTransactionbyNode",
      requires_env = [],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        NodeID = "node-0001",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "Test with dummy node ID - may return empty array, which is valid",
    },

    get_transaction_by_address = {
      description = "E2E: Get transactions by wallet address",
      endpoint = "getTransactionbyAddress",
      requires_env = ["CIRCULAR_TEST_ADDRESS"],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        Address = "${CIRCULAR_TEST_ADDRESS}",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "May return empty array or transactions - both valid",
    },

    get_transaction_by_date = {
      description = "E2E: Get transactions by date range",
      endpoint = "getTransactionbyDate",
      requires_env = [],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        StartDate = "2024-01-01",
        EndDate = "2024-12-31",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "Test with date range - may return empty array, which is valid",
    },

    get_pending_transaction = {
      description = "E2E: Get pending transactions",
      endpoint = "getPendingTransaction",
      requires_env = [],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "May return empty array (no pending txs) - valid response",
    },
  },

  # Asset API E2E Tests
  asset_tests = {
    get_asset_list = {
      description = "E2E: Get list of all assets on blockchain",
      endpoint = "getAssetList",
      requires_env = [],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "Returns array of assets - may be empty on test blockchain",
    },

    get_asset = {
      description = "E2E: Get specific asset information",
      endpoint = "getAsset",
      requires_env = [],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        AssetName = "CIRX",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "Tests with CIRX (native asset) - should exist on all blockchains",
    },

    get_asset_supply = {
      description = "E2E: Get asset supply information",
      endpoint = "getAssetSupply",
      requires_env = [],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        AssetName = "CIRX",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "Tests supply info for CIRX native asset",
    },

    get_voucher = {
      description = "E2E: Get voucher details",
      endpoint = "getVoucher",
      requires_env = [],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        VoucherID = "test-voucher-id",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "Tests with dummy voucher ID - 404 response is valid",
    },
  },

  network_tests = {
    get_blockchains = {
      description = "E2E: Retrieve list of available blockchains",
      endpoint = "getBlockchains",
      requires_env = [],
      request_template = {
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.Blockchains", operator = "isArray", value = true },
      ],
    },
  },

  block_tests = {
    get_block_count = {
      description = "E2E: Get current block count from blockchain",
      endpoint = "getBlockCount",
      requires_env = [],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "Returns blockchain height (also known as getBlockHeight)",
    },

    get_block = {
      description = "E2E: Retrieve specific block by number",
      endpoint = "getBlock",
      requires_env = [],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        BlockNumber = 1,
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "May return Result 200 (block data) or error - both prove SDK works",
    },

    get_block_range = {
      description = "E2E: Retrieve range of blocks",
      endpoint = "getBlockRange",
      requires_env = [],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        StartBlock = 1,
        EndBlock = 10,
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "Tests block range query - may return partial range if blockchain is short",
    },

    get_analytics = {
      description = "E2E: Get blockchain analytics and statistics",
      endpoint = "getAnalytics",
      requires_env = [],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "Returns comprehensive blockchain statistics - transactions, wallets, assets, height",
    },
  },

  # Domain API E2E Tests
  domain_tests = {
    get_domain = {
      description = "E2E: Resolve domain name to wallet address",
      endpoint = "getDomain",
      requires_env = [],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        Domain = "test.circular",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "Tests with dummy domain - 404 response (domain not found) is valid (also known as resolveDomain)",
    },
  },

  # Contract API E2E Tests (read-only testContract)
  contract_tests = {
    test_contract = {
      description = "E2E: Test smart contract execution (simulation)",
      endpoint = "testContract",
      requires_env = [],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        ContractAddress = "0x0000000000000000000000000000000000000000000000000000000000000000",
        Method = "testMethod",
        Parameters = "{}",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      note = "Tests contract simulation with dummy contract - error response is valid",
    },
  },

  # Tests to skip (write operations - too risky for E2E)
  skipped_tests = [
    "registerWallet",
    "sendTransaction",
    "callContract",
  ],
}
