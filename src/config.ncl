# Circular Protocol Canonical - Base Configuration
# Single source of truth for version and common settings

{
  # Project metadata
  name = "Circular Protocol Canonical API",
  description = "Official API specification for Circular Protocol blockchain operations and wallet management",
  version = "1.0.8",

  # API Configuration
  api = {
    # Base URL (will be overridden by user's node selection)
    # Note: This is a placeholder URL for testing and development
    base_url = "https://api.circular.example",
    # Base protocol (http/https)
    protocol = "https",

    # API version path (if needed in future)
    version_path = "v1",

    # Default timeout in milliseconds
    timeout_ms = 30000,

    # Default retry attempts
    retry_attempts = 3,
  },

  # Network defaults
  network = {
    # Default blockchain
    default_blockchain = "MainNet",

    # Default node (will be set by user via setNode)
    default_node = "",
  },

  # Feature flags
  features = {
    # Enable request/response validation
    enable_validation = true,

    # Enable debug logging
    enable_debug = false,

    # Enable automatic retries
    enable_retries = true,
  },
}
