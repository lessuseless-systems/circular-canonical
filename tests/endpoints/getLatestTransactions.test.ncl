# getLatestTransactions Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../src/schemas/types.ncl" in
let config = import "../../src/config.ncl" in

{
  test_name = "getLatestTransactions Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    mainnet_request = {
      request | {
        Blockchain | types.Blockchain,
        Address | types.Address,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Version = config.version,
      },
      expected = "valid",
    },

    devnet_request = {
      request | {
        Blockchain | types.Blockchain,
        Address | types.Address,
        Version | String,
      } = {
        Blockchain = 'DevNet,
        Address = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses with transaction arrays
  valid_success_responses = {
    single_transaction = {
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
            Amount = 1000,
            Timestamp = "2024-01-15:10:30:00",
          },
        ],
      },
      expected = "valid",
    },

    multiple_transactions = {
      response | {
        Result | types.ResultCode,
        Response,
      } = {
        Result = 200,
        Response = [
          {
            ID = "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            From = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
            To = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
            Amount = 500,
            Timestamp = "2024-01-15:10:30:00",
          },
          {
            ID = "0xdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd",
            From = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
            To = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
            Amount = 250,
            Timestamp = "2024-01-15:11:00:00",
          },
        ],
      },
      expected = "valid",
    },

    empty_transactions = {
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
    wallet_not_found = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 404,
        Response = "Wallet not found",
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
