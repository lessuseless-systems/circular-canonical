# Java SDK Generator for Circular Protocol
# Transforms Nickel API definitions into Java SDK code
# Applies lessons learned from TypeScript/Python validation

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

# Helper: Convert Nickel type to Java type
let rec nickel_type_to_java = fun type_str =>
  if type_str == "string" then "String"
  else if type_str == "number" then "Long"
  else if type_str == "boolean" then "Boolean"
  else if std.is_record type_str then
    if std.record.has_field "type" type_str && type_str.type == "array" then
      "List<%{nickel_type_to_java type_str.items}>"
    else
      # For complex types, we'll use Map<String, Object>
      "Map<String, Object>"
  else "Object"
in

# Helper: Convert PascalCase to camelCase
let to_camel_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  "%{std.string.lowercase first_char}%{rest}"
in

# Helper: Extract endpoint name from path
let endpoint_name_from_path = fun path =>
  # Remove leading slash
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

# Helper: Generate Java POJO class for request
let generate_request_class = fun endpoint =>
  let class_name = "%{endpoint_name_from_path endpoint.path}Request" in
  let fields = std.record.map
    (fun field_name field_type =>
      "    private %{nickel_type_to_java field_type} %{to_camel_case field_name};")
    endpoint.request_body
  in
  let getters_setters = std.record.map
    (fun field_name field_type =>
      let camel_name = to_camel_case field_name in
      let java_type = nickel_type_to_java field_type in
      m%"
    public %{java_type} get%{field_name}() {
        return this.%{camel_name};
    }

    public void set%{field_name}(%{java_type} %{camel_name}) {
        this.%{camel_name} = %{camel_name};
    }
"%    )
    endpoint.request_body
  in

  m%"
/**
 * Request object for %{endpoint.summary}
 */
public static class %{class_name} {
%{std.string.join "\n" (std.record.values fields)}

%{std.string.join "\n" (std.record.values getters_setters)}
}
"%
in

# Helper: Generate Java POJO class for response
let generate_response_class = fun endpoint =>
  let class_name = "%{endpoint_name_from_path endpoint.path}Response" in
  let response_type = nickel_type_to_java endpoint.response_schema in

  m%"
/**
 * Response object for %{endpoint.summary}
 * Wraps the API response with Result code and Response data
 */
public static class %{class_name} {
    private Integer result;
    private %{response_type} response;

    public Integer getResult() {
        return this.result;
    }

    public void setResult(Integer result) {
        this.result = result;
    }

    public %{response_type} getResponse() {
        return this.response;
    }

    public void setResponse(%{response_type} response) {
        this.response = response;
    }
}
"%
in

# Helper: Generate method
let generate_method = fun endpoint =>
  let method_name = to_camel_case (endpoint_name_from_path endpoint.path) in
  let request_class = "%{endpoint_name_from_path endpoint.path}Request" in
  let response_class = "%{endpoint_name_from_path endpoint.path}Response" in

  m%"
    /**
     * %{endpoint.summary}
     * %{endpoint.description}
     *
     * @param request The request parameters
     * @return CompletableFuture containing the response
     * @throws CircularProtocolException if the API request fails
     */
    public CompletableFuture<%{response_class}> %{method_name}(%{request_class} request) {
        return makeRequest("%{path_to_endpoint_name endpoint.path}", request, %{response_class}.class);
    }
"%
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

# Generate all request classes
let request_classes = std.array.map generate_request_class all_endpoints in

# Generate all response classes
let response_classes = std.array.map generate_response_class all_endpoints in

# Generate all methods
let methods = std.array.map generate_method all_endpoints in

# Assemble the complete SDK
{
  sdk_code = m%"
package io.circular.protocol;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;

/**
 * Circular Protocol Java SDK
 * Generated from Nickel API specification
 * Version: %{config.version}
 *
 * Provides typed access to all Circular Protocol blockchain API endpoints.
 *
 * Example usage:
 * <pre>
 * CircularProtocolAPI api = new CircularProtocolAPI();
 * CircularProtocolAPI.checkWalletRequest request = new CircularProtocolAPI.checkWalletRequest();
 * request.setAddress("0x...");
 * request.setBlockchain("MainNet");
 * request.setVersion("%{config.version}");
 *
 * CompletableFuture<CircularProtocolAPI.checkWalletResponse> future = api.checkWallet(request);
 * CircularProtocolAPI.checkWalletResponse response = future.get();
 * </pre>
 */
public class CircularProtocolAPI {
    private final HttpClient httpClient;
    private final ObjectMapper objectMapper;
    private final Map<String, String> headers;
    private String nagUrl;
    private String nagKey;

    /**
     * Create a new Circular Protocol API client
     *
     * @param nagUrl Optional NAG endpoint URL (default: https://nag.circularlabs.io/NAG.php?cep=)
     * @param nagKey Optional NAG API key for authentication
     */
    public CircularProtocolAPI(String nagUrl, String nagKey) {
        this.httpClient = HttpClient.newHttpClient();
        this.objectMapper = new ObjectMapper();
        this.headers = new HashMap<>();
        this.nagUrl = nagUrl != null ? nagUrl : "https://nag.circularlabs.io/NAG.php?cep=";
        this.nagKey = nagKey != null ? nagKey : "";
    }

    /**
     * Create a new Circular Protocol API client with default NAG URL
     */
    public CircularProtocolAPI() {
        this(null, null);
    }

    /**
     * Set custom NAG endpoint URL
     * @param url NAG endpoint URL
     */
    public void setNagUrl(String url) {
        this.nagUrl = url;
    }

    /**
     * Get current NAG endpoint URL
     * @return Current NAG URL
     */
    public String getNagUrl() {
        return this.nagUrl;
    }

    /**
     * Set NAG API key for authenticated requests
     * @param key API key
     */
    public void setNagKey(String key) {
        this.nagKey = key;
    }

    /**
     * Get current NAG API key
     * @return Current NAG key
     */
    public String getNagKey() {
        return this.nagKey;
    }

    /**
     * Make HTTP request to NAG endpoint
     *
     * @param endpoint Endpoint path (e.g., '/checkWallet')
     * @param requestData Request payload object
     * @param responseClass Class of the response type
     * @return CompletableFuture containing the response
     * @throws CircularProtocolException if the API request fails
     */
    private <T, R> CompletableFuture<R> makeRequest(String endpoint, T requestData, Class<R> responseClass) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                String url = this.nagUrl + "Circular_" + endpoint + "_";

                // Build headers
                Map<String, String> requestHeaders = new HashMap<>(this.headers);
                requestHeaders.put("Content-Type", "application/json");
                if (this.nagKey != null && !this.nagKey.isEmpty()) {
                    requestHeaders.put("X-NAG-Key", this.nagKey);
                }

                // Serialize request
                String requestBody = objectMapper.writeValueAsString(requestData);

                // Build HTTP request
                HttpRequest.Builder requestBuilder = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody));

                // Add headers
                requestHeaders.forEach(requestBuilder::header);

                HttpRequest request = requestBuilder.build();

                // Send request
                HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

                // Check HTTP status
                if (response.statusCode() != 200) {
                    throw new CircularProtocolException(
                        "API error: HTTP " + response.statusCode(),
                        response.statusCode(),
                        endpoint
                    );
                }

                // Parse response
                Map<String, Object> result = objectMapper.readValue(
                    response.body(),
                    new TypeReference<Map<String, Object>>() {}
                );

                // Check API-level errors
                Integer resultCode = (Integer) result.get("Result");
                if (resultCode == null || resultCode != 200) {
                    String errorMsg = result.get("Response") != null
                        ? result.get("Response").toString()
                        : "API request failed";
                    throw new CircularProtocolException(errorMsg, resultCode != null ? resultCode : 0, endpoint);
                }

                // Return full response (with Result and Response fields)
                return objectMapper.convertValue(result, responseClass);

            } catch (CircularProtocolException e) {
                throw e;
            } catch (Exception e) {
                throw new CircularProtocolException(
                    "Request failed: " + e.getMessage(),
                    0,
                    endpoint,
                    e
                );
            }
        });
    }

    // ============================================================================
    // API Methods
    // ============================================================================

%{std.string.join "\n" methods}

    // ============================================================================
    // Request/Response Classes
    // ============================================================================

%{std.string.join "\n" request_classes}

%{std.string.join "\n" response_classes}

    // ============================================================================
    // Exception Class
    // ============================================================================

    /**
     * Exception thrown when API requests fail
     */
    public static class CircularProtocolException extends RuntimeException {
        private final int statusCode;
        private final String endpoint;

        public CircularProtocolException(String message, int statusCode, String endpoint) {
            super(message);
            this.statusCode = statusCode;
            this.endpoint = endpoint;
        }

        public CircularProtocolException(String message, int statusCode, String endpoint, Throwable cause) {
            super(message, cause);
            this.statusCode = statusCode;
            this.endpoint = endpoint;
        }

        public int getStatusCode() {
            return statusCode;
        }

        public String getEndpoint() {
            return endpoint;
        }
    }
}
"%,

  # Metadata
  metadata = {
    version = config.version,
    endpoints_count = std.array.length all_endpoints,
    language = "Java",
    target = "Java 11+",
  },
}
