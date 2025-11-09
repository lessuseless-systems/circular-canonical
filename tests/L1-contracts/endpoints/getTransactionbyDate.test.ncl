# getTransactionbyDate Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../../src/schemas/types.ncl" in
let config = import "../../../src/config.ncl" in

{
  test_name = "getTransactionbyDate Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    date_range_query = {
      request | {
        Blockchain | types.Blockchain,
        InitialDate | types.Timestamp,
        FinalDate | types.Timestamp,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        InitialDate = "2024-01-01:00:00:00",
        FinalDate = "2024-01-31:23:59:59",
        Version = config.version,
      },
      expected = "valid",
    },

    single_day_query = {
      request | {
        Blockchain | types.Blockchain,
        InitialDate | types.Timestamp,
        FinalDate | types.Timestamp,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        InitialDate = "2024-02-15:00:00:00",
        FinalDate = "2024-02-15:23:59:59",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    multiple_transactions = {
      response | {
        Result | types.ResultCode,
        Response,
      } = {
        Result = 200,
        Response = [
          {
            ID = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd",
            From = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
            To = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
            Timestamp = "2024-01-15:10:30:00",
          },
          {
            ID = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
            From = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            To = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
            Timestamp = "2024-01-20:14:22:33",
          },
        ],
      },
      expected = "valid",
    },

    empty_result = {
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
    invalid_date_range = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 400,
        Response = "Invalid date range",
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
