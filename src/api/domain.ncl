# Circular Protocol Canonacle - Domain API Endpoints
# Reference: docs/API_REFERENCE.md (Domains)

let types = import "../schemas/types.ncl" in

{
  getDomain = {
    method = "POST",
    path = "/getDomain",
    summary = "Resolve domain to wallet address",
    description = m%"
      Resolves a domain name to a wallet address.
      A single wallet can have multiple domain associations.
      Also known as resolveDomain.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where domain and wallet are registered",
        default = "MainNet",
      },

      name = {
        type = "string",
        required = true,
        description = "Domain name",
      },
    },

    request_body = {
      Blockchain = "string",
      Domain = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        Domain = "string",
        Address = "string",
      },
    },

    example_request = {
      blockchain = "MainNet",
      name = "alice.cir",
    },

    example_response = {
      Result = 200,
      Response = {
        Domain = "alice.cir",
        Address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      },
    },
  },
}
