# getPendingTransaction Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../src/schemas/types.ncl" in
let config = import "../../src/config.ncl" in

{
  test_name = "getPendingTransaction Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    mainnet_query = {
      request | {
        Blockchain | types.Blockchain,
        ID | types.TransactionID,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        ID = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd",
        Version = config.version,
      },
      expected = "valid",
    },

    testnet_query = {
      request | {
        Blockchain | types.Blockchain,
        ID | types.TransactionID,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        ID = "0xdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    pending_transaction_found = {
      response | {
        Result | types.ResultCode,
        Response | {
          ID | types.TransactionID,
          From | types.Address,
          To | types.Address,
          Timestamp | types.Timestamp,
          Type | String,
          Payload | String,
          Nonce | String,
          Signature | String,
          Status | String,
        },
      } = {
        Result = 200,
        Response = {
          ID = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd",
          From = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
          To = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
          Timestamp = "2024-01-15:10:30:00",
          Type = "C_TYPE_TRANSACTION",
          Payload = "0x48656c6c6f",
          Nonce = "5",
          Signature = "0xsig123",
          Status = "pending",
        },
      },
      expected = "valid",
    },
  },

  # Valid error responses
  valid_error_responses = {
    transaction_not_found = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 404,
        Response = "Transaction not found",
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
