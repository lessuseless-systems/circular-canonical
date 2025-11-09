/**
 * Circular Protocol TypeScript SDK Integration Tests
 * Generated from tests/L3-integration/integration-tests.test.ncl
 *
 * These tests validate SDK functionality against a mock API server.
 * They test real HTTP requests, response parsing, and error handling.
 *
 * Requirements:
 * - Mock server running on http://localhost:8080
 * - Start with: python3 dist/tests/mock-server.py
 *
 * Run tests:
 *   cd tests/L3-integration
 *   npm test
 */

import { CircularProtocolAPI } from '../../dist/typescript/src/index'

const API_URL = process.env.CIRCULAR_API_URL || 'http://localhost:8080'
const API_VERSION = '2.0.0-alpha.1'

describe('Circular Protocol SDK Integration Tests', () => {
  let api: CircularProtocolAPI

  beforeAll(() => {
    api = new CircularProtocolAPI(API_URL)
  })

  describe('Network API', () => {
  test('Should list supported blockchains', async () => {
    const result = await api.getBlockchains({
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(Array.isArray(result.Response?.blockchains)).toBe(true)
expect(result.Response?.blockchains).toContain('MainNet')

    console.log('  ✅ Should list supported blockchains')
  }, 10000)
  })

  describe('Wallet API', () => {
  test('Should successfully check if wallet exists', async () => {
    const result = await api.checkWallet({
  "Address": "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.exists).toBe(true)

    console.log('  ✅ Should successfully check if wallet exists')
  }, 10000)
  test('Should fetch recent transactions for wallet', async () => {
    const result = await api.getLatestTransactions({
  "Address": "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
  "Blockchain": "MainNet",
  "Limit": 10,
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(Array.isArray(result.Response?.transactions)).toBe(true)

    console.log('  ✅ Should fetch recent transactions for wallet')
  }, 10000)
  test('Should retrieve wallet details', async () => {
    const result = await api.getWallet({
  "Address": "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.address).toBeDefined()

    console.log('  ✅ Should retrieve wallet details')
  }, 10000)
  test('Should get wallet balance for specific asset', async () => {
    const result = await api.getWalletBalance({
  "Address": "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
  "Asset": "0xC123",
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.balance).toBeDefined()

    console.log('  ✅ Should get wallet balance for specific asset')
  }, 10000)
  test('Should get current wallet nonce', async () => {
    const result = await api.getWalletNonce({
  "Address": "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.nonce).toBeGreaterThanOrEqual(0)

    console.log('  ✅ Should get current wallet nonce')
  }, 10000)
  test('Should register a new wallet', async () => {
    const result = await api.registerWallet({
  "Address": "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
  "Blockchain": "MainNet",
  "PublicKey": "0x04abcdef1234567890",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.success).toBe(true)

    console.log('  ✅ Should register a new wallet')
  }, 10000)
  })

  describe('Transaction API', () => {
  test('Should get pending transactions', async () => {
    const result = await api.getPendingTransaction({
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(Array.isArray(result.Response?.transactions)).toBe(true)

    console.log('  ✅ Should get pending transactions')
  }, 10000)
  test('Should get transactions by address', async () => {
    const result = await api.getTransactionbyAddress({
  "Address": "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(Array.isArray(result.Response?.transactions)).toBe(true)

    console.log('  ✅ Should get transactions by address')
  }, 10000)
  test('Should get transactions by date range', async () => {
    const result = await api.getTransactionbyDate({
  "Blockchain": "MainNet",
  "EndDate": "2024-12-31",
  "StartDate": "2024-01-01",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(Array.isArray(result.Response?.transactions)).toBe(true)

    console.log('  ✅ Should get transactions by date range')
  }, 10000)
  test('Should get transaction by ID', async () => {
    const result = await api.getTransactionbyID({
  "Blockchain": "MainNet",
  "TransactionID": "0xaabbccdd11223344",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.transaction).toBeDefined()

    console.log('  ✅ Should get transaction by ID')
  }, 10000)
  test('Should get transactions by node', async () => {
    const result = await api.getTransactionbyNode({
  "Blockchain": "MainNet",
  "Node": "0xnode123",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(Array.isArray(result.Response?.transactions)).toBe(true)

    console.log('  ✅ Should get transactions by node')
  }, 10000)
  test('Should submit a transaction to blockchain', async () => {
    const result = await api.sendTransaction({
  "From": "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
  "ID": "0xaabbccdd11223344",
  "Nonce": 1,
  "Payload": "0x1234",
  "Signature": "0xsignature",
  "Timestamp": "1234567890",
  "To": "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
  "Type": "transfer",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.transaction_id).toBeDefined()

    console.log('  ✅ Should submit a transaction to blockchain')
  }, 10000)
  })

  describe('Asset API', () => {
  test('Should get asset details', async () => {
    const result = await api.getAsset({
  "Asset": "0xC123",
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.asset).toBeDefined()

    console.log('  ✅ Should get asset details')
  }, 10000)
  test('Should get list of all assets', async () => {
    const result = await api.getAssetList({
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(Array.isArray(result.Response?.assets)).toBe(true)

    console.log('  ✅ Should get list of all assets')
  }, 10000)
  test('Should get asset supply information', async () => {
    const result = await api.getAssetSupply({
  "Asset": "0xC123",
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.total_supply).toBeDefined()

    console.log('  ✅ Should get asset supply information')
  }, 10000)
  test('Should get voucher details', async () => {
    const result = await api.getVoucher({
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1",
  "VoucherID": "0xvoucher123"
})

expect(result.Result).toBe(200)
expect(result.Response?.voucher).toBeDefined()

    console.log('  ✅ Should get voucher details')
  }, 10000)
  })

  describe('Block API', () => {
  test('Should get blockchain analytics', async () => {
    const result = await api.getAnalytics({
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.analytics).toBeDefined()

    console.log('  ✅ Should get blockchain analytics')
  }, 10000)
  test('Should get block by number', async () => {
    const result = await api.getBlock({
  "Block": 12345,
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.block).toBeDefined()

    console.log('  ✅ Should get block by number')
  }, 10000)
  test('Should get current blockchain height', async () => {
    const result = await api.getBlockCount({
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.count).toBeGreaterThan(0)

    console.log('  ✅ Should get current blockchain height')
  }, 10000)
  test('Should get range of blocks', async () => {
    const result = await api.getBlockRange({
  "Blockchain": "MainNet",
  "EndBlock": 10010,
  "StartBlock": 10000,
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(Array.isArray(result.Response?.blocks)).toBe(true)

    console.log('  ✅ Should get range of blocks')
  }, 10000)
  })

  describe('Smart Contract API', () => {
  test('Should call contract method', async () => {
    const result = await api.callContract({
  "Blockchain": "MainNet",
  "ContractAddress": "0xcontract123",
  "Method": "balanceOf",
  "Parameters": [
    "0xwallet123"
  ],
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.result).toBeDefined()

    console.log('  ✅ Should call contract method')
  }, 10000)
  test('Should test contract execution (dry run)', async () => {
    const result = await api.testContract({
  "Blockchain": "MainNet",
  "ContractAddress": "0xcontract123",
  "Method": "transfer",
  "Parameters": [
    "0xrecipient",
    "1000"
  ],
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.result).toBeDefined()

    console.log('  ✅ Should test contract execution (dry run)')
  }, 10000)
  })

  describe('Domain API', () => {
  test('Should resolve domain to address', async () => {
    const result = await api.getDomain({
  "Blockchain": "MainNet",
  "Domain": "myname.circular",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.address).toBeDefined()

    console.log('  ✅ Should resolve domain to address')
  }, 10000)
  })

  describe('Error Handling', () => {
test('Should handle network connection errors gracefully', async () => {
  const invalidApi = new CircularProtocolAPI('http://localhost:9999')

  await expect(invalidApi.checkWallet({
  "Address": "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
}))
    .rejects
    .toThrow()

  console.log('  ✅ Should handle network connection errors gracefully')
}, 10000)
test('Should handle invalid address gracefully', async () => {
  await expect(api.checkWallet({
  "Address": "invalid",
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
}))
    .rejects
    .toThrow()

  console.log('  ✅ Should handle invalid address gracefully')
}, 10000)
  })
})