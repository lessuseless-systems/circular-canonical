# Circular Protocol Canonical - Transaction API Endpoints
# Reference: docs/API_REFERENCE.md (Transactions)

let types = import "../schemas/types.ncl" in

{
  sendTransaction = {
    method = "POST",
    path = "/sendTransaction",
    summary = "Submit transaction to blockchain",
    description = m%"
      Submits a transaction to the blockchain. Requires a complete signed transaction
      including ID, addresses, payload, nonce, and signature.
    "%,

    parameters = {
      id = {
        type = "string",
        required = true,
        description = "Transaction ID (hash of tx components)",
      },

      from = {
        type = "string",
        required = true,
        description = "Sender wallet address",
      },

      to = {
        type = "string",
        required = true,
        description = "Recipient wallet address",
      },

      timestamp = {
        type = "string",
        required = true,
        description = "Transaction timestamp",
      },

      type = {
        type = "string",
        required = true,
        description = "Transaction type",
      },

      payload = {
        type = "string",
        required = true,
        description = "Transaction payload (hex-encoded)",
      },

      nonce = {
        type = "string",
        required = true,
        description = "Wallet nonce",
      },

      signature = {
        type = "string",
        required = true,
        description = "Transaction signature",
      },

      blockchain = {
        type = "string",
        required = true,
        description = "Target blockchain",
        default = "MainNet",
      },
    },

    request_body = {
      ID = "string",
      From = "string",
      To = "string",
      Timestamp = "string",
      Type = "string",
      Payload = "string",
      Nonce = "string",
      Signature = "string",
      Blockchain = "string",
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
      id = "0xabc123...",
      from = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      to = "0x9876543210fedcba9876543210fedcba98765432",
      timestamp = "2024-01-15:10:30:00",
      type = "C_TYPE_TRANSACTION",
      payload = "0x48656c6c6f",
      nonce = "5",
      signature = "0xsig123...",
      blockchain = "MainNet",
    },

    example_response = {
      Result = 200,
      Response = {
        TransactionID = "0xabc123...",
        Status = "pending",
      },
    },
  },

  getPendingTransaction = {
    method = "POST",
    path = "/getPendingTransaction",
    summary = "Get pending transaction by ID",
    description = m%"
      Searches for a transaction by ID among pending transactions.
      Returns the transaction if it exists and is still pending.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where to search the transaction",
        default = "MainNet",
      },

      TxID = {
        type = "string",
        required = true,
        description = "Transaction ID",
      },
    },

    request_body = {
      Blockchain = "string",
      ID = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        ID = "string",
        From = "string",
        To = "string",
        Status = "string",
      },
    },

    example_request = {
      blockchain = "MainNet",
      TxID = "0xabc123...",
    },

    example_response = {
      Result = 200,
      Response = {
        ID = "0xabc123...",
        From = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
        To = "0x9876543210fedcba9876543210fedcba98765432",
        Status = "pending",
      },
    },
  },

  getTransactionbyID = {
    method = "POST",
    path = "/getTransactionbyID",
    summary = "Find transaction by ID",
    description = m%"
      Finds a transaction by ID within a specified block range.
      Searches through blocks to locate the transaction.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where to search",
        default = "MainNet",
      },

      TxID = {
        type = "string",
        required = true,
        description = "Transaction ID",
      },

      start = {
        type = "string",
        required = true,
        description = "Start block",
      },

      end = {
        type = "string",
        required = true,
        description = "End block",
      },
    },

    request_body = {
      Blockchain = "string",
      ID = "string",
      Start = "string",
      End = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        ID = "string",
        From = "string",
        To = "string",
        BlockNumber = "number",
        Timestamp = "string",
      },
    },

    example_request = {
      blockchain = "MainNet",
      TxID = "0xabc123...",
      start = "1000",
      end = "2000",
    },

    example_response = {
      Result = 200,
      Response = {
        ID = "0xabc123...",
        From = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
        To = "0x9876543210fedcba9876543210fedcba98765432",
        BlockNumber = 1523,
        Timestamp = "2024-01-15:10:30:00",
      },
    },
  },

  getTransactionbyNode = {
    method = "POST",
    path = "/getTransactionbyNode",
    summary = "Find transactions by node ID",
    description = m%"
      Finds transactions by node ID within a specified block range.
      Returns all transactions associated with the node.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where to search",
        default = "MainNet",
      },

      nodeID = {
        type = "string",
        required = true,
        description = "Node ID",
      },

      start = {
        type = "string",
        required = true,
        description = "Start block",
      },

      end = {
        type = "string",
        required = true,
        description = "End block",
      },
    },

    request_body = {
      Blockchain = "string",
      NodeID = "string",
      Start = "string",
      End = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        type = "array",
        items = {
          ID = "string",
          NodeID = "string",
          BlockNumber = "number",
        },
      },
    },

    example_request = {
      blockchain = "MainNet",
      nodeID = "0xnode123...",
      start = "1000",
      end = "2000",
    },

    example_response = {
      Result = 200,
      Response = [
        {
          ID = "0xabc123...",
          NodeID = "0xnode123...",
          BlockNumber = 1523,
        },
      ],
    },
  },

  getTransactionbyAddress = {
    method = "POST",
    path = "/getTransactionbyAddress",
    summary = "Find transactions by address",
    description = m%"
      Finds transactions by wallet address within a specified block range.
      Returns transactions where the address is sender or recipient.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where to search",
        default = "MainNet",
      },

      address = {
        type = "string",
        required = true,
        description = "Wallet address (sender or recipient)",
      },

      start = {
        type = "string",
        required = true,
        description = "Start block",
      },

      end = {
        type = "string",
        required = true,
        description = "End block",
      },
    },

    request_body = {
      Blockchain = "string",
      Address = "string",
      Start = "string",
      End = "string",
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
          BlockNumber = "number",
        },
      },
    },

    example_request = {
      blockchain = "MainNet",
      address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      start = "1000",
      end = "2000",
    },

    example_response = {
      Result = 200,
      Response = [
        {
          ID = "0xabc123...",
          From = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
          To = "0x9876543210fedcba9876543210fedcba98765432",
          BlockNumber = 1523,
        },
      ],
    },
  },

  getTransactionbyDate = {
    method = "POST",
    path = "/getTransactionbyDate",
    summary = "Find transactions by date range",
    description = m%"
      Finds transactions by wallet address within a specified date range.
      Returns all transactions for the address between the dates.
    "%,

    parameters = {
      Blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where to search",
        default = "MainNet",
      },

      Address = {
        type = "string",
        required = true,
        description = "Wallet address",
      },

      StartDate = {
        type = "string",
        required = true,
        description = "Start date (YYYY-MM-DD or timestamp)",
      },

      EndDate = {
        type = "string",
        required = true,
        description = "End date (YYYY-MM-DD or timestamp)",
      },
    },

    request_body = {
      Blockchain = "string",
      Address = "string",
      StartDate = "string",
      EndDate = "string",
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
          Timestamp = "string",
        },
      },
    },

    example_request = {
      Blockchain = "MainNet",
      Address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      StartDate = "2024-01-01",
      EndDate = "2024-01-31",
    },

    example_response = {
      Result = 200,
      Response = [
        {
          ID = "0xabc123...",
          From = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
          To = "0x9876543210fedcba9876543210fedcba98765432",
          Timestamp = "2024-01-15:10:30:00",
        },
      ],
    },
  },
}
