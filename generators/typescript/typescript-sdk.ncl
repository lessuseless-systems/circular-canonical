# TypeScript SDK Generator for Circular Protocol
# Transforms Nickel API definitions into TypeScript SDK code

let config = import "../../src/config.ncl" in
let wallet = import "../../src/api/wallet.ncl" in
let transaction = import "../../src/api/transaction.ncl" in
let block = import "../../src/api/block.ncl" in
let contract = import "../../src/api/contract.ncl" in
let asset = import "../../src/api/asset.ncl" in
let domain = import "../../src/api/domain.ncl" in
let network = import "../../src/api/network.ncl" in
let helpers_crypto = import "../shared/helpers-crypto.ncl" in
let helpers_encoding = import "../shared/helpers-encoding.ncl" in
let helpers_config = import "../shared/helpers-config.ncl" in
let helpers_advanced = import "../shared/helpers-advanced.ncl" in

# Helper: Convert Nickel type to TypeScript type
let rec nickel_type_to_ts = fun type_str =>
  if type_str == "string" then "string"
  else if type_str == "number" then "number"
  else if type_str == "boolean" then "boolean"
  else if std.is_record type_str then
    if std.record.has_field "type" type_str && type_str.type == "array" then
      "Array<%{nickel_type_to_ts type_str.items}>"
    else
      # Generate inline object type with proper property types
      let props = std.record.map
        (fun field type => "%{field}: %{nickel_type_to_ts type}")
        type_str
      in
      let props_str = std.string.join "; " (std.record.values props) in
      "{ %{props_str} }"
  else "any"
in

# Helper: Convert PascalCase to camelCase
let to_camel_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  "%{std.string.lowercase first_char}%{rest}"
in

# Helper: Generate TypeScript interface from schema
let generate_interface = fun name schema =>
  let properties = std.record.map
    (fun field type_str =>
      "  %{field}: %{nickel_type_to_ts type_str};")
    schema
  in
  let props_list = std.record.values properties in
  let props_str = std.string.join "\n" props_list in
  "export interface %{name} {\n%{props_str}\n}"
in

# Helper: Extract endpoint name from path
let endpoint_name_from_path = fun path =>
  # Remove leading slash
  std.string.substring 1 (std.string.length path) path
in

# Helper: Generate method from endpoint
let generate_method = fun endpoint =>
  let method_name = to_camel_case (endpoint_name_from_path endpoint.path) in
  let request_interface = "%{endpoint_name_from_path endpoint.path}Request" in
  let response_interface = "%{endpoint_name_from_path endpoint.path}Response" in

  "  /**
   * %{endpoint.summary}
   * %{endpoint.description}
   */
  async %{method_name}(req: %{request_interface}): Promise<%{response_interface}> {
    return this._makeRequest('%{endpoint.path}', req);
  }"
in

# Collect all endpoints
let all_endpoints = [
  wallet.checkWallet,
  wallet.getWallet,
  wallet.getLatestTransactions,
  wallet.getWalletBalance,
  wallet.getWalletNonce,
  wallet.registerWallet,
  transaction.sendTransaction,
  transaction.getPendingTransaction,
  transaction.getTransactionbyID,
  transaction.getTransactionbyNode,
  transaction.getTransactionbyAddress,
  transaction.getTransactionbyDate,
  block.getBlock,
  block.getBlockRange,
  block.getBlockCount,
  block.getAnalytics,
  contract.testContract,
  contract.callContract,
  asset.getAssetList,
  asset.getAsset,
  asset.getAssetSupply,
  asset.getVoucher,
  domain.getDomain,
  network.getBlockchains,
] in

# Generate all request interfaces
let request_interfaces = std.array.map
  (fun endpoint =>
    let name = "%{endpoint_name_from_path endpoint.path}Request" in
    generate_interface name endpoint.request_body)
  all_endpoints
in

# Generate all response interfaces
let response_interfaces = std.array.map
  (fun endpoint =>
    let name = "%{endpoint_name_from_path endpoint.path}Response" in
    generate_interface name endpoint.response_schema)
  all_endpoints
in

# Generate all methods
let methods = std.array.map generate_method all_endpoints in

# Assemble the complete SDK
{
  sdk_code = "/**
 * Circular Protocol TypeScript SDK
 * Generated from Nickel API specification
 * Version: %{config.version}
 */

%{helpers_crypto.typescript.imports}

// ============================================================================
// Request Interfaces
// ============================================================================

%{std.string.join "\n\n" request_interfaces}

// ============================================================================
// Response Interfaces
// ============================================================================

%{std.string.join "\n\n" response_interfaces}

// ============================================================================
// Main API Client
// ============================================================================

/**
 * Circular Protocol API Client
 *
 * Provides typed access to all Circular Protocol blockchain API endpoints.
 *
 * @example
 * ```typescript
 * const api = new CircularProtocolAPI('https://api.circular.network');
 *
 * const result = await api.checkWallet({
 *   Blockchain: 'MainNet',
 *   Address: '0x...',
 *   Version: '%{config.version}'
 * });
 * ```
 */
export class CircularProtocolAPI {
  private readonly baseUrl: string;
  private readonly apiKey: string;
  private readonly headers: Record<string, string>;
%{helpers_config.typescript.fields}
%{helpers_advanced.typescript.errorField}

  /**
   * Create a new Circular Protocol API client
   *
   * @param baseUrl - Base URL of the API server (default: %{config.api.base_url})
   * @param apiKey - Optional API key for authentication
   */
  constructor(baseUrl?: string, apiKey?: string) {
    this.baseUrl = baseUrl || '%{config.api.base_url}';
    this.apiKey = apiKey || '';
    this.headers = {};
  }

%{helpers_config.typescript.makeRequestUpdate}

  // ============================================================================
  // API Methods
  // ============================================================================

%{std.string.join "\n\n" methods}

  // ============================================================================
  // Helper Methods - Cryptography
  // ============================================================================

%{helpers_crypto.typescript.signMessage}

%{helpers_crypto.typescript.verifySignature}

%{helpers_crypto.typescript.getPublicKey}

%{helpers_crypto.typescript.hashString}

  // ============================================================================
  // Helper Methods - Encoding
  // ============================================================================

%{helpers_encoding.typescript.hexFix}

%{helpers_encoding.typescript.stringToHex}

%{helpers_encoding.typescript.hexToString}

%{helpers_encoding.typescript.padNumber}

%{helpers_encoding.typescript.getFormattedTimestamp}

  // ============================================================================
  // Helper Methods - Configuration
  // ============================================================================

%{helpers_config.typescript.setNAGURL}

%{helpers_config.typescript.getNAGURL}

%{helpers_config.typescript.setNAGKey}

%{helpers_config.typescript.getNAGKey}

  // ============================================================================
  // Helper Methods - Advanced
  // ============================================================================

%{helpers_advanced.typescript.GetError}

%{helpers_advanced.typescript.handleError}

%{helpers_advanced.typescript.getTransactionOutcome}
}

// ============================================================================
// Types already exported above via export interface declarations
// ============================================================================
",

  # Metadata
  metadata = {
    version = config.version,
    endpoints_count = std.array.length all_endpoints,
    language = "TypeScript",
    target = "ES2015+",
  },
}
