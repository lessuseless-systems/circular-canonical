# Manual Test Specifications
# Layer 5: Manual tests for write operations on live blockchain
# REQUIRES: User credentials (CIRCULAR_PRIVATE_KEY, CIRCULAR_PUBLIC_KEY)
# USAGE: Generated test scripts can be run manually to verify write operations
# Input: Test scenarios for write operations (registerWallet, sendTransaction, etc.)
# Output: Used by generators to create manual test scripts

let config = import "../../src/config.ncl" in
let types = import "../../src/schemas/types.ncl" in

{
  test_suite_name = "Circular Protocol Manual Write Tests",
  description = "Manual tests for write operations on live blockchain (requires credentials)",
  version = config.version,

  # Required environment variables for manual tests
  required_env_vars = {
    private_key = {
      name = "CIRCULAR_PRIVATE_KEY",
      description = "Private key for signing transactions (64 hex characters)",
      required = true,
      security = "SENSITIVE - Never commit or share",
    },
    public_key = {
      name = "CIRCULAR_PUBLIC_KEY",
      description = "Public key derived from private key (128 hex characters)",
      required = true,
    },
    test_blockchain = {
      name = "CIRCULAR_TEST_BLOCKCHAIN",
      description = "Blockchain to test on (default: Circular SandBox)",
      default = "0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5ad72b2",
    },
    nag_url = {
      name = "CIRCULAR_NAG_URL",
      description = "NAG endpoint URL",
      default = "https://nag.circularlabs.io/NAG.php?cep=",
    },
  },

  # Safety configuration
  safety = {
    enable_env_var = "CIRCULAR_ALLOW_WRITE_TESTS",
    blockchain_whitelist = [
      "0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5ad72b2",  # SandBox
    ],
    warning = "⚠️  WARNING: These tests write to a LIVE blockchain. Only run on test networks.",
  },

  # Manual test cases for write operations
  write_operation_tests = {
    register_wallet = {
      description = "Manual: Register a new wallet on blockchain",
      operation = "registerWallet",
      category = "convenience_method",
      requires_env = ["CIRCULAR_PRIVATE_KEY", "CIRCULAR_PUBLIC_KEY", "CIRCULAR_TEST_BLOCKCHAIN"],

      test_parameters = {
        blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        publicKey = "${CIRCULAR_PUBLIC_KEY}",
      },

      expected_result = {
        Result = 200,
        Response = {
          TransactionID = "string (64 hex chars)",
          Status = "string",
        },
      },

      verification_steps = [
        "1. Call registerWallet() with test blockchain and public key",
        "2. Verify Result = 200 (success)",
        "3. Verify Response contains TransactionID",
        "4. Use checkWallet() to verify wallet now exists",
        "5. Use getWallet() to verify wallet details",
      ],

      notes = [
        "This creates a REAL wallet on the blockchain",
        "Transaction ID should be derivable: sha256(blockchain + from + to + payload + nonce + timestamp)",
        "From and To addresses = sha256(publicKey)",
        "Can only register wallet once per public key per blockchain",
      ],
    },

    send_transaction = {
      description = "Manual: Send a transaction between wallets",
      operation = "sendTransaction",
      category = "api_endpoint",
      requires_env = ["CIRCULAR_PRIVATE_KEY", "CIRCULAR_PUBLIC_KEY", "CIRCULAR_TEST_BLOCKCHAIN"],

      prerequisites = [
        "Source wallet must exist (use registerWallet first)",
        "Destination wallet must exist",
        "Source wallet must have sufficient balance",
      ],

      test_parameters = {
        Blockchain = "${CIRCULAR_TEST_BLOCKCHAIN}",
        From = "derived from CIRCULAR_PUBLIC_KEY",
        To = "destination address",
        Amount = "100",
        Timestamp = "current timestamp",
        Type = "C_TYPE_TRANSACTION",
        Payload = "hex encoded data",
        Nonce = "from getWalletNonce",
        Signature = "DER-encoded ECDSA signature",
        ID = "sha256(blockchain + from + to + payload + nonce + timestamp)",
        Version = config.version,
      },

      expected_result = {
        Result = 200,
        Response = {
          TransactionID = "string",
          Status = "string",
        },
      },

      verification_steps = [
        "1. Get source wallet nonce",
        "2. Build transaction with correct nonce",
        "3. Sign transaction with private key (DER-encoded ECDSA)",
        "4. Submit via sendTransaction()",
        "5. Verify transaction appears in getLatestTransactions()",
        "6. Verify balances updated correctly",
      ],

      notes = [
        "This sends REAL tokens on the blockchain",
        "Signature must be DER-encoded ECDSA (not raw r,s values)",
        "Transaction ID is deterministic based on inputs",
        "Nonce must increment with each transaction from same wallet",
      ],
    },
  },

  # Output formats
  output_formats = {
    python = {
      script_name = "manual-test-registerWallet.py",
      template = "python3",
    },
    typescript = {
      script_name = "manual-test-registerWallet.ts",
      template = "ts-node",
    },
    bash = {
      script_name = "manual-test-registerWallet.sh",
      template = "bash + curl",
    },
  },

  # Documentation
  documentation = {
    usage = m%"
# Manual Test Usage

These tests write to a LIVE blockchain and are disabled by default.

## Setup

1. Set required environment variables:
   ```bash
   export CIRCULAR_PRIVATE_KEY="your_64_char_hex_private_key"
   export CIRCULAR_PUBLIC_KEY="your_128_char_hex_public_key"
   export CIRCULAR_TEST_BLOCKCHAIN="0x8a20baa40c45dc5055aeb26197c203e576ef389d9acb171bd62da11dc5ad72b2"
   export CIRCULAR_ALLOW_WRITE_TESTS=1  # Enable write operations
   ```

2. Generate manual test scripts:
   ```bash
   just generate-manual-tests
   ```

3. Run scripts:
   ```bash
   # Python
   python3 dist/tests/manual/manual-test-registerWallet.py

   # TypeScript
   npx ts-node dist/tests/manual/manual-test-registerWallet.ts
   ```

## Safety

- ⚠️  Only run on test blockchains (SandBox)
- ⚠️  Never commit private keys
- ⚠️  Requires CIRCULAR_ALLOW_WRITE_TESTS=1 to enable
- ⚠️  All operations are logged for audit trail

## Expected Results

After successful registerWallet:
- Wallet exists on blockchain (checkWallet returns Result=200)
- Wallet has initial balance of 0
- Wallet nonce is 0
- TransactionID is returned and can be queried
    "%,
  },
}
