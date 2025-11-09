# getAssetList Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../../src/schemas/types.ncl" in
let config = import "../../../src/config.ncl" in

{
  test_name = "getAssetList Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    mainnet_list = {
      request | {
        Blockchain | types.Blockchain,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        Version = config.version,
      },
      expected = "valid",
    },

    testnet_list = {
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
    multiple_assets = {
      response | {
        Result | types.ResultCode,
        Response,
      } = {
        Result = 200,
        Response = [
          { AssetName = "CIRX" },
          { AssetName = "BTC" },
          { AssetName = "ETH" },
        ],
      },
      expected = "valid",
    },

    empty_list = {
      response | {
        Result | types.ResultCode,
        Response,
      } = {
        Result = 200,
        Response = [],
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
