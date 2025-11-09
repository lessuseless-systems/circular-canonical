# src/CLAUDE.md

Guidance for working with API definitions and schemas in the `src/` directory.

> **Parent Context**: See `/CLAUDE.md` for project overview and essential commands.

## Directory Structure

```
src/
├── config.ncl              # Base configuration (version, defaults)
├── schemas/
│   ├── types.ncl           # Core types (Address, Amount, Blockchain)
│   ├── requests.ncl        # Request body schemas
│   └── responses.ncl       # Response schemas
└── api/
    ├── wallet.ncl          # Wallet operations (6 endpoints)
    ├── transaction.ncl     # Transaction operations (6 endpoints)
    ├── asset.ncl           # Asset queries (4 endpoints)
    ├── block.ncl           # Block queries (4 endpoints)
    ├── contract.ncl        # Smart contract operations (2 endpoints)
    ├── domain.ncl          # Domain resolution (1 endpoint)
    ├── network.ncl         # Network queries (1 endpoint)
    └── all.ncl             # Aggregate all APIs
```

## Adding a New API Endpoint

**Step-by-step process:**

1. **Define in `src/api/<domain>.ncl`**:
```nickel
let types = import "../schemas/types.ncl" in

{
  newEndpoint = {
    method = "GET",
    path = "/newEndpoint",
    summary = "Brief description",
    description = "Detailed description with context and usage",

    parameters = {
      required_param = {
        type = "string",
        contract = types.Address,
        required = true,
        description = "Parameter description",
      },
      optional_param = {
        type = "number",
        required = false,
        description = "Optional parameter",
      },
    },

    response_schema = {
      result | types.SomeType,
      count | std.number.PosNat,
    },
  },
}
```

2. **Add contract tests** in `tests/contracts/<domain>.test.ncl`
3. **Update `src/api/all.ncl`** to include the new endpoint
4. **Regenerate**: `just generate`
5. **Validate**: `just test`

## Defining Custom Types

### Simple Type with Contract

```nickel
let Address = std.contract.from_predicate (fun value =>
  let len = std.string.length value in
  (len == 64 || len == 66) && std.string.is_match "^(0x)?[0-9a-fA-F]+$" value
)
```

### Complex Type with Validation

```nickel
let Amount = std.contract.from_predicate (fun value =>
  if not (std.is_string value) then
    std.contract.blame_with_message "Amount must be a string" value
  else if not (std.string.is_match "^[0-9]+$" value) then
    std.contract.blame_with_message "Amount must contain only digits" value
  else
    true
)
```

### Enum Type

```nickel
let Blockchain = std.contract.from_predicate (fun value =>
  let valid = ["ethereum", "polygon", "bsc", "avalanche"] in
  std.array.elem value valid
)
```

### Record Type

```nickel
let WalletResponse = {
  address | Address,
  balance | Amount,
  nonce | std.number.PosNat,
  blockchain | Blockchain,
  status | std.enum.TagOrString,
}
```

## Modifying Existing Types

**Critical workflow to prevent breaking changes:**

1. **Edit `src/schemas/types.ncl`** with new type definition
2. **Update dependent schemas** (`requests.ncl`, `responses.ncl`)
3. **Update API endpoints** that use the type
4. **Run validation**: `just validate`
5. **Run tests**: `just test`
6. **Check for breaking changes**: `./tests/regression/detect-breaking-changes.sh`
7. **If breaking**: Update version, add migration guide, update CHANGELOG
8. **Regenerate**: `just generate`

## API Domains to Implement

Refer to circular-js reference implementation for exact API surface:

### 1. Wallet Operations (6 endpoints)
- `checkWallet`: Verify wallet exists
- `getWallet`: Get wallet details
- `getLatestTransactions`: Recent transaction history
- `getWalletBalance`: Current balance
- `getWalletNonce`: Transaction nonce
- `registerWallet`: Create new wallet

### 2. Smart Contracts (2 endpoints)
- `testContract`: Simulate contract execution
- `callContract`: Execute contract method

### 3. Assets (4 endpoints)
- `getAssetList`: List all assets
- `getAsset`: Get asset details
- `getAssetSupply`: Total supply info
- `getVoucher`: Voucher details

### 4. Blocks (4 endpoints)
- `getBlock`: Get block by height/hash
- `getBlockRange`: Get block range
- `getBlockHeight`: Current blockchain height
- `getAnalytics`: Block analytics

### 5. Transactions (6 endpoints)
- `sendTransaction`: Submit transaction
- `getTransactionByID`: Get by transaction ID
- `getTransactionByNode`: Get by node
- `getTransactionByAddress`: Get by wallet address
- `getTransactionByDate`: Get by date range
- `getPendingTransaction`: Get pending transactions

### 6. Domains (1 endpoint)
- `resolveDomain`: Resolve domain to address

### 7. Network (1 endpoint)
- `getBlockchains`: List supported blockchains

## Contract Validation Best Practices

### Clear Error Messages

Always provide helpful error messages:
```nickel
let Address = std.contract.from_predicate (fun value =>
  if not (std.is_string value) then
    std.contract.blame_with_message "Address must be a string, got %{std.typeof value}" value
  else if std.string.length value != 64 && std.string.length value != 66 then
    std.contract.blame_with_message "Address must be 64 or 66 characters, got %{std.string.from_number (std.string.length value)}" value
  else if not (std.string.is_match "^(0x)?[0-9a-fA-F]+$" value) then
    std.contract.blame_with_message "Address must be hexadecimal" value
  else
    true
)
```

### Composable Contracts

Build complex contracts from simple ones:
```nickel
let NonEmptyString = std.contract.from_predicate (fun value =>
  std.is_string value && std.string.length value > 0
)

let HexString = std.contract.from_predicate (fun value =>
  std.is_string value && std.string.is_match "^(0x)?[0-9a-fA-F]+$" value
)

let Address = std.contract.from_predicate (fun value =>
  (NonEmptyString value) && (HexString value) &&
  (std.string.length value == 64 || std.string.length value == 66)
)
```

### Optional Fields

Use Nickel's optional field syntax:
```nickel
{
  required_field | types.Address,
  optional_field | std.number.PosNat | optional,
  field_with_default | std.string.NonEmpty | default = "default_value",
}
```

## Common Issues

### Contract Fails with Unclear Error

**Problem**: Contract error doesn't indicate what failed
**Solution**: Add detailed error messages with `std.contract.blame_with_message`

### Import Path Not Found

**Problem**: `import "../foo.ncl"` fails
**Solution**: Use correct relative paths from current file location

### Type Check Errors

**Problem**: Nickel type checker reports errors
**Solution**:
- Contract before equals: `field | Contract = value` (not `field = value | Contract`)
- String interpolation needs conversion: `"Count: %{std.string.from_number 42}"`
- Optional field access: use `field or "default"` or check with `std.record.has_field`

### Circular Dependencies

**Problem**: `import` creates circular dependency
**Solution**: Extract shared types to separate file, import in both

## Testing Contracts

### Unit Test Pattern

```nickel
# tests/contracts/types.test.ncl
let types = import "../../src/schemas/types.ncl" in

{
  test_valid_address = {
    input = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
    expected = true,
    actual = (input | types.Address) == input,
  },

  test_invalid_address = {
    input = "invalid",
    expected = false,
    # This should fail contract validation
  },
}
```

### Running Contract Tests

```bash
# Test single file
nickel export tests/contracts/types.test.ncl > /dev/null

# Test all contracts
./tests/run-contract-tests.sh

# Test specific endpoint
nickel query src/api/wallet.ncl checkWallet | jq .
```

## Cross-References

- Generator usage of these schemas: `generators/CLAUDE.md`
- TypeScript type mappings: `generators/typescript/CLAUDE.md`
- Python type mappings: `generators/python/CLAUDE.md`
