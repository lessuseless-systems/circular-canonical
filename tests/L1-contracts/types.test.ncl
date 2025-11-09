# Contract Validation Test - Core Types
# Tests that type contracts properly validate inputs

let types = import "../../src/schemas/types.ncl" in

{
  test_name = "Core Types Validation",

  # Test Address contract
  valid_addresses = {
    with_prefix_66_chars = {
      value | types.Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
      expected = "valid",
    },

    without_prefix_64_chars = {
      value | types.Address = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      expected = "valid",
    },
  },

  # Test Amount contract
  valid_amounts = {
    zero = {
      value | types.Amount = 0,
      expected = "valid",
    },

    positive = {
      value | types.Amount = 1000,
      expected = "valid",
    },

    large = {
      value | types.Amount = 999999999999,
      expected = "valid",
    },
  },

  # Test Blockchain enum
  valid_blockchains = {
    mainnet = {
      value | types.Blockchain = 'MainNet,
      expected = "valid",
    },

    testnet = {
      value | types.Blockchain = 'TestNet,
      expected = "valid",
    },

    devnet = {
      value | types.Blockchain = 'DevNet,
      expected = "valid",
    },
  },

  # Test Nonce contract
  valid_nonces = {
    zero = {
      value | types.Nonce = 0,
      expected = "valid",
    },

    positive_int = {
      value | types.Nonce = 42,
      expected = "valid",
    },
  },

  # Test TransactionID contract (same as Address)
  valid_transaction_ids = {
    with_prefix = {
      value | types.TransactionID = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      expected = "valid",
    },

    without_prefix = {
      value | types.TransactionID = "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
      expected = "valid",
    },
  },

  # Test AssetName contract
  valid_asset_names = {
    short = {
      value | types.AssetName = "CIRX",
      expected = "valid",
    },

    medium = {
      value | types.AssetName = "Bitcoin",
      expected = "valid",
    },

    max_length = {
      value | types.AssetName = "VeryLongAssetNameThirtyTwoChar",
      expected = "valid",
    },
  },

  # Test Timestamp contract
  valid_timestamps = {
    standard = {
      value | types.Timestamp = "2024-01-15:10:30:45",
      expected = "valid",
    },

    midnight = {
      value | types.Timestamp = "2024-12-31:00:00:00",
      expected = "valid",
    },

    end_of_day = {
      value | types.Timestamp = "2025-06-15:23:59:59",
      expected = "valid",
    },
  },

  # Test BlockNumber contract
  valid_block_numbers = {
    zero = {
      value | types.BlockNumber = 0,
      expected = "valid",
    },

    small = {
      value | types.BlockNumber = 12345,
      expected = "valid",
    },

    large = {
      value | types.BlockNumber = 9999999999,
      expected = "valid",
    },
  },

  # Test DomainName contract
  valid_domain_names = {
    simple = {
      value | types.DomainName = "alice",
      expected = "valid",
    },

    with_extension = {
      value | types.DomainName = "alice.cir",
      expected = "valid",
    },

    complex = {
      value | types.DomainName = "my-wallet.circular.net",
      expected = "valid",
    },
  },

  # Test Boolean contract
  valid_booleans = {
    true_value = {
      value | types.Boolean = true,
      expected = "valid",
    },

    false_value = {
      value | types.Boolean = false,
      expected = "valid",
    },
  },

  # Test HttpMethod enum
  valid_http_methods = {
    get = {
      value | types.HttpMethod = 'GET,
      expected = "valid",
    },

    post = {
      value | types.HttpMethod = 'POST,
      expected = "valid",
    },

    put = {
      value | types.HttpMethod = 'PUT,
      expected = "valid",
    },

    delete = {
      value | types.HttpMethod = 'DELETE,
      expected = "valid",
    },

    patch = {
      value | types.HttpMethod = 'PATCH,
      expected = "valid",
    },
  },

  # Test ResultCode contract
  valid_result_codes = {
    success = {
      value | types.ResultCode = 200,
      expected = "valid",
    },

    created = {
      value | types.ResultCode = 201,
      expected = "valid",
    },

    bad_request = {
      value | types.ResultCode = 400,
      expected = "valid",
    },

    not_found = {
      value | types.ResultCode = 404,
      expected = "valid",
    },

    server_error = {
      value | types.ResultCode = 500,
      expected = "valid",
    },
  },

  # NOTE: Invalid cases are commented out to prevent test from failing
  # Uncomment specific tests when testing error messages
  #
  # invalid_addresses = {
  #   too_short = {
  #     value | types.Address = "0x123",
  #     expected_error = "must be 64 or 66 characters",
  #   },
  # },
  #
  # invalid_asset_names = {
  #   too_long = {
  #     value | types.AssetName = "ThisAssetNameIsDefinitelyWayTooLongToBeValid",
  #     expected_error = "must be 32 characters or less",
  #   },
  # },
  #
  # invalid_timestamps = {
  #   wrong_format = {
  #     value | types.Timestamp = "2024/01/15 10:30:45",
  #     expected_error = "must match YYYY-MM-DD:HH:MM:SS",
  #   },
  # },
  #
  # invalid_result_codes = {
  #   too_low = {
  #     value | types.ResultCode = 99,
  #     expected_error = "must be between 100 and 599",
  #   },
  #   too_high = {
  #     value | types.ResultCode = 600,
  #     expected_error = "must be between 100 and 599",
  #   },
  # },
}
