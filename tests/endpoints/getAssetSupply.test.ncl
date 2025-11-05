# getAssetSupply Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../src/schemas/types.ncl" in
let config = import "../../src/config.ncl" in

{
  test_name = "getAssetSupply Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    cirx_supply = {
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

    btc_supply = {
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
    supply_metrics = {
      response | {
        Result | types.ResultCode,
        Response | {
          TotalSupply | Number,
          CirculatingSupply | Number,
          ResidualSupply | Number,
        },
      } = {
        Result = 200,
        Response = {
          TotalSupply = 1000000000,
          CirculatingSupply = 750000000,
          ResidualSupply = 250000000,
        },
      },
      expected = "valid",
    },

    zero_supply = {
      response | {
        Result | types.ResultCode,
        Response | {
          TotalSupply | Number,
          CirculatingSupply | Number,
          ResidualSupply | Number,
        },
      } = {
        Result = 200,
        Response = {
          TotalSupply = 0,
          CirculatingSupply = 0,
          ResidualSupply = 0,
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
