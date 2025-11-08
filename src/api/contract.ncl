# Circular Protocol Canonical - Smart Contract API Endpoints
# Reference: docs/API_REFERENCE.md (Smart Contracts)

let types = import "../schemas/types.ncl" in

{
  testContract = {
    method = "POST",
    path = "/testContract",
    summary = "Test smart contract execution",
    description = m%"
      Tests smart contract execution locally without sending a transaction.
      Useful for testing contract logic before deploying or executing.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where the smart contract is deployed",
        default = "MainNet",
      },

      from = {
        type = "string",
        required = true,
        description = "Caller wallet address",
      },

      project = {
        type = "string",
        required = true,
        description = "Smart contract project/code (hex-encoded)",
      },
    },

    request_body = {
      Blockchain = "string",
      From = "string",
      Project = "string",
      Timestamp = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = "string",  # Mixed result
    },

    example_request = {
      blockchain = "MainNet",
      from = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      project = "0x636f6e74726163745f636f6465...",
    },

    example_response = {
      Result = 200,
      Response = "Contract execution successful",
    },
  },

  callContract = {
    method = "POST",
    path = "/callContract",
    summary = "Call smart contract function",
    description = m%"
      Calls a smart contract function on the blockchain.
      Executes the specified function with provided parameters.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where the smart contract is deployed",
        default = "MainNet",
      },

      from = {
        type = "string",
        required = true,
        description = "Caller wallet address",
      },

      address = {
        type = "string",
        required = true,
        description = "Smart contract address",
      },

      request = {
        type = "string",
        required = true,
        description = "Smart contract local endpoint/function call (hex-encoded)",
      },
    },

    request_body = {
      Blockchain = "string",
      From = "string",
      Address = "string",
      Request = "string",
      Timestamp = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = "string",  # Mixed result
    },

    example_request = {
      blockchain = "MainNet",
      from = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      address = "0x9876543210fedcba9876543210fedcba98765432",
      request = "0x66756e6374696f6e4e616d65...",
    },

    example_response = {
      Result = 200,
      Response = "Function returned: success",
    },
  },
}
