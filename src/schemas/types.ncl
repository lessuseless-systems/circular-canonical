# Circular Protocol Canonical - Core Type Definitions
# Defines all custom types and contracts used across the API

{
  # Version (from config)
  Version = "2.0.8",

  # Address Contract
  # Validates wallet addresses (64 or 66 hex characters, with or without 0x prefix)
  Address = std.contract.from_predicate (fun value =>
    std.is_string value &&
    (let len = std.string.length value in
     let is_hex = std.string.is_match "^(0x)?[0-9a-fA-F]+$" value in
     is_hex && (len == 64 || len == 66))
  ),

  # Amount Contract
  # Non-negative number representing amounts in smallest unit
  Amount = std.contract.from_predicate (fun value =>
    std.is_number value && value >= 0
  ),

  # Blockchain Enum
  # Supported blockchain networks
  Blockchain = [| 'MainNet, 'TestNet, 'DevNet |],

  # Transaction ID Contract
  # Similar to Address contract (hash values)
  TransactionID = std.contract.from_predicate (fun value =>
    std.is_string value &&
    (let len = std.string.length value in
     let is_hex = std.string.is_match "^(0x)?[0-9a-fA-F]+$" value in
     is_hex && (len == 64 || len == 66))
  ),

  # AssetName Contract
  # Asset names are typically short strings (e.g., "CIRX")
  AssetName = std.contract.from_predicate (fun value =>
    std.is_string value &&
    (let len = std.string.length value in
     len > 0 && len <= 32)
  ),

  # Timestamp Contract
  # Formatted timestamp string (YYYY-MM-DD:HH:MM:SS)
  Timestamp = std.contract.from_predicate (fun value =>
    std.is_string value &&
    std.string.is_match "^[0-9]{4}-[0-9]{2}-[0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{2}$" value
  ),

  # Nonce Contract
  # Non-negative integer for transaction ordering
  Nonce = std.contract.from_predicate (fun value =>
    std.is_number value && value >= 0 && value == std.number.floor value
  ),

  # BlockNumber Contract
  # Positive integer for block identification
  BlockNumber = std.contract.from_predicate (fun value =>
    std.is_number value && value >= 0 && value == std.number.floor value
  ),

  # DomainName Contract
  # Domain names for wallet resolution
  DomainName = std.contract.from_predicate (fun value =>
    std.is_string value && std.string.length value > 0
  ),

  # Boolean Contract
  # Simple boolean validation
  Boolean = std.contract.from_predicate (fun value =>
    std.is_bool value
  ),

  # HTTP Method Enum
  HttpMethod = [| 'GET, 'POST, 'PUT, 'DELETE, 'PATCH |],

  # Result Code Contract
  # Standard HTTP-style result codes (200 = success, 500 = error, etc.)
  ResultCode = std.contract.from_predicate (fun value =>
    std.is_number value && value >= 100 && value < 600
  ),
}
