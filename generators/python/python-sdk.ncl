# Python SDK Generator for Circular Protocol
# Transforms Nickel API definitions into Python SDK code

let config = import "../../src/config.ncl" in
let wallet = import "../../src/api/wallet.ncl" in
let transaction = import "../../src/api/transaction.ncl" in
let block = import "../../src/api/block.ncl" in
let contract = import "../../src/api/contract.ncl" in
let asset = import "../../src/api/asset.ncl" in
let domain = import "../../src/api/domain.ncl" in
let network = import "../../src/api/network.ncl" in
let convenience_methods = import "../../src/api/convenience-methods.ncl" in
let helpers = import "../shared/helpers.ncl" in
let helpers_crypto = import "../shared/helpers-crypto.ncl" in
let helpers_encoding = import "../shared/helpers-encoding.ncl" in
let helpers_config = import "../shared/helpers-config.ncl" in
let helpers_advanced = import "../shared/helpers-advanced.ncl" in

# Helper: Convert endpoint path to NAG endpoint name
# /checkWallet -> CheckWallet
let path_to_endpoint_name = fun path =>
  let without_slash = if std.string.substring 0 1 path == "/" then
    std.string.substring 1 (std.string.length path) path
  else
    path
  in
  # Capitalize first letter
  let first_char = std.string.substring 0 1 without_slash in
  let rest = std.string.substring 1 (std.string.length without_slash) without_slash in
  (std.string.uppercase first_char) ++ rest
in

# Helper: Convert Nickel type to Python type
let rec nickel_type_to_python = fun type_str parent_name =>
  if type_str == "string" then "str"
  else if type_str == "number" then "int"
  else if type_str == "boolean" then "bool"
  else if std.is_record type_str then
    if std.record.has_field "type" type_str && type_str.type == "array" then
      # Array type - recursively convert items
      let items_type = nickel_type_to_python type_str.items "%{parent_name}Item" in
      "List[%{items_type}]"
    else
      # Nested object - return class name to be generated
      parent_name
  else "Any"
in

# Helper: Convert path to PascalCase type name
let path_to_type_name = fun path =>
  # Remove leading slash
  let name = std.string.substring 1 (std.string.length path) path in
  let first_char = std.string.substring 0 1 name in
  let rest = std.string.substring 1 (std.string.length name) name in
  "%{std.string.uppercase first_char}%{rest}"
in

# Helper: Generate TypedDict class for nested object
let rec generate_typeddict = fun class_name schema =>
  if std.is_record schema then
    if std.record.has_field "type" schema && schema.type == "array" then
      # For arrays, generate the item type
      generate_typeddict "%{class_name}Item" schema.items
    else
      # Generate class for object
      let fields = std.record.map
        (fun field type_str =>
          let python_type = nickel_type_to_python type_str "%{class_name}%{field}" in
          "    %{field}: %{python_type}")
        schema
      in
      let fields_list = std.record.values fields in
      let fields_str = if fields_list == [] then
        "    pass"  # Empty TypedDict needs pass statement
      else
        std.string.join "\n" fields_list
      in
      "class %{class_name}(TypedDict):\n%{fields_str}\n"
  else
    ""
in

# Helper: Generate all nested TypedDict classes for a schema
let rec collect_nested_typedicts = fun class_name schema =>
  if std.is_record schema then
    if std.record.has_field "type" schema && schema.type == "array" then
      # Recursively collect from array items
      collect_nested_typedicts "%{class_name}Item" schema.items
    else
      # Collect TypedDicts for all nested objects
      let nested_list = std.record.map
        (fun field type_str =>
          if std.is_record type_str then
            if std.record.has_field "type" type_str && type_str.type == "array" then
              # Nested array
              let item_class = "%{class_name}%{field}Item" in
              let item_typedicts = collect_nested_typedicts item_class type_str.items in
              let array_typedef = generate_typeddict "%{class_name}%{field}Item" type_str.items in
              if item_typedicts == "" then
                "%{array_typedef}\n"
              else
                "%{item_typedicts}%{array_typedef}\n"
            else
              # Nested object
              let nested_class = "%{class_name}%{field}" in
              let nested_typedicts = collect_nested_typedicts nested_class type_str in
              let typedef = generate_typeddict nested_class type_str in
              "%{nested_typedicts}%{typedef}\n"
          else
            "")
        schema
      in
      let nested_values = std.record.values nested_list in
      std.string.join "" nested_values
  else
    ""
in

# Helper: Generate Python method from endpoint
let generate_method = fun endpoint =>
  let method_name = helpers.path_to_snake_case."%{endpoint.path}" in

  # Filter out Version field since it's added automatically
  let request_fields = if std.record.has_field "Version" endpoint.request_body then
    std.record.remove "Version" endpoint.request_body
  else
    endpoint.request_body
  in

  # Generate parameters with snake_case names
  let params_list = std.record.map
    (fun field _type =>
      let param_name = if std.record.has_field field helpers.field_to_snake_case then
        helpers.field_to_snake_case."%{field}"
      else
        std.string.lowercase field
      in
      "%{param_name}: str")
    request_fields
  in
  let params = std.string.join ", " (std.record.values params_list) in

  # Generate data dictionary mapping snake_case params to PascalCase fields
  let data_mappings = std.record.map
    (fun field _type =>
      let param_name = if std.record.has_field field helpers.field_to_snake_case then
        helpers.field_to_snake_case."%{field}"
      else
        std.string.lowercase field
      in
      "            \"%{field}\": %{param_name}")
    request_fields
  in
  let data_fields = std.string.join ",\n" (std.record.values data_mappings) in

  let response_type = "%{path_to_type_name endpoint.path}Response" in
  "    def %{method_name}(self%{if params == "" then "" else ", %{params}"}) -> %{response_type}:
        \"\"\"
        %{endpoint.summary}

        %{endpoint.description}

        Args:
%{std.string.join "\n" (std.record.map (fun field _type => let pname = if std.record.has_field field helpers.field_to_snake_case then helpers.field_to_snake_case."%{field}" else std.string.lowercase field in "            %{pname}: %{field} parameter") request_fields |> std.record.values)}

        Returns:
            Dict containing the API response

        Raises:
            requests.exceptions.RequestException: If the API request fails
        \"\"\"
        data = {
%{if data_fields == "" then "" else "%{data_fields},\n"}            \"Version\": self.version,
        }
        return self._make_request('%{path_to_endpoint_name endpoint.path}', data)"
in

# Helper: Generate convenience method (wraps API calls)
let generate_convenience_method = fun method_name spec =>
  "    def %{method_name}(self, blockchain: str, public_key: str) -> dict:
        \"\"\"
        %{spec.summary} (Convenience Method)
        %{spec.description}

        This is a convenience method that wraps %{spec.wraps}().
        It handles transaction construction internally.

        Args:
            blockchain: Blockchain where the wallet will be registered
            public_key: Wallet public key (128 hex characters)

        Returns:
            dict: Same as send_transaction response
        \"\"\"
        from ._crypto import hash_string, get_public_key
        from ._encoding import string_to_hex, get_formatted_timestamp
        import json

        # Derive addresses from public key
        from_addr = hash_string(public_key)
        to_addr = from_addr
        nonce = '%{spec.implementation.nonce}'
        tx_type = '%{spec.implementation.transaction_type}'

        # Build payload
        payload_obj = {
            'Action': '%{spec.implementation.payload_structure.Action}',
            'PublicKey': public_key
        }
        payload = string_to_hex(json.dumps(payload_obj, separators=(',', ':')))
        timestamp = get_formatted_timestamp()

        # Calculate transaction ID
        tx_id = hash_string(blockchain + from_addr + to_addr + payload + nonce + timestamp)
        signature = '%{spec.implementation.signature}'

        # Call send_transaction
        return self.send_transaction(
            blockchain=blockchain,
            from_wallet=from_addr,
            to_wallet=to_addr,
            timestamp=timestamp,
            type=tx_type,
            payload=payload,
            nonce=nonce,
            signature=signature,
            id=tx_id
        )"
in

# Collect all endpoints (real API endpoints only - no convenience methods)
let all_endpoints = [
  wallet.checkWallet,
  wallet.getWallet,
  wallet.getLatestTransactions,
  wallet.getWalletBalance,
  wallet.getWalletNonce,
  # Note: registerWallet removed - it's now a convenience method, not an endpoint
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

# Generate all methods
let methods = std.array.map generate_method all_endpoints in

# Generate convenience methods
let convenience_method_specs = [
  { name = "register_wallet", spec = convenience_methods.registerWallet },
  # Future convenience methods can be added here
] in
let convenience_methods_code = std.array.map
  (fun item => generate_convenience_method item.name item.spec)
  convenience_method_specs
in

# Generate TypedDict classes for all endpoints
let generate_response_typedicts = fun endpoint =>
  let type_name = path_to_type_name endpoint.path in
  let response_class = "%{type_name}Response" in
  let response_schema = endpoint.response_schema in

  # Collect nested TypedDicts from Response field
  let response_field = response_schema.Response in
  let response_data_class = "%{response_class}Data" in

  # Determine if Response field is an array
  let is_array = std.is_record response_field && std.record.has_field "type" response_field && response_field.type == "array" in

  # For arrays, generate Item TypedDict
  let response_data_typedef = if is_array then
    generate_typeddict "%{response_data_class}Item" response_field.items
  else if std.is_record response_field then
    # For objects, generate the data TypedDict
    generate_typeddict response_data_class response_field
  else
    # For primitives (string, number, etc), no typedef needed
    ""
  in

  # Collect nested TypedDicts (for nested objects within the Response)
  let nested_typedicts = if is_array then
    collect_nested_typedicts "%{response_data_class}Item" response_field.items
  else
    collect_nested_typedicts response_data_class response_field
  in

  # Get the type for Response field
  let response_type = nickel_type_to_python response_field response_data_class in

  # Generate main response TypedDict
  let main_typedef = "class %{response_class}(TypedDict):\n    Result: int\n    Response: %{response_type}\n" in

  "%{nested_typedicts}%{response_data_typedef}%{main_typedef}"
in

let all_typedicts = std.array.map generate_response_typedicts all_endpoints in
let typedicts_code = std.string.join "\n" all_typedicts in

# Assemble the complete SDK
{
  sdk_code = "\"\"\"
Circular Protocol Python SDK
Generated from Nickel API specification
Version: %{config.version}

This SDK provides typed access to all Circular Protocol blockchain API endpoints.

Example:
    >>> from circular_protocol import CircularProtocolAPI
    >>> api = CircularProtocolAPI('https://api.circular.network')
    >>> result = api.check_wallet(
    ...     blockchain='MainNet',
    ...     address='0x...'
    ... )
    >>> print(result)
\"\"\"

from typing import Dict, List, Optional, TypedDict
import requests
import json
%{helpers_crypto.python.imports}


# ============================================================================
# TypedDict Response Types
# ============================================================================

%{typedicts_code}

# ============================================================================
# API Client
# ============================================================================

class CircularProtocolAPI:
    \"\"\"
    Circular Protocol API Client

    Provides access to all Circular Protocol blockchain API endpoints with
    automatic request handling, error management, and response parsing.

    Attributes:
        base_url: Base URL of the API server
        api_key: Optional API key for authentication
        version: API version
        session: Requests session for connection pooling

    Example:
        >>> api = CircularProtocolAPI('https://api.circular.network', api_key='your-key')
        >>> wallet = api.get_wallet(blockchain='MainNet', address='0x...')
    \"\"\"

    def __init__(
        self,
        base_url: Optional[str] = None,
        api_key: Optional[str] = None
    ):
        \"\"\"
        Initialize the Circular Protocol API client

        Args:
            base_url: Base URL of the API server (default: %{config.api.base_url})
            api_key: Optional API key for authentication
        \"\"\"
        self.base_url = base_url or '%{config.api.base_url}'
        self.api_key = api_key
        self.version = '%{config.version}'
        self.session = requests.Session()
        self.headers = {}

        if self.api_key:
            self.session.headers['Authorization'] = f'Bearer {self.api_key}'

        self.session.headers['Content-Type'] = 'application/json'
        %{std.string.replace_regex "\n" "\n        " helpers_config.python.fields}%{std.string.replace_regex "\n" "\n        " helpers_advanced.python.errorField}

    %{std.string.replace_regex "\n" "\n    " helpers_config.python.makeRequestUpdate}

    def _build_url(self, endpoint: str) -> str:
        \"\"\"
        Build complete URL for endpoint

        Args:
            endpoint: API endpoint path

        Returns:
            Complete URL
        \"\"\"
        return f'{self.base_url}{endpoint}'

    # ============================================================================
    # API Methods
    # ============================================================================

%{std.string.join "\n\n" methods}

    # ============================================================================
    # Convenience Methods
    # ============================================================================
    # These methods wrap underlying API calls to simplify common workflows

%{std.string.join "\n\n" convenience_methods_code}

    # ============================================================================
    # Helper Methods - Cryptography
    # ============================================================================

    %{std.string.replace_regex "\n" "\n    " helpers_crypto.python.signMessage}

    %{std.string.replace_regex "\n" "\n    " helpers_crypto.python.verifySignature}

    %{std.string.replace_regex "\n" "\n    " helpers_crypto.python.getPublicKey}

    %{std.string.replace_regex "\n" "\n    " helpers_crypto.python.hashString}

    # ============================================================================
    # Helper Methods - Encoding
    # ============================================================================

    %{std.string.replace_regex "\n" "\n    " helpers_encoding.python.hexFix}

    %{std.string.replace_regex "\n" "\n    " helpers_encoding.python.stringToHex}

    %{std.string.replace_regex "\n" "\n    " helpers_encoding.python.hexToString}

    %{std.string.replace_regex "\n" "\n    " helpers_encoding.python.padNumber}

    %{std.string.replace_regex "\n" "\n    " helpers_encoding.python.getFormattedTimestamp}

    # ============================================================================
    # Helper Methods - Configuration
    # ============================================================================

    %{std.string.replace_regex "\n" "\n    " helpers_config.python.setNAGURL}

    %{std.string.replace_regex "\n" "\n    " helpers_config.python.getNAGURL}

    %{std.string.replace_regex "\n" "\n    " helpers_config.python.setNAGKey}

    %{std.string.replace_regex "\n" "\n    " helpers_config.python.getNAGKey}

    # ============================================================================
    # Helper Methods - Advanced
    # ============================================================================

    %{std.string.replace_regex "\n" "\n    " helpers_advanced.python.GetError}

    %{std.string.replace_regex "\n" "\n    " helpers_advanced.python.handleError}

    %{std.string.replace_regex "\n" "\n    " helpers_advanced.python.getTransactionOutcome}


# ============================================================================
# Version Information
# ============================================================================

__version__ = '%{config.version}'
__author__ = 'Circular Protocol'
__all__ = ['CircularProtocolAPI']
",

  # Metadata
  metadata = {
    version = config.version,
    endpoints_count = std.array.length all_endpoints,
    language = "Python",
    python_version = "3.8+",
  },
}
