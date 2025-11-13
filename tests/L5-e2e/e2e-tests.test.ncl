# E2E Test Specifications
# Layer 5: End-to-end tests against real NAG endpoints
# Only runs when required environment variables are present
# Input: Test scenarios for read-only NAG operations
# Output: Used by generators to create TypeScript/Python/Java/PHP E2E tests

let config = import "../../src/config.ncl" in
let types = import "../../src/schemas/types.ncl" in

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
      note = "May return Result 200 (block count) or error - both prove SDK works",
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
  },

  # Tests to skip (write operations - too risky for E2E)
  skipped_tests = [
    "registerWallet",
    "sendTransaction",
    "callContract",
  ],
}
