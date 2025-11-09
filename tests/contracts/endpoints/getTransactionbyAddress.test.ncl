# getTransactionbyAddress Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../../src/schemas/types.ncl" in
let config = import "../../../src/config.ncl" in

{
  test_name = "getTransactionbyAddress Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    mainnet_address = {
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

    testnet_address = {
      request | {
        Blockchain | types.Blockchain,
        Address | types.Address,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        Address = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
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
            BlockNumber = 12345,
          },
          {
            ID = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
            From = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
            To = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
            BlockNumber = 12350,
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
    address_not_found = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 404,
        Response = "Address not found",
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
