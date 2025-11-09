# Helper Function Test Specifications
# Defines test cases for crypto/utility helper functions

{
  # Address validation and formatting helpers
  address_helpers = {
    hex_fix = {
      description = "Normalize hex strings (add/remove 0x prefix, lowercase)",
      tests = [
        {
          name = "adds_0x_prefix_when_missing",
          input = "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
          expected = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
        },
        {
          name = "preserves_0x_prefix_when_present",
          input = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
          expected = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
        },
        {
          name = "converts_uppercase_to_lowercase",
          input = "0xABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890",
          expected = "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890",
        },
      ],
    },

    is_valid_address = {
      description = "Validate Circular Protocol addresses (64 or 66 chars, hex)",
      tests = [
        {
          name = "accepts_64_char_hex_without_prefix",
          input = "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
          expected = true,
        },
        {
          name = "accepts_66_char_hex_with_0x_prefix",
          input = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
          expected = true,
        },
        {
          name = "rejects_too_short",
          input = "0x123",
          expected = false,
        },
        {
          name = "rejects_non_hex_characters",
          input = "0xzzz4567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
          expected = false,
        },
      ],
    },
  },

  # Cryptographic hash helpers
  hash_helpers = {
    sha256_hash = {
      description = "Generate SHA256 hash of input string",
      tests = [
        {
          name = "hashes_simple_string",
          input = "hello world",
          expected = "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9",
        },
        {
          name = "hashes_empty_string",
          input = "",
          expected = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        },
      ],
    },
  },

  # Timestamp helpers
  timestamp_helpers = {
    get_timestamp = {
      description = "Generate Circular Protocol timestamp (YYYY-MM-DD:HH:MM:SS format)",
      tests = [
        {
          name = "formats_timestamp_correctly",
          input_description = "Date object or timestamp",
          expected_format = "YYYY-MM-DD:HH:MM:SS",
          validation = "matches regex pattern",
        },
      ],
    },

    is_valid_timestamp = {
      description = "Validate timestamp format",
      tests = [
        {
          name = "accepts_valid_format",
          input = "2024-01-15:14:30:45",
          expected = true,
        },
        {
          name = "rejects_invalid_format",
          input = "2024/01/15 14:30:45",
          expected = false,
        },
        {
          name = "rejects_incomplete_timestamp",
          input = "2024-01-15",
          expected = false,
        },
      ],
    },
  },

  # Hex encoding/decoding helpers
  hex_helpers = {
    to_hex = {
      description = "Convert string to hex representation",
      tests = [
        {
          name = "converts_ascii_to_hex",
          input = "hello",
          expected = "68656c6c6f",
        },
        {
          name = "converts_empty_string",
          input = "",
          expected = "",
        },
      ],
    },

    from_hex = {
      description = "Convert hex string to ASCII",
      tests = [
        {
          name = "converts_hex_to_ascii",
          input = "68656c6c6f",
          expected = "hello",
        },
        {
          name = "converts_empty_hex",
          input = "",
          expected = "",
        },
      ],
    },
  },

  # Number formatting helpers
  number_helpers = {
    to_wei = {
      description = "Convert amount to smallest unit (wei equivalent)",
      tests = [
        {
          name = "converts_1_to_wei",
          input = "1",
          expected = "1000000000000000000",
        },
        {
          name = "converts_0_to_wei",
          input = "0",
          expected = "0",
        },
      ],
    },

    from_wei = {
      description = "Convert from smallest unit to standard unit",
      tests = [
        {
          name = "converts_wei_to_standard",
          input = "1000000000000000000",
          expected = "1",
        },
        {
          name = "converts_0_wei",
          input = "0",
          expected = "0",
        },
      ],
    },
  },

  # Amount validation helpers
  validation_helpers = {
    is_valid_amount = {
      description = "Validate amount strings (non-negative integers only)",
      tests = [
        {
          name = "accepts_positive_integer",
          input = "1000",
          expected = true,
        },
        {
          name = "accepts_zero",
          input = "0",
          expected = true,
        },
        {
          name = "rejects_negative",
          input = "-100",
          expected = false,
        },
        {
          name = "rejects_decimal",
          input = "10.5",
          expected = false,
        },
        {
          name = "rejects_non_numeric",
          input = "abc",
          expected = false,
        },
      ],
    },
  },
}
