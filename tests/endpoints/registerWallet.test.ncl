# registerWallet Endpoint Contract Tests
# Tests that complete request/response objects conform to contracts

let types = import "../../src/schemas/types.ncl" in
let config = import "../../src/config.ncl" in

{
  test_name = "registerWallet Endpoint Validation",

  # Valid complete request bodies
  valid_requests = {
    mainnet_registration = {
      request | {
        Blockchain | types.Blockchain,
        PublicKey | String,
        Version | String,
      } = {
        Blockchain = 'MainNet,
        PublicKey = "04abc123def456789abcdef0123456789abcdef0123456789abcdef012345678",
        Version = config.version,
      },
      expected = "valid",
    },

    testnet_registration = {
      request | {
        Blockchain | types.Blockchain,
        PublicKey | String,
        Version | String,
      } = {
        Blockchain = 'TestNet,
        PublicKey = "04fedcba987654321fedcba987654321fedcba987654321fedcba987654321",
        Version = config.version,
      },
      expected = "valid",
    },

    devnet_registration = {
      request | {
        Blockchain | types.Blockchain,
        PublicKey | String,
        Version | String,
      } = {
        Blockchain = 'DevNet,
        PublicKey = "041234567890abcdef1234567890abcdef1234567890abcdef1234567890abcd",
        Version = config.version,
      },
      expected = "valid",
    },
  },

  # Valid success responses
  valid_success_responses = {
    registration_pending = {
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
          Status = "pending",
        },
      },
      expected = "valid",
    },

    registration_confirmed = {
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
          Status = "confirmed",
        },
      },
      expected = "valid",
    },
  },

  # Valid error responses
  valid_error_responses = {
    already_registered = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 400,
        Response = "Wallet already registered on this blockchain",
      },
      expected = "valid",
    },

    invalid_public_key = {
      response | {
        Result | types.ResultCode,
        Response | String,
      } = {
        Result = 400,
        Response = "Invalid public key format",
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
