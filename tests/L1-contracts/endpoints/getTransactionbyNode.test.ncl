# getTransactionbyNode Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../../src/schemas/types.ncl" in
let config = import "../../../src/config.ncl" in

{
  test_name = "getTransactionbyNode Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    mainnet_node = {
      request | {
        Blockchain | types.Blockchain,
        Node | String,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        Node = "node1.circular.network",
        Version = config.version,
      },
      expected = "valid",
    },

    testnet_node = {
      request | {
        Blockchain | types.Blockchain,
        Node | String,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        Node = "node2.circular.test",
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
            BlockNumber = 100,
          },
          {
            ID = "0xdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd",
            From = "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            To = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
            BlockNumber = 101,
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
    node_not_found = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 404,
        Response = "Node not found",
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
