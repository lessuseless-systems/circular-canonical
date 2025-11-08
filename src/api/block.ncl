# Circular Protocol Canonical - Block API Endpoints
# Reference: docs/API_REFERENCE.md (Blocks)

let types = import "../schemas/types.ncl" in

{
  getBlock = {
    method = "POST",
    path = "/getBlock",
    summary = "Get specific block",
    description = m%"
      Retrieves a desired block by block number.
      Returns complete block information including transactions and hash.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where to search the block",
        default = "MainNet",
      },

      num = {
        type = "string",
        required = true,
        description = "Block number",
      },
    },

    request_body = {
      Blockchain = "string",
      BlockNumber = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        BlockNumber = "number",
        Timestamp = "string",
        Transactions = {
          type = "array",
          items = {},
        },
        Hash = "string",
      },
    },

    example_request = {
      blockchain = "MainNet",
      num = "12345",
    },

    example_response = {
      Result = 200,
      Response = {
        BlockNumber = 12345,
        Timestamp = "2024-01-15:10:30:00",
        Transactions = [],
        Hash = "0xblock123...",
      },
    },
  },

  getBlockRange = {
    method = "POST",
    path = "/getBlockRange",
    summary = "Get range of blocks",
    description = m%"
      Retrieves all blocks in a specified range.
      If End = 0, then Start is the number of blocks from the last one minted going backward.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where to search the blocks",
        default = "MainNet",
      },

      start = {
        type = "string",
        required = true,
        description = "Initial block (or count from end if end=0)",
      },

      end = {
        type = "string",
        required = true,
        description = "End block (or 0 for backward count)",
      },
    },

    request_body = {
      Blockchain = "string",
      Start = "string",
      End = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        type = "array",
        items = {
          BlockNumber = "number",
          Timestamp = "string",
          Transactions = {
            type = "array",
            items = {},
          },
        },
      },
    },

    example_request = {
      blockchain = "MainNet",
      start = "100",
      end = "200",
    },

    example_response = {
      Result = 200,
      Response = [
        {
          BlockNumber = 100,
          Timestamp = "2024-01-15:10:30:00",
          Transactions = [],
        },
      ],
    },
  },

  getBlockCount = {
    method = "POST",
    path = "/getBlockCount",
    summary = "Get blockchain height",
    description = m%"
      Retrieves the blockchain block height (total number of blocks).
      Also known as getBlockHeight in some documentation.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where to count the blocks",
        default = "MainNet",
      },
    },

    request_body = {
      Blockchain = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        BlockCount = "number",
      },
    },

    example_request = {
      blockchain = "MainNet",
    },

    example_response = {
      Result = 200,
      Response = {
        BlockCount = 123456,
      },
    },
  },

  getAnalytics = {
    method = "POST",
    path = "/getAnalytics",
    summary = "Get blockchain analytics",
    description = m%"
      Retrieves blockchain analytics and statistics.
      Returns comprehensive information about the blockchain state.
    "%,

    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Selected blockchain",
        default = "MainNet",
      },
    },

    request_body = {
      Blockchain = "string",
      Version = "string",
    },

    response_schema = {
      Result = "number",
      Response = {
        TotalTransactions = "number",
        TotalWallets = "number",
        TotalAssets = "number",
        BlockHeight = "number",
      },
    },

    example_request = {
      blockchain = "MainNet",
    },

    example_response = {
      Result = 200,
      Response = {
        TotalTransactions = 1000000,
        TotalWallets = 50000,
        TotalAssets = 100,
        BlockHeight = 123456,
      },
    },
  },
}
