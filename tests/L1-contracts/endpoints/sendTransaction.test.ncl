# sendTransaction Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../../src/schemas/types.ncl" in
let config = import "../../../src/config.ncl" in

{
  test_name = "sendTransaction Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    mainnet_transaction = {
      request | {
        ID | types.TransactionID,
        From | types.Address,
        To | types.Address,
        Timestamp | types.Timestamp,
        Type | String,
        Payload | String,
        Nonce | String,
        Signature | String,
        Blockchain | types.Blockchain,
        Version | String,
      } = {
        ID = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd",
        From = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        To = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
        Timestamp = "2024-01-15:10:30:00",
        Type = "C_TYPE_TRANSACTION",
        Payload = "0x48656c6c6f",
        Nonce = "5",
        Signature = "0xsig123",
        Blockchain = 'MainNet,
        Version = config.version,
      },
      expected = "valid",
    },

    testnet_transaction = {
      request | {
        ID | types.TransactionID,
        From | types.Address,
        To | types.Address,
        Timestamp | types.Timestamp,
        Type | String,
        Payload | String,
        Nonce | String,
        Signature | String,
        Blockchain | types.Blockchain,
        Version | String,
      } = {
        ID = "0xdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd",
        From = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        To = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Timestamp = "2024-02-20:15:45:30",
        Type = "C_TYPE_TRANSACTION",
        Payload = "0x576f726c64",
        Nonce = "10",
        Signature = "0xsig456",
        Blockchain = 'TestNet,
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    transaction_accepted = {
      response | {
        Result | types.ResultCode,
        Response | {
          TransactionID | types.TransactionID,
          Status | String,
        },
      } = {
        Result = 200,
        Response = {
          TransactionID = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd",
          Status = "pending",
        },
      },
      expected = "valid",
    },

    transaction_confirmed = {
      response | {
        Result | types.ResultCode,
        Response | {
          TransactionID | types.TransactionID,
          Status | String,
        },
      } = {
        Result = 200,
        Response = {
          TransactionID = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
          Status = "confirmed",
        },
      },
      expected = "valid",
    },
  },

  # Valid error responses
  valid_error_responses = {
    invalid_signature = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 400,
        Response = "Invalid signature",
      },
      expected = "valid",
    },

    insufficient_balance = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 400,
        Response = "Insufficient balance",
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
