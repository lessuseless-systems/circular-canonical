# Write Operations E2E Test Specifications
# Layer 5: End-to-end tests for write operations against live blockchain
# Only runs when CIRCULAR_PRIVATE_KEY environment variable is present
# Input: Test scenarios for write NAG operations (registerWallet, sendTransaction)
# Output: Used by generators to create TypeScript/Python/Java/PHP write E2E tests

let config = import "../../../src/config.ncl" in
let types = import "../../../src/schemas/types.ncl" in

{
  test_suite_name = "Circular Protocol Write Operations E2E Tests",
  description = "End-to-end tests for write operations against live blockchain (registerWallet, certifyData)",
  version = config.version,

  # Required environment variables for write operations
  required_env_vars = {
    nag_url = {
      name = "CIRCULAR_NAG_URL",
      description = "NAG endpoint URL (e.g., https://nag.circularlabs.io/NAG.php?cep=)",
      default = "https://nag.circularlabs.io/NAG.php?cep=",
    },
    private_key = {
      name = "CIRCULAR_PRIVATE_KEY",
      description = "Private key for signing transactions (32-byte hex, with or without 0x prefix)",
      required = true,
      security_note = "NEVER commit this value. Use environment variable only.",
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
      description = "Request timeout in milliseconds (write operations may take longer)",
      default = "60000",
    },
  },

  # Test configuration
  timeout_ms = 60000,
  retry_attempts = 1,
  retry_delay_ms = 2000,

  # Safety configuration
  safety = {
    skip_if_no_private_key = true,
    warn_before_execution = true,
    log_transaction_ids = true,
    require_sandbox_blockchain = false,
    warning_message = "⚠️  Write operations will create real transactions on the blockchain. Ensure you are using a test blockchain and test funds.",
  },

  # Write Operation Tests
  wallet_write_tests = {
    register_wallet = {
      description = "E2E Write: Register a new wallet on the blockchain",
      endpoint = "registerWallet",
      operation_type = "write",
      requires_env = ["CIRCULAR_PRIVATE_KEY", "CIRCULAR_TEST_BLOCKCHAIN"],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        AccountName = "E2E-Test-Wallet-${TIMESTAMP}",
        PublicKey = "${DERIVED_PUBLIC_KEY}",
        Signature = "${COMPUTED_SIGNATURE}",
        Version = config.version,
      },
      signature_payload = {
        Description = "Signature payload for registerWallet operation",
        Fields = ["Blockchain", "AccountName", "PublicKey"],
        Format = "Blockchain + AccountName + PublicKey",
      },
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.WalletAddress", operator = "isDefined", value = true },
        { field = "Response.WalletAddress", operator = "isHexString", value = true },
        { field = "Response.TransactionID", operator = "isDefined", value = true },
      ],
      success_criteria = {
        Result_200 = "Wallet registered successfully",
        Transaction_ID_returned = "Blockchain confirmed transaction",
        Wallet_Address_returned = "New wallet address assigned",
      },
      note = "Creates a new wallet on the blockchain. Requires valid DER-encoded ECDSA signature.",
    },
  },

  transaction_write_tests = {
    certify_data = {
      description = "E2E Write: Certify data on the blockchain (C_TYPE_CERTIFICATE)",
      endpoint = "sendTransaction",
      operation_type = "write",
      transaction_type = "C_TYPE_CERTIFICATE",
      requires_env = ["CIRCULAR_PRIVATE_KEY", "CIRCULAR_TEST_BLOCKCHAIN"],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        FromWallet = "${DERIVED_ADDRESS}",
        ToWallet = "${DERIVED_ADDRESS}",
        Amount = "0",
        TransactionType = "C_TYPE_CERTIFICATE",
        Timestamp = "${FORMATTED_TIMESTAMP}",
        Voucher = "",
        Data = "E2E Test Data Certification ${TIMESTAMP}",
        Signature = "${COMPUTED_SIGNATURE}",
        Version = config.version,
      },
      signature_payload = {
        Description = "Signature payload for certificate transaction",
        Fields = [
          "Blockchain",
          "FromWallet",
          "ToWallet",
          "Amount",
          "TransactionType",
          "Timestamp",
          "Voucher",
          "Data",
        ],
        Format = "Blockchain + FromWallet + ToWallet + Amount + TransactionType + Timestamp + Voucher + Data",
      },
      assertions = [
        { field = "Result", operator = "equals", value = 200 },
        { field = "Response.TransactionID", operator = "isDefined", value = true },
        { field = "Response.TransactionID", operator = "isHexString", value = true },
      ],
      success_criteria = {
        Result_200 = "Data certified successfully",
        Transaction_ID_returned = "Blockchain confirmed certification",
        Data_immutable = "Certificate permanently recorded on blockchain",
      },
      note = "Creates a certificate transaction on the blockchain. Proves SDK can create valid DER-encoded signatures.",
      reference = {
        Proven_Python_TX_1 = "0xf6c83ca16bc0d63d73767359e7db94958b9a78deac6c466d63acf0c920604f66",
        Proven_Python_TX_2 = "21c7b039b5d62c4bc7a1ce6ab5a8aeeb7e396aa57eab953ce954cf7c510520fa",
        Documentation = "docs/CERTIFICATE_TRANSACTIONS.md",
      },
    },
  },

  contract_write_tests = {
    call_contract = {
      description = "E2E Write: Call smart contract function on blockchain",
      endpoint = "callContract",
      operation_type = "write",
      requires_env = ["CIRCULAR_PRIVATE_KEY", "CIRCULAR_TEST_BLOCKCHAIN"],
      request_template = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        From = "${DERIVED_ADDRESS}",
        Address = "0x0000000000000000000000000000000000000000000000000000000000000000",
        Request = "0x74657374",
        Timestamp = "${FORMATTED_TIMESTAMP}",
        Version = config.version,
      },
      assertions = [
        { field = "Result", operator = "isDefined", value = true },
      ],
      success_criteria = {
        Result_defined = "Contract call executed (may fail if contract doesn't exist)",
        SDK_correctly_formatted = "Request properly formatted and sent to blockchain",
      },
      note = "Calls a smart contract function. Uses dummy contract address for testing. May return error if contract doesn't exist, which is expected.",
      warning = "This is a WRITE operation that can modify blockchain state. Only use with test contracts on test blockchain.",
    },
  },

  # Validation helper functions (for generators to implement)
  helper_functions = {
    derive_address = {
      description = "Derive wallet address from private key using secp256k1",
      inputs = ["private_key"],
      outputs = ["address"],
      algorithm = "SHA256(PublicKey)",
      format = "64-byte hex (no 0x prefix)",
    },
    derive_public_key = {
      description = "Derive public key from private key using secp256k1",
      inputs = ["private_key"],
      outputs = ["public_key"],
      format = "Uncompressed 64-byte hex (no 0x04 prefix)",
    },
    sign_message = {
      description = "Create DER-encoded ECDSA signature",
      inputs = ["message", "private_key"],
      outputs = ["signature"],
      algorithm = "ECDSA secp256k1 with SHA256 hash, DER encoding",
      format = "DER-encoded hex string",
    },
    format_timestamp = {
      description = "Format timestamp for Circular Protocol",
      inputs = [],
      outputs = ["timestamp"],
      format = "YYYY:MM:DD-HH:MM:SS (UTC)",
    },
  },

  # Test execution order
  execution_order = [
    {
      test_name = "register_wallet",
      prerequisite = "None",
      creates = "New wallet address",
      note = "Run first to create wallet for subsequent tests",
    },
    {
      test_name = "certify_data",
      prerequisite = "Wallet must exist (from register_wallet or pre-existing)",
      creates = "Certificate transaction",
      note = "Can use newly registered wallet or existing test wallet",
    },
    {
      test_name = "call_contract",
      prerequisite = "Wallet must exist (from register_wallet or pre-existing)",
      creates = "Smart contract execution attempt",
      note = "Uses dummy contract address - expected to fail gracefully if contract doesn't exist",
    },
  ],

  # Expected outcomes for all languages
  expected_outcomes = {
    TypeScript = {
      status = "TODO",
      last_validated = "Never",
      transaction_ids = [],
    },
    Python = {
      status = "PROVEN",
      last_validated = "2025-11-13",
      transaction_ids = [
        "0xf6c83ca16bc0d63d73767359e7db94958b9a78deac6c466d63acf0c920604f66",
        "21c7b039b5d62c4bc7a1ce6ab5a8aeeb7e396aa57eab953ce954cf7c510520fa",
      ],
    },
    Java = {
      status = "TODO",
      last_validated = "Never",
      transaction_ids = [],
    },
    PHP = {
      status = "TODO",
      last_validated = "Never",
      transaction_ids = [],
    },
  },
}
