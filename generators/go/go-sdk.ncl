# Go SDK Generator for Circular Protocol
# Transforms Nickel API definitions into Go SDK code
# Follows Go idioms: exported types, error returns, struct-based API

let config = import "../../src/config.ncl" in
let wallet = import "../../src/api/wallet.ncl" in
let transaction = import "../../src/api/transaction.ncl" in
let block = import "../../src/api/block.ncl" in
let contract = import "../../src/api/contract.ncl" in
let asset = import "../../src/api/asset.ncl" in
let domain = import "../../src/api/domain.ncl" in
let network = import "../../src/api/network.ncl" in

# Helper: Convert Nickel type to Go type
let nickel_type_to_go = fun type_str =>
  if type_str == "string" then "string"
  else if type_str == "number" then "int64"
  else if type_str == "boolean" then "bool"
  else if std.is_record type_str then
    if std.record.has_field "type" type_str && type_str.type == "array" then
      "[]interface{}"
    else
      "map[string]interface{}"
  else "interface{}"
in

# Helper: Convert to PascalCase (Go exported names)
let to_pascal_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  (std.string.uppercase first_char) ++ rest
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
  let method_name = to_pascal_case (endpoint_name_from_path endpoint.path) in

  m%"
// %{method_name} %{endpoint.summary}
// %{endpoint.description}
func (c *Client) %{method_name}(ctx context.Context, req map[string]interface{}) (map[string]interface{}, error) {
	return c.makeRequest(ctx, "%{path_to_endpoint_name endpoint.path}", req)
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
  sdk_code = m%"
// Package circularprotocol provides a Go SDK for the Circular Protocol blockchain API.
// Generated from Nickel API specification
// Version: %{config.version}
//
// Example usage:
//
//	client := circularprotocol.NewClient("https://nag.circularlabs.io/NAG.php?cep=", "")
//	result, err := client.CheckWallet(context.Background(), map[string]interface{}{
//		"Address":    "0x...",
//		"Blockchain": "714d2ac07a826b66ac56752eebd7c77b58d2ee842e523d913fd0ef06e6bdfcae",
//		"Version":    "%{config.version}",
//	})
//	if err != nil {
//		log.Fatal(err)
//	}
package circularprotocol

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// Client represents a Circular Protocol API client
type Client struct {
	nagURL     string
	nagKey     string
	httpClient *http.Client
	headers    map[string]string
}

// Config holds client configuration options
type Config struct {
	NAGURL     string
	NAGKey     string
	Timeout    time.Duration
	HTTPClient *http.Client
	Headers    map[string]string
}

// APIError represents an error returned by the Circular Protocol API
type APIError struct {
	Message    string
	StatusCode int
	Endpoint   string
}

func (e *APIError) Error() string {
	return fmt.Sprintf("API error on %s (status %d): %s", e.Endpoint, e.StatusCode, e.Message)
}

// NewClient creates a new Circular Protocol API client
func NewClient(nagURL, nagKey string) *Client {
	return NewClientWithConfig(Config{
		NAGURL:  nagURL,
		NAGKey:  nagKey,
		Timeout: 30 * time.Second,
	})
}

// NewClientWithConfig creates a new client with custom configuration
func NewClientWithConfig(cfg Config) *Client {
	nagURL := cfg.NAGURL
	if nagURL == "" {
		nagURL = "https://nag.circularlabs.io/NAG.php?cep="
	}

	httpClient := cfg.HTTPClient
	if httpClient == nil {
		httpClient = &http.Client{
			Timeout: cfg.Timeout,
		}
		if cfg.Timeout == 0 {
			httpClient.Timeout = 30 * time.Second
		}
	}

	headers := cfg.Headers
	if headers == nil {
		headers = make(map[string]string)
	}

	return &Client{
		nagURL:     nagURL,
		nagKey:     cfg.NAGKey,
		httpClient: httpClient,
		headers:    headers,
	}
}

// SetNAGURL updates the NAG endpoint URL
func (c *Client) SetNAGURL(url string) {
	c.nagURL = url
}

// GetNAGURL returns the current NAG endpoint URL
func (c *Client) GetNAGURL() string {
	return c.nagURL
}

// SetNAGKey updates the NAG API key
func (c *Client) SetNAGKey(key string) {
	c.nagKey = key
}

// GetNAGKey returns the current NAG API key
func (c *Client) GetNAGKey() string {
	return c.nagKey
}

// SetHeader sets a custom HTTP header
func (c *Client) SetHeader(key, value string) {
	c.headers[key] = value
}

// makeRequest performs an HTTP request to the NAG API
func (c *Client) makeRequest(ctx context.Context, endpoint string, data map[string]interface{}) (map[string]interface{}, error) {
	url := c.nagURL + "Circular_" + endpoint + "_"

	// Marshal request data
	jsonData, err := json.Marshal(data)
	if err != nil {
		return nil, &APIError{
			Message:    fmt.Sprintf("failed to marshal request: %v", err),
			StatusCode: 0,
			Endpoint:   endpoint,
		}
	}

	// Create HTTP request
	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, &APIError{
			Message:    fmt.Sprintf("failed to create request: %v", err),
			StatusCode: 0,
			Endpoint:   endpoint,
		}
	}

	// Set headers
	req.Header.Set("Content-Type", "application/json")
	for key, value := range c.headers {
		req.Header.Set(key, value)
	}
	if c.nagKey != "" {
		req.Header.Set("X-NAG-Key", c.nagKey)
	}

	// Send request
	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, &APIError{
			Message:    fmt.Sprintf("request failed: %v", err),
			StatusCode: 0,
			Endpoint:   endpoint,
		}
	}
	defer resp.Body.Close()

	// Read response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, &APIError{
			Message:    fmt.Sprintf("failed to read response: %v", err),
			StatusCode: resp.StatusCode,
			Endpoint:   endpoint,
		}
	}

	// Check HTTP status
	if resp.StatusCode != http.StatusOK {
		return nil, &APIError{
			Message:    fmt.Sprintf("HTTP error: %s", resp.Status),
			StatusCode: resp.StatusCode,
			Endpoint:   endpoint,
		}
	}

	// Parse JSON response
	var result map[string]interface{}
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, &APIError{
			Message:    fmt.Sprintf("failed to parse response: %v", err),
			StatusCode: resp.StatusCode,
			Endpoint:   endpoint,
		}
	}

	// Check API-level errors
	resultCode, ok := result["Result"].(float64)
	if !ok || resultCode != 200 {
		errorMsg := "API request failed"
		if response, ok := result["Response"].(string); ok {
			errorMsg = response
		}
		return nil, &APIError{
			Message:    errorMsg,
			StatusCode: int(resultCode),
			Endpoint:   endpoint,
		}
	}

	// Return full response (with Result and Response fields)
	return result, nil
}

// ============================================================================
// API Methods
// ============================================================================
%{std.string.join "\n" methods}
"%,

  # Metadata
  metadata = {
    version = config.version,
    endpoints_count = std.array.length all_endpoints,
    language = "Go",
    target = "Go 1.19+",
  },
}
