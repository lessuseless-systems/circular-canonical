# getVoucher Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../../src/schemas/types.ncl" in
let config = import "../../../src/config.ncl" in

{
  test_name = "getVoucher Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    with_prefix = {
      request | {
        Blockchain | types.Blockchain,
        Code | String,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        Code = "0xVOUCHERCODE123...",
        Version = config.version,
      },
      expected = "valid",
    },

    without_prefix = {
      request | {
        Blockchain | types.Blockchain,
        Code | String,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        Code = "VOUCHERCODE456...",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    voucher_unredeemed = {
      response | {
        Result | types.ResultCode,
        Response | {
          Code | String,
          Value | Number,
          Asset | types.AssetName,
          Redeemed | types.Boolean,
        },
      } = {
        Result = 200,
        Response = {
          Code = "VOUCHERCODE123...",
          Value = 100,
          Asset = "CIRX",
          Redeemed = false,
        },
      },
      expected = "valid",
    },

    voucher_redeemed = {
      response | {
        Result | types.ResultCode,
        Response | {
          Code | String,
          Value | Number,
          Asset | types.AssetName,
          Redeemed | types.Boolean,
        },
      } = {
        Result = 200,
        Response = {
          Code = "VOUCHERCODE456...",
          Value = 50,
          Asset = "BTC",
          Redeemed = true,
        },
      },
      expected = "valid",
    },
  },

  # Valid error responses
  valid_error_responses = {
    voucher_not_found = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 404,
        Response = "Voucher not found",
      },
      expected = "valid",
    },

    invalid_code = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 400,
        Response = "Invalid voucher code",
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
