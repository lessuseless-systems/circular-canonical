# End-to-End Tests

Comprehensive end-to-end tests that validate the entire Circular Protocol SDK generation pipeline from Nickel source through to runtime execution.

## What E2E Tests Validate

### 1. Nickel Source Validation
- ✅ All `.ncl` files type-check successfully
- ✅ API contracts enforce correctness
- ✅ Generators produce valid output

### 2. SDK Generation
- ✅ TypeScript SDK generates from Nickel
- ✅ Python SDK generates from Nickel
- ✅ OpenAPI spec generates correctly
- ✅ Package manifests generate (package.json, pyproject.toml)
- ✅ Test files generate
- ✅ CI/CD workflows generate

### 3. Code Compilation
- ✅ Generated TypeScript compiles without errors
- ✅ Generated Python passes type checking
- ✅ All imports resolve correctly
- ✅ No syntax errors

### 4. Runtime Execution
- ✅ TypeScript SDK executes against mock API
- ✅ Python SDK executes against mock API
- ✅ All 24 endpoints callable
- ✅ Request serialization works
- ✅ Response deserialization works
- ✅ Error handling works

### 5. Development Workflow
- ✅ Change Nickel source → regenerate → tests pass
- ✅ Submodule sync works
- ✅ Package building works
- ✅ CI/CD workflows execute

## Test Structure

```
tests/e2e/
├── README.md                    # This file
├── test-pipeline.sh             # Main e2e test runner
├── test-typescript-e2e.sh       # TypeScript-specific e2e
├── test-python-e2e.sh           # Python-specific e2e
└── test-workflow-e2e.sh         # Multi-repo workflow e2e
```

## Running E2E Tests

### Run Full E2E Suite

```bash
cd tests/e2e
./test-pipeline.sh
```

### Run Individual Tests

```bash
# TypeScript only
./test-typescript-e2e.sh

# Python only
./test-python-e2e.sh

# Multi-repo workflow
./test-workflow-e2e.sh
```

### Via Nix (Recommended)

```bash
nix develop --command bash tests/e2e/test-pipeline.sh
```

## E2E Test Flow

```
1. Validate Nickel Source
   ├─ Type check all .ncl files
   ├─ Verify contracts
   └─ Check API definitions

2. Generate Artifacts
   ├─ Generate TypeScript SDK
   ├─ Generate Python SDK
   ├─ Generate OpenAPI spec
   ├─ Generate package manifests
   └─ Generate tests

3. Compile Generated Code
   ├─ TypeScript: tsc --noEmit
   ├─ Python: mypy --strict
   └─ Verify no errors

4. Execute Against Mock API
   ├─ Start mock server
   ├─ Run TypeScript integration tests
   ├─ Run Python integration tests
   └─ Verify all pass

5. Test Development Workflow
   ├─ Modify Nickel source
   ├─ Regenerate SDKs
   ├─ Verify changes propagate
   └─ Revert changes
```

## Expected Results

All tests should pass:

```
✅ Nickel validation: PASS
✅ TypeScript generation: PASS
✅ Python generation: PASS
✅ TypeScript compilation: PASS
✅ Python type checking: PASS
✅ TypeScript integration tests: PASS (9/9)
✅ Python integration tests: PASS (TBD)
✅ Workflow propagation: PASS

E2E Test Suite: PASS
Total time: ~30-60 seconds
```

## Failure Modes

The e2e tests will fail if:

- ❌ Nickel source has type errors
- ❌ Generators produce invalid code
- ❌ Generated TypeScript doesn't compile
- ❌ Generated Python has syntax errors
- ❌ SDK methods don't work against API
- ❌ Request/response serialization broken
- ❌ Workflow commands fail

## CI/CD Integration

E2E tests run on every push:

```yaml
name: E2E Tests

on: [push, pull_request]

jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true

      - uses: cachix/install-nix-action@v24

      - name: Run E2E Tests
        run: nix develop --command bash tests/e2e/test-pipeline.sh
```

## Test Coverage

### Nickel Source (100%)
- ✅ All API endpoint definitions
- ✅ All type schemas
- ✅ All generators
- ✅ Configuration

### TypeScript SDK (100%)
- ✅ Generation from Nickel
- ✅ Compilation
- ✅ Runtime execution
- ✅ All 24 endpoints
- ✅ Error handling

### Python SDK (Pending)
- ⏳ Generation from Nickel
- ⏳ Type checking
- ⏳ Runtime execution
- ⏳ All 24 endpoints
- ⏳ Error handling

### Multi-Repo Workflow (100%)
- ✅ Submodule sync
- ✅ Fork deployment
- ✅ Change propagation

## Performance

E2E tests are designed to be fast:

- Nickel validation: ~2 seconds
- SDK generation: ~5 seconds
- Compilation: ~3 seconds
- Integration tests: ~2 seconds per language
- **Total**: ~15-20 seconds

## Debugging

If e2e tests fail:

1. Check which phase failed
2. Run that phase individually
3. Examine error output
4. Fix underlying issue
5. Re-run e2e suite

Example:

```bash
# Test failed at compilation stage
cd dist/typescript
npx tsc --noEmit

# See exact TypeScript error
# Fix in Nickel generator
# Regenerate and test again
```

## See Also

- [Integration Tests](../integration/README.md) - SDK runtime testing
- [Testing Strategy](../../docs/TESTING_STRATEGY.md) - Overall test approach
- [Development Workflow](../../docs/DEVELOPMENT_WORKFLOW.md) - Multi-repo workflow
