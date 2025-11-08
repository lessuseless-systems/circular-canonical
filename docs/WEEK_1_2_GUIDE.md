# Week 1-2 Implementation Guide: Canonical Foundation

> **📝 Note (2025-11-07)**: This guide reflects the initial project structure. The project has since been reorganized with a **language-first** approach (`generators/typescript/`, `generators/python/`, `generators/shared/`). For current structure, see `/CLAUDE.md` and the updated `CANONICAL_TODOs.md`.

**Goal**: Go from empty directories to working PoC with 3-5 endpoints, validated generators, and first exports.

**Reference**: See [NICKEL_PATTERNS.md](./NICKEL_PATTERNS.md) for Nickel syntax help

---

## Week 1: Foundation & First Definitions

### Day 1: Setup & First Type Definition

**Morning (2-3 hours): Environment Setup**

1. **Install Nickel**
   ```bash
   nix shell nixpkgs#nickel

   # Verify installation
   nickel --version  # Should show v1.x.x
   ```

2. **Test Nickel REPL**
   ```bash
   nickel repl

   # Try basic commands:
   > { hello = "world" }
   > { x | Num | doc "A number" = 42 }
   > :q  # Exit
   ```

3. **Configure Editor** (VS Code recommended)
   ```bash
   # Install Nickel extension
   code --install-extension nickel-lang.nickel-syntax
   ```

**Afternoon (3-4 hours): First Type Definition**

4. **Create `src/schemas/types.ncl`**
   ```nickel
   # src/schemas/types.ncl
   {
     # Basic string type with validation
     Address = std.string.NonEmpty
       | doc "Wallet address (64 or 66 chars with 0x prefix)",

     # Version constant
     Version = "1.0.8",

     # Test type
     TestData = {
       field1 | Address,
       field2 | std.string.NonEmpty,
     }
   }
   ```

5. **Test Export**
   ```bash
   nickel export src/schemas/types.ncl --format json

   # Should output:
   # {
   #   "Address": {},
   #   "Version": "1.0.8",
   #   "TestData": { ... }
   # }
   ```

6. **Create Simple Test**
   ```bash
   # tests/types-basic.ncl
   let types = import "../src/schemas/types.ncl" in
   {
     version_check = types.Version == "1.0.8",
     address_test = "0x123" | types.Address,
   }
   ```

   ```bash
   nickel export tests/types-basic.ncl
   # Should succeed
   ```

**✅ Day 1 Success Criteria:**
- [ ] Nickel installed and working
- [ ] Created first `.ncl` file
- [ ] Successfully exported to JSON
- [ ] Understood basic Nickel syntax

---

### Day 2: Complete Core Types + Contracts

**Morning (3 hours): Define All Core Types**

1. **Expand `src/schemas/types.ncl`**
   ```nickel
   {
     # String types with validation contracts
     Address = fun label value =>
       let len = std.string.length value in
       if len == 64 || len == 66 then value
       else std.contract.blame_with_message
         "Address must be 64 or 66 characters, got %{std.to_string len}"
         label
       | doc "Wallet address (64 or 66 chars with 0x prefix)",

     Blockchain = fun label value =>
       let len = std.string.length value in
       if len == 64 || len == 66 then value
       else std.contract.blame_with_message
         "Blockchain must be 64 or 66 characters, got %{std.to_string len}"
         label
       | doc "Blockchain identifier (64 char hash)",

     Timestamp = fun label value =>
       if std.string.is_match "^[0-9]{4}:[0-9]{2}:[0-9]{2}-[0-9]{2}:[0-9]{2}:[0-9]{2}$" value
       then value
       else std.contract.blame_with_message
         "Timestamp must be in format YYYY:MM:DD-HH:MM:SS"
         label
       | doc "UTC timestamp in format YYYY:MM:DD-HH:MM:SS",

     TransactionID = fun label value =>
       if std.string.length value == 64 then value
       else std.contract.blame_with_message
         "TransactionID must be exactly 64 characters"
         label
       | doc "Transaction ID (64 char hash)",

     Version = "1.0.8",

     # Enum types
     TransactionType = [|
       'C_TYPE_COIN,
       'C_TYPE_TOKEN,
       'C_TYPE_ASSET,
       'C_TYPE_CERTIFICATE,
       'C_TYPE_REGISTERWALLET,
       'C_TYPE_HC_DEPLOYMENT,
       'C_TYPE_HC_REQUEST,
       'C_TYPE_USERDEF
     |],

     Network = [| 'mainnet, 'testnet, 'devnet |],

     # Helper to just optional fields
     Optional = fun T => [| 'Some T, 'None |],
   }
   ```

**Afternoon (3 hours): Write Contract Tests**

2. **Create `tests/contracts.test.ncl`**
   ```nickel
   let types = import "../src/schemas/types.ncl" in
   {
     # Test valid inputs
     valid_address = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
       | types.Address,

     valid_timestamp = "2024:01:15-10:30:45"
       | types.Timestamp,

     # Test invalid inputs (should fail)
     # Run: nickel export tests/contracts.test.ncl
     # invalid_address = "too_short" | types.Address,  # Uncomment to test failure

     # Test enums
     valid_tx_type = 'C_TYPE_COIN | types.TransactionType,
     valid_network = 'mainnet | types.Network,

     all_tests_passed = true
   }
   ```

3. **Test Validation**
   ```bash
   # Should succeed
   nickel export tests/contracts.test.ncl

   # Test failures work (uncomment invalid_address line)
   # nickel export tests/contracts.test.ncl
   # Should show contract error with helpful message
   ```

**✅ Day 2 Success Criteria:**
- [ ] All core types defined with contracts
- [ ] Contract validation working (rejects invalid data)
- [ ] Tests passing for valid inputs
- [ ] Understand how contracts enforce rules

---

### Day 3: First Complete API Endpoint

**Full Day (6-8 hours): checkWallet Endpoint**

1. **Create `src/schemas/requests.ncl`**
   ```nickel
   let types = import "./types.ncl" in
   {
     # Base request that all APIs include
     BaseRequest = {
       blockchain | types.Blockchain,
       version | std.string.NonEmpty | default = types.Version,
     },

     # Wallet-specific request
     CheckWalletRequest = BaseRequest & {
       walletAddress | types.Address,
       includeMetadata | Bool | optional | default = false,
     },
   }
   ```

2. **Create `src/schemas/responses.ncl`**
   ```nickel
   let types = import "./types.ncl" in
   {
     # Base response
     BaseResponse = {
       result | std.string.NonEmpty,
       response | std.string.NonEmpty,
     },

     # Check wallet response
     CheckWalletResponse = BaseResponse & {
       exists | Bool,
       walletAddress | types.Address,
       blockchain | types.Blockchain,
       createdAt | types.Timestamp | optional,
       transactionCount | Num | optional,
       metadata | { _ | Dyn } | optional,
     },

     # Error response
     ErrorResponse = {
       code | std.string.NonEmpty,
       message | std.string.NonEmpty,
       details | { _ | Dyn } | optional,
     },
   }
   ```

3. **Create `src/api/wallet.ncl`**
   ```nickel
   let types = import "../schemas/types.ncl" in
   let requests = import "../schemas/requests.ncl" in
   let responses = import "../schemas/responses.ncl" in
   {
     checkWallet = {
       metadata = {
         name = "checkWallet",
         description = "Checks if a wallet exists on the specified blockchain",
         category = "wallet",
         version = types.Version,
         async = true,
       },

       request = requests.CheckWalletRequest,
       response = responses.CheckWalletResponse,
       error = responses.ErrorResponse,

       errors = [
         { code = "INVALID_ADDRESS", message = "Wallet address format is invalid" },
         { code = "BLOCKCHAIN_NOT_FOUND", message = "Specified blockchain does not exist" },
         { code = "NETWORK_ERROR", message = "Failed to connect to blockchain network" },
       ],

       examples = [
         {
           request = {
             walletAddress = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
             blockchain = "0000000000000000000000000000000000000000000000000000000000000001",
             includeMetadata = true,
           },
           response = {
             result = "OK",
             response = "Wallet found",
             exists = true,
             walletAddress = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
             blockchain = "0000000000000000000000000000000000000000000000000000000000000001",
             createdAt = "2024:01:15-10:30:45",
             transactionCount = 42,
           },
         },
       ],
     },
   }
   ```

4. **Test Complete Definition**
   ```bash
   nickel export src/api/wallet.ncl --format json | jq .

   # Should output complete API definition with metadata, request, response, errors, examples
   ```

**✅ Day 3 Success Criteria:**
- [ ] Complete checkWallet API defined
- [ ] Request and response schemas with contracts
- [ ] Error definitions included
- [ ] Working example included
- [ ] Exports to clean JSON

---

### Day 4: First Generator (Simple JSON Export)

**Morning (3-4 hours): Build JSON Generator**

1. **Create `generators/lib/helpers.ncl`**
   ```nickel
   {
     # Convert record to array of entries
     toEntries = fun record =>
       std.record.fields record
       |> std.array.map (fun field => { key = field, value = record."%{field}" }),

     # String manipulation helpers
     capitalize = fun s =>
       let first = std.string.uppercase (std.string.substring 0 1 s) in
       let rest = std.string.substring 1 (std.string.length s) s in
       "%{first}%{rest}",

     # Join array with separator
     join = fun sep arr =>
       if std.array.length arr == 0 then ""
       else if std.array.length arr == 1 then std.array.at 0 arr
       else std.array.foldl (fun acc x => "%{acc}%{sep}%{x}") (std.array.at 0 arr) (std.array.drop 1 arr),
   }
   ```

2. **Create `generators/json-export.ncl`**
   ```nickel
   let wallet = import "../src/api/wallet.ncl" in
   {
     api = {
       version = "1.0.0",
       name = "Circular Protocol API",
       endpoints = {
         checkWallet = wallet.checkWallet,
       },
     },
   }
   ```

3. **Test Generator**
   ```bash
   nickel export generators/json-export.ncl --format json > output/api-spec.json

   # Validate output
   cat output/api-spec.json | jq .
   ```

**Afternoon (2-3 hours): Create justfile**

4. **Create `justfile`**
   ```justfile
   .PHONY: all clean test generate validate

   all: test generate

   # Type check all Nickel files
   typecheck:
   	@echo "Type checking Nickel files..."
   	@find src -name "*.ncl" -exec nickel typecheck {} \;
   	@find generators -name "*.ncl" -exec nickel typecheck {} \;

   # Run contract tests
   test:
   	@echo "Running contract tests..."
   	@nickel export tests/contracts.test.ncl > /dev/null
   	@echo "✅ All tests passed"

   # Generate JSON export
   generate-json:
   	@echo "Generating JSON export..."
   	@mkdir -p output
   	@nickel export generators/json-export.ncl --format json > output/api-spec.json
   	@echo "✅ Generated output/api-spec.json"

   generate: generate-json

   # Validate generated output
   validate:
   	@echo "Validating generated files..."
   	@jq empty output/api-spec.json && echo "✅ Valid JSON" || echo "❌ Invalid JSON"

   # Clean generated files
   clean:
   	@rm -rf output/*
   	@echo "✅ Cleaned output directory"
   ```

5. **Test justfile**
   ```bash
   just clean
   just test
   just generate
   just validate
   ```

**✅ Day 4 Success Criteria:**
- [ ] First generator working
- [ ] justfile automates common tasks
- [ ] Output validates as correct JSON
- [ ] Understand generator pattern

---

### Day 5: Add More Endpoints

**Full Day (6-8 hours): getWallet & sendTransaction**

1. **Add to `src/schemas/requests.ncl`**
   ```nickel
   let types = import "./types.ncl" in
   {
     BaseRequest = { ... },  # existing
     CheckWalletRequest = { ... },  # existing

     GetWalletRequest = BaseRequest & {
       walletAddress | types.Address,
       includeTransactions | Bool | optional | default = false,
       transactionLimit | Num | optional | default = 10,
     },

     SendTransactionRequest = BaseRequest & {
       walletAddress | types.Address,
       txType | types.TransactionType,
       to | types.Address | optional,
       amount | Num | optional,
       data | std.string.NonEmpty | optional,
       signature | std.string.NonEmpty,
     },
   }
   ```

2. **Add to `src/schemas/responses.ncl`**
   ```nickel
   let types = import "./types.ncl" in
   {
     BaseResponse = { ... },  # existing
     CheckWalletResponse = { ... },  # existing
     ErrorResponse = { ... },  # existing

     GetWalletResponse = BaseResponse & {
       walletAddress | types.Address,
       balance | Num,
       nonce | Num,
       transactions | Array { ... } | optional,
     },

     SendTransactionResponse = BaseResponse & {
       transactionID | types.TransactionID,
       status | std.string.NonEmpty,
       blockID | std.string.NonEmpty | optional,
     },
   }
   ```

3. **Expand `src/api/wallet.ncl`**
   ```nickel
   # Add getWallet and sendTransaction following same pattern as checkWallet
   {
     checkWallet = { ... },  # existing

     getWallet = {
       metadata = {
         name = "getWallet",
         description = "Retrieve wallet information and optionally recent transactions",
         category = "wallet",
       },
       request = requests.GetWalletRequest,
       response = responses.GetWalletResponse,
       # ... rest of definition
     },

     sendTransaction = {
       metadata = {
         name = "sendTransaction",
         description = "Submit a signed transaction to the blockchain",
         category = "wallet",
       },
       request = requests.SendTransactionRequest,
       response = responses.SendTransactionResponse,
       # ... rest of definition
     },
   }
   ```

4. **Update generator to include all endpoints**
   ```nickel
   # generators/json-export.ncl
   let wallet = import "../src/api/wallet.ncl" in
   {
     api = {
       endpoints = {
         checkWallet = wallet.checkWallet,
         getWallet = wallet.getWallet,
         sendTransaction = wallet.sendTransaction,
       },
     },
   }
   ```

5. **Regenerate and test**
   ```bash
   just generate
   just validate

   # Check output includes all 3 endpoints
   jq '.api.endpoints | keys' output/api-spec.json
   ```

**✅ Day 5 Success Criteria:**
- [ ] 3 complete endpoint definitions
- [ ] All export correctly to JSON
- [ ] Patterns becoming clear
- [ ] Ready for Week 2 generators

---

### Days 6-7: Weekend Review & Documentation

**Saturday (3-4 hours): Review & Refactor**

1. **Review all code**
   - Check for consistency across endpoints
   - Refactor common patterns into helpers
   - Improve contract error messages
   - Add more inline documentation

2. **Write notes**
   - Document patterns you've learned
   - Note any pain points or confusions
   - List questions for community/docs

**Sunday (2-3 hours): Prepare for Week 2**

3. **Read ahead**
   - Review OpenAPI 3.0 spec format
   - Study MCP (Model Context Protocol) basics
   - Plan generator architecture

4. **Set up Week 2 structure**
   ```bash
   mkdir -p generators/{openapi,mcp,lib}
   touch generators/openapi/generator.ncl
   touch generators/mcp/generator.ncl
   ```

**✅ Week 1 Complete Checklist:**
- [ ] Nickel development environment working
- [ ] Core types defined with contracts
- [ ] 3 complete API endpoints (checkWallet, getWallet, sendTransaction)
- [ ] Simple JSON generator working
- [ ] justfile automates common tasks
- [ ] Tests validate contracts work
- [ ] Understand Nickel basics
- [ ] Ready for complex generators in Week 2

---

## Week 2: Generators & Validation

### Day 8-9: OpenAPI Generator Foundation

**Day 8 Morning (4 hours): OpenAPI Structure**

1. **Create `generators/openapi/types.ncl`**
   ```nickel
   {
     # OpenAPI 3.0 structure definitions
     Info = {
       title | std.string.NonEmpty,
       version | std.string.NonEmpty,
       description | std.string.NonEmpty | optional,
     },

     Server = {
       url | std.string.NonEmpty,
       description | std.string.NonEmpty | optional,
     },

     Schema = {
       type | std.string.NonEmpty,
       properties | { _ | Dyn } | optional,
       required | Array std.string.NonEmpty | optional,
     },
   }
   ```

2. **Create `generators/openapi/transform.ncl`**
   ```nickel
   let helpers = import "../lib/helpers.ncl" in
   {
     # Transform Nickel type to JSON Schema type
     nickelTypeToJsonSchema = fun nickelType =>
       if nickelType == "Num" then "number"
       else if nickelType == "Bool" then "boolean"
       else if nickelType == "String" then "string"
       else "object",

     # Transform API endpoint to OpenAPI path
     endpointToPath = fun endpoint =>
       {
         post = {
           summary = endpoint.metadata.description,
           operationId = endpoint.metadata.name,
           requestBody = {
             required = true,
             content = {
               "application/json" = {
                 schema = { "$ref" = "#/components/schemas/%{helpers.capitalize endpoint.metadata.name}Request" },
               },
             },
           },
           responses = {
             "200" = {
               description = "Successful response",
               content = {
                 "application/json" = {
                   schema = { "$ref" = "#/components/schemas/%{helpers.capitalize endpoint.metadata.name}Response" },
                 },
               },
             },
           },
         },
       },
   }
   ```

**Day 8 Afternoon + Day 9 (6-8 hours): Complete Generator**

3. **Create `generators/openapi/generator.ncl`**
   ```nickel
   let wallet = import "../../src/api/wallet.ncl" in
   let transform = import "./transform.ncl" in
   {
     openapi = "3.0.0",
     info = {
       title = "Circular Protocol API",
       version = "1.0.0",
       description = "Official API for Circular Protocol blockchain operations",
     },
     servers = [
       { url = "https://api.circular.com/v1", description = "Production" },
       { url = "https://testnet-api.circular.com/v1", description = "Testnet" },
     ],
     paths = {
       "/wallet/check" = transform.endpointToPath wallet.checkWallet,
       "/wallet/get" = transform.endpointToPath wallet.getWallet,
       "/wallet/sendTransaction" = transform.endpointToPath wallet.sendTransaction,
     },
     components = {
       schemas = {
         # TODO: Generate schemas from request/response types
       },
     },
   }
   ```

4. **Test OpenAPI generator**
   ```bash
   nickel export generators/openapi/generator.ncl --format yaml > output/openapi.yaml

   # Validate with Redocly
   npx @redocly/cli lint output/openapi.yaml
   ```

5. **Update justfile**
   ```justfile
   generate-openapi:
   	@echo "Generating OpenAPI spec..."
   	@nickel export generators/openapi/generator.ncl --format yaml > output/openapi.yaml
   	@echo "✅ Generated output/openapi.yaml"

   generate: generate-json generate-openapi
   ```

**✅ Days 8-9 Success Criteria:**
- [ ] OpenAPI 3.0 spec generated
- [ ] Validates with Redocly CLI
- [ ] All 3 endpoints included
- [ ] Understand transformation pattern

---

### Days 10-11: Additional Endpoint Definitions

**Goal**: Define remaining ~17 endpoints in Nickel

1. **Create `src/api/transactions.ncl`**
   - getTransactionByID
   - getTransactionByAddress
   - getTransactionByDate
   - getPendingTransaction

2. **Create `src/api/assets.ncl`**
   - getAssetList
   - getAsset
   - getAssetSupply

3. **Create `src/api/blocks.ncl`**
   - getBlock
   - getBlockRange
   - getBlockHeight

4. **Update generators to include all endpoints**

**✅ Days 10-11 Success Criteria:**
- [ ] All 20+ endpoints defined
- [ ] All export correctly
- [ ] OpenAPI includes all endpoints
- [ ] Patterns consistent across all

---

### Days 12-13: MCP Server Generator

**Day 12: MCP Structure**

1. **Create `generators/mcp/template.ncl`**
   ```nickel
   let helpers = import "../lib/helpers.ncl" in
   {
     # TypeScript MCP server template
     serverTemplate = fun endpoints =>
       "
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

const server = new Server({
  name: 'circular-protocol',
  version: '1.0.0',
}, {
  capabilities: {
    tools: {}
  }
});

%{generateTools endpoints}

const transport = new StdioServerTransport();
await server.connect(transport);
       ",

     generateTools = fun endpoints =>
       # Generate tool definitions from endpoints
       "// TODO: Generate tools",
   }
   ```

**Day 13: Complete & Test**

2. **Generate MCP server**
   ```bash
   nickel export generators/mcp/generator.ncl > output/mcp-server.ts

   # Test it compiles
   tsc --noEmit output/mcp-server.ts
   ```

**✅ Days 12-13 Success Criteria:**
- [ ] MCP server TypeScript generated
- [ ] Compiles without errors
- [ ] 5-7 tools included
- [ ] Ready for Claude Desktop testing

---

### Day 14: Validation Against circular-js

**Full Day: Comparison & Validation**

1. **Create validation script**
   ```bash
   # scripts/validate-against-circular-js.sh
   #!/bin/bash

   # Compare generated API surface with circular-js
   echo "Checking endpoint coverage..."

   # Extract methods from circular-js
   grep -r "export.*function\|export.*class" ../circular-js/src/ | \
     sed 's/.*export.*function \([a-zA-Z]*\).*/\1/' > /tmp/circular-js-methods.txt

   # Extract methods from our OpenAPI
   cat output/openapi.yaml | grep operationId | \
     sed 's/.*operationId: \(.*\)/\1/' > /tmp/canonical-methods.txt

   # Compare
   echo "Methods in circular-js but not in Canonical:"
   comm -23 <(sort /tmp/circular-js-methods.txt) <(sort /tmp/canonical-methods.txt)

   echo "Methods in Canonical but not in circular-js:"
   comm -13 <(sort /tmp/circular-js-methods.txt) <(sort /tmp/canonical-methods.txt)
   ```

2. **Run validation**
   ```bash
   bash scripts/validate-against-circular-js.sh
   ```

3. **Fix any gaps**
   - Add missing endpoints
   - Verify parameter compatibility
   - Check response formats match

**✅ Day 14 Success Criteria:**
- [ ] All circular-js endpoints covered
- [ ] Parameter names match
- [ ] Response formats compatible
- [ ] Ready for Phase 1 (Weeks 3-4)

---

## Week 1-2 Deliverables

At the end of 2 weeks, you should have:

### Files Created:
```
circular-canonical/
├── src/
│   ├── schemas/
│   │   ├── types.ncl              ✅ All core types
│   │   ├── requests.ncl           ✅ Request schemas
│   │   └── responses.ncl          ✅ Response schemas
│   ├── api/
│   │   ├── wallet.ncl             ✅ 6 endpoints
│   │   ├── transactions.ncl       ✅ 7 endpoints
│   │   ├── assets.ncl             ✅ 4 endpoints
│   │   └── blocks.ncl             ✅ 4 endpoints
├── generators/
│   ├── lib/
│   │   └── helpers.ncl            ✅ Helper functions
│   ├── json-export.ncl            ✅ Simple JSON generator
│   ├── openapi/
│   │   ├── types.ncl
│   │   ├── transform.ncl
│   │   └── generator.ncl          ✅ OpenAPI 3.0 generator
│   └── mcp/
│       ├── template.ncl
│       └── generator.ncl          ✅ MCP server generator
├── tests/
│   ├── contracts.test.ncl         ✅ Contract validation
│   └── generated.test.ts          ✅ Generated code tests
├── output/
│   ├── api-spec.json              ✅ Generated
│   ├── openapi.yaml               ✅ Generated
│   └── mcp-server.ts              ✅ Generated
├── scripts/
│   └── validate-against-circular-js.sh ✅
├── justfile                        ✅
└── docs/
    └── WEEK_1_2_GUIDE.md          ✅ This file
```

### Skills Gained:
- ✅ Nickel syntax and contract system
- ✅ Generator pattern (input → transformation → output)
- ✅ Type-safe API definitions
- ✅ Validation and testing strategies
- ✅ Development workflow (edit → generate → validate)

### Metrics:
- ✅ 20+ API endpoints defined in Nickel
- ✅ 100% validation coverage (all contracts tested)
- ✅ 3+ output formats generated (JSON, YAML, TypeScript)
- ✅ 100% parity with circular-js endpoints
- ✅ justfile automates all common tasks

---

## Next Steps (Week 3-4)

After completing this guide, proceed to:

1. **Generate remaining artifact types**
   - Anthropic tool schemas
   - OpenAI function schemas
   - Zod schemas
   - AGENTS.md

2. **Build Canonical-Enterprise-APIs**
   - CEP_Account class definition
   - Multi-language generators

3. **Set up CI/CD**
   - Auto-generate on commit
   - Validate outputs
   - Run tests

See [DEVELOPMENT_WORKFLOW.md](./DEVELOPMENT_WORKFLOW.md) for ongoing practices.

---

## Troubleshooting

### "Contract violation" errors
- Check that values match type constraints
- Use `nickel typecheck` to catch errors early
- Read error messages carefully - they show what was expected vs received

### "Module not found" errors
- Verify import paths are correct (relative from current file)
- Use `import "./file.ncl"` for same directory
- Use `import "../file.ncl"` for parent directory

### Generator produces malformed output
- Test transformation functions in isolation first
- Use `nickel repl` to debug transformations
- Start with simple cases, then add complexity

### Make commands fail
- Check that Nickel files have no syntax errors
- Run `just typecheck` first
- Verify output directory exists

---

## Resources

- [Nickel Language Documentation](https://nickel-lang.org/user-manual/introduction)
- [Nickel Standard Library](https://nickel-lang.org/stdlib/std/)
- [NICKEL_PATTERNS.md](./NICKEL_PATTERNS.md) - Syntax quick reference
- [TESTING_STRATEGY.md](./TESTING_STRATEGY.md) - How to test everything
- [OpenAPI 3.0 Spec](https://swagger.io/specification/)
- [MCP Protocol](https://modelcontextprotocol.io/)

---

**Remember**: The goal is steady progress, not perfection. If you get stuck, reference the pattern files, and don't hesitate to iterate. By Day 14, you'll have a solid foundation for all future Canonical work!
