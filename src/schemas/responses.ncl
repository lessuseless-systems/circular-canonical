# Circular Protocol Canonacle - Response Schemas
# Defines all API response schemas with contract validation applied

let types = import "./types.ncl" in

{
  # Standard API Response Envelope
  # All API responses follow this structure
  ApiResponse = {
    Result | types.ResultCode,
    Response,  # Actual type depends on endpoint
  },

  # Error Response (used by all endpoints)
  ErrorResponse = {
    Result | types.ResultCode,
    Response | String,  # Error message
  },

  # Wallet API Response Schemas

  CheckWalletResponse = {
    Result | types.ResultCode,
    Response | {
      exists | types.Boolean,
      address | types.Address,
    },
  },

  GetWalletResponse = {
    Result | types.ResultCode,
    Response | {
      Address | types.Address,
      Balance | types.Amount,
      Nonce | types.Nonce,
    },
  },

  # GetLatestTransactions returns an array of transactions
  GetLatestTransactionsResponse = {
    Result | types.ResultCode,
    Response,  # Array of transaction objects
  },

  GetWalletBalanceResponse = {
    Result | types.ResultCode,
    Response | {
      Balance | types.Amount,
      Asset | types.AssetName,
    },
  },

  GetWalletNonceResponse = {
    Result | types.ResultCode,
    Response | {
      Nonce | types.Nonce,
    },
  },

  RegisterWalletResponse = {
    Result | types.ResultCode,
    Response | {
      TransactionID | types.TransactionID,
      Status | String,
    },
  },

  # Transaction API Response Schemas

  SendTransactionResponse = {
    Result | types.ResultCode,
    Response | {
      TransactionID | types.TransactionID,
      Status | String,
    },
  },

  GetPendingTransactionResponse = {
    Result | types.ResultCode,
    Response | {
      ID | types.TransactionID,
      From | types.Address,
      To | types.Address,
      Timestamp | types.Timestamp,
      Type | String,
      Payload | String,
      Nonce | String,
      Signature | String,
      Status | String,
    },
  },

  GetTransactionbyIDResponse = {
    Result | types.ResultCode,
    Response | {
      ID | types.TransactionID,
      From | types.Address,
      To | types.Address,
      BlockNumber | types.BlockNumber,
      Timestamp | types.Timestamp,
      Type | String,
    },
  },

  GetTransactionbyNodeResponse = {
    Result | types.ResultCode,
    Response,  # Array of transaction objects
  },

  GetTransactionbyAddressResponse = {
    Result | types.ResultCode,
    Response,  # Array of transaction objects
  },

  GetTransactionbyDateResponse = {
    Result | types.ResultCode,
    Response,  # Array of transaction objects
  },

  # Block API Response Schemas

  GetBlockResponse = {
    Result | types.ResultCode,
    Response | {
      BlockNumber | types.BlockNumber,
      Timestamp | types.Timestamp,
      Transactions,  # Array of transactions
      Hash | String,
    },
  },

  GetBlockRangeResponse = {
    Result | types.ResultCode,
    Response,  # Array of block objects
  },

  GetBlockCountResponse = {
    Result | types.ResultCode,
    Response | {
      BlockCount | types.BlockNumber,
    },
  },

  GetAnalyticsResponse = {
    Result | types.ResultCode,
    Response | {
      TotalTransactions | Number,
      TotalWallets | Number,
      TotalAssets | Number,
      BlockHeight | types.BlockNumber,
    },
  },

  # Smart Contract API Response Schemas

  TestContractResponse = {
    Result | types.ResultCode,
    Response | String,  # Mixed result from contract execution
  },

  CallContractResponse = {
    Result | types.ResultCode,
    Response | String,  # Mixed result from contract execution
  },

  # Asset API Response Schemas

  GetAssetListResponse = {
    Result | types.ResultCode,
    Response,  # Array of asset objects with AssetName
  },

  GetAssetResponse = {
    Result | types.ResultCode,
    Response | {
      AssetName | types.AssetName,
      TotalSupply | Number,
      Decimals | Number,
      Owner | types.Address,
    },
  },

  GetAssetSupplyResponse = {
    Result | types.ResultCode,
    Response | {
      TotalSupply | Number,
      CirculatingSupply | Number,
      ResidualSupply | Number,
    },
  },

  GetVoucherResponse = {
    Result | types.ResultCode,
    Response | {
      Code | String,
      Value | Number,
      Asset | types.AssetName,
      Redeemed | types.Boolean,
    },
  },

  # Domain API Response Schemas

  GetDomainResponse = {
    Result | types.ResultCode,
    Response | {
      Domain | types.DomainName,
      Address | types.Address,
    },
  },

  # Network API Response Schemas

  GetBlockchainsResponse = {
    Result | types.ResultCode,
    Response,  # Array of blockchain objects with Name, ChainID, Active
  },
}
