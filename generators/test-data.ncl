# Test Data Aggregator
# Collects test data from all endpoint test files for test generation

let config = import "../src/config.ncl" in

# Import all endpoint test files
let checkWallet_test = import "../tests/endpoints/checkWallet.test.ncl" in
let getWallet_test = import "../tests/endpoints/getWallet.test.ncl" in
let getLatestTransactions_test = import "../tests/endpoints/getLatestTransactions.test.ncl" in
let getWalletBalance_test = import "../tests/endpoints/getWalletBalance.test.ncl" in
let getWalletNonce_test = import "../tests/endpoints/getWalletNonce.test.ncl" in
let registerWallet_test = import "../tests/endpoints/registerWallet.test.ncl" in
let sendTransaction_test = import "../tests/endpoints/sendTransaction.test.ncl" in
let getPendingTransaction_test = import "../tests/endpoints/getPendingTransaction.test.ncl" in
let getTransactionbyID_test = import "../tests/endpoints/getTransactionbyID.test.ncl" in
let getTransactionbyNode_test = import "../tests/endpoints/getTransactionbyNode.test.ncl" in
let getTransactionbyAddress_test = import "../tests/endpoints/getTransactionbyAddress.test.ncl" in
let getTransactionbyDate_test = import "../tests/endpoints/getTransactionbyDate.test.ncl" in
let getBlock_test = import "../tests/endpoints/getBlock.test.ncl" in
let getBlockRange_test = import "../tests/endpoints/getBlockRange.test.ncl" in
let getBlockCount_test = import "../tests/endpoints/getBlockCount.test.ncl" in
let getAnalytics_test = import "../tests/endpoints/getAnalytics.test.ncl" in
let testContract_test = import "../tests/endpoints/testContract.test.ncl" in
let callContract_test = import "../tests/endpoints/callContract.test.ncl" in
let getAssetList_test = import "../tests/endpoints/getAssetList.test.ncl" in
let getAsset_test = import "../tests/endpoints/getAsset.test.ncl" in
let getAssetSupply_test = import "../tests/endpoints/getAssetSupply.test.ncl" in
let getVoucher_test = import "../tests/endpoints/getVoucher.test.ncl" in
let getDomain_test = import "../tests/endpoints/getDomain.test.ncl" in
let getBlockchains_test = import "../tests/endpoints/getBlockchains.test.ncl" in

# Aggregated test data structure
{
  version = config.version,

  # All endpoint tests
  endpoints = {
    # Wallet API (6 endpoints)
    checkWallet = checkWallet_test,
    getWallet = getWallet_test,
    getLatestTransactions = getLatestTransactions_test,
    getWalletBalance = getWalletBalance_test,
    getWalletNonce = getWalletNonce_test,
    registerWallet = registerWallet_test,

    # Transaction API (6 endpoints)
    sendTransaction = sendTransaction_test,
    getPendingTransaction = getPendingTransaction_test,
    getTransactionbyID = getTransactionbyID_test,
    getTransactionbyNode = getTransactionbyNode_test,
    getTransactionbyAddress = getTransactionbyAddress_test,
    getTransactionbyDate = getTransactionbyDate_test,

    # Block API (4 endpoints)
    getBlock = getBlock_test,
    getBlockRange = getBlockRange_test,
    getBlockCount = getBlockCount_test,
    getAnalytics = getAnalytics_test,

    # Smart Contract API (2 endpoints)
    testContract = testContract_test,
    callContract = callContract_test,

    # Asset API (4 endpoints)
    getAssetList = getAssetList_test,
    getAsset = getAsset_test,
    getAssetSupply = getAssetSupply_test,
    getVoucher = getVoucher_test,

    # Domain API (1 endpoint)
    getDomain = getDomain_test,

    # Network API (1 endpoint)
    getBlockchains = getBlockchains_test,
  },

  # Metadata
  total_endpoints = 24,
  categories = {
    wallet = 6,
    transaction = 6,
    block = 4,
    contract = 2,
    asset = 4,
    domain = 1,
    network = 1,
  },
}
