# TypeScript Jest Test Generator
# Generates comprehensive SDK tests from Nickel endpoint test data

let config = import "../src/config.ncl" in
let helpers = import "./helpers.ncl" in

{
  test_code = "/**
 * Circular Protocol TypeScript SDK Tests
 * Generated from Nickel API specification
 *
 * These tests use the real generated SDK to make HTTP requests
 * to the mock server, validating full response structures.
 *
 * Prerequisites:
 * - Mock server running on http://localhost:8080
 * - Start with: just mock-server
 */

import { CircularProtocolAPI } from '../sdk/circular-protocol'

describe('Circular Protocol SDK Tests', () => {
  let api: CircularProtocolAPI
  const MOCK_SERVER_URL = 'http://localhost:8080'
  const API_VERSION = '%{config.version}'

  beforeAll(() => {
    api = new CircularProtocolAPI(MOCK_SERVER_URL)
  })

  describe('Wallet API', () => {
    describe('checkWallet', () => {
      test('should check if wallet exists on MainNet', async () => {
        const result = await api.checkWallet({
          Blockchain: 'MainNet',
          Address: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('exists')
        expect(result.Response).toHaveProperty('address')
        expect(typeof result.Response.exists).toBe('boolean')
      })

      test('should check if wallet exists on TestNet', async () => {
        const result = await api.checkWallet({
          Blockchain: 'TestNet',
          Address: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('exists')
        expect(result.Response).toHaveProperty('address')
      })
    })

    describe('getWallet', () => {
      test('should get wallet information', async () => {
        const result = await api.getWallet({
          Blockchain: 'MainNet',
          Address: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('Address')
        expect(result.Response).toHaveProperty('Balance')
        expect(result.Response).toHaveProperty('Nonce')
        expect(typeof result.Response.Balance).toBe('number')
      })
    })

    describe('getWalletBalance', () => {
      test('should get wallet balance for specific asset', async () => {
        const result = await api.getWalletBalance({
          Blockchain: 'MainNet',
          Address: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          Asset: 'CIRX',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('Balance')
        expect(result.Response).toHaveProperty('Asset')
        expect(result.Response.Asset).toBe('CIRX')
      })
    })

    describe('getWalletNonce', () => {
      test('should get wallet nonce', async () => {
        const result = await api.getWalletNonce({
          Blockchain: 'MainNet',
          Address: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('Nonce')
        expect(typeof result.Response.Nonce).toBe('number')
      })
    })

    describe('registerWallet', () => {
      test('should register a new wallet', async () => {
        const result = await api.registerWallet({
          Blockchain: 'MainNet',
          PublicKey: '04abc123def456789abcdef0123456789abcdef0123456789abcdef012345678',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('TransactionID')
        expect(result.Response).toHaveProperty('Status')
      })
    })

    describe('getLatestTransactions', () => {
      test('should get latest transactions for wallet', async () => {
        const result = await api.getLatestTransactions({
          Blockchain: 'MainNet',
          Address: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('Transactions')
      })
    })
  })

  describe('Transaction API', () => {
    describe('sendTransaction', () => {
      test('should send a transaction', async () => {
        const result = await api.sendTransaction({
          ID: '0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd',
          From: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          To: '0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
          Timestamp: '2024-01-15:10:30:00',
          Type: 'C_TYPE_TRANSACTION',
          Payload: '0x48656c6c6f',
          Nonce: '5',
          Signature: '0xsig123',
          Blockchain: 'MainNet',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('TransactionID')
        expect(result.Response).toHaveProperty('Status')
      })
    })

    describe('getPendingTransaction', () => {
      test('should get pending transaction by ID', async () => {
        const result = await api.getPendingTransaction({
          Blockchain: 'MainNet',
          ID: '0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('TransactionID')
      })
    })

    describe('getTransactionbyID', () => {
      test('should find transaction by ID', async () => {
        const result = await api.getTransactionbyID({
          Blockchain: 'MainNet',
          ID: '0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd',
          Start: '100',
          End: '200',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('Transactions')
      })
    })

    describe('getTransactionbyAddress', () => {
      test('should find transactions by address', async () => {
        const result = await api.getTransactionbyAddress({
          Blockchain: 'MainNet',
          Address: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          Start: '0',
          End: '100',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('Transactions')
      })
    })

    describe('getTransactionbyDate', () => {
      test('should find transactions by date range', async () => {
        const result = await api.getTransactionbyDate({
          Blockchain: 'MainNet',
          Address: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          StartDate: '2024-01-01:00:00:00',
          EndDate: '2024-01-31:23:59:59',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('Transactions')
      })
    })
  })

  describe('Block API', () => {
    describe('getBlock', () => {
      test('should get specific block', async () => {
        const result = await api.getBlock({
          Blockchain: 'MainNet',
          BlockNumber: '12345',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('BlockNumber')
        expect(result.Response).toHaveProperty('Hash')
      })
    })

    describe('getBlockRange', () => {
      test('should get range of blocks', async () => {
        const result = await api.getBlockRange({
          Blockchain: 'MainNet',
          Start: '100',
          End: '200',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('Blocks')
      })
    })

    describe('getBlockCount', () => {
      test('should get total block count', async () => {
        const result = await api.getBlockCount({
          Blockchain: 'MainNet',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('BlockCount')
        expect(typeof result.Response.BlockCount).toBe('number')
      })
    })

    describe('getAnalytics', () => {
      test('should get blockchain analytics', async () => {
        const result = await api.getAnalytics({
          Blockchain: 'MainNet',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('TotalTransactions')
        expect(result.Response).toHaveProperty('TotalWallets')
        expect(result.Response).toHaveProperty('BlockHeight')
      })
    })
  })

  describe('Smart Contract API', () => {
    describe('testContract', () => {
      test('should test contract execution', async () => {
        const result = await api.testContract({
          Blockchain: 'MainNet',
          From: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          Project: '0x636f6e74726163745f636f6465...',
          Timestamp: '2024-01-15:10:30:00',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toBeDefined()
      })
    })

    describe('callContract', () => {
      test('should call deployed contract', async () => {
        const result = await api.callContract({
          Blockchain: 'MainNet',
          From: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          Address: '0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
          Request: '0x66756e6374696f6e4e616d65...',
          Timestamp: '2024-01-15:10:30:00',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toBeDefined()
      })
    })
  })

  describe('Asset API', () => {
    describe('getAssetList', () => {
      test('should get list of all assets', async () => {
        const result = await api.getAssetList({
          Blockchain: 'MainNet',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('Assets')
      })
    })

    describe('getAsset', () => {
      test('should get specific asset details', async () => {
        const result = await api.getAsset({
          Blockchain: 'MainNet',
          AssetName: 'CIRX',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('AssetName')
        expect(result.Response).toHaveProperty('TotalSupply')
      })
    })

    describe('getAssetSupply', () => {
      test('should get asset supply information', async () => {
        const result = await api.getAssetSupply({
          Blockchain: 'MainNet',
          AssetName: 'CIRX',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('TotalSupply')
        expect(result.Response).toHaveProperty('CirculatingSupply')
      })
    })

    describe('getVoucher', () => {
      test('should get voucher information', async () => {
        const result = await api.getVoucher({
          Blockchain: 'MainNet',
          Code: 'VOUCHERCODE123',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('Code')
        expect(result.Response).toHaveProperty('Value')
      })
    })
  })

  describe('Domain API', () => {
    describe('getDomain', () => {
      test('should resolve domain name to address', async () => {
        const result = await api.getDomain({
          Blockchain: 'MainNet',
          Domain: 'alice.cir',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('Domain')
        expect(result.Response).toHaveProperty('Address')
      })
    })
  })

  describe('Network API', () => {
    describe('getBlockchains', () => {
      test('should list available blockchains', async () => {
        const result = await api.getBlockchains({
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(Array.isArray(result.Response)).toBe(true)
      })
    })
  })
})
",

  metadata = {
    version = config.version,
    framework = "Jest",
    test_count = 24,
    description = "Generated TypeScript SDK integration tests",
  },
}
