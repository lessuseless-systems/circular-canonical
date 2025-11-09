# getAnalytics Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../../src/schemas/types.ncl" in
let config = import "../../../src/config.ncl" in

{
  test_name = "getAnalytics Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    mainnet_analytics = {
      request | {
        Blockchain | types.Blockchain,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        Version = config.version,
      },
      expected = "valid",
    },

    testnet_analytics = {
      request | {
        Blockchain | types.Blockchain,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    full_analytics = {
      response | {
        Result | types.ResultCode,
        Response | {
          TotalTransactions | Number,
          TotalWallets | Number,
          TotalAssets | Number,
          BlockHeight | types.BlockNumber,
        },
      } = {
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

    zero_analytics = {
      response | {
        Result | types.ResultCode,
        Response | {
          TotalTransactions | Number,
          TotalWallets | Number,
          TotalAssets | Number,
          BlockHeight | types.BlockNumber,
        },
      } = {
        Result = 200,
        Response = {
          TotalTransactions = 0,
          TotalWallets = 0,
          TotalAssets = 0,
          BlockHeight = 0,
        },
      },
      expected = "valid",
    },
  },

  # Valid error responses
  valid_error_responses = {
    blockchain_not_found = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 404,
        Response = "Blockchain not found",
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
