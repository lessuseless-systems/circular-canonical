# Circular Protocol Canonical - Network API Endpoints
# Reference: docs/API_REFERENCE.md (Network)

let types = import "../schemas/types.ncl" in

{
  getBlockchains = {
    method = "POST",
    path = "/getBlockchains",
    summary = "List available blockchains",
    description = m%"
      Retrieves the list of blockchains available in the network.
      Returns information about all active and inactive blockchains.
    "%,

    parameters = {},

    request_body = {},

    response_schema = {
      Result = "number",
      Response = {
        type = "array",
        items = {
          Name = "string",
          ChainID = "string",
          Active = "boolean",
        },
      },
    },

    example_request = {},

    example_response = {
      Result = 200,
      Response = [
        {
          Name = "MainNet",
          ChainID = "1",
          Active = true,
        },
        {
          Name = "TestNet",
          ChainID = "2",
          Active = true,
        },
        {
          Name = "DevNet",
          ChainID = "3",
          Active = true,
        },
      ],
    },
  },
}
