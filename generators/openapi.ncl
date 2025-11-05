# OpenAPI 3.0 Generator for Circular Protocol Canonacle
# Transforms Nickel API definitions into OpenAPI specification

let config = import "../src/config.ncl" in
let wallet = import "../src/api/wallet.ncl" in
let transaction = import "../src/api/transaction.ncl" in
let block = import "../src/api/block.ncl" in
let contract = import "../src/api/contract.ncl" in
let asset = import "../src/api/asset.ncl" in
let domain = import "../src/api/domain.ncl" in
let network = import "../src/api/network.ncl" in

# Helper function to convert type metadata to OpenAPI schema
let rec type_to_schema = fun type_str =>
  if type_str == "string" then
    { type = "string" }
  else if type_str == "number" then
    { type = "number" }
  else if type_str == "boolean" then
    { type = "boolean" }
  else if std.is_record type_str then
    # Check if this is an array schema (has "type" = "array" field)
    if std.record.has_field "type" type_str && type_str.type == "array" then
      # Array schema
      {
        type = "array",
        items = type_to_schema type_str.items,
      }
    else
      # Nested object - recursively convert fields
      {
        type = "object",
        properties = std.record.map (fun _field value => type_to_schema value) type_str,
      }
  else
    { type = "string" }  # Fallback
in

# Convert endpoint definition to OpenAPI path item
let endpoint_to_path_item = fun endpoint =>
  let method_lower = std.string.lowercase endpoint.method in
  {
    "%{method_lower}" = {
      summary = endpoint.summary,
      description = endpoint.description,
      requestBody = {
        required = true,
        content = {
          "application/json" = {
            schema = {
              type = "object",
              properties = std.record.map
                (fun _field type_str => type_to_schema type_str)
                endpoint.request_body,
              required = std.record.fields endpoint.request_body,
            },
          },
        },
      },
      responses = {
        "200" = {
          description = "Successful response",
          content = {
            "application/json" = {
              schema = {
                type = "object",
                properties = std.record.map
                  (fun _field type_str => type_to_schema type_str)
                  endpoint.response_schema,
              },
            },
          },
        },
        "400" = {
          description = "Bad request - invalid parameters",
          content = {
            "application/json" = {
              schema = {
                type = "object",
                properties = {
                  Result = { type = "number" },
                  Response = { type = "string" },
                },
              },
            },
          },
        },
        "500" = {
          description = "Internal server error",
          content = {
            "application/json" = {
              schema = {
                type = "object",
                properties = {
                  Result = { type = "number" },
                  Response = { type = "string" },
                },
              },
            },
          },
        },
      },
    },
  }
in

# Main OpenAPI specification
{
  openapi = "3.0.0",

  info = {
    title = config.name,
    version = config.version,
    description = config.description,
  },

  servers = [
    {
      url = config.api.base_url,
      description = "Main API server",
    },
  ],

  paths = {
    # Wallet endpoints
    "%{wallet.checkWallet.path}" = endpoint_to_path_item wallet.checkWallet,
    "%{wallet.getWallet.path}" = endpoint_to_path_item wallet.getWallet,
    "%{wallet.getLatestTransactions.path}" = endpoint_to_path_item wallet.getLatestTransactions,
    "%{wallet.getWalletBalance.path}" = endpoint_to_path_item wallet.getWalletBalance,
    "%{wallet.getWalletNonce.path}" = endpoint_to_path_item wallet.getWalletNonce,
    "%{wallet.registerWallet.path}" = endpoint_to_path_item wallet.registerWallet,

    # Transaction endpoints
    "%{transaction.sendTransaction.path}" = endpoint_to_path_item transaction.sendTransaction,
    "%{transaction.getPendingTransaction.path}" = endpoint_to_path_item transaction.getPendingTransaction,
    "%{transaction.getTransactionbyID.path}" = endpoint_to_path_item transaction.getTransactionbyID,
    "%{transaction.getTransactionbyNode.path}" = endpoint_to_path_item transaction.getTransactionbyNode,
    "%{transaction.getTransactionbyAddress.path}" = endpoint_to_path_item transaction.getTransactionbyAddress,
    "%{transaction.getTransactionbyDate.path}" = endpoint_to_path_item transaction.getTransactionbyDate,

    # Block endpoints
    "%{block.getBlock.path}" = endpoint_to_path_item block.getBlock,
    "%{block.getBlockRange.path}" = endpoint_to_path_item block.getBlockRange,
    "%{block.getBlockCount.path}" = endpoint_to_path_item block.getBlockCount,
    "%{block.getAnalytics.path}" = endpoint_to_path_item block.getAnalytics,

    # Smart Contract endpoints
    "%{contract.testContract.path}" = endpoint_to_path_item contract.testContract,
    "%{contract.callContract.path}" = endpoint_to_path_item contract.callContract,

    # Asset endpoints
    "%{asset.getAssetList.path}" = endpoint_to_path_item asset.getAssetList,
    "%{asset.getAsset.path}" = endpoint_to_path_item asset.getAsset,
    "%{asset.getAssetSupply.path}" = endpoint_to_path_item asset.getAssetSupply,
    "%{asset.getVoucher.path}" = endpoint_to_path_item asset.getVoucher,

    # Domain endpoints
    "%{domain.getDomain.path}" = endpoint_to_path_item domain.getDomain,

    # Network endpoints
    "%{network.getBlockchains.path}" = endpoint_to_path_item network.getBlockchains,
  },

  components = {
    schemas = {
      # Common schemas can be defined here
      Error = {
        type = "object",
        properties = {
          Result = { type = "number" },
          Response = { type = "string" },
        },
        required = ["Result", "Response"],
      },
    },
  },
}
