# PHP SDK Generator for Circular Protocol
# Transforms Nickel API definitions into PHP SDK code
# Applies lessons learned from TypeScript/Python/Java validation

let config = import "../../src/config.ncl" in
let wallet = import "../../src/api/wallet.ncl" in
let transaction = import "../../src/api/transaction.ncl" in
let block = import "../../src/api/block.ncl" in
let contract = import "../../src/api/contract.ncl" in
let asset = import "../../src/api/asset.ncl" in
let domain = import "../../src/api/domain.ncl" in
let network = import "../../src/api/network.ncl" in
let convenience_methods = import "../../src/api/convenience-methods.ncl" in

# Helper: Convert Nickel type to PHP type hint
let nickel_type_to_php = fun type_str =>
  if type_str == "string" then "string"
  else if type_str == "number" then "int"
  else if type_str == "boolean" then "bool"
  else if std.is_record type_str then
    if std.record.has_field "type" type_str && type_str.type == "array" then
      "array"
    else
      "array"
  else "mixed"
in

# Helper: Convert PascalCase to snake_case
let to_snake_case = fun str =>
  # Simple conversion - could be enhanced
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  "%{std.string.lowercase first_char}%{rest}"
in

# Helper: Extract endpoint name from path
let endpoint_name_from_path = fun path =>
  std.string.substring 1 (std.string.length path) path
in

# Helper: Convert path to NAG endpoint name (CheckWallet not checkWallet)
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

# Helper: Generate method
let generate_method = fun endpoint =>
  let method_name = to_snake_case (endpoint_name_from_path endpoint.path) in

  m%"
    /**
     * %{endpoint.summary}
     * %{endpoint.description}
     *
     * @param array $request Request parameters
     * @return array Response with Result and Response fields
     * @throws CircularProtocolException
     */
    public function %{method_name}(array $request): array
    {
        return $this->makeRequest('%{path_to_endpoint_name endpoint.path}', $request);
    }
"%
in

# Helper: Generate convenience method (wraps API calls)
let generate_convenience_method = fun method_name spec =>
  m%"
    /**
     * %{spec.summary} (Convenience Method)
     * %{spec.description}
     *
     * This is a convenience method that wraps %{spec.wraps}().
     * It handles transaction construction internally.
     *
     * @param string $blockchain Blockchain where the wallet will be registered
     * @param string $publicKey Wallet public key (128 hex characters)
     * @return array Same as send_transaction response
     * @throws CircularProtocolException
     */
    public function %{method_name}(string $blockchain, string $publicKey): array
    {
        // Derive addresses from public key
        $from = $this->hashString($publicKey);
        $to = $from;
        $nonce = '%{spec.implementation.nonce}';
        $type = '%{spec.implementation.transaction_type}';

        // Build payload
        $payloadObj = [
            'Action' => '%{spec.implementation.payload_structure.Action}',
            'PublicKey' => $publicKey
        ];
        $payload = $this->stringToHex(json_encode($payloadObj, JSON_UNESCAPED_SLASHES));
        $timestamp = $this->getFormattedTimestamp();

        // Calculate transaction ID
        $id = $this->hashString($blockchain . $from . $to . $payload . $nonce . $timestamp);
        $signature = '%{spec.implementation.signature}';

        // Build request
        $request = [
            'ID' => $id,
            'From' => $from,
            'To' => $to,
            'Timestamp' => $timestamp,
            'Type' => $type,
            'Payload' => $payload,
            'Nonce' => $nonce,
            'Signature' => $signature,
            'Blockchain' => $blockchain,
            'Version' => '%{config.version}'
        ];

        // Call sendTransaction
        return $this->send_transaction($request);
    }
"%
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

# Assemble the complete SDK
{
  sdk_code = m%"
<?php

namespace Circular\Protocol;

use Exception;

/**
 * Circular Protocol PHP SDK
 * Generated from Nickel API specification
 * Version: %{config.version}
 *
 * Provides access to all Circular Protocol blockchain API endpoints.
 *
 * Example usage:
 * <code>
 * $api = new CircularProtocolAPI();
 * $response = $api->checkWallet([
 *     'Address' => '0x...',
 *     'Blockchain' => 'MainNet',
 *     'Version' => '%{config.version}'
 * ]);
 * </code>
 */
class CircularProtocolAPI
{
    /** @var string NAG endpoint URL */
    private string $nagUrl;

    /** @var string NAG API key */
    private string $nagKey;

    /** @var array<string, string> HTTP headers */
    private array $headers;

    /**
     * Create a new Circular Protocol API client
     *
     * @param string|null $nagUrl Optional NAG endpoint URL
     * @param string|null $nagKey Optional NAG API key
     */
    public function __construct(?string $nagUrl = null, ?string $nagKey = null)
    {
        $this->nagUrl = $nagUrl ?? 'https://nag.circularlabs.io/NAG.php?cep=';
        $this->nagKey = $nagKey ?? '';
        $this->headers = [];
    }

    /**
     * Set custom NAG endpoint URL
     *
     * @param string $url NAG endpoint URL
     * @return void
     */
    public function setNagUrl(string $url): void
    {
        $this->nagUrl = $url;
    }

    /**
     * Get current NAG endpoint URL
     *
     * @return string Current NAG URL
     */
    public function getNagUrl(): string
    {
        return $this->nagUrl;
    }

    /**
     * Set NAG API key for authenticated requests
     *
     * @param string $key API key
     * @return void
     */
    public function setNagKey(string $key): void
    {
        $this->nagKey = $key;
    }

    /**
     * Get current NAG API key
     *
     * @return string Current NAG key
     */
    public function getNagKey(): string
    {
        return $this->nagKey;
    }

    /**
     * Make HTTP request to NAG endpoint
     *
     * @param string $endpoint Endpoint path (e.g., '/checkWallet')
     * @param array $data Request payload
     * @return array Full API response with Result and Response fields
     * @throws CircularProtocolException
     */
    private function makeRequest(string $endpoint, array $data): array
    {
        $url = $this->nagUrl . 'Circular_' . $endpoint . '_';

        // Build headers
        $headers = array_merge($this->headers, [
            'Content-Type' => 'application/json',
        ]);

        // Add NAG key if set
        if (!empty($this->nagKey)) {
            $headers['X-NAG-Key'] = $this->nagKey;
        }

        // Format headers for curl
        $curlHeaders = [];
        foreach ($headers as $key => $value) {
            $curlHeaders[] = "$key: $value";
        }

        // Initialize curl
        $ch = curl_init($url);
        if ($ch === false) {
            throw new CircularProtocolException('Failed to initialize curl', 0, $endpoint);
        }

        // Set curl options
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($data),
            CURLOPT_HTTPHEADER => $curlHeaders,
            CURLOPT_TIMEOUT => 30,
        ]);

        // Execute request
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        // Check for curl errors
        if ($response === false) {
            throw new CircularProtocolException(
                "Request failed: $error",
                0,
                $endpoint
            );
        }

        // Check HTTP status
        if ($httpCode !== 200) {
            throw new CircularProtocolException(
                "API error: HTTP $httpCode",
                $httpCode,
                $endpoint
            );
        }

        // Parse JSON response
        $result = json_decode($response, true);
        if ($result === null && json_last_error() !== JSON_ERROR_NONE) {
            throw new CircularProtocolException(
                'Failed to parse JSON response: ' . json_last_error_msg(),
                0,
                $endpoint
            );
        }

        // Check API-level errors
        if (!isset($result['Result']) || $result['Result'] !== 200) {
            $errorMsg = $result['Response'] ?? 'API request failed';
            $resultCode = $result['Result'] ?? 0;
            throw new CircularProtocolException($errorMsg, $resultCode, $endpoint);
        }

        // Return full response (with Result and Response fields)
        return $result;
    }

    // ============================================================================
    // API Methods
    // ============================================================================
%{std.string.join "\n" methods}

    // ============================================================================
    // Convenience Methods
    // ============================================================================
    // These methods wrap underlying API calls to simplify common workflows

%{std.string.join "\n" convenience_methods_code}
}

/**
 * Exception thrown when API requests fail
 */
class CircularProtocolException extends Exception
{
    /** @var int HTTP status code or API result code */
    private int $statusCode;

    /** @var string Endpoint that failed */
    private string $endpoint;

    /**
     * @param string $message Error message
     * @param int $statusCode HTTP or API status code
     * @param string $endpoint Endpoint path
     */
    public function __construct(string $message, int $statusCode, string $endpoint)
    {
        parent::__construct($message);
        $this->statusCode = $statusCode;
        $this->endpoint = $endpoint;
    }

    /**
     * Get status code
     *
     * @return int
     */
    public function getStatusCode(): int
    {
        return $this->statusCode;
    }

    /**
     * Get endpoint
     *
     * @return string
     */
    public function getEndpoint(): string
    {
        return $this->endpoint;
    }
}
"%,

  # Metadata
  metadata = {
    version = config.version,
    endpoints_count = std.array.length all_endpoints,
    language = "PHP",
    target = "PHP 8.0+",
  },
}
