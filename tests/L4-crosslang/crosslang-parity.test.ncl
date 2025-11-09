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

    # Additional Wallet Tests
    register_wallet_parity = {
      description = "registerWallet returns identical results in TS and Python",
      endpoint = "registerWallet",
      method_name_ts = "registerWallet",
      method_name_py = "register_wallet",
      request = {
        Blockchain = 'MainNet,
        Address = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
        PublicKey = "0x04abcdef1234567890",
        Version = config.version,
      },
      compare_fields = ["Result", "Response.success", "Response.address"],
    },

    # Transaction API Parity Tests
    send_transaction_parity = {
      description = "sendTransaction returns identical results in TS and Python",
      endpoint = "sendTransaction",
      method_name_ts = "sendTransaction",
      method_name_py = "send_transaction",
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
      compare_fields = ["Result", "Response.transaction_id"],
    },

    get_pending_transaction_parity = {
      description = "getPendingTransaction returns identical results in TS and Python",
      endpoint = "getPendingTransaction",
      method_name_ts = "getPendingTransaction",
      method_name_py = "get_pending_transaction",
      request = {
        Blockchain = 'MainNet,
        Version = config.version,
      },
      compare_fields = ["Result", "Response.transactions"],
    },

    get_transaction_by_id_parity = {
      description = "getTransactionbyID returns identical results in TS and Python",
      endpoint = "getTransactionbyID",
      method_name_ts = "getTransactionbyID",
      method_name_py = "get_transaction_by_id",
      request = {
        Blockchain = 'MainNet,
        TransactionID = "0xaabbccdd11223344",
        Version = config.version,
      },
      compare_fields = ["Result", "Response.transaction"],
    },

    get_transaction_by_address_parity = {
      description = "getTransactionbyAddress returns identical results in TS and Python",
      endpoint = "getTransactionbyAddress",
      method_name_ts = "getTransactionbyAddress",
      method_name_py = "get_transaction_by_address",
      request = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Version = config.version,
      },
      compare_fields = ["Result", "Response.transactions"],
    },

    # Asset API Parity Tests
    get_asset_list_parity = {
      description = "getAssetList returns identical results in TS and Python",
      endpoint = "getAssetList",
      method_name_ts = "getAssetList",
      method_name_py = "get_asset_list",
      request = {
        Blockchain = 'MainNet,
        Version = config.version,
      },
      compare_fields = ["Result", "Response.assets"],
    },

    get_asset_supply_parity = {
      description = "getAssetSupply returns identical results in TS and Python",
      endpoint = "getAssetSupply",
      method_name_ts = "getAssetSupply",
      method_name_py = "get_asset_supply",
      request = {
        Blockchain = 'MainNet,
        Asset = "0xC123",
        Version = config.version,
      },
      compare_fields = ["Result", "Response.total_supply", "Response.circulating_supply"],
    },

    get_voucher_parity = {
      description = "getVoucher returns identical results in TS and Python",
      endpoint = "getVoucher",
      method_name_ts = "getVoucher",
      method_name_py = "get_voucher",
      request = {
        Blockchain = 'MainNet,
        VoucherID = "0xvoucher123",
        Version = config.version,
      },
      compare_fields = ["Result", "Response.voucher"],
    },

    # Block API Parity Tests
    get_block_range_parity = {
      description = "getBlockRange returns identical results in TS and Python",
      endpoint = "getBlockRange",
      method_name_ts = "getBlockRange",
      method_name_py = "get_block_range",
      request = {
        Blockchain = 'MainNet,
        StartBlock = 10000,
        EndBlock = 10010,
        Version = config.version,
      },
      compare_fields = ["Result", "Response.blocks"],
    },

    get_analytics_parity = {
      description = "getAnalytics returns identical results in TS and Python",
      endpoint = "getAnalytics",
      method_name_ts = "getAnalytics",
      method_name_py = "get_analytics",
      request = {
        Blockchain = 'MainNet,
        Version = config.version,
      },
      compare_fields = ["Result", "Response.analytics"],
    },

    # Smart Contract API Parity Tests
    test_contract_parity = {
      description = "testContract returns identical results in TS and Python",
      endpoint = "testContract",
      method_name_ts = "testContract",
      method_name_py = "test_contract",
      request = {
        Blockchain = 'MainNet,
        ContractAddress = "0xcontract123",
        Method = "transfer",
        Parameters = ["0xrecipient", "1000"],
        Version = config.version,
      },
      compare_fields = ["Result", "Response.result", "Response.gas_estimate"],
    },

    call_contract_parity = {
      description = "callContract returns identical results in TS and Python",
      endpoint = "callContract",
      method_name_ts = "callContract",
      method_name_py = "call_contract",
      request = {
        Blockchain = 'MainNet,
        ContractAddress = "0xcontract123",
        Method = "balanceOf",
        Parameters = ["0xwallet123"],
        Version = config.version,
      },
      compare_fields = ["Result", "Response.result"],
    },

    # Domain API Parity Test
    get_domain_parity = {
      description = "getDomain returns identical results in TS and Python",
      endpoint = "getDomain",
      method_name_ts = "getDomain",
      method_name_py = "get_domain",
      request = {
        Blockchain = 'MainNet,
        Domain = "myname.circular",
        Version = config.version,
      },
      compare_fields = ["Result", "Response.address"],
    },
  },

  # Test execution configuration
  languages = ["typescript", "python"],

  # Expected test results (now covering all 24 endpoints)
  total_tests = 24,

  # Comparison strictness
  comparison_mode = "deep_equals",  # Options: "deep_equals", "structural", "fuzzy"

  # Fields to ignore in comparison (e.g., timestamps that vary)
  ignore_fields = [],
}
