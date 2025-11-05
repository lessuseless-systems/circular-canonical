# callContract Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../src/schemas/types.ncl" in
let config = import "../../src/config.ncl" in

{
  test_name = "callContract Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    mainnet_call = {
      request | {
        Blockchain | types.Blockchain,
        From | types.Address,
        Address | types.Address,
        Request | String,
        Timestamp | types.Timestamp,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        From = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Address = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
        Request = "0x66756e6374696f6e4e616d65...",
        Timestamp = "2024-01-15:10:30:00",
        Version = config.version,
      },
      expected = "valid",
    },

    testnet_call = {
      request | {
        Blockchain | types.Blockchain,
        From | types.Address,
        Address | types.Address,
        Request | String,
        Timestamp | types.Timestamp,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        From = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        Address = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        Request = "0x616e6f7468657246756e6374696f6e...",
        Timestamp = "2024-02-20:15:45:30",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    call_successful = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 200,
        Response = "Function returned: success",
      },
      expected = "valid",
    },

    call_with_data = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 200,
        Response = "{\"data\": [1, 2, 3], \"status\": \"ok\"}",
      },
      expected = "valid",
    },
  },

  # Valid error responses
  valid_error_responses = {
    contract_not_found = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 404,
        Response = "Contract not found",
      },
      expected = "valid",
    },

    function_error = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 400,
        Response = "Function execution failed",
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
