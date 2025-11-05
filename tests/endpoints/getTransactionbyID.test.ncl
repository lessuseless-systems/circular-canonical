# getTransactionbyID Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../src/schemas/types.ncl" in
let config = import "../../src/config.ncl" in

{
  test_name = "getTransactionbyID Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    with_block_range = {
      request | {
        Blockchain | types.Blockchain,
        ID | types.TransactionID,
        Start | String,
        End | String,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        ID = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd",
        Start = "100",
        End = "200",
        Version = config.version,
      },
      expected = "valid",
    },

    without_range = {
      request | {
        Blockchain | types.Blockchain,
        ID | types.TransactionID,
        Start | String,
        End | String,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        ID = "0xdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd",
        Start = "0",
        End = "0",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    transaction_found = {
      response | {
        Result | types.ResultCode,
        Response | {
          ID | types.TransactionID,
          From | types.Address,
          To | types.Address,
          BlockNumber | types.BlockNumber,
          Timestamp | types.Timestamp,
          Type | String,
        },
      } = {
        Result = 200,
        Response = {
          ID = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd",
          From = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
          To = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
          BlockNumber = 12345,
          Timestamp = "2024-01-15:10:30:00",
          Type = "C_TYPE_TRANSACTION",
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
        Response = "Transaction not found in specified range",
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
