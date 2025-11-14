# Python Client Module Generator
# Generates the main CircularProtocolAPI client class

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

# Helper: Convert path to PascalCase type name
let path_to_type_name = fun path =>
  # Remove leading slash
  let name = std.string.substring 1 (std.string.length path) path in
  let first_char = std.string.substring 0 1 name in
  let rest = std.string.substring 1 (std.string.length name) name in
  "%{std.string.uppercase first_char}%{rest}"
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
            %{response_type}: Dict containing the API response with Result and Response fields

        Raises:
            CircularProtocolError: If the API request fails
            APIConnectionError: If unable to connect to the API
            APITimeoutError: If the request times out
        \"\"\"
        data = {
%{if data_fields == "" then "" else "%{data_fields},\n"}            \"Version\": self.version,
        }
        return self._make_request('%{path_to_endpoint_name endpoint.path}', data)"
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

{
  client_code = "\"\"\"
Main API client for Circular Protocol.

This module contains the CircularProtocolAPI class which provides
access to all blockchain API endpoints.
\"\"\"

from typing import Dict, Optional
import requests
import json

from ._crypto import sign_message, verify_signature, get_public_key, hash_string
from ._helpers import (
    hex_fix,
    string_to_hex,
    hex_to_string,
    pad_number,
    get_formatted_timestamp,
    set_nag_url,
    get_nag_url,
    set_nag_key,
    get_nag_key,
    GetError,
    handle_error,
    get_transaction_outcome,
)
from .models import *
from .exceptions import (
    CircularProtocolError,
    APIConnectionError,
    APITimeoutError,
    AuthenticationError,
    InvalidSignatureError,
    InvalidNonceError,
    InvalidPayloadError,
    RateLimitError,
)


class CircularProtocolAPI:
    \"\"\"
    Circular Protocol API Client.

    Provides access to all Circular Protocol blockchain API endpoints with
    automatic request handling, error management, and response parsing.

    Attributes:
        base_url: Base URL of the API server
        api_key: Optional API key for authentication
        version: API version
        session: Requests session for connection pooling

    Example:
        >>> from circular_protocol_api import CircularProtocolAPI
        >>> api = CircularProtocolAPI()
        >>> result = api.check_wallet(
        ...     blockchain='MainNet',
        ...     address='0x...'
        ... )
        >>> print(result['Result'])
        200
    \"\"\"

    def __init__(
        self,
        base_url: Optional[str] = None,
        api_key: Optional[str] = None
    ):
        \"\"\"
        Initialize the Circular Protocol API client.

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
        Build complete URL for endpoint.

        Args:
            endpoint: API endpoint path

        Returns:
            str: Complete URL
        \"\"\"
        return f'{self.base_url}{endpoint}'

    # ============================================================================
    # Cryptographic Methods (delegated to _crypto module)
    # ============================================================================

    def sign_message(self, message: str, private_key: str) -> str:
        \"\"\"
        Sign a message using secp256k1 with DER encoding.

        Args:
            message: Message to sign (will be SHA256 hashed)
            private_key: Private key in hex format (with or without '0x' prefix)

        Returns:
            str: DER-encoded signature as hex string
        \"\"\"
        return sign_message(message, private_key)

    def verify_signature(self, public_key: str, message: str, signature: str) -> bool:
        \"\"\"
        Verify a DER-encoded signature.

        Args:
            public_key: Public key in hex format
            message: Original message that was signed
            signature: DER-encoded signature in hex format

        Returns:
            bool: True if signature is valid, False otherwise
        \"\"\"
        return verify_signature(public_key, message, signature)

    def get_public_key(self, private_key: str) -> str:
        \"\"\"
        Derive public key from private key.

        Args:
            private_key: Private key in hex format (with or without '0x' prefix)

        Returns:
            str: Public key in uncompressed hex format
        \"\"\"
        return get_public_key(private_key)

    def hash_string(self, string: str) -> str:
        \"\"\"
        Compute SHA256 hash of a string.

        Args:
            string: String to hash

        Returns:
            str: SHA256 hash as hex string
        \"\"\"
        return hash_string(string)

    # ============================================================================
    # Helper Methods (delegated to _helpers module)
    # ============================================================================

    def hex_fix(self, hex_string: str) -> str:
        \"\"\"Remove 0x prefix from hex string if present.\"\"\"
        return hex_fix(hex_string)

    def string_to_hex(self, string: str) -> str:
        \"\"\"Convert string to hex encoding.\"\"\"
        return string_to_hex(string)

    def hex_to_string(self, hex_string: str) -> str:
        \"\"\"Convert hex encoding to string.\"\"\"
        return hex_to_string(hex_string)

    def pad_number(self, num: int, length: int) -> str:
        \"\"\"Pad number with leading zeros.\"\"\"
        return pad_number(num, length)

    def get_formatted_timestamp(self) -> str:
        \"\"\"Get current timestamp in Circular Protocol format.\"\"\"
        return get_formatted_timestamp()

    def set_nag_url(self, url: str) -> None:
        \"\"\"Set NAG URL.\"\"\"
        set_nag_url(self, url)

    def get_nag_url(self) -> str:
        \"\"\"Get NAG URL.\"\"\"
        return get_nag_url(self)

    def set_nag_key(self, key: str) -> None:
        \"\"\"Set NAG API key.\"\"\"
        set_nag_key(self, key)

    def get_nag_key(self) -> Optional[str]:
        \"\"\"Get NAG API key.\"\"\"
        return get_nag_key(self)

    def GetError(self, code: int) -> str:
        \"\"\"Get error message for result code.\"\"\"
        return GetError(code)

    def handle_error(self, result: Dict) -> None:
        \"\"\"Handle API error responses.\"\"\"
        handle_error(result)

    def get_transaction_outcome(self, transaction_result: Dict) -> str:
        \"\"\"Get human-readable transaction outcome.\"\"\"
        return get_transaction_outcome(transaction_result)

    # ============================================================================
    # API Methods
    # ============================================================================

%{std.string.join "\n\n" methods}
",
}
