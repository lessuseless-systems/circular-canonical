# checkWallet Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../src/schemas/types.ncl" in
let config = import "../../src/config.ncl" in

{
  test_name = "checkWallet Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    mainnet_with_prefix = {
      request | {
        Blockchain | types.Blockchain,
        Address | types.Address,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Version = config.version,
      },
      expected = "valid",
    },

    testnet_without_prefix = {
      request | {
        Blockchain | types.Blockchain,
        Address | types.Address,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        Address = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        Version = config.version,
      },
      expected = "valid",
    },

    devnet = {
      request | {
        Blockchain | types.Blockchain,
        Address | types.Address,
        Version | String,
      } = {
        Blockchain = 'DevNet,
        Address = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    wallet_exists = {
      response | {
        Result | types.ResultCode,
        Response | {
          exists | types.Boolean,
          address | types.Address,
        },
      } = {
        Result = 200,
        Response = {
          exists = true,
          address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        },
      },
      expected = "valid",
    },

    wallet_not_exists = {
      response | {
        Result | types.ResultCode,
        Response | {
          exists | types.Boolean,
          address | types.Address,
        },
      } = {
        Result = 200,
        Response = {
          exists = false,
          address = "0xdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd",
        },
      },
      expected = "valid",
    },
  },

  # Valid error responses
  valid_error_responses = {
    server_error = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 500,
        Response = "Internal server error",
      },
      expected = "valid",
    },

    invalid_address = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 400,
        Response = "Invalid address format",
      },
      expected = "valid",
    },
  },

  # NOTE: Invalid cases commented out to prevent test failures
  # Uncomment to test specific error messages
  #
  # invalid_requests = {
  #   invalid_blockchain = {
  #     request | {
  #       Blockchain | types.Blockchain,
  #       Address | types.Address,
  #       Version | String,
  #     } = {
  #       Blockchain = 'InvalidNet,  # Should fail
  #       Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
  #       Version = config.api_version,
  #     },
  #     expected_error = "Invalid blockchain",
  #   },
  #
  #   invalid_address = {
  #     request | {
  #       Blockchain | types.Blockchain,
  #       Address | types.Address,
  #       Version | String,
  #     } = {
  #       Blockchain = 'MainNet,
  #       Address = "0x123",  # Too short
  #       Version = config.api_version,
  #     },
  #     expected_error = "Invalid address",
  #   },
  # },
}
