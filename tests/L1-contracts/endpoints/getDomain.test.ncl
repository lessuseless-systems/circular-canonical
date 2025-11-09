# getDomain Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../../src/schemas/types.ncl" in
let config = import "../../../src/config.ncl" in

{
  test_name = "getDomain Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    simple_domain = {
      request | {
        Blockchain | types.Blockchain,
        Domain | types.DomainName,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        Domain = "alice.cir",
        Version = config.version,
      },
      expected = "valid",
    },

    complex_domain = {
      request | {
        Blockchain | types.Blockchain,
        Domain | types.DomainName,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        Domain = "my-wallet.circular.net",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    domain_resolved = {
      response | {
        Result | types.ResultCode,
        Response | {
          Domain | types.DomainName,
          Address | types.Address,
        },
      } = {
        Result = 200,
        Response = {
          Domain = "alice.cir",
          Address = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        },
      },
      expected = "valid",
    },

    another_domain = {
      response | {
        Result | types.ResultCode,
        Response | {
          Domain | types.DomainName,
          Address | types.Address,
        },
      } = {
        Result = 200,
        Response = {
          Domain = "bob.circular.test",
          Address = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        },
      },
      expected = "valid",
    },
  },

  # Valid error responses
  valid_error_responses = {
    domain_not_found = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 404,
        Response = "Domain not found",
      },
      expected = "valid",
    },

    invalid_domain = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 400,
        Response = "Invalid domain format",
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
