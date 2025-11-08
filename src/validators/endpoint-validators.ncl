# Circular Protocol Canonical - Endpoint Validators
# Provides validation functions that apply contracts to requests and responses

let requests = import "../schemas/requests.ncl" in
let responses = import "../schemas/responses.ncl" in

{
  # Wallet API Validators

  # checkWallet validators
  validate_checkWallet_request = fun req =>
    req | requests.CheckWalletRequest,

  validate_checkWallet_response_success = fun resp =>
    resp | responses.CheckWalletResponse,

  validate_checkWallet_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getWallet validators
  validate_getWallet_request = fun req =>
    req | requests.GetWalletRequest,

  validate_getWallet_response_success = fun resp =>
    resp | responses.GetWalletResponse,

  validate_getWallet_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getLatestTransactions validators
  validate_getLatestTransactions_request = fun req =>
    req | requests.GetLatestTransactionsRequest,

  validate_getLatestTransactions_response_success = fun resp =>
    resp | responses.GetLatestTransactionsResponse,

  validate_getLatestTransactions_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getWalletBalance validators
  validate_getWalletBalance_request = fun req =>
    req | requests.GetWalletBalanceRequest,

  validate_getWalletBalance_response_success = fun resp =>
    resp | responses.GetWalletBalanceResponse,

  validate_getWalletBalance_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getWalletNonce validators
  validate_getWalletNonce_request = fun req =>
    req | requests.GetWalletNonceRequest,

  validate_getWalletNonce_response_success = fun resp =>
    resp | responses.GetWalletNonceResponse,

  validate_getWalletNonce_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # registerWallet validators
  validate_registerWallet_request = fun req =>
    req | requests.RegisterWalletRequest,

  validate_registerWallet_response_success = fun resp =>
    resp | responses.RegisterWalletResponse,

  validate_registerWallet_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # Transaction API Validators

  # sendTransaction validators
  validate_sendTransaction_request = fun req =>
    req | requests.SendTransactionRequest,

  validate_sendTransaction_response_success = fun resp =>
    resp | responses.SendTransactionResponse,

  validate_sendTransaction_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getPendingTransaction validators
  validate_getPendingTransaction_request = fun req =>
    req | requests.GetPendingTransactionRequest,

  validate_getPendingTransaction_response_success = fun resp =>
    resp | responses.GetPendingTransactionResponse,

  validate_getPendingTransaction_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getTransactionbyID validators
  validate_getTransactionbyID_request = fun req =>
    req | requests.GetTransactionbyIDRequest,

  validate_getTransactionbyID_response_success = fun resp =>
    resp | responses.GetTransactionbyIDResponse,

  validate_getTransactionbyID_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getTransactionbyNode validators
  validate_getTransactionbyNode_request = fun req =>
    req | requests.GetTransactionbyNodeRequest,

  validate_getTransactionbyNode_response_success = fun resp =>
    resp | responses.GetTransactionbyNodeResponse,

  validate_getTransactionbyNode_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getTransactionbyAddress validators
  validate_getTransactionbyAddress_request = fun req =>
    req | requests.GetTransactionbyAddressRequest,

  validate_getTransactionbyAddress_response_success = fun resp =>
    resp | responses.GetTransactionbyAddressResponse,

  validate_getTransactionbyAddress_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getTransactionbyDate validators
  validate_getTransactionbyDate_request = fun req =>
    req | requests.GetTransactionbyDateRequest,

  validate_getTransactionbyDate_response_success = fun resp =>
    resp | responses.GetTransactionbyDateResponse,

  validate_getTransactionbyDate_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # Block API Validators

  # getBlock validators
  validate_getBlock_request = fun req =>
    req | requests.GetBlockRequest,

  validate_getBlock_response_success = fun resp =>
    resp | responses.GetBlockResponse,

  validate_getBlock_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getBlockRange validators
  validate_getBlockRange_request = fun req =>
    req | requests.GetBlockRangeRequest,

  validate_getBlockRange_response_success = fun resp =>
    resp | responses.GetBlockRangeResponse,

  validate_getBlockRange_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getBlockCount validators
  validate_getBlockCount_request = fun req =>
    req | requests.GetBlockCountRequest,

  validate_getBlockCount_response_success = fun resp =>
    resp | responses.GetBlockCountResponse,

  validate_getBlockCount_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getAnalytics validators
  validate_getAnalytics_request = fun req =>
    req | requests.GetAnalyticsRequest,

  validate_getAnalytics_response_success = fun resp =>
    resp | responses.GetAnalyticsResponse,

  validate_getAnalytics_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # Smart Contract API Validators

  # testContract validators
  validate_testContract_request = fun req =>
    req | requests.TestContractRequest,

  validate_testContract_response_success = fun resp =>
    resp | responses.TestContractResponse,

  validate_testContract_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # callContract validators
  validate_callContract_request = fun req =>
    req | requests.CallContractRequest,

  validate_callContract_response_success = fun resp =>
    resp | responses.CallContractResponse,

  validate_callContract_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # Asset API Validators

  # getAssetList validators
  validate_getAssetList_request = fun req =>
    req | requests.GetAssetListRequest,

  validate_getAssetList_response_success = fun resp =>
    resp | responses.GetAssetListResponse,

  validate_getAssetList_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getAsset validators
  validate_getAsset_request = fun req =>
    req | requests.GetAssetRequest,

  validate_getAsset_response_success = fun resp =>
    resp | responses.GetAssetResponse,

  validate_getAsset_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getAssetSupply validators
  validate_getAssetSupply_request = fun req =>
    req | requests.GetAssetSupplyRequest,

  validate_getAssetSupply_response_success = fun resp =>
    resp | responses.GetAssetSupplyResponse,

  validate_getAssetSupply_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # getVoucher validators
  validate_getVoucher_request = fun req =>
    req | requests.GetVoucherRequest,

  validate_getVoucher_response_success = fun resp =>
    resp | responses.GetVoucherResponse,

  validate_getVoucher_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # Domain API Validators

  # getDomain validators
  validate_getDomain_request = fun req =>
    req | requests.GetDomainRequest,

  validate_getDomain_response_success = fun resp =>
    resp | responses.GetDomainResponse,

  validate_getDomain_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # Network API Validators

  # getBlockchains validators
  validate_getBlockchains_request = fun req =>
    req | requests.GetBlockchainsRequest,

  validate_getBlockchains_response_success = fun resp =>
    resp | responses.GetBlockchainsResponse,

  validate_getBlockchains_response_error = fun resp =>
    resp | responses.ErrorResponse,
}
