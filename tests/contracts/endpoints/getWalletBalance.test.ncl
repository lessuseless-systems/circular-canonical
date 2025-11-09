# getWalletBalance Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../../src/schemas/types.ncl" in
let config = import "../../../src/config.ncl" in

{
  test_name = "getWalletBalance Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    cirx_balance_request = {
      request | {
        Blockchain | types.Blockchain,
        Address | types.Address,
        Asset | types.AssetName,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Asset = "CIRX",
        Version = config.version,
      },
      expected = "valid",
    },

    btc_balance_request = {
      request | {
        Blockchain | types.Blockchain,
        Address | types.Address,
        Asset | types.AssetName,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        Address = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        Asset = "BTC",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    with_balance = {
      response | {
        Result | types.ResultCode,
        Response | {
          Balance | types.Amount,
          Asset | types.AssetName,
        },
      } = {
        Result = 200,
        Response = {
          Balance = 1000000,
          Asset = "CIRX",
        },
      },
      expected = "valid",
    },

    zero_balance = {
      response | {
        Result | types.ResultCode,
        Response | {
          Balance | types.Amount,
          Asset | types.AssetName,
        },
      } = {
        Result = 200,
        Response = {
          Balance = 0,
          Asset = "ETH",
        },
      },
      expected = "valid",
    },
  },

  # Valid error responses
  valid_error_responses = {
    wallet_not_found = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 404,
        Response = "Wallet not found",
      },
      expected = "valid",
    },

    asset_not_found = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 404,
        Response = "Asset not found",
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
