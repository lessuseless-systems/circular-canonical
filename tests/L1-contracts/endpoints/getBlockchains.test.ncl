# getBlockchains Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../../src/schemas/types.ncl" in
let config = import "../../../src/config.ncl" in

{
  test_name = "getBlockchains Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    basic_request = {
      request | {
        Version | String | optional,
      } = {
        Version = config.version,
      },
      expected = "valid",
    },

    minimal_request = {
      request | {
        Version | String | optional,
      } = {},
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    multiple_blockchains = {
      response | {
        Result | types.ResultCode,
        Response,
      } = {
        Result = 200,
        Response = [
          {
            Name = "MainNet",
            ChainID = "1",
            Active = true,
          },
          {
            Name = "TestNet",
            ChainID = "2",
            Active = true,
          },
          {
            Name = "DevNet",
            ChainID = "3",
            Active = false,
          },
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
    service_unavailable = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 503,
        Response = "Service unavailable",
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
