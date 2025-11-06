# Python SDK Structure Tests
# Defines expected structure of generated Python SDK
# These tests run BEFORE the generator is implemented (TDD approach)

let config = import "../../src/config.ncl" in
let wallet = import "../../src/api/wallet.ncl" in
let transaction = import "../../src/api/transaction.ncl" in
let block = import "../../src/api/block.ncl" in
let contract = import "../../src/api/contract.ncl" in
let asset = import "../../src/api/asset.ncl" in
let domain = import "../../src/api/domain.ncl" in
let network = import "../../src/api/network.ncl" in

{
  test_name = "Python SDK Structure Validation",

  # Expected SDK structure
  expected_structure = {
    # Main class that should be generated
    main_class = {
      name = "CircularProtocolAPI",
      constructor_params = ["base_url: Optional[str] = None", "api_key: Optional[str] = None"],

      # Properties
      properties = {
        base_url = "str",
        api_key = "Optional[str]",
        version = "str",
        session = "requests.Session",
      },

      # All methods that should exist (from all API modules)
      methods = {
        # Wallet methods (6)
        check_wallet = {
          name = "check_wallet",
          params = ["blockchain: str", "address: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_wallet = {
          name = "get_wallet",
          params = ["blockchain: str", "address: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_latest_transactions = {
          name = "get_latest_transactions",
          params = ["blockchain: str", "address: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_wallet_balance = {
          name = "get_wallet_balance",
          params = ["blockchain: str", "address: str", "asset: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_wallet_nonce = {
          name = "get_wallet_nonce",
          params = ["blockchain: str", "address: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        register_wallet = {
          name = "register_wallet",
          params = ["blockchain: str", "public_key: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },

        # Transaction methods (6)
        send_transaction = {
          name = "send_transaction",
          params = [
            "transaction_id: str",
            "from_address: str",
            "to_address: str",
            "timestamp: str",
            "tx_type: str",
            "payload: str",
            "nonce: str",
            "signature: str",
            "blockchain: str",
          ],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_pending_transaction = {
          name = "get_pending_transaction",
          params = ["blockchain: str", "transaction_id: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_transaction_by_id = {
          name = "get_transaction_by_id",
          params = ["blockchain: str", "transaction_id: str", "start: str", "end: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_transaction_by_node = {
          name = "get_transaction_by_node",
          params = ["blockchain: str", "node: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_transaction_by_address = {
          name = "get_transaction_by_address",
          params = ["blockchain: str", "address: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_transaction_by_date = {
          name = "get_transaction_by_date",
          params = ["blockchain: str", "initial_date: str", "final_date: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },

        # Block methods (4)
        get_block = {
          name = "get_block",
          params = ["blockchain: str", "block_number: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_block_range = {
          name = "get_block_range",
          params = ["blockchain: str", "start: str", "end: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_block_count = {
          name = "get_block_count",
          params = ["blockchain: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_analytics = {
          name = "get_analytics",
          params = ["blockchain: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },

        # Contract methods (2)
        test_contract = {
          name = "test_contract",
          params = ["blockchain: str", "from_address: str", "project: str", "timestamp: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        call_contract = {
          name = "call_contract",
          params = ["blockchain: str", "from_address: str", "contract_address: str", "request: str", "timestamp: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },

        # Asset methods (4)
        get_asset_list = {
          name = "get_asset_list",
          params = ["blockchain: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_asset = {
          name = "get_asset",
          params = ["blockchain: str", "asset_name: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_asset_supply = {
          name = "get_asset_supply",
          params = ["blockchain: str", "asset_name: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
        get_voucher = {
          name = "get_voucher",
          params = ["blockchain: str", "code: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },

        # Domain methods (1)
        get_domain = {
          name = "get_domain",
          params = ["blockchain: str", "domain: str"],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },

        # Network methods (1)
        get_blockchains = {
          name = "get_blockchains",
          params = [],
          return_type = "Dict[str, Any]",
          has_docstring = true,
        },
      },
    },

    # Type hints and imports
    imports = {
      required_modules = [
        "typing",
        "requests",
        "json",
      ],
      type_hints = [
        "Dict",
        "Any",
        "Optional",
      ],
    },

    # Common response structure
    response_structure = {
      result_field = "Result",
      response_field = "Response",
      result_type = "int",
      response_type = "Any",
    },

    # Expected helper methods
    helper_methods = {
      _make_request = {
        name = "_make_request",
        params = ["method: str", "endpoint: str", "data: Optional[Dict[str, Any]] = None"],
        return_type = "Dict[str, Any]",
        is_private = true,
      },
      _build_url = {
        name = "_build_url",
        params = ["endpoint: str"],
        return_type = "str",
        is_private = true,
      },
    },
  },

  # Validation rules
  validation_rules = {
    # Total method count
    total_methods = 24,

    # Method naming
    method_names_snake_case = true,

    # All methods must have type hints
    all_methods_typed = true,

    # All methods must have docstrings
    all_methods_documented = true,

    # All methods return Dict[str, Any]
    all_methods_return_dict = true,

    # Version must match config
    version_matches_config = config.version,

    # Uses requests library
    uses_requests_library = true,

    # Has error handling
    has_error_handling = true,
  },

  # Code quality requirements
  quality = {
    has_type_hints = true,
    has_docstrings = true,
    has_error_handling = true,
    uses_requests_session = true,
    follows_pep8 = true,
    mypy_compatible = true,
  },

  # Test metadata
  test_metadata = {
    description = "Validates that generated Python SDK has correct structure",
    approach = "TDD - test written before generator implementation",
    validates = [
      "Class structure",
      "Method signatures",
      "Type hints",
      "Docstrings",
      "Error handling",
      "Import structure",
    ],
    follows_pattern = "circular-py existing SDK structure",
  },
}
