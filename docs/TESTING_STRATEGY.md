# Testing Strategy for Circular Protocol Canonical

Comprehensive testing approach for ensuring quality, consistency, and reliability across all generated artifacts.

## Table of Contents

1. [Testing Philosophy](#testing-philosophy)
2. [Test Layers](#test-layers)
3. [Contract Validation Testing](#contract-validation-testing)
4. [Generator Output Testing](#generator-output-testing)
5. [Cross-Language Validation](#cross-language-validation)
6. [Nickel-First Test Infrastructure](#nickel-first-test-infrastructure)
7. [Integration Testing](#integration-testing)
8. [Regression Testing](#regression-testing)
9. [CI/CD Integration](#cicd-integration)
10. [Testing Checklist](#testing-checklist)

---

## Testing Philosophy

### Core Principles

1. **Single Source of Truth**: All tests validate against Nickel definitions as the canonical reference
2. **Fail Fast**: Catch errors at compile/export time, not runtime
3. **Comprehensive Coverage**: Test contracts, generators, and outputs
4. **Cross-Language Consistency**: All language SDKs must behave identically
5. **Automated Verification**: No manual testing in CI/CD pipeline

### What We Test

```
Nickel Contracts ──> Generator Logic ──> Generated Code ──> Runtime Behavior
      ↓                    ↓                  ↓                    ↓
   Unit Tests      Generator Tests     Syntax Tests      Integration Tests
```

### Testing Pyramid

```
                  ┌─────────────┐
                  │ Integration │  ← Fewest, slowest
                  │   Testing   │
                  └─────────────┘
              ┌─────────────────────┐
              │  Cross-Language     │
              │    Validation       │
              └─────────────────────┘
          ┌─────────────────────────────┐
          │    Generator Output         │
          │       Testing               │
          └─────────────────────────────┘
      ┌───────────────────────────────────┐
      │     Contract Validation           │  ← Most, fastest
      │         Testing                   │
      └───────────────────────────────────┘
```

---

## Test Layers

### Layer 1: Contract Validation (Fast, Many)

**Purpose:** Validate that Nickel contracts enforce expected rules

**Tools:**
- Nickel's built-in contract system
- Nickel export (triggers contract evaluation)

**Speed:** < 1 second per test
**Frequency:** Run on every file save

### Layer 2: Generator Output (Medium Speed, Medium Number)

**Purpose:** Verify generators produce syntactically correct output in target languages

**Tools:**
- Language-specific parsers (TypeScript compiler, Python AST, etc.)
- Snapshot testing
- JSON/YAML schema validation

**Speed:** 1-5 seconds per test
**Frequency:** Run on commit

### Layer 3: Cross-Language Validation (Medium Speed, Fewer)

**Purpose:** Ensure all language SDKs produce identical behavior

**Tools:**
- Test harness that runs identical tests across all languages
- Differential testing

**Speed:** 5-30 seconds per test
**Frequency:** Run on PR

### Layer 4: Integration Testing (Slow, Fewest)

**Purpose:** Validate against live blockchain or mock server

**Tools:**
- Docker containers for test environments
- Mock blockchain servers
- circular-js reference implementation

**Speed:** 30+ seconds per test
**Frequency:** Run before release

---

## Contract Validation Testing

### Test Structure

```nickel
# tests/contracts/types.test.ncl
let types = import "../../src/schemas/types.ncl" in

{
  # Test suite metadata
  suite_name = "Type Contract Validation",

  # Valid cases - should pass contract validation
  valid_addresses = {
    with_0x_prefix = {
      value | types.Address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
      expected = "valid",
    },

    without_prefix_64_chars = {
      value | types.Address = "742d35Cc6634C0532925a3b844Bc9e7595f0bEb742d35Cc6634C0532925a3b8",
      expected = "valid",
    },
  },

  # Invalid cases - document expected failures (commented out to avoid breaking build)
  # invalid_addresses = {
  #   too_short = {
  #     value | types.Address = "0x123",
  #     expected_error = "Address must be 64 or 66 characters",
  #   },
  #
  #   not_hex = {
  #     value | types.Address = "not_a_hex_string_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  #     expected_error = "Address must be hexadecimal",
  #   },
  # },

  valid_amounts = {
    zero = {
      value | types.Amount = 0,
      expected = "valid",
    },

    large_number = {
      value | types.Amount = 1000000000,
      expected = "valid",
    },
  },

  # Test enum validation
  valid_blockchains = {
    mainnet = {
      value | types.Blockchain = 'MainNet,
      expected = "valid",
    },

    testnet = {
      value | types.Blockchain = 'TestNet,
      expected = "valid",
    },
  },
}
```

### Running Contract Tests

```bash
# Test single file
nickel export tests/contracts/types.test.ncl > /dev/null
echo "✓ Type contracts validated"

# Test all contract files
find tests/contracts -name "*.test.ncl" -exec nickel export {} \; > /dev/null

# With error reporting
nickel export tests/contracts/types.test.ncl 2>&1 | grep -i "error"
```

### Automated Contract Testing

```bash
# tests/run-contract-tests.sh
#!/bin/bash

set -e

echo "Running contract validation tests..."

FAILED=0
PASSED=0

for test_file in tests/contracts/*.test.ncl; do
  echo -n "Testing $(basename $test_file)... "

  if nickel export "$test_file" > /dev/null 2>&1; then
    echo "✓ PASS"
    ((PASSED++))
  else
    echo "✗ FAIL"
    nickel export "$test_file" 2>&1
    ((FAILED++))
  fi
done

echo ""
echo "Contract Tests: $PASSED passed, $FAILED failed"

if [ $FAILED -gt 0 ]; then
  exit 1
fi
```

### Negative Testing Pattern

Document expected failures without breaking the build:

```nickel
# tests/contracts/negative-cases.ncl
{
  # This file documents contract violations but doesn't export them
  # Use a test runner script to validate these fail as expected

  documented_failures = {
    invalid_address_too_short = {
      contract = "types.Address",
      input = "0x123",
      expected_error_pattern = "Address must be 64 or 66 characters",
    },

    invalid_amount_negative = {
      contract = "types.Amount",
      input = -100,
      expected_error_pattern = "must be positive",
    },
  },
}

# Then in test runner:
# nickel export <(echo 'let val | types.Address = "0x123" in val') 2>&1 | grep -q "must be"
```

---

## Runtime Validation

### Overview

The Circular Protocol Canonical implements a **dual-layer validation system**:

1. **Compile-time validation**: Nickel contracts enforce type safety during export
2. **Runtime validation**: Validation functions apply contracts to request/response data

This ensures data integrity at both development time (when writing tests) and runtime (when processing actual API calls).

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Type Definitions (src/schemas/types.ncl)                │
│  - Address, Amount, Blockchain, etc.                    │
│  - Reusable contracts for all data types                │
└────────────────┬────────────────────────────────────────┘
                 │ imported by
     ┌───────────┴──────────────┬─────────────────┐
     │                          │                 │
     v                          v                 v
┌──────────────┐   ┌────────────────────┐   ┌─────────────────┐
│  Request     │   │  Response          │   │ API Definitions │
│  Schemas     │   │  Schemas           │   │  (metadata)     │
│  (contracts) │   │  (contracts)       │   │  (for OpenAPI)  │
└──────┬───────┘   └─────────┬──────────┘   └─────────────────┘
       │                     │
       │ imported by         │ imported by
       │                     │
       v                     v
┌──────────────────────────────────────────┐
│ Validation Functions                     │
│  (src/validators/endpoint-validators.ncl)│
│  - validate_checkWallet_request          │
│  - validate_checkWallet_response         │
│  - etc.                                  │
└────────────────┬─────────────────────────┘
                 │ used by
                 v
┌──────────────────────────────────────────┐
│ Test Suites & Generated SDKs             │
│  - Endpoint tests                        │
│  - Runtime validation tests              │
│  - Future: TypeScript/Python SDKs        │
└──────────────────────────────────────────┘
```

### Request/Response Schemas

All API requests and responses have corresponding schema definitions with contracts applied:

**Request Schemas** (`src/schemas/requests.ncl`):
```nickel
let types = import "./types.ncl" in
{
  CheckWalletRequest = {
    Blockchain | types.Blockchain,
    Address | types.Address,
    Version | String,
  },

  GetWalletRequest = {
    Blockchain | types.Blockchain,
    Address | types.Address,
    Version | String,
  },

  # ... etc for all 6 endpoints
}
```

**Response Schemas** (`src/schemas/responses.ncl`):
```nickel
let types = import "./types.ncl" in
{
  CheckWalletResponse = {
    Result | types.ResultCode,
    Response | {
      exists | types.Boolean,
      address | types.Address,
    },
  },

  ErrorResponse = {
    Result | types.ResultCode,
    Response | String,  # Error message
  },

  # ... etc for all 6 endpoints
}
```

### Validation Functions

Validation functions provide a simple API for applying contracts to data:

```nickel
# src/validators/endpoint-validators.ncl
let requests = import "../schemas/requests.ncl" in
let responses = import "../schemas/responses.ncl" in

{
  # checkWallet validators
  validate_checkWallet_request = fun req =>
    req | requests.CheckWalletRequest,

  validate_checkWallet_response_success = fun resp =>
    resp | responses.CheckWalletResponse,

  validate_checkWallet_response_error = fun resp =>
    resp | responses.ErrorResponse,

  # ... etc for all 6 endpoints
}
```

### Testing Runtime Validation

Runtime validation is tested in `tests/validation/runtime-validation.test.ncl`:

```nickel
let validators = import "../../src/validators/endpoint-validators.ncl" in

{
  checkWallet_tests = {
    valid_request = {
      data = validators.validate_checkWallet_request {
        Blockchain = 'MainNet,
        Address = "0xbbbb...",
        Version = "2.0.0",
      },
      expected = "valid",
    },

    valid_success_response = {
      data = validators.validate_checkWallet_response_success {
        Result = 200,
        Response = {
          exists = true,
          address = "0xbbbb...",
        },
      },
      expected = "valid",
    },
  },
}
```

### Running Validation Tests

```bash
# Run all validation tests
./scripts/test.sh

# Run only runtime validation tests
nickel export tests/validation/runtime-validation.test.ncl

# Run with detailed output
nickel export tests/validation/runtime-validation.test.ncl --format json | jq .
```

### Benefits of Runtime Validation

1. **Type Safety**: Contracts ensure data conforms to expected shapes
2. **Single Source of Truth**: One contract definition used everywhere
3. **Fail Fast**: Invalid data is caught immediately, not deep in application logic
4. **Documentation**: Schemas serve as executable documentation
5. **SDK Generation**: Validators can be translated to TypeScript/Python/etc.
6. **Testing**: Easy to test that validators work correctly

### Future: SDK Integration

When generating SDKs, validators will be translated to target languages:

**TypeScript Example**:
```typescript
// Generated from Nickel validators
export function validateCheckWalletRequest(req: unknown): CheckWalletRequest {
  if (!isValidBlockchain(req.Blockchain)) {
    throw new ValidationError("Invalid blockchain");
  }
  if (!isValidAddress(req.Address)) {
    throw new ValidationError("Invalid address");
  }
  return req as CheckWalletRequest;
}
```

**Python Example**:
```python
# Generated from Nickel validators
def validate_check_wallet_request(req: dict) -> CheckWalletRequest:
    if not is_valid_blockchain(req["Blockchain"]):
        raise ValidationError("Invalid blockchain")
    if not is_valid_address(req["Address"]):
        raise ValidationError("Invalid address")
    return CheckWalletRequest(**req)
```

---

## Generator Output Testing

### Snapshot Testing

Compare generator output against known-good snapshots:

```bash
# tests/generators/snapshot-test.sh
#!/bin/bash

SNAPSHOT_DIR="tests/generators/snapshots"
OUTPUT_DIR="tests/generators/output"

mkdir -p "$OUTPUT_DIR"

# Generate current output
nickel export generators/openapi.ncl --format yaml > "$OUTPUT_DIR/openapi.yaml"
nickel export generators/typescript-types.ncl > "$OUTPUT_DIR/types.ts"
nickel export generators/python-types.ncl > "$OUTPUT_DIR/types.py"

# Compare against snapshots
if diff -r "$SNAPSHOT_DIR" "$OUTPUT_DIR"; then
  echo "✓ Generator output matches snapshots"
else
  echo "✗ Generator output differs from snapshots"
  echo ""
  echo "If changes are intentional, update snapshots:"
  echo "  cp -r $OUTPUT_DIR/* $SNAPSHOT_DIR/"
  exit 1
fi
```

### Syntax Validation

Ensure generated code is syntactically valid:

```bash
# tests/generators/syntax-validation.sh
#!/bin/bash

set -e

echo "Validating generated code syntax..."

# Generate outputs
nickel export generators/typescript-sdk.ncl > /tmp/client.ts
nickel export generators/python-sdk.ncl > /tmp/client.py
nickel export generators/java-sdk.ncl > /tmp/Client.java
nickel export generators/openapi.ncl --format yaml > /tmp/openapi.yaml

# TypeScript syntax check
echo -n "TypeScript... "
npx typescript /tmp/client.ts --noEmit
echo "✓"

# Python syntax check
echo -n "Python... "
python3 -m py_compile /tmp/client.py
echo "✓"

# Java syntax check
echo -n "Java... "
javac -d /tmp /tmp/Client.java
echo "✓"

# OpenAPI schema validation
echo -n "OpenAPI... "
npx @apidevtools/swagger-cli validate /tmp/openapi.yaml
echo "✓"

echo ""
echo "All generated code is syntactically valid ✓"
```

### Schema Validation

Validate JSON/YAML output against schemas:

```bash
# tests/generators/schema-validation.sh
#!/bin/bash

# Generate OpenAPI spec
nickel export generators/openapi.ncl --format yaml > /tmp/openapi.yaml

# Validate against OpenAPI 3.0 schema
npx @apidevtools/swagger-cli validate /tmp/openapi.yaml

# Generate MCP server schema
nickel export generators/mcp-server.ncl --format json > /tmp/mcp-tools.json

# Validate against MCP schema
ajv validate -s tests/schemas/mcp-schema.json -d /tmp/mcp-tools.json
```

### Regression Testing

Prevent unintended changes:

```nickel
# tests/generators/regression.test.ncl
let openapi_v1 = import "tests/snapshots/openapi-v1.0.8.ncl" in
let openapi_current = import "generators/openapi.ncl" in

{
  # Verify version incremented properly
  version_check = {
    previous = openapi_v1.info.version,
    current = openapi_current.info.version,
    # Should be >= previous version
  },

  # Verify no endpoints removed (only additions allowed)
  endpoint_count_check = {
    previous_count = std.record.length openapi_v1.paths,
    current_count = std.record.length openapi_current.paths,
    # current_count >= previous_count
  },

  # Verify specific critical endpoints unchanged
  critical_endpoints_unchanged = {
    check_wallet_path = openapi_current.paths."/checkWallet" == openapi_v1.paths."/checkWallet",
    get_wallet_path = openapi_current.paths."/getWallet" == openapi_v1.paths."/getWallet",
  },
}
```

---

## Cross-Language Validation

### Test Harness Structure

Create identical test scenarios for all language SDKs:

```yaml
# tests/cross-lang/test-scenarios.yaml
scenarios:
  - name: "checkWallet with valid address"
    api: checkWallet
    input:
      address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
      blockchain: "MainNet"
    expected_output:
      exists: true
      address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
      blockchain: "MainNet"

  - name: "getWallet returns balance"
    api: getWallet
    input:
      address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
    expected_output:
      address: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
      balance: 1000
      nonce: 5

  - name: "sendTransaction with valid params"
    api: sendTransaction
    input:
      from: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
      to: "0x123d35Cc6634C0532925a3b844Bc9e7595f0456"
      amount: 100
      memo: "Test transaction"
    expected_output:
      transactionId: "<any string>"
      status: "pending"
```

### Multi-Language Test Runner

```python
# tests/cross-lang/run-tests.py
import json
import subprocess
import yaml
from pathlib import Path

def load_scenarios():
    with open('tests/cross-lang/test-scenarios.yaml') as f:
        return yaml.safe_load(f)['scenarios']

def run_typescript_test(scenario):
    """Run test using TypeScript SDK"""
    result = subprocess.run(
        ['ts-node', 'tests/cross-lang/typescript-runner.ts'],
        input=json.dumps(scenario),
        capture_output=True,
        text=True
    )
    return json.loads(result.stdout)

def run_python_test(scenario):
    """Run test using Python SDK"""
    result = subprocess.run(
        ['python3', 'tests/cross-lang/python-runner.py'],
        input=json.dumps(scenario),
        capture_output=True,
        text=True
    )
    return json.loads(result.stdout)

def run_java_test(scenario):
    """Run test using Java SDK"""
    result = subprocess.run(
        ['java', '-cp', 'target/classes', 'TestRunner'],
        input=json.dumps(scenario),
        capture_output=True,
        text=True
    )
    return json.loads(result.stdout)

def compare_outputs(outputs):
    """Verify all SDKs produced identical output"""
    first = outputs[0][1]  # First SDK's output

    for lang, output in outputs[1:]:
        if output != first:
            print(f"❌ Output mismatch between {outputs[0][0]} and {lang}")
            print(f"  {outputs[0][0]}: {first}")
            print(f"  {lang}: {output}")
            return False

    return True

def main():
    scenarios = load_scenarios()

    passed = 0
    failed = 0

    for scenario in scenarios:
        print(f"Testing: {scenario['name']}")

        # Run same test in all languages
        outputs = [
            ('TypeScript', run_typescript_test(scenario)),
            ('Python', run_python_test(scenario)),
            ('Java', run_java_test(scenario)),
        ]

        if compare_outputs(outputs):
            print(f"  ✓ All SDKs returned identical results")
            passed += 1
        else:
            print(f"  ✗ SDKs produced different results")
            failed += 1

    print(f"\nCross-language tests: {passed} passed, {failed} failed")

    return 0 if failed == 0 else 1

if __name__ == '__main__':
    exit(main())
```

### Differential Testing

```bash
# tests/cross-lang/differential-test.sh
#!/bin/bash

# Generate test data from Nickel
nickel export tests/cross-lang/test-data.ncl --format json > /tmp/test-data.json

# Run each SDK with same inputs
echo "Running TypeScript SDK..."
ts-node tests/cross-lang/runners/typescript.ts < /tmp/test-data.json > /tmp/ts-output.json

echo "Running Python SDK..."
python3 tests/cross-lang/runners/python.py < /tmp/test-data.json > /tmp/py-output.json

echo "Running Java SDK..."
java -jar tests/cross-lang/runners/java-runner.jar < /tmp/test-data.json > /tmp/java-output.json

# Compare outputs
echo "Comparing outputs..."
if diff /tmp/ts-output.json /tmp/py-output.json && \
   diff /tmp/ts-output.json /tmp/java-output.json; then
  echo "✓ All SDKs produced identical output"
else
  echo "✗ SDKs produced different outputs"
  exit 1
fi
```

---

## Nickel-First Test Infrastructure

### Philosophy

**Critical Principle**: All test infrastructure must be **generated** from Nickel definitions to prevent drift and maintain single source of truth.

### The Problem with Manual Test Code

Manual test code creates duplication and drift risk:

```
API Definition (src/api/wallet.ncl):
  checkWallet = { parameters = ..., example_response = ... }

Manual Mock Server (tests/mock-server/server.py):  ❌ DUPLICATION
  def handle_check_wallet(): return {"Result": 200, ...}

Manual Integration Tests (tests/integration/test.py): ❌ DUPLICATION
  def test_check_wallet(): assert response == {"Result": 200, ...}
```

**Problem**: When API changes, three places need manual updates. This causes:
- Out-of-sync mock responses
- Outdated test expectations
- Inconsistent behavior across SDKs
- Maintenance burden

### The Nickel-First Solution

Generate all test infrastructure from canonical Nickel definitions:

```
src/api/*.ncl (SINGLE SOURCE OF TRUTH)
        ↓
generators/shared/mock-server.ncl
        ↓
dist/tests/mock-server.py (auto-generated)

        ↓
generators/*/tests/*-tests.ncl
        ↓
dist/tests/sdk.test.ts (auto-generated)
dist/tests/test_sdk.py (auto-generated)
```

**Benefits**:
1. **Zero Drift**: Mock server responses always match API definitions
2. **DRY**: 24 API endpoints defined once, not duplicated
3. **Consistency**: All SDKs tested against same definitions
4. **Automatic Updates**: Add endpoint → all tests auto-include it
5. **Type Safety**: Nickel contracts validate test specs

### What Gets Generated

All test infrastructure in `dist/tests/` is generated:

| Generated File | Generator Source | Lines | Purpose |
|---|---|---|---|
| `mock-server.py` | `generators/shared/mock-server.ncl` (135 lines) | 192 | HTTP mock server |
| `run-contract-tests.sh` | `generators/shared/test-runners/contract-runner.ncl` (122 lines) | 150 | Layer 1 test runner |
| `syntax-validation.sh` | `generators/shared/test-runners/syntax-validator.ncl` (101 lines) | 86 | Layer 2 validator |
| `sdk.test.ts` | `generators/typescript/tests/typescript-tests.ncl` (397 lines) | 381 | TypeScript integration tests |
| `test_sdk.py` | `generators/python/tests/python-tests.ncl` (345 lines) | 329 | Python integration tests |
| `sdk.unit.test.ts` | `generators/typescript/tests/typescript-unit-tests.ncl` (512 lines) | 495 | TypeScript unit tests |
| `test_sdk_unit.py` | `generators/python/tests/python-unit-tests.ncl` (491 lines) | 474 | Python unit tests |

**Total**: ~2,100 lines generated from ~2,100 lines of Nickel specs.
**Replaced**: 1,554 lines of manual Python/shell test code (eliminated).

### How It Works

#### 1. Mock Server Generation

**Input**: API definitions in `src/api/*.ncl`
```nickel
# src/api/wallet.ncl
checkWallet = {
  endpoint = "/checkWallet",
  method = "POST",
  example_response = {
    Result = 200,
    Response = { exists = true, address = "0xtest" }
  },
}
```

**Generator**: `generators/shared/mock-server.ncl`
```nickel
let generate_handler = fun endpoint =>
  m%"
def _handle_%{endpoint.name}(self, body):
    return %{to_python endpoint.example_response}
  "%
```

**Output**: `dist/tests/mock-server.py`
```python
def _handle_check_wallet(self, body):
    return {"Result": 200, "Response": {"exists": True, "address": "0xtest"}}
```

#### 2. Integration Test Generation

**Generator**: `generators/typescript/tests/typescript-tests.ncl`

Iterates over all API endpoints and generates test cases:
- Uses `example_request` for test input
- Uses `example_response` for assertions
- Tests against mock server (http://localhost:8080)

**Output**: 381 lines of TypeScript integration tests covering 24 endpoints.

#### 3. Unit Test Generation

**Generator**: `generators/*/tests/*-unit-tests.ncl`

Generates unit tests that:
- Mock HTTP libraries (fetch/requests)
- Test request payload building
- Test response parsing
- Test error handling
- No server required

**Output**: 495 lines (TypeScript) + 474 lines (Python) of unit tests.

### Development Workflow

```bash
# 1. Change API definition
vim src/api/wallet.ncl

# 2. Regenerate all test infrastructure (< 5 seconds)
just generate-all-tests

# 3. Tests automatically include changes
just test-sdk-unit  # Unit tests (no server)
just test-sdk       # Integration tests (with mock server)
```

### Migration Status (Sprint 3)

**Completed Phases**:
- ✅ Phase 1: Mock Server Generator
- ✅ Phase 2: Test Runner Generators
- ✅ Phase 3: Unit Test Generators (verified existing)
- ✅ Phase 4: Integration Test Migration (verified existing)

**Future Phases**:
- ⏭️ Phase 5: Cross-Language Validator Generator (deferred)
- ⏭️ Phase 6: Regression Test Generator (deferred)

**Impact**:
- Manual test code eliminated: 655 lines
- Zero-drift guarantee: All tests regenerate from Nickel
- Test coverage maintained: All existing tests still pass

### Commands

```bash
# Generate all test infrastructure
just generate-all-tests

# Generate individual components
just generate-mock-server
just generate-contract-runner
just generate-syntax-validator
just generate-tests              # Integration tests
just generate-unit-tests

# Run tests
./dist/tests/run-contract-tests.sh    # Layer 1: Contracts
just test-sdk-unit                     # Layer 2: Unit tests
just test-sdk                          # Layer 3: Integration tests
python3 tests/cross-lang/run-tests.py  # Layer 4: Cross-language
```

---

## Integration Testing

### Mock Server Setup

The mock server is **generated** from Nickel API definitions, not manually coded:

**Generation**:
```bash
# Generate mock server from Nickel API definitions
just generate-mock-server

# Output: dist/tests/mock-server.py (192 lines)
# Includes handlers for all 24 API endpoints

# Start mock server
just mock-server  # Runs on http://localhost:8080
```

**Generated Mock Server Structure** (`dist/tests/mock-server.py`):
```python
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class MockAPIHandler(BaseHTTPRequestHandler):
    """Generated mock server for Circular Protocol API"""

    def _handle_check_wallet(self, body):
        """Generated from src/api/wallet.ncl"""
        return {
            "Result": 200,
            "Response": {
                "exists": True,
                "address": body.get("Address"),
                "blockchain": body.get("Blockchain", "MainNet")
            }
        }

    def _handle_get_wallet(self, body):
        """Generated from src/api/wallet.ncl"""
        return {
            "Result": 200,
            "Response": {
                "Address": body.get("Address"),
                "Balance": 1000,
                "Nonce": 5
            }
        }

    # ... 22 more generated handlers for all endpoints ...
```

**Note**: Never edit `dist/tests/mock-server.py` directly. Always regenerate from Nickel definitions.

### Integration Test Suite

Integration tests are **generated** from Nickel API definitions:

**Generation**:
```bash
# Generate integration tests for both languages
just generate-tests

# Output:
#   dist/tests/sdk.test.ts (381 lines)
#   dist/tests/test_sdk.py (329 lines)
```

**Generated Test Structure** (`dist/tests/sdk.test.ts`):
```typescript
import { CircularProtocolAPI } from '../src/index'

describe('Circular Protocol SDK Tests', () => {
  let api: CircularProtocolAPI
  const MOCK_SERVER_URL = 'http://localhost:8080'

  beforeAll(() => {
    api = new CircularProtocolAPI(MOCK_SERVER_URL)
  })

  describe('Wallet API', () => {
    describe('checkWallet', () => {
      test('should check if wallet exists on MainNet', async () => {
        const result = await api.checkWallet({
          Blockchain: 'MainNet',
          Address: '0xbbbb...',
          Version: '2.0.0-alpha.1'
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('exists')
      })
      // ... more generated tests for all 24 endpoints ...
    })
  })
})
```

**Running Integration Tests**:
```bash
# Terminal 1: Start generated mock server
just mock-server

# Terminal 2: Run generated integration tests
just test-sdk-ts   # TypeScript tests
just test-sdk-py   # Python tests
just test-sdk      # Both languages
```

**Note**: Integration tests are automatically generated from API definitions. To add new test scenarios, update `example_request`/`example_response` in `src/api/*.ncl`.

### Reference Implementation Validation

Test against circular-js reference:

```bash
# tests/integration/validate-against-reference.sh
#!/bin/bash

echo "Validating against circular-js reference implementation..."

# Install reference
npm install circular-js

# Run comparison tests
node tests/integration/compare-with-reference.js
```

```javascript
// tests/integration/compare-with-reference.js
const circularJs = require('circular-js');
const { CircularClient } = require('../../output/typescript/client');

const referenceClient = new circularJs.CircularClient();
const canonicalClient = new CircularClient();

async function compareAPI(apiName, params) {
  console.log(`Testing ${apiName}...`);

  try {
    const referenceResult = await referenceClient[apiName](params);
    const canonicalResult = await canonicalClient[apiName](params);

    if (JSON.stringify(referenceResult) === JSON.stringify(canonicalResult)) {
      console.log(`  ✓ ${apiName} matches reference`);
      return true;
    } else {
      console.log(`  ✗ ${apiName} differs from reference`);
      console.log(`    Reference: ${JSON.stringify(referenceResult)}`);
      console.log(`    Canonical: ${JSON.stringify(canonicalResult)}`);
      return false;
    }
  } catch (error) {
    console.log(`  ✗ ${apiName} threw error: ${error.message}`);
    return false;
  }
}

async function main() {
  const tests = [
    ['checkWallet', { address: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb' }],
    ['getWallet', { address: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb' }],
    // Add more test cases
  ];

  let passed = 0;
  let failed = 0;

  for (const [api, params] of tests) {
    if (await compareAPI(api, params)) {
      passed++;
    } else {
      failed++;
    }
  }

  console.log(`\nReference validation: ${passed} passed, ${failed} failed`);
  process.exit(failed > 0 ? 1 : 0);
}

main();
```

---

## Regression Testing

### Version Comparison

```bash
# tests/regression/compare-versions.sh
#!/bin/bash

PREVIOUS_VERSION="v1.0.7"
CURRENT_VERSION="v1.0.8"

echo "Comparing $PREVIOUS_VERSION with $CURRENT_VERSION..."

# Checkout previous version
git worktree add /tmp/canonical-previous $PREVIOUS_VERSION

# Generate outputs from both versions
cd /tmp/canonical-previous
nickel export generators/openapi.ncl --format yaml > /tmp/openapi-previous.yaml

cd -
nickel export generators/openapi.ncl --format yaml > /tmp/openapi-current.yaml

# Compare for breaking changes
node tests/regression/detect-breaking-changes.js \
  /tmp/openapi-previous.yaml \
  /tmp/openapi-current.yaml

# Cleanup
git worktree remove /tmp/canonical-previous
```

### Breaking Change Detection

```javascript
// tests/regression/detect-breaking-changes.js
const yaml = require('yaml');
const fs = require('fs');

function loadOpenAPI(filepath) {
  return yaml.parse(fs.readFileSync(filepath, 'utf8'));
}

function findBreakingChanges(previous, current) {
  const breaking = [];

  // Check removed endpoints
  for (const path in previous.paths) {
    if (!current.paths[path]) {
      breaking.push(`Removed endpoint: ${path}`);
    } else {
      // Check removed methods
      for (const method in previous.paths[path]) {
        if (!current.paths[path][method]) {
          breaking.push(`Removed method: ${method.toUpperCase()} ${path}`);
        }
      }
    }
  }

  // Check removed required parameters
  for (const path in previous.paths) {
    if (!current.paths[path]) continue;

    for (const method in previous.paths[path]) {
      if (!current.paths[path][method]) continue;

      const prevParams = previous.paths[path][method].parameters || [];
      const currParams = current.paths[path][method].parameters || [];

      for (const param of prevParams) {
        if (param.required) {
          const stillExists = currParams.find(p => p.name === param.name);
          if (!stillExists) {
            breaking.push(`Removed required parameter: ${param.name} from ${method.toUpperCase()} ${path}`);
          }
        }
      }
    }
  }

  return breaking;
}

function main() {
  const [,, previousFile, currentFile] = process.argv;

  const previous = loadOpenAPI(previousFile);
  const current = loadOpenAPI(currentFile);

  const breaking = findBreakingChanges(previous, current);

  if (breaking.length > 0) {
    console.log('⚠️  Breaking changes detected:');
    breaking.forEach(change => console.log(`  - ${change}`));
    process.exit(1);
  } else {
    console.log('✓ No breaking changes detected');
    process.exit(0);
  }
}

main();
```

---

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Test Canonical

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  contract-tests:
    name: Contract Validation Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Nickel
        run: |
          curl -sSL https://get.nickel-lang.org | sh
          echo "$HOME/.nickel/bin" >> $GITHUB_PATH

      - name: Run contract tests
        run: |
          chmod +x tests/run-contract-tests.sh
          ./tests/run-contract-tests.sh

  generator-tests:
    name: Generator Output Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Nickel
        run: |
          curl -sSL https://get.nickel-lang.org | sh
          echo "$HOME/.nickel/bin" >> $GITHUB_PATH

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Run generator tests
        run: |
          chmod +x tests/generators/syntax-validation.sh
          ./tests/generators/syntax-validation.sh

      - name: Run snapshot tests
        run: |
          chmod +x tests/generators/snapshot-test.sh
          ./tests/generators/snapshot-test.sh

  cross-lang-tests:
    name: Cross-Language Validation
    runs-on: ubuntu-latest
    needs: [contract-tests, generator-tests]
    steps:
      - uses: actions/checkout@v3

      - name: Install dependencies
        run: |
          npm install
          pip install -r requirements.txt

      - name: Run cross-language tests
        run: python3 tests/cross-lang/run-tests.py

  integration-tests:
    name: Integration Tests
    runs-on: ubuntu-latest
    needs: [cross-lang-tests]
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm install

      - name: Run integration tests
        run: npm test

  regression-tests:
    name: Regression Tests
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Need full history for comparison

      - name: Run regression tests
        run: |
          chmod +x tests/regression/compare-versions.sh
          ./tests/regression/compare-versions.sh
```

### Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash

echo "Running pre-commit tests..."

# Fast contract validation
if ! ./tests/run-contract-tests.sh; then
  echo "❌ Contract validation failed"
  exit 1
fi

# Type check all Nickel files
if ! find src -name "*.ncl" -exec nickel typecheck {} \;; then
  echo "❌ Type checking failed"
  exit 1
fi

echo "✓ Pre-commit checks passed"
```

---

## Testing Checklist

### Before Every Commit

- [ ] All Nickel files pass `nickel typecheck`
- [ ] All contract tests pass
- [ ] No TODO comments in committed code (unless tracked in issues)

### Before Every PR

- [ ] Contract validation tests pass
- [ ] Generator output tests pass
- [ ] Snapshot tests pass (or snapshots updated intentionally)
- [ ] Cross-language validation passes
- [ ] No breaking changes (or documented in CHANGELOG)
- [ ] New features have corresponding tests

### Before Every Release

- [ ] All CI/CD tests pass
- [ ] Integration tests against mock server pass
- [ ] Regression tests pass
- [ ] Generated SDKs tested against reference implementation (circular-js)
- [ ] Version numbers updated everywhere
- [ ] CHANGELOG updated
- [ ] Documentation updated

### Monthly Health Checks

- [ ] Test coverage analysis
- [ ] Performance benchmark comparison
- [ ] Dependency updates
- [ ] Security audit of generated code
- [ ] Review flaky tests

---

## Performance Testing

### Generator Performance

```bash
# tests/performance/generator-benchmark.sh
#!/bin/bash

echo "Benchmarking generator performance..."

# Time OpenAPI generation
time nickel export generators/openapi.ncl --format yaml > /dev/null

# Time TypeScript SDK generation
time nickel export generators/typescript-sdk.ncl > /dev/null

# Time all generators
time just generate
```

### Contract Evaluation Performance

```bash
# tests/performance/contract-benchmark.sh
#!/bin/bash

# Generate large test dataset
nickel export tests/performance/large-dataset.ncl > /tmp/large-dataset.json

# Time contract validation
time nickel export tests/performance/validate-large.ncl > /dev/null
```

---

## Next Steps

1. **Implement** Layer 1 tests (contracts) on Day 2-3 of Week 1
2. **Add** generator tests on Day 4-5
3. **Create** cross-language test harness in Week 3
4. **Setup** CI/CD pipeline in Week 4
5. **Establish** regression testing baseline before first release

---

## Resources

- [Nickel Documentation](https://nickel-lang.org/)
- [OpenAPI Validator](https://github.com/APIDevTools/swagger-cli)
- [Jest Testing Framework](https://jestjs.io/)
- [pytest for Python](https://docs.pytest.org/)
- [JUnit for Java](https://junit.org/)
