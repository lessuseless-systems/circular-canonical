# Rust SDK Generator for Circular Protocol
# Transforms Nickel API definitions into Rust SDK code
# Follows Rust idioms: Result types, async/await, strong type safety

let config = import "../../src/config.ncl" in
let wallet = import "../../src/api/wallet.ncl" in
let transaction = import "../../src/api/transaction.ncl" in
let block = import "../../src/api/block.ncl" in
let contract = import "../../src/api/contract.ncl" in
let asset = import "../../src/api/asset.ncl" in
let domain = import "../../src/api/domain.ncl" in
let network = import "../../src/api/network.ncl" in

# Helper: Convert Nickel type to Rust type
let nickel_type_to_rust = fun type_str =>
  if type_str == "string" then "String"
  else if type_str == "number" then "i64"
  else if type_str == "boolean" then "bool"
  else if std.is_record type_str then
    if std.record.has_field "type" type_str && type_str.type == "array" then
      "Vec<serde_json::Value>"
    else
      "serde_json::Map<String, serde_json::Value>"
  else "serde_json::Value"
in

# Helper: Convert to snake_case (Rust naming convention)
let to_snake_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  (std.string.lowercase first_char) ++ rest
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
    /// %{endpoint.summary}
    /// %{endpoint.description}
    pub async fn %{method_name}(&self, request: serde_json::Value) -> Result<serde_json::Value> {
        self.make_request("%{path_to_endpoint_name endpoint.path}", request).await
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
//! Circular Protocol Rust SDK
//!
//! Generated from Nickel API specification
//! Version: %{config.version}
//!
//! # Example
//!
//! ```no_run
//! use circular_protocol::Client;
//! use serde_json::json;
//!
//! #[tokio::main]
//! async fn main() -> Result<(), Box<dyn std::error::Error>> {
//!     let client = Client::new(
//!         "https://nag.circularlabs.io/NAG.php?cep=".to_string(),
//!         None,
//!     );
//!
//!     let result = client.check_wallet(json!({
//!         "Address": "0xd55872dbe508fd27445889b9d81bbc9411bb0f1353153a249f2fb34ef2690310",
//!         "Blockchain": "714d2ac07a826b66ac56752eebd7c77b58d2ee842e523d913fd0ef06e6bdfcae",
//!         "Version": "%{config.version}",
//!     })).await?;
//!
//!     println!("{:?}", result);
//!     Ok(())
//! }
//! ```

use reqwest;
use serde_json;
use std::collections::HashMap;
use std::time::Duration;

/// Result type for Circular Protocol API operations
pub type Result<T> = std::result::Result<T, Error>;

/// Error types for Circular Protocol API
#[derive(Debug, thiserror::Error)]
pub enum Error {
    #[error("HTTP error: {0}")]
    Http(#[from] reqwest::Error),

    #[error("JSON error: {0}")]
    Json(#[from] serde_json::Error),

    #[error("API error: {message} (code: {status_code}, endpoint: {endpoint})")]
    Api {
        message: String,
        status_code: i64,
        endpoint: String,
    },
}

/// Configuration for the Circular Protocol client
#[derive(Debug, Clone)]
pub struct Config {
    pub nag_url: String,
    pub nag_key: Option<String>,
    pub timeout: Duration,
    pub headers: HashMap<String, String>,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            nag_url: "https://nag.circularlabs.io/NAG.php?cep=".to_string(),
            nag_key: None,
            timeout: Duration::from_secs(30),
            headers: HashMap::new(),
        }
    }
}

/// Circular Protocol API client
#[derive(Debug, Clone)]
pub struct Client {
    nag_url: String,
    nag_key: Option<String>,
    http_client: reqwest::Client,
    headers: HashMap<String, String>,
}

impl Client {
    /// Create a new client with default configuration
    pub fn new(nag_url: String, nag_key: Option<String>) -> Self {
        Self::with_config(Config {
            nag_url,
            nag_key,
            ..Default::default()
        })
    }

    /// Create a new client with custom configuration
    pub fn with_config(config: Config) -> Self {
        let http_client = reqwest::Client::builder()
            .timeout(config.timeout)
            .build()
            .expect("Failed to build HTTP client");

        Self {
            nag_url: config.nag_url,
            nag_key: config.nag_key,
            http_client,
            headers: config.headers,
        }
    }

    /// Get the current NAG URL
    pub fn nag_url(&self) -> &str {
        &self.nag_url
    }

    /// Set the NAG URL
    pub fn set_nag_url(&mut self, url: String) {
        self.nag_url = url;
    }

    /// Get the current NAG key
    pub fn nag_key(&self) -> Option<&str> {
        self.nag_key.as_deref()
    }

    /// Set the NAG key
    pub fn set_nag_key(&mut self, key: Option<String>) {
        self.nag_key = key;
    }

    /// Set a custom header
    pub fn set_header(&mut self, key: String, value: String) {
        self.headers.insert(key, value);
    }

    /// Make an HTTP request to the NAG API
    async fn make_request(&self, endpoint: &str, data: serde_json::Value) -> Result<serde_json::Value> {
        let url = format!("{}Circular_{}_", self.nag_url, endpoint);

        // Build request
        let mut request = self.http_client
            .post(&url)
            .header("Content-Type", "application/json")
            .json(&data);

        // Add custom headers
        for (key, value) in &self.headers {
            request = request.header(key, value);
        }

        // Add NAG key if present
        if let Some(ref nag_key) = self.nag_key {
            request = request.header("X-NAG-Key", nag_key);
        }

        // Send request
        let response = request.send().await?;

        // Check HTTP status
        if !response.status().is_success() {
            return Err(Error::Api {
                message: format!("HTTP error: {}", response.status()),
                status_code: response.status().as_u16() as i64,
                endpoint: endpoint.to_string(),
            });
        }

        // Parse response
        let result: serde_json::Value = response.json().await?;

        // Check API-level errors
        let result_code = result.get("Result")
            .and_then(|v| v.as_i64())
            .unwrap_or(0);

        if result_code != 200 {
            let error_msg = result.get("Response")
                .and_then(|v| v.as_str())
                .unwrap_or("API request failed")
                .to_string();

            return Err(Error::Api {
                message: error_msg,
                status_code: result_code,
                endpoint: endpoint.to_string(),
            });
        }

        Ok(result)
    }

    // ============================================================================
    // API Methods
    // ============================================================================
%{std.string.join "\n" methods}
}
"%,

  # Metadata
  metadata = {
    version = config.version,
    endpoints_count = std.array.length all_endpoints,
    language = "Rust",
    target = "Rust 1.70+",
  },
}
