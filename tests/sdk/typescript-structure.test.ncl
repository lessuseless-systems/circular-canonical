# TypeScript SDK Structure Tests
# Defines expected structure of generated TypeScript SDK
# These tests run BEFORE the generator is implemented (TDD approach)

let config = import "../../src/config.ncl" in
let wallet = import "../../src/api/wallet.ncl" in
let transaction = import "../../src/api/transaction.ncl" in
let block = import "../../src/api/block.ncl" in
let contract = import "../../src/api/contract.ncl" in
let asset = import "../../src/api/asset.ncl" in
let domain = import "../../src/api/domain.ncl" in
let network = import "../../src/api/network.ncl" in

{
  test_name = "TypeScript SDK Structure Validation",

  # Expected SDK structure
  expected_structure = {
    # Main class that should be generated
    main_class = {
      name = "CircularProtocolAPI",
      constructor_params = ["baseUrl?: string", "apiKey?: string"],

      # Properties
      properties = {
        baseUrl = "private readonly baseUrl: string",
        apiKey = "private readonly apiKey: string",
        version = "private readonly version: string",
      },

      # All methods that should exist (from all API modules)
      methods = {
        # Wallet methods (6)
        checkWallet = {
          name = "checkWallet",
          params = ["req: CheckWalletRequest"],
          return_type = "Promise<CheckWalletResponse>",
        },
        getWallet = {
          name = "getWallet",
          params = ["req: GetWalletRequest"],
          return_type = "Promise<GetWalletResponse>",
        },
        getLatestTransactions = {
          name = "getLatestTransactions",
          params = ["req: GetLatestTransactionsRequest"],
          return_type = "Promise<GetLatestTransactionsResponse>",
        },
        getWalletBalance = {
          name = "getWalletBalance",
          params = ["req: GetWalletBalanceRequest"],
          return_type = "Promise<GetWalletBalanceResponse>",
        },
        getWalletNonce = {
          name = "getWalletNonce",
          params = ["req: GetWalletNonceRequest"],
          return_type = "Promise<GetWalletNonceResponse>",
        },
        registerWallet = {
          name = "registerWallet",
          params = ["req: RegisterWalletRequest"],
          return_type = "Promise<RegisterWalletResponse>",
        },

        # Transaction methods (6)
        sendTransaction = {
          name = "sendTransaction",
          params = ["req: SendTransactionRequest"],
          return_type = "Promise<SendTransactionResponse>",
        },
        getPendingTransaction = {
          name = "getPendingTransaction",
          params = ["req: GetPendingTransactionRequest"],
          return_type = "Promise<GetPendingTransactionResponse>",
        },
        getTransactionbyID = {
          name = "getTransactionbyID",
          params = ["req: GetTransactionbyIDRequest"],
          return_type = "Promise<GetTransactionbyIDResponse>",
        },
        getTransactionbyNode = {
          name = "getTransactionbyNode",
          params = ["req: GetTransactionbyNodeRequest"],
          return_type = "Promise<GetTransactionbyNodeResponse>",
        },
        getTransactionbyAddress = {
          name = "getTransactionbyAddress",
          params = ["req: GetTransactionbyAddressRequest"],
          return_type = "Promise<GetTransactionbyAddressResponse>",
        },
        getTransactionbyDate = {
          name = "getTransactionbyDate",
          params = ["req: GetTransactionbyDateRequest"],
          return_type = "Promise<GetTransactionbyDateResponse>",
        },

        # Block methods (4)
        getBlock = {
          name = "getBlock",
          params = ["req: GetBlockRequest"],
          return_type = "Promise<GetBlockResponse>",
        },
        getBlockRange = {
          name = "getBlockRange",
          params = ["req: GetBlockRangeRequest"],
          return_type = "Promise<GetBlockRangeResponse>",
        },
        getBlockCount = {
          name = "getBlockCount",
          params = ["req: GetBlockCountRequest"],
          return_type = "Promise<GetBlockCountResponse>",
        },
        getAnalytics = {
          name = "getAnalytics",
          params = ["req: GetAnalyticsRequest"],
          return_type = "Promise<GetAnalyticsResponse>",
        },

        # Contract methods (2)
        testContract = {
          name = "testContract",
          params = ["req: TestContractRequest"],
          return_type = "Promise<TestContractResponse>",
        },
        callContract = {
          name = "callContract",
          params = ["req: CallContractRequest"],
          return_type = "Promise<CallContractResponse>",
        },

        # Asset methods (4)
        getAssetList = {
          name = "getAssetList",
          params = ["req: GetAssetListRequest"],
          return_type = "Promise<GetAssetListResponse>",
        },
        getAsset = {
          name = "getAsset",
          params = ["req: GetAssetRequest"],
          return_type = "Promise<GetAssetResponse>",
        },
        getAssetSupply = {
          name = "getAssetSupply",
          params = ["req: GetAssetSupplyRequest"],
          return_type = "Promise<GetAssetSupplyResponse>",
        },
        getVoucher = {
          name = "getVoucher",
          params = ["req: GetVoucherRequest"],
          return_type = "Promise<GetVoucherResponse>",
        },

        # Domain methods (1)
        getDomain = {
          name = "getDomain",
          params = ["req: GetDomainRequest"],
          return_type = "Promise<GetDomainResponse>",
        },

        # Network methods (1)
        getBlockchains = {
          name = "getBlockchains",
          params = ["req: GetBlockchainsRequest"],
          return_type = "Promise<GetBlockchainsResponse>",
        },
      },
    },

    # Interfaces that should be generated
    interfaces = {
      # Request interfaces (24)
      request_interfaces = [
        "CheckWalletRequest",
        "GetWalletRequest",
        "GetLatestTransactionsRequest",
        "GetWalletBalanceRequest",
        "GetWalletNonceRequest",
        "RegisterWalletRequest",
        "SendTransactionRequest",
        "GetPendingTransactionRequest",
        "GetTransactionbyIDRequest",
        "GetTransactionbyNodeRequest",
        "GetTransactionbyAddressRequest",
        "GetTransactionbyDateRequest",
        "GetBlockRequest",
        "GetBlockRangeRequest",
        "GetBlockCountRequest",
        "GetAnalyticsRequest",
        "TestContractRequest",
        "CallContractRequest",
        "GetAssetListRequest",
        "GetAssetRequest",
        "GetAssetSupplyRequest",
        "GetVoucherRequest",
        "GetDomainRequest",
        "GetBlockchainsRequest",
      ],

      # Response interfaces (24)
      response_interfaces = [
        "CheckWalletResponse",
        "GetWalletResponse",
        "GetLatestTransactionsResponse",
        "GetWalletBalanceResponse",
        "GetWalletNonceResponse",
        "RegisterWalletResponse",
        "SendTransactionResponse",
        "GetPendingTransactionResponse",
        "GetTransactionbyIDResponse",
        "GetTransactionbyNodeResponse",
        "GetTransactionbyAddressResponse",
        "GetTransactionbyDateResponse",
        "GetBlockResponse",
        "GetBlockRangeResponse",
        "GetBlockCountResponse",
        "GetAnalyticsResponse",
        "TestContractResponse",
        "CallContractResponse",
        "GetAssetListResponse",
        "GetAssetResponse",
        "GetAssetSupplyResponse",
        "GetVoucherResponse",
        "GetDomainResponse",
        "GetBlockchainsResponse",
      ],

      # Common response structure
      common_response = {
        Result = "number",
        Response = "any",
      },
    },

    # Expected exports
    exports = {
      main_export = "export class CircularProtocolAPI",
      interface_exports = true,
      type_exports = true,
    },

    # Code quality requirements
    quality = {
      has_jsdoc_comments = true,
      has_error_handling = true,
      uses_fetch_api = true,
      uses_typescript_strict = true,
    },
  },

  # Validation rules
  validation_rules = {
    # Total method count
    total_methods = 24,

    # Total interfaces
    total_request_interfaces = 24,
    total_response_interfaces = 24,

    # Method naming
    method_names_camelCase = true,

    # All methods must be async
    all_methods_async = true,

    # All methods return Promise
    all_methods_return_promise = true,

    # Version must match config
    version_matches_config = config.version,
  },

  # Test metadata
  test_metadata = {
    description = "Validates that generated TypeScript SDK has correct structure",
    approach = "TDD - test written before generator implementation",
    validates = [
      "Class structure",
      "Method signatures",
      "TypeScript interfaces",
      "Error handling",
      "Export structure",
    ],
  },
}
