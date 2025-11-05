# getWallet Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../src/schemas/types.ncl" in
let config = import "../../src/config.ncl" in

{
  test_name = "getWallet Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    mainnet_request = {
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

    testnet_request = {
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
  },

  # Valid success responses
  valid_success_responses = {
    wallet_info = {
      response | {
        Result | types.ResultCode,
        Response | {
          Address | types.Address,
          Balance | types.Amount,
          Nonce | types.Nonce,
        },
      } = {
        Result = 200,
        Response = {
          Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
          Balance = 1000000,
          Nonce = 42,
        },
      },
      expected = "valid",
    },

    zero_balance = {
      response | {
        Result | types.ResultCode,
        Response | {
          Address | types.Address,
          Balance | types.Amount,
          Nonce | types.Nonce,
        },
      } = {
        Result = 200,
        Response = {
          Address = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
          Balance = 0,
          Nonce = 0,
        },
      },
      expected = "valid",
    },
  },

  # Valid error responses
  valid_error_responses = {
    not_found = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 404,
        Response = "Wallet not found",
      },
      expected = "valid",
    },

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
  },
}
