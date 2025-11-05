# Circular Protocol Canonacle - Request Schemas
# Defines all API request schemas with contract validation applied

let types = import "./types.ncl" in

{
  # Wallet API Request Schemas

  CheckWalletRequest = {
    Blockchain | types.Blockchain,
    Address | types.Address,
    Version | String,
  },

  GetWalletRequest = {
    Blockchain | types.Blockchain,
    Address | types.Address,
    Version | String,
  },

  GetLatestTransactionsRequest = {
    Blockchain | types.Blockchain,
    Address | types.Address,
    Version | String,
  },

  GetWalletBalanceRequest = {
    Blockchain | types.Blockchain,
    Address | types.Address,
    Asset | types.AssetName,
    Version | String,
  },

  GetWalletNonceRequest = {
    Blockchain | types.Blockchain,
    Address | types.Address,
    Version | String,
  },

  RegisterWalletRequest = {
    Blockchain | types.Blockchain,
    PublicKey | String,  # Public key format validation could be added
    Version | String,
  },

  # Transaction API Request Schemas

  SendTransactionRequest = {
    ID | types.TransactionID,
    From | types.Address,
    To | types.Address,
    Timestamp | types.Timestamp,
    Type | String,
    Payload | String,
    Nonce | String,
    Signature | String,
    Blockchain | types.Blockchain,
    Version | String,
  },

  GetPendingTransactionRequest = {
    Blockchain | types.Blockchain,
    ID | types.TransactionID,
    Version | String,
  },

  GetTransactionbyIDRequest = {
    Blockchain | types.Blockchain,
    ID | types.TransactionID,
    Start | String,
    End | String,
    Version | String,
  },

  GetTransactionbyNodeRequest = {
    Blockchain | types.Blockchain,
    Node | String,
    Version | String,
  },

  GetTransactionbyAddressRequest = {
    Blockchain | types.Blockchain,
    Address | types.Address,
    Version | String,
  },

  GetTransactionbyDateRequest = {
    Blockchain | types.Blockchain,
    InitialDate | types.Timestamp,
    FinalDate | types.Timestamp,
    Version | String,
  },

  # Block API Request Schemas

  GetBlockRequest = {
    Blockchain | types.Blockchain,
    BlockNumber | String,
    Version | String,
  },

  GetBlockRangeRequest = {
    Blockchain | types.Blockchain,
    Start | String,
    End | String,
    Version | String,
  },

  GetBlockCountRequest = {
    Blockchain | types.Blockchain,
    Version | String,
  },

  GetAnalyticsRequest = {
    Blockchain | types.Blockchain,
    Version | String,
  },

  # Smart Contract API Request Schemas

  TestContractRequest = {
    Blockchain | types.Blockchain,
    From | types.Address,
    Project | String,
    Timestamp | types.Timestamp,
    Version | String,
  },

  CallContractRequest = {
    Blockchain | types.Blockchain,
    From | types.Address,
    Address | types.Address,
    Request | String,
    Timestamp | types.Timestamp,
    Version | String,
  },

  # Asset API Request Schemas

  GetAssetListRequest = {
    Blockchain | types.Blockchain,
    Version | String,
  },

  GetAssetRequest = {
    Blockchain | types.Blockchain,
    AssetName | types.AssetName,
    Version | String,
  },

  GetAssetSupplyRequest = {
    Blockchain | types.Blockchain,
    AssetName | types.AssetName,
    Version | String,
  },

  GetVoucherRequest = {
    Blockchain | types.Blockchain,
    Code | String,
    Version | String,
  },

  # Domain API Request Schemas

  GetDomainRequest = {
    Blockchain | types.Blockchain,
    Domain | types.DomainName,
    Version | String,
  },

  # Network API Request Schemas

  GetBlockchainsRequest = {
    Version | String | optional,
  },
}
