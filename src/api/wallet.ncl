# Circular Protocol Canonacle - Wallet API Endpoints
# Reference: docs/API_REFERENCE.md (Wallet Operations)

let types = import "../schemas/types.ncl" in

{
  # Example: checkWallet - Complete implementation as template
  checkWallet = {
    method = "POST",
    path = "/checkWallet",
    summary = "Check if wallet exists",
    description = m%"
      Checks whether a wallet address exists on the specified blockchain.
      Returns existence status and confirms the address format.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where the wallet is registered",
        default = "MainNet",
      },

      address = {
        type = "string",
        required = true,
        description = "Wallet address (64 or 66 hex characters)",
      },
    },

    request_body = {
      Blockchain = "string",
      Address = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        exists = "boolean",
        address = "string",
      },
    },

    example_request = {
      blockchain = "MainNet",
      address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    },

    example_response = {
      Result = 200,
      Response = {
        exists = true,
        address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      },
    },
  },

  getWallet = {
    method = "POST",
    path = "/getWallet",
    summary = "Get wallet information",
    description = m%"
      Retrieves complete wallet information including balance and nonce.
      Returns all wallet properties including current state on the blockchain.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where the wallet is registered",
        default = "MainNet",
      },

      address = {
        type = "string",
        required = true,
        description = "Wallet address",
      },
    },

    request_body = {
      Blockchain = "string",
      Address = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        Address = "string",
        Balance = "number",
        Nonce = "number",
      },
    },

    example_request = {
      blockchain = "MainNet",
      address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    },

    example_response = {
      Result = 200,
      Response = {
        Address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
        Balance = 1000000,
        Nonce = 42,
      },
    },
  },

  getLatestTransactions = {
    method = "POST",
    path = "/getLatestTransactions",
    summary = "Get latest transactions for wallet",
    description = m%"
      Retrieves the latest transactions for a wallet address.
      Returns an array of transaction objects with details.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where the wallet is registered",
        default = "MainNet",
      },

      address = {
        type = "string",
        required = true,
        description = "Wallet address",
      },
    },

    request_body = {
      Blockchain = "string",
      Address = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        type = "array",
        items = {
          ID = "string",
          From = "string",
          To = "string",
          Amount = "number",
          Timestamp = "string",
        },
      },
    },

    example_request = {
      blockchain = "MainNet",
      address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    },

    example_response = {
      Result = 200,
      Response = [
        {
          ID = "0xabc123def456...",
          From = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
          To = "0x9876543210fedcba...",
          Amount = 1000,
          Timestamp = "2024-01-15:10:30:00",
        },
      ],
    },
  },

  getWalletBalance = {
    method = "POST",
    path = "/getWalletBalance",
    summary = "Get wallet balance for specific asset",
    description = m%"
      Retrieves the balance of a specified asset in a wallet.
      Returns the balance amount for the requested asset.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where the wallet is registered",
        default = "MainNet",
      },

      address = {
        type = "string",
        required = true,
        description = "Wallet address",
      },

      asset = {
        type = "string",
        required = true,
        description = "Asset name (e.g., 'CIRX')",
      },
    },

    request_body = {
      Blockchain = "string",
      Address = "string",
      Asset = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        Balance = "number",
        Asset = "string",
      },
    },

    example_request = {
      blockchain = "MainNet",
      address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      asset = "CIRX",
    },

    example_response = {
      Result = 200,
      Response = {
        Balance = 1000000,
        Asset = "CIRX",
      },
    },
  },

  getWalletNonce = {
    method = "POST",
    path = "/getWalletNonce",
    summary = "Get wallet nonce",
    description = m%"
      Retrieves the nonce (transaction counter) of a wallet.
      The nonce is used for transaction ordering and must increment with each transaction.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where the wallet is registered",
        default = "MainNet",
      },

      address = {
        type = "string",
        required = true,
        description = "Wallet address",
      },
    },

    request_body = {
      Blockchain = "string",
      Address = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        Nonce = "number",
      },
    },

    example_request = {
      blockchain = "MainNet",
      address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    },

    example_response = {
      Result = 200,
      Response = {
        Nonce = 42,
      },
    },
  },

  registerWallet = {
    method = "POST",
    path = "/registerWallet",
    summary = "Register wallet on blockchain",
    description = m%"
      Registers a wallet on a desired blockchain. The same wallet can be registered
      on multiple blockchains. Without registration, the wallet will not be reachable
      on the blockchain. This endpoint constructs a transaction of type C_TYPE_REGISTERWALLET.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where the wallet will be registered",
        default = "MainNet",
      },

      publicKey = {
        type = "string",
        required = true,
        description = "Wallet public key",
      },
    },

    request_body = {
      Blockchain = "string",
      PublicKey = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        TransactionID = "string",
        Status = "string",
      },
    },

    example_request = {
      blockchain = "MainNet",
      publicKey = "04abc123def456...",
    },

    example_response = {
      Result = 200,
      Response = {
        TransactionID = "0x9876543210fedcba...",
        Status = "pending",
      },
    },

    notes = m%"
      This endpoint constructs a transaction with:
      - Type: C_TYPE_REGISTERWALLET
      - From: sha256(publicKey)
      - To: sha256(publicKey)
      - Nonce: '0'
      - Payload: stringToHex({"Action": "CP_REGISTERWALLET", "PublicKey": publicKey})
    "%,
  },
}
