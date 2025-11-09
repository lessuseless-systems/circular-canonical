# Regression Test Specifications
# Layer 4b: Detects breaking changes between API versions
# Input: Rules for identifying breaking vs non-breaking changes
# Output: Used by regression test generator

let config = import "../../src/config.ncl" in

{
  test_suite_name = "API Regression Tests - Breaking Change Detection",
  description = "Compares current API with previous version to detect breaking changes",
  version = config.version,

  # Breaking change rules - these changes require MAJOR version bump
  breaking_changes = {
    removed_endpoint = {
      rule = "endpoint_removed",
      description = "API endpoint was removed",
      severity = "MAJOR",
      example = "DELETE /checkWallet from API",
      requires_migration = true,
    },

    removed_required_parameter = {
      rule = "required_parameter_removed",
      description = "Required parameter was removed from endpoint",
      severity = "MAJOR",
      example = "Address parameter removed from checkWallet",
      requires_migration = true,
    },

    changed_parameter_type = {
      rule = "parameter_type_changed",
      description = "Parameter type was changed",
      severity = "MAJOR",
      example = "Address changed from string to number",
      requires_migration = true,
    },

    changed_response_schema = {
      rule = "response_schema_changed",
      description = "Response structure was changed (fields removed or types changed)",
      severity = "MAJOR",
      example = "Response.exists field removed",
      requires_migration = true,
    },

    parameter_became_required = {
      rule = "parameter_now_required",
      description = "Optional parameter became required",
      severity = "MAJOR",
      example = "Version parameter now required",
      requires_migration = true,
    },

    endpoint_renamed = {
      rule = "endpoint_renamed",
      description = "Endpoint path or name changed",
      severity = "MAJOR",
      example = "/checkWallet renamed to /verifyWallet",
      requires_migration = true,
    },
  },

  # Non-breaking changes - these are safe, require MINOR/PATCH version bump
  non_breaking_changes = {
    added_endpoint = {
      rule = "endpoint_added",
      description = "New API endpoint added",
      severity = "MINOR",
      example = "Added /getDomain endpoint",
      requires_migration = false,
    },

    added_optional_parameter = {
      rule = "optional_parameter_added",
      description = "New optional parameter added to endpoint",
      severity = "MINOR",
      example = "Added Limit parameter to getLatestTransactions",
      requires_migration = false,
    },

    added_response_field = {
      rule = "response_field_added",
      description = "New field added to response",
      severity = "PATCH",
      example = "Added Response.timestamp field",
      requires_migration = false,
    },

    parameter_became_optional = {
      rule = "parameter_now_optional",
      description = "Required parameter became optional",
      severity = "MINOR",
      example = "Version parameter now optional",
      requires_migration = false,
    },

    documentation_updated = {
      rule = "documentation_changed",
      description = "Endpoint description or documentation updated",
      severity = "PATCH",
      example = "Updated checkWallet description",
      requires_migration = false,
    },

    example_updated = {
      rule = "example_changed",
      description = "Example request/response updated",
      severity = "PATCH",
      example = "Updated example values",
      requires_migration = false,
    },
  },

  # Comparison strategy
  comparison = {
    method = "openapi_diff",
    previous_source = "git_tag",  # Compare against latest git tag
    current_source = "generated",  # Current generated OpenAPI spec
    ignore_fields = [
      "info.version",  # Version number changes are expected
      "servers",  # Server URLs can change without breaking API
    ],
  },

  # Output configuration
  output = {
    exit_code_on_breaking = 1,
    exit_code_on_non_breaking = 0,
    exit_code_on_no_changes = 0,
    show_diff = true,
    diff_context_lines = 5,
    max_diff_lines = 50,
  },

  # Semantic versioning guidance
  versioning = {
    major_bump_required = ["endpoint_removed", "required_parameter_removed", "parameter_type_changed", "response_schema_changed", "parameter_now_required", "endpoint_renamed"],
    minor_bump_allowed = ["endpoint_added", "optional_parameter_added", "parameter_now_optional"],
    patch_bump_allowed = ["response_field_added", "documentation_changed", "example_changed"],
  },
}
