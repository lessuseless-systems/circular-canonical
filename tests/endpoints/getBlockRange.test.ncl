# getBlockRange Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../src/schemas/types.ncl" in
let config = import "../../src/config.ncl" in

{
  test_name = "getBlockRange Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    range_query = {
      request | {
        Blockchain | types.Blockchain,
        Start | String,
        End | String,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        Start = "100",
        End = "200",
        Version = config.version,
      },
      expected = "valid",
    },

    backward_count = {
      request | {
        Blockchain | types.Blockchain,
        Start | String,
        End | String,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        Start = "10",
        End = "0",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    multiple_blocks = {
      response | {
        Result | types.ResultCode,
        Response,
      } = {
        Result = 200,
        Response = [
          {
            BlockNumber = 100,
            Timestamp = "2024-01-15:10:30:00",
            Transactions = [],
          },
          {
            BlockNumber = 101,
            Timestamp = "2024-01-15:10:31:00",
            Transactions = [],
          },
        ],
      },
      expected = "valid",
    },

    empty_range = {
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
    invalid_range = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 400,
        Response = "Invalid block range",
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
