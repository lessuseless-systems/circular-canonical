# testContract Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../src/schemas/types.ncl" in
let config = import "../../src/config.ncl" in

{
  test_name = "testContract Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    mainnet_test = {
      request | {
        Blockchain | types.Blockchain,
        From | types.Address,
        Project | String,
        Timestamp | types.Timestamp,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        From = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Project = "0x636f6e74726163745f636f6465...",
        Timestamp = "2024-01-15:10:30:00",
        Version = config.version,
      },
      expected = "valid",
    },

    testnet_test = {
      request | {
        Blockchain | types.Blockchain,
        From | types.Address,
        Project | String,
        Timestamp | types.Timestamp,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        From = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        Project = "0x70726f6a6563745f636f6465...",
        Timestamp = "2024-02-20:15:45:30",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    test_successful = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 200,
        Response = "Contract execution successful",
      },
      expected = "valid",
    },

    test_with_output = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 200,
        Response = "{\"result\": \"test passed\", \"gas_used\": 21000}",
      },
      expected = "valid",
    },
  },

  # Valid error responses
  valid_error_responses = {
    contract_error = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 400,
        Response = "Contract execution failed: invalid bytecode",
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
