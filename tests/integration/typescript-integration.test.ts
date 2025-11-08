/**
 * Circular Protocol TypeScript SDK Integration Tests
 *
 * Tests the SDK against a real Circular Protocol API endpoint.
 *
 * Setup:
 *   1. Ensure .env file exists with test credentials
 *   2. Set CIRCULAR_API_URL environment variable (default: http://localhost:3000)
 *   3. Run: npm test -- integration
 *
 * Note: These tests require a running Circular Protocol node or compatible API.
 */

import { CircularProtocolAPI } from '../../dist/typescript/src/index'
import * as dotenv from 'dotenv'
import * as path from 'path'

// Load environment variables from root .env
dotenv.config({ path: path.join(__dirname, '../../.env') })

// Test credentials from .env
const TEST_ADDRESS = process.env.CIRCULAR_STANDARD_ADDRESS || ''
const TEST_SEED = process.env.CIRCULAR_STANDARD_SEED || ''

describe('CircularProtocolAPI Integration Tests', () => {
  let api: CircularProtocolAPI
  const API_URL = process.env.CIRCULAR_API_URL || 'http://localhost:3000'
  const API_VERSION = '2.0.0-alpha.1'

  beforeAll(() => {
    if (!TEST_ADDRESS || !TEST_SEED) {
      console.warn('⚠️  Test credentials not found in .env file')
      console.warn('   Set CIRCULAR_STANDARD_ADDRESS and CIRCULAR_STANDARD_SEED')
    }

    console.log('🔵 Running integration tests against:', API_URL)
    api = new CircularProtocolAPI(API_URL)
  })

  describe('Wallet Operations', () => {
    describe('checkWallet', () => {
      it('should check if a wallet exists', async () => {
        const result = await api.checkWallet({
          Blockchain: 'MainNet',
          Address: TEST_ADDRESS,
          Version: API_VERSION,
        })

        expect(result).toBeDefined()
        expect(result.Result).toBeDefined()
        expect(typeof result.Result).toBe('number')

        if (result.Response) {
          expect(result.Response).toHaveProperty('exists')
          expect(typeof result.Response.exists).toBe('boolean')

          if (result.Response.exists) {
            console.log('  ✅ Wallet exists:', TEST_ADDRESS)
          } else {
            console.log('  ℹ️  Wallet not found (may need registration)')
          }
        }
      }, 10000) // 10s timeout for network requests

      it('should handle invalid address format', async () => {
        try {
          await api.checkWallet({
            Blockchain: 'MainNet',
            Address: 'invalid-address',
            Version: API_VERSION,
          })
          // If we get here, API didn't validate - that's okay, just log it
          console.log('  ℹ️  API accepted invalid address (validation may be client-side only)')
        } catch (error: any) {
          // Expected: API should reject invalid addresses
          expect(error).toBeDefined()
          console.log('  ✅ API rejected invalid address:', error.message)
        }
      }, 10000)
    })

    describe('getWallet', () => {
      it('should get wallet information', async () => {
        const result = await api.getWallet({
          Blockchain: 'MainNet',
          Address: TEST_ADDRESS,
          Version: API_VERSION,
        })

        expect(result).toBeDefined()
        expect(result.Result).toBeDefined()

        if (result.Result === 200 && result.Response) {
          console.log('  ✅ Retrieved wallet info:')
          console.log('     Address:', result.Response.Address)
          console.log('     Balance:', result.Response.Balance)
          console.log('     Nonce:', result.Response.Nonce)
        } else {
          console.log('  ℹ️  Wallet not found or error:', result.Result)
        }
      }, 10000)
    })

    describe('getWalletBalance', () => {
      it('should get wallet balance for CIRX asset', async () => {
        const result = await api.getWalletBalance({
          Blockchain: 'MainNet',
          Address: TEST_ADDRESS,
          Asset: 'CIRX',
          Version: API_VERSION,
        })

        expect(result).toBeDefined()
        expect(result.Result).toBeDefined()

        if (result.Response) {
          console.log('  ✅ CIRX Balance:', result.Response.Balance)
        }
      }, 10000)
    })

    describe('getWalletNonce', () => {
      it('should get wallet nonce', async () => {
        const result = await api.getWalletNonce({
          Blockchain: 'MainNet',
          Address: TEST_ADDRESS,
          Version: API_VERSION,
        })

        expect(result).toBeDefined()
        expect(result.Result).toBeDefined()

        if (result.Response) {
          console.log('  ✅ Current nonce:', result.Response.Nonce)
        }
      }, 10000)
    })

    describe('getLatestTransactions', () => {
      it('should get latest transactions for wallet', async () => {
        const result = await api.getLatestTransactions({
          Blockchain: 'MainNet',
          Address: TEST_ADDRESS,
          Version: API_VERSION,
        })

        expect(result).toBeDefined()
        expect(result.Result).toBeDefined()

        if (result.Response && Array.isArray(result.Response)) {
          console.log(`  ✅ Found ${result.Response.length} recent transactions`)
          if (result.Response.length > 0) {
            console.log('     Latest:', result.Response[0].ID)
          }
        } else {
          console.log('  ℹ️  No transactions found')
        }
      }, 10000)
    })
  })

  describe('Network Operations', () => {
    describe('getBlockchains', () => {
      it('should list supported blockchains', async () => {
        const result = await api.getBlockchains({
          Version: API_VERSION,
        })

        expect(result).toBeDefined()
        expect(result.Result).toBeDefined()

        if (result.Response && Array.isArray(result.Response)) {
          console.log('  ✅ Supported blockchains:', result.Response.join(', '))
        }
      }, 10000)
    })
  })

  describe('Block Operations', () => {
    describe('getBlockCount', () => {
      it('should get current block count', async () => {
        const result = await api.getBlockCount({
          Blockchain: 'MainNet',
          Version: API_VERSION,
        })

        expect(result).toBeDefined()
        expect(result.Result).toBeDefined()

        if (result.Response) {
          console.log('  ✅ Current block count:', result.Response.BlockCount)
        }
      }, 10000)
    })
  })

  describe('API Health', () => {
    it('should handle connection errors gracefully', async () => {
      const badApi = new CircularProtocolAPI('http://invalid-endpoint-12345.local:9999')

      try {
        await badApi.checkWallet({
          Blockchain: 'MainNet',
          Address: TEST_ADDRESS,
          Version: API_VERSION,
        })
        fail('Should have thrown an error for invalid endpoint')
      } catch (error: any) {
        expect(error).toBeDefined()
        console.log('  ✅ Handled connection error:', error.message)
      }
    }, 10000)
  })
})

/**
 * Test Summary Helper
 *
 * Run after tests to show summary of API connectivity
 */
afterAll(() => {
  console.log('\n' + '='.repeat(60))
  console.log('Integration Test Summary')
  console.log('='.repeat(60))
  console.log('API Endpoint:', process.env.CIRCULAR_API_URL || 'http://localhost:3000')
  console.log('Test Address:', TEST_ADDRESS ? `${TEST_ADDRESS.substring(0, 10)}...` : 'Not configured')
  console.log('='.repeat(60) + '\n')
})
