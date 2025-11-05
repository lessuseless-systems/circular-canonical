# Runtime Validation Test Suite
# Tests that validation functions correctly apply contracts to data

let validators = import "../../src/validators/endpoint-validators.ncl" in
let config = import "../../src/config.ncl" in

{
  test_name = "Runtime Validation Test Suite",

  # Test checkWallet validators
  checkWallet_tests = {
    valid_request = {
      data = validators.validate_checkWallet_request {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_checkWallet_response_success {
        Result = 200,
        Response = {
          exists = true,
          address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        },
      },
      expected = "valid",
    },

    valid_error_response = {
      data = validators.validate_checkWallet_response_error {
        Result = 404,
        Response = "Wallet not found",
      },
      expected = "valid",
    },
  },

  # Test getWallet validators
  getWallet_tests = {
    valid_request = {
      data = validators.validate_getWallet_request {
        Blockchain = 'TestNet,
        Address = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_getWallet_response_success {
        Result = 200,
        Response = {
          Address = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
          Balance = 1000,
          Nonce = 5,
        },
      },
      expected = "valid",
    },
  },

  # Test getWalletBalance validators
  getWalletBalance_tests = {
    valid_request = {
      data = validators.validate_getWalletBalance_request {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Asset = "CIRX",
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_getWalletBalance_response_success {
        Result = 200,
        Response = {
          Balance = 500000,
          Asset = "CIRX",
        },
      },
      expected = "valid",
    },
  },

  # Test getWalletNonce validators
  getWalletNonce_tests = {
    valid_request = {
      data = validators.validate_getWalletNonce_request {
        Blockchain = 'DevNet,
        Address = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_getWalletNonce_response_success {
        Result = 200,
        Response = {
          Nonce = 42,
        },
      },
      expected = "valid",
    },
  },

  # Test registerWallet validators
  registerWallet_tests = {
    valid_request = {
      data = validators.validate_registerWallet_request {
        Blockchain = 'MainNet,
        PublicKey = "04abc123def456789abcdef0123456789abcdef0123456789abcdef012345678",
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_registerWallet_response_success {
        Result = 200,
        Response = {
          TransactionID = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
          Status = "pending",
        },
      },
      expected = "valid",
    },
  },

  # Transaction API Validators

  sendTransaction_tests = {
    valid_request = {
      data = validators.validate_sendTransaction_request {
        ID = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd",
        From = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        To = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
        Timestamp = "2024-01-15:10:30:00",
        Type = "C_TYPE_TRANSACTION",
        Payload = "0x48656c6c6f",
        Nonce = "5",
        Signature = "0xsig123",
        Blockchain = 'MainNet,
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_sendTransaction_response_success {
        Result = 200,
        Response = {
          TransactionID = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd",
          Status = "pending",
        },
      },
      expected = "valid",
    },
  },

  getPendingTransaction_tests = {
    valid_request = {
      data = validators.validate_getPendingTransaction_request {
        Blockchain = 'MainNet,
        ID = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  getTransactionbyID_tests = {
    valid_request = {
      data = validators.validate_getTransactionbyID_request {
        Blockchain = 'MainNet,
        ID = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd",
        Start = "100",
        End = "200",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  getTransactionbyNode_tests = {
    valid_request = {
      data = validators.validate_getTransactionbyNode_request {
        Blockchain = 'MainNet,
        Node = "node1.circular.network",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  getTransactionbyAddress_tests = {
    valid_request = {
      data = validators.validate_getTransactionbyAddress_request {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  getTransactionbyDate_tests = {
    valid_request = {
      data = validators.validate_getTransactionbyDate_request {
        Blockchain = 'MainNet,
        InitialDate = "2024-01-01:00:00:00",
        FinalDate = "2024-01-31:23:59:59",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Block API Validators

  getBlock_tests = {
    valid_request = {
      data = validators.validate_getBlock_request {
        Blockchain = 'MainNet,
        BlockNumber = "12345",
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_getBlock_response_success {
        Result = 200,
        Response = {
          BlockNumber = 12345,
          Timestamp = "2024-01-15:10:30:00",
          Transactions = [],
          Hash = "0xblock123...",
        },
      },
      expected = "valid",
    },
  },

  getBlockRange_tests = {
    valid_request = {
      data = validators.validate_getBlockRange_request {
        Blockchain = 'MainNet,
        Start = "100",
        End = "200",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  getBlockCount_tests = {
    valid_request = {
      data = validators.validate_getBlockCount_request {
        Blockchain = 'MainNet,
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_getBlockCount_response_success {
        Result = 200,
        Response = {
          BlockCount = 123456,
        },
      },
      expected = "valid",
    },
  },

  getAnalytics_tests = {
    valid_request = {
      data = validators.validate_getAnalytics_request {
        Blockchain = 'MainNet,
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_getAnalytics_response_success {
        Result = 200,
        Response = {
          TotalTransactions = 1000000,
          TotalWallets = 50000,
          TotalAssets = 100,
          BlockHeight = 123456,
        },
      },
      expected = "valid",
    },
  },

  # Smart Contract API Validators

  testContract_tests = {
    valid_request = {
      data = validators.validate_testContract_request {
        Blockchain = 'MainNet,
        From = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Project = "0x636f6e74726163745f636f6465...",
        Timestamp = "2024-01-15:10:30:00",
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_testContract_response_success {
        Result = 200,
        Response = "Contract execution successful",
      },
      expected = "valid",
    },
  },

  callContract_tests = {
    valid_request = {
      data = validators.validate_callContract_request {
        Blockchain = 'MainNet,
        From = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Address = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
        Request = "0x66756e6374696f6e4e616d65...",
        Timestamp = "2024-01-15:10:30:00",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Asset API Validators

  getAssetList_tests = {
    valid_request = {
      data = validators.validate_getAssetList_request {
        Blockchain = 'MainNet,
        Version = config.version,
      },
      expected = "valid",
    },
  },

  getAsset_tests = {
    valid_request = {
      data = validators.validate_getAsset_request {
        Blockchain = 'MainNet,
        AssetName = "CIRX",
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_getAsset_response_success {
        Result = 200,
        Response = {
          AssetName = "CIRX",
          TotalSupply = 1000000000,
          Decimals = 8,
          Owner = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        },
      },
      expected = "valid",
    },
  },

  getAssetSupply_tests = {
    valid_request = {
      data = validators.validate_getAssetSupply_request {
        Blockchain = 'MainNet,
        AssetName = "CIRX",
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_getAssetSupply_response_success {
        Result = 200,
        Response = {
          TotalSupply = 1000000000,
          CirculatingSupply = 750000000,
          ResidualSupply = 250000000,
        },
      },
      expected = "valid",
    },
  },

  getVoucher_tests = {
    valid_request = {
      data = validators.validate_getVoucher_request {
        Blockchain = 'MainNet,
        Code = "VOUCHERCODE123",
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_getVoucher_response_success {
        Result = 200,
        Response = {
          Code = "VOUCHERCODE123",
          Value = 100,
          Asset = "CIRX",
          Redeemed = false,
        },
      },
      expected = "valid",
    },
  },

  # Domain API Validators

  getDomain_tests = {
    valid_request = {
      data = validators.validate_getDomain_request {
        Blockchain = 'MainNet,
        Domain = "alice.cir",
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_getDomain_response_success {
        Result = 200,
        Response = {
          Domain = "alice.cir",
          Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        },
      },
      expected = "valid",
    },
  },

  # Network API Validators

  getBlockchains_tests = {
    valid_request = {
      data = validators.validate_getBlockchains_request {
        Version = config.version,
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_getBlockchains_response_success {
        Result = 200,
        Response = [
          { Name = "MainNet", ChainID = "1", Active = true },
          { Name = "TestNet", ChainID = "2", Active = true },
        ],
      },
      expected = "valid",
    },
  },

  # Test that all validators exist and are functions
  validator_existence = {
    all_validators_defined = std.is_function validators.validate_checkWallet_request &&
                             std.is_function validators.validate_checkWallet_response_success &&
                             std.is_function validators.validate_getWallet_request &&
                             std.is_function validators.validate_getWallet_response_success &&
                             std.is_function validators.validate_getWalletBalance_request &&
                             std.is_function validators.validate_getWalletBalance_response_success &&
                             std.is_function validators.validate_getWalletNonce_request &&
                             std.is_function validators.validate_getWalletNonce_response_success &&
                             std.is_function validators.validate_registerWallet_request &&
                             std.is_function validators.validate_registerWallet_response_success,
  },
}
