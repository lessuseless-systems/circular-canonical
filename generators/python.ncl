# Python SDK Generator for Circular Protocol
# Transforms Nickel API definitions into Python SDK code

let config = import "../src/config.ncl" in
let wallet = import "../src/api/wallet.ncl" in
let transaction = import "../src/api/transaction.ncl" in
let block = import "../src/api/block.ncl" in
let contract = import "../src/api/contract.ncl" in
let asset = import "../src/api/asset.ncl" in
let domain = import "../src/api/domain.ncl" in
let network = import "../src/api/network.ncl" in
let helpers = import "./helpers.ncl" in

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

  "    def %{method_name}(self%{if params == "" then "" else ", %{params}"}) -> Dict[str, Any]:
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
        return self._make_request('%{endpoint.path}', data)"
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

# Generate all methods
let methods = std.array.map generate_method all_endpoints in

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

from typing import Dict, Any, Optional
import requests
import json


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

        if self.api_key:
            self.session.headers['Authorization'] = f'Bearer {self.api_key}'

        self.session.headers['Content-Type'] = 'application/json'

    def _make_request(
        self,
        endpoint: str,
        data: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        \"\"\"
        Make an HTTP request to the API

        Args:
            endpoint: API endpoint path
            data: Request payload

        Returns:
            Parsed JSON response

        Raises:
            requests.exceptions.RequestException: If the request fails
        \"\"\"
        url = f'{self.base_url}{endpoint}'

        try:
            response = self.session.post(url, json=data)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            raise requests.exceptions.RequestException(
                f'API request failed: {e}'
            ) from e

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
# Type Aliases
# ============================================================================

# Common response structure
Response = Dict[str, Any]


# ============================================================================
# Version Information
# ============================================================================

__version__ = '%{config.version}'
__author__ = 'Circular Protocol'
__all__ = ['CircularProtocolAPI', 'Response']
",

  # Metadata
  metadata = {
    version = config.version,
    endpoints_count = std.array.length all_endpoints,
    language = "Python",
    python_version = "3.8+",
  },
}
