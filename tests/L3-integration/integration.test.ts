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
  })

  describe('Block API', () => {
  test('Should get current blockchain height', async () => {
    const result = await api.getBlockCount({
  "Blockchain": "MainNet",
  "Version": "2.0.0-alpha.1"
})

expect(result.Result).toBe(200)
expect(result.Response?.count).toBeGreaterThan(0)

    console.log('  ✅ Should get current blockchain height')
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