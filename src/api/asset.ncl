# Circular Protocol Canonical - Asset API Endpoints
# Reference: docs/API_REFERENCE.md (Assets)

let types = import "../schemas/types.ncl" in

{
  getAssetList = {
    method = "POST",
    path = "/getAssetList",
    summary = "List all assets on blockchain",
    description = m%"
      Retrieves the list of all assets minted on a specific blockchain.
      Returns an array of asset information.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where to request the list",
        default = "MainNet",
      },
    },

    request_body = {
      Blockchain = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        type = "array",
        items = {
          AssetName = "string",
        },
      },
    },

    example_request = {
      blockchain = "MainNet",
    },

    example_response = {
      Result = 200,
      Response = [
        {
          AssetName = "CIRX",
        },
        {
          AssetName = "BTC",
        },
      ],
    },
  },

  getAsset = {
    method = "POST",
    path = "/getAsset",
    summary = "Get specific asset information",
    description = m%"
      Retrieves an asset descriptor with complete asset information.
      Returns detailed information about the specified asset.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where the asset is minted",
        default = "MainNet",
      },

      name = {
        type = "string",
        required = true,
        description = "Asset name (e.g., 'CIRX')",
      },
    },

    request_body = {
      Blockchain = "string",
      AssetName = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        AssetName = "string",
        TotalSupply = "number",
        Decimals = "number",
        Owner = "string",
      },
    },

    example_request = {
      blockchain = "MainNet",
      name = "CIRX",
    },

    example_response = {
      Result = 200,
      Response = {
        AssetName = "CIRX",
        TotalSupply = 1000000000,
        Decimals = 8,
        Owner = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      },
    },
  },

  getAssetSupply = {
    method = "POST",
    path = "/getAssetSupply",
    summary = "Get asset supply information",
    description = m%"
      Retrieves the total, circulating, and residual supply of a specified asset.
      Returns comprehensive supply metrics.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where the asset is minted",
        default = "MainNet",
      },

      name = {
        type = "string",
        required = true,
        description = "Asset name (e.g., 'CIRX')",
      },
    },

    request_body = {
      Blockchain = "string",
      AssetName = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        TotalSupply = "number",
        CirculatingSupply = "number",
        ResidualSupply = "number",
      },
    },

    example_request = {
      blockchain = "MainNet",
      name = "CIRX",
    },

    example_response = {
      Result = 200,
      Response = {
        TotalSupply = 1000000000,
        CirculatingSupply = 750000000,
        ResidualSupply = 250000000,
      },
    },
  },

  getVoucher = {
    method = "POST",
    path = "/getVoucher",
    summary = "Retrieve voucher information",
    description = m%"
      Retrieves an existing voucher by code.
      Code is automatically stripped of 0x prefix if present.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where the voucher was minted",
        default = "MainNet",
      },

      code = {
        type = "string",
        required = true,
        description = "Voucher code (with or without 0x prefix)",
      },
    },

    request_body = {
      Blockchain = "string",
      Code = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        Code = "string",
        Value = "number",
        Asset = "string",
        Redeemed = "boolean",
      },
    },

    example_request = {
      blockchain = "MainNet",
      code = "0xVOUCHERCODE123...",
    },

    example_response = {
      Result = 200,
      Response = {
        Code = "VOUCHERCODE123...",
        Value = 100,
        Asset = "CIRX",
        Redeemed = false,
      },
    },
  },
}
