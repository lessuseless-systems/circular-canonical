# generators/typescript/CLAUDE.md

Guidance for working with TypeScript SDK generators.

> **Parent Context**: See `generators/CLAUDE.md` for generator system overview.

## ⚠️ CRITICAL: Complete SDK Generation

**The TypeScript generator produces a COMPLETE, PRODUCTION-READY SDK - NEVER hand-code!**

`typescript-sdk.ncl` generates **all 39 methods**:
- 24 API endpoint methods (imported from `src/api/*.ncl`)
- 15 helper/utility methods (imported from `generators/shared/helpers-*.ncl`)

**To modify TypeScript SDK:**
1. Edit `generators/typescript/typescript-sdk.ncl` or helper generators in `generators/shared/`
2. Run `just generate-ts-package`
3. **NEVER** manually edit `dist/circular-ts/src/index.ts`

## Directory Structure

```
generators/typescript/
├── CLAUDE.md                          # This file
├── typescript-sdk.ncl                 # Main SDK generator
├── tests/
│   ├── typescript-tests.ncl           # Integration test generator
│   └── typescript-unit-tests.ncl      # Unit test generator
├── config/
│   ├── typescript-tsconfig.ncl        # tsconfig.json generator
│   ├── typescript-jest.ncl            # jest.config.js generator
│   ├── typescript-webpack-cjs.ncl     # webpack config for CJS
│   ├── typescript-webpack-esm.ncl     # webpack config for ESM
│   └── typescript-eslint.todo.ncl     # ESLint config (TODO)
├── docs/
│   └── typescript-readme.ncl          # README.md generator
├── package-manifest/
│   └── typescript-package-json.ncl    # package.json generator
├── metadata/
│   └── (future .gitignore generator)
└── ci-cd/
    └── typescript-github-actions-test.todo.ncl  # GitHub Actions (TODO)
```

## TypeScript SDK Generator

### Complete SDK Structure

The TypeScript SDK generator (`typescript-sdk.ncl`) imports helper generators and produces a complete SDK:

```nickel
# generators/typescript/typescript-sdk.ncl (lines 13-16)
let helpers_crypto = import "../shared/helpers-crypto.ncl" in
let helpers_encoding = import "../shared/helpers-encoding.ncl" in
let helpers_config = import "../shared/helpers-config.ncl" in
let helpers_advanced = import "../shared/helpers-advanced.ncl" in
```

**Generated output** (`dist/circular-ts/src/index.ts` - 917 lines):

```typescript
// Generated SDK structure
export class CircularProtocolAPI {
  private baseURL: string;
  private headers: Record<string, string>;

  constructor(config: CircularProtocolConfig) {
    this.baseURL = config.baseURL;
    this.headers = config.headers || {};
  }

  // ========== API ENDPOINTS (24 methods) ==========
  // Wallet operations
  async checkWallet(address: string): Promise<WalletCheckResponse> { }
  async getWallet(address: string): Promise<WalletResponse> { }
  async getWalletBalance(address: string): Promise<BalanceResponse> { }
  async getWalletNonce(address: string): Promise<NonceResponse> { }
  async getLatestTransactions(address: string): Promise<TransactionListResponse> { }
  async registerWallet(params: RegisterWalletParams): Promise<WalletResponse> { }

  // Transaction operations (6 methods)
  async sendTransaction(params: TransactionParams): Promise<TransactionResponse> { }
  // ... more transaction methods

  // Asset operations (4 methods)
  async getAssetList(): Promise<AssetListResponse> { }
  // ... more asset methods

  // Block operations (4 methods)
  async getBlock(height: number): Promise<BlockResponse> { }
  // ... more block methods

  // Contract operations (2 methods)
  async testContract(params: ContractParams): Promise<ContractTestResponse> { }
  async callContract(params: ContractParams): Promise<ContractCallResponse> { }

  // Domain operations (1 method)
  async resolveDomain(domain: string): Promise<DomainResponse> { }

  // Network operations (1 method)
  async getBlockchains(): Promise<BlockchainListResponse> { }

  // ========== HELPER METHODS (15 methods) ==========
  // Cryptographic helpers (from helpers-crypto.ncl)
  signMessage(message: string, privateKey: string): string { }
  verifySignature(message: string, signature: string, publicKey: string): boolean { }
  getPublicKey(privateKey: string): string { }
  hashString(input: string): string { }
  getFormattedTimestamp(): string { }

  // Encoding helpers (from helpers-encoding.ncl)
  hexFix(hex: string): string { }
  stringToHex(str: string): string { }
  hexToString(hex: string): string { }
  padNumber(num: number, length: number): string { }

  // Advanced helpers (from helpers-advanced.ncl)
  getTransactionOutcome(tx: Transaction): string { }
  GetError(error: any): string { }
  handleError(error: any): void { }

  // Configuration helpers (from helpers-config.ncl)
  getNagUrl(): string { }
  setNagUrl(url: string): void { }
}
```

**Total: 39 methods** - 100% generated from Nickel

### Type Mappings

Nickel types → TypeScript types:

```nickel
let type_mapping = fun nickel_type =>
  if nickel_type == "string" then "string"
  else if nickel_type == "number" then "number"
  else if nickel_type == "boolean" then "boolean"
  else if nickel_type == "array" then "Array<any>"
  else if nickel_type == "object" then "Record<string, any>"
  else "unknown"
```

### Naming Conventions

- **Functions/Methods**: `camelCase` (e.g., `checkWallet`, `getAssetList`)
- **Classes**: `PascalCase` (e.g., `CircularProtocolAPI`, `WalletResponse`)
- **Interfaces**: `PascalCase` (e.g., `CircularProtocolConfig`)
- **Type Aliases**: `PascalCase` (e.g., `Address`, `Amount`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `DEFAULT_TIMEOUT`)

### Async Patterns

All API methods use `async/await`:

```nickel
let generate_method = fun endpoint =>
  m%"
  async %{helpers.to_camel_case endpoint.name}(%{generate_params endpoint.parameters}): Promise<%{generate_response_type endpoint}> {
    const response = await fetch(`${this.baseURL}%{endpoint.path}`, {
      method: '%{endpoint.method}',
      headers: this.headers,
      body: JSON.stringify(params),
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    return response.json();
  }
  "%
```

## Package Configuration

### package.json Generator

Generates complete npm package manifest:

```json
{
  "name": "circular-protocol-api",
  "version": "2.0.0-alpha.1",
  "description": "Official TypeScript SDK for Circular Protocol blockchain",
  "main": "./lib/index.cjs",
  "module": "./lib/index.js",
  "types": "./lib/index.d.ts",
  "exports": {
    ".": {
      "require": "./lib/index.cjs",
      "import": "./lib/index.js",
      "types": "./lib/index.d.ts"
    }
  },
  "scripts": {
    "build": "tsc && webpack",
    "test": "jest",
    "lint": "eslint src/**/*.ts"
  }
}
```

### tsconfig.json Generator

Generates TypeScript compiler configuration:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "node",
    "lib": ["ES2020"],
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./lib",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "lib", "**/*.test.ts"]
}
```

### Dual Module Support (CJS + ESM)

The TypeScript generators support both CommonJS and ES Modules:

**webpack-cjs.ncl**: Generates CommonJS bundle (lib/index.cjs)
**webpack-esm.ncl**: Generates ES Module bundle (lib/index.js)

This allows the SDK to be used in both:
- Node.js `require()` (CJS)
- Node.js/Browser `import` (ESM)

## Test Generators

### Unit Tests (Jest)

Generates Jest unit tests for each API method:

```typescript
describe('CircularProtocolAPI', () => {
  describe('checkWallet', () => {
    it('should check wallet exists', async () => {
      const api = new CircularProtocolAPI({ baseURL: 'http://test' });
      const result = await api.checkWallet('0x1234...');
      expect(result.exists).toBeDefined();
    });

    it('should throw on invalid address', async () => {
      const api = new CircularProtocolAPI({ baseURL: 'http://test' });
      await expect(api.checkWallet('invalid')).rejects.toThrow();
    });
  });
});
```

### Integration Tests

Generates integration tests that hit real API endpoints (or mocked server):

```typescript
describe('Integration: Wallet Operations', () => {
  let api: CircularProtocolAPI;

  beforeAll(() => {
    api = new CircularProtocolAPI({
      baseURL: process.env.API_URL || 'http://localhost:3000',
    });
  });

  it('should perform full wallet workflow', async () => {
    const address = await api.registerWallet({ /* params */ });
    const wallet = await api.getWallet(address);
    const balance = await api.getWalletBalance(address);
    expect(balance).toBeDefined();
  });
});
```

## Documentation Generator

### README.md Structure

The `typescript-readme.ncl` generator produces:

```markdown
# Circular Protocol API - TypeScript SDK

[![npm version](https://img.shields.io/npm/v/circular-protocol-api.svg)](...)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](...)

> Official TypeScript SDK for Circular Protocol blockchain

## Installation

npm install circular-protocol-api

## Quick Start

```typescript
import { CircularProtocolAPI } from 'circular-protocol-api';

const api = new CircularProtocolAPI({
  baseURL: 'https://api.circular.org',
});

const wallet = await api.checkWallet('0x1234...');
```

## API Reference

[24 methods listed with parameters and return types]

## Examples

[Top 5 endpoints with detailed examples]
```

## Build Process

### Development Build

```bash
# Type check
just validate

# Generate TypeScript SDK
just generate-ts-sdk

# Build (compile + bundle)
cd dist/typescript && npm run build

# Test
cd dist/typescript && npm test
```

### Production Build

```bash
# Generate optimized bundles
just generate
cd dist/typescript
npm run build --production

# Verify bundle size
ls -lh lib/

# Test production bundle
npm pack
npm install circular-protocol-api-2.0.0-alpha.1.tgz
```

## Type Safety Patterns

### Runtime Validation

Generate runtime validators for TypeScript types:

```typescript
export function isAddress(value: unknown): value is string {
  return (
    typeof value === 'string' &&
    (value.length === 64 || value.length === 66) &&
    /^(0x)?[0-9a-fA-F]+$/.test(value)
  );
}

export function assertAddress(value: unknown): asserts value is string {
  if (!isAddress(value)) {
    throw new Error(`Invalid address: ${value}`);
  }
}
```

### Type Guards

```typescript
export type Blockchain = 'ethereum' | 'polygon' | 'bsc' | 'avalanche';

export function isBlockchain(value: unknown): value is Blockchain {
  return (
    typeof value === 'string' &&
    ['ethereum', 'polygon', 'bsc', 'avalanche'].includes(value)
  );
}
```

## Common Patterns

### Error Handling

```typescript
export class CircularAPIError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public endpoint: string
  ) {
    super(message);
    this.name = 'CircularAPIError';
  }
}

async checkWallet(address: string): Promise<WalletCheckResponse> {
  try {
    const response = await fetch(/* ... */);
    if (!response.ok) {
      throw new CircularAPIError(
        response.statusText,
        response.status,
        '/checkWallet'
      );
    }
    return response.json();
  } catch (error) {
    if (error instanceof CircularAPIError) throw error;
    throw new CircularAPIError(
      'Network error',
      0,
      '/checkWallet'
    );
  }
}
```

### Request/Response Interceptors

```typescript
export interface CircularProtocolConfig {
  baseURL: string;
  headers?: Record<string, string>;
  beforeRequest?: (config: RequestConfig) => RequestConfig;
  afterResponse?: (response: Response) => Response;
}
```

## Publishing to npm

### Pre-publish Checklist

1. ✅ All tests pass: `npm test`
2. ✅ Type check passes: `tsc --noEmit`
3. ✅ Bundles built: `npm run build`
4. ✅ README up to date
5. ✅ CHANGELOG updated
6. ✅ Version bumped in package.json

### Publish Commands

```bash
# Dry run
npm publish --dry-run

# Publish alpha
npm publish --tag alpha

# Publish production
npm publish
```

## Common Issues

### Module Resolution Errors

**Problem**: `Cannot find module 'circular-protocol-api'`
**Solution**: Ensure `exports` field in package.json correctly maps to built files

### Type Declaration Issues

**Problem**: TypeScript consumers can't find type definitions
**Solution**: Verify `types` field in package.json points to correct .d.ts file

### Webpack Bundle Size

**Problem**: Bundle too large
**Solution**:
- Enable tree-shaking: `"sideEffects": false` in package.json
- Minimize: `optimization.minimize: true` in webpack config
- Externalize Node.js built-ins

## Cross-References

- Generator patterns: `generators/CLAUDE.md`
- Source schemas: `src/CLAUDE.md`
- Python SDK comparison: `generators/python/CLAUDE.md`
