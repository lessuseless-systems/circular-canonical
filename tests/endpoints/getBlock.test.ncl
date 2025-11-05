# getBlock Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../src/schemas/types.ncl" in
let config = import "../../src/config.ncl" in

{
  test_name = "getBlock Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    mainnet_block = {
      request | {
        Blockchain | types.Blockchain,
        BlockNumber | String,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        BlockNumber = "12345",
        Version = config.version,
      },
      expected = "valid",
    },

    testnet_block = {
      request | {
        Blockchain | types.Blockchain,
        BlockNumber | String,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        BlockNumber = "100",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    block_with_transactions = {
      response | {
        Result | types.ResultCode,
        Response | {
          BlockNumber | types.BlockNumber,
          Timestamp | types.Timestamp,
          Transactions,
          Hash | String,
        },
      } = {
        Result = 200,
        Response = {
          BlockNumber = 12345,
          Timestamp = "2024-01-15:10:30:00",
          Transactions = [
            { ID = "0xabcdef...", From = "0x742d35...", To = "0x987654..." },
          ],
          Hash = "0xblock123...",
        },
      },
      expected = "valid",
    },

    empty_block = {
      response | {
        Result | types.ResultCode,
        Response | {
          BlockNumber | types.BlockNumber,
          Timestamp | types.Timestamp,
          Transactions,
          Hash | String,
        },
      } = {
        Result = 200,
        Response = {
          BlockNumber = 100,
          Timestamp = "2024-01-15:10:31:00",
          Transactions = [],
          Hash = "0xblock456...",
        },
      },
      expected = "valid",
    },
  },

  # Valid error responses
  valid_error_responses = {
    block_not_found = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 404,
        Response = "Block not found",
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
