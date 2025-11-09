# getAsset Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../../src/schemas/types.ncl" in
let config = import "../../../src/config.ncl" in

{
  test_name = "getAsset Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    cirx_asset = {
      request | {
        Blockchain | types.Blockchain,
        AssetName | types.AssetName,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        AssetName = "CIRX",
        Version = config.version,
      },
      expected = "valid",
    },

    btc_asset = {
      request | {
        Blockchain | types.Blockchain,
        AssetName | types.AssetName,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        AssetName = "BTC",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    asset_details = {
      response | {
        Result | types.ResultCode,
        Response | {
          AssetName | types.AssetName,
          TotalSupply | Number,
          Decimals | Number,
          Owner | types.Address,
        },
      } = {
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

  # Valid error responses
  valid_error_responses = {
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
