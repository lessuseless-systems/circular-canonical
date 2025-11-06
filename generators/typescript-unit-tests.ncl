# TypeScript Unit Test Generator
# Generates Jest unit tests with mocked fetch API

let config = import "../src/config.ncl" in
let helpers = import "./helpers.ncl" in

{
  test_code = "/**
 * Circular Protocol TypeScript SDK Unit Tests
 * Generated from Nickel API specification
 *
 * These tests mock the fetch API to test SDK methods in isolation.
 * They verify request building, response parsing, and error handling.
 *
 * No mock server required - tests run independently.
 */

import { CircularProtocolAPI } from '../sdk/circular-protocol'

// Mock fetch globally
global.fetch = jest.fn()

describe('CircularProtocolAPI Unit Tests', () => {
  let api: CircularProtocolAPI
  let mockFetch: jest.MockedFunction<typeof fetch>
  const TEST_URL = 'http://test.api'
  const API_VERSION = '%{config.version}'

  beforeEach(() => {
    mockFetch = global.fetch as jest.MockedFunction<typeof fetch>
    mockFetch.mockClear()
    api = new CircularProtocolAPI(TEST_URL)
  })

  describe('Wallet API Unit Tests', () => {
    describe('checkWallet', () => {
      test('should build correct request payload', async () => {
        const mockResponse = {
          Result: 200,
          Response: { exists: true, address: '0xtest' }
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        await api.checkWallet({
          Blockchain: 'MainNet',
          Address: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          Version: API_VERSION
        })

        expect(mockFetch).toHaveBeenCalledWith(
          `${TEST_URL}/checkWallet`,
          expect.objectContaining({
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: expect.stringContaining('MainNet')
          })
        )
      })

      test('should parse success response correctly', async () => {
        const mockResponse = {
          Result: 200,
          Response: { exists: true, address: '0xtest' }
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        const result = await api.checkWallet({
          Blockchain: 'MainNet',
          Address: '0xtest',
          Version: API_VERSION
        })

        expect(result).toEqual(mockResponse)
        expect(result.Result).toBe(200)
      })

      test('should handle HTTP errors', async () => {
        mockFetch.mockResolvedValueOnce({
          ok: false,
          status: 500,
        } as unknown as Response)

        await expect(
          api.checkWallet({
            Blockchain: 'MainNet',
            Address: '0xtest',
            Version: API_VERSION
          })
        ).rejects.toThrow('HTTP error! status: 500')
      })

      test('should handle network errors', async () => {
        mockFetch.mockRejectedValueOnce(new Error('Network failure'))

        await expect(
          api.checkWallet({
            Blockchain: 'MainNet',
            Address: '0xtest',
            Version: API_VERSION
          })
        ).rejects.toThrow('API request failed')
      })
    })

    describe('getWallet', () => {
      test('should build correct request and parse response', async () => {
        const mockResponse = {
          Result: 200,
          Response: { Address: '0xtest', Balance: 1000, Nonce: 5 }
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        const result = await api.getWallet({
          Blockchain: 'MainNet',
          Address: '0xtest',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
        expect(result.Response).toHaveProperty('Balance')
      })
    })

    describe('getWalletBalance', () => {
      test('should include Asset parameter in request', async () => {
        const mockResponse = {
          Result: 200,
          Response: { Balance: 5000, Asset: 'CIRX' }
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        await api.getWalletBalance({
          Blockchain: 'MainNet',
          Address: '0xtest',
          Asset: 'CIRX',
          Version: API_VERSION
        })

        const callBody = JSON.parse(mockFetch.mock.calls[0][1]?.body as string)
        expect(callBody.Asset).toBe('CIRX')
      })
    })
  })

  describe('Transaction API Unit Tests', () => {
    describe('sendTransaction', () => {
      test('should build complete transaction payload', async () => {
        const mockResponse = {
          Result: 200,
          Response: { TransactionID: '0xtxid', Status: 'pending' }
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        await api.sendTransaction({
          ID: '0xtxid',
          From: '0xfrom',
          To: '0xto',
          Timestamp: '2024-01-01:00:00:00',
          Type: 'C_TYPE_TRANSACTION',
          Payload: '0xdata',
          Nonce: '1',
          Signature: '0xsig',
          Blockchain: 'MainNet',
          Version: API_VERSION
        })

        expect(mockFetch).toHaveBeenCalledWith(
          `${TEST_URL}/sendTransaction`,
          expect.objectContaining({ method: 'POST' })
        )

        const callBody = JSON.parse(mockFetch.mock.calls[0][1]?.body as string)
        expect(callBody).toHaveProperty('Signature')
        expect(callBody).toHaveProperty('Nonce')
      })

      test('should parse transaction response', async () => {
        const mockResponse = {
          Result: 200,
          Response: { TransactionID: '0xtxid', Status: 'confirmed' }
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        const result = await api.sendTransaction({
          ID: '0xtxid',
          From: '0xfrom',
          To: '0xto',
          Timestamp: '2024-01-01:00:00:00',
          Type: 'C_TYPE_TRANSACTION',
          Payload: '0xdata',
          Nonce: '1',
          Signature: '0xsig',
          Blockchain: 'MainNet',
          Version: API_VERSION
        })

        expect((result.Response as any).Status).toBeDefined()
      })
    })

    describe('getPendingTransaction', () => {
      test('should fetch pending transaction by ID', async () => {
        const mockResponse = {
          Result: 200,
          Response: { TransactionID: '0xtx', Status: 'pending' }
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        const result = await api.getPendingTransaction({
          Blockchain: 'MainNet',
          ID: '0xtx',
          Version: API_VERSION
        })

        expect(result.Response).toHaveProperty('TransactionID')
      })
    })
  })

  describe('Block API Unit Tests', () => {
    describe('getBlock', () => {
      test('should fetch block by number', async () => {
        const mockResponse = {
          Result: 200,
          Response: { BlockNumber: 12345, Hash: '0xblockhash' }
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        const result = await api.getBlock({
          Blockchain: 'MainNet',
          BlockNumber: '12345',
          Version: API_VERSION
        })

        expect(result.Response).toHaveProperty('BlockNumber')
        expect(result.Response).toHaveProperty('Hash')
      })
    })

    describe('getBlockCount', () => {
      test('should return block count', async () => {
        const mockResponse = {
          Result: 200,
          Response: { BlockCount: 999999 }
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        const result = await api.getBlockCount({
          Blockchain: 'MainNet',
          Version: API_VERSION
        })

        expect(typeof (result.Response as any).BlockCount).toBe('number')
      })
    })

    describe('getAnalytics', () => {
      test('should return analytics data', async () => {
        const mockResponse = {
          Result: 200,
          Response: {
            TotalTransactions: 1000000,
            TotalWallets: 50000,
            BlockHeight: 99999
          }
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        const result = await api.getAnalytics({
          Blockchain: 'MainNet',
          Version: API_VERSION
        })

        expect(result.Response).toHaveProperty('TotalTransactions')
        expect(result.Response).toHaveProperty('BlockHeight')
      })
    })
  })

  describe('Smart Contract API Unit Tests', () => {
    describe('testContract', () => {
      test('should send contract test request', async () => {
        const mockResponse = {
          Result: 200,
          Response: 'Contract execution successful'
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        const result = await api.testContract({
          Blockchain: 'MainNet',
          From: '0xfrom',
          Project: '0xproject',
          Timestamp: '2024-01-01:00:00:00',
          Version: API_VERSION
        })

        expect(result.Result).toBe(200)
      })
    })

    describe('callContract', () => {
      test('should call contract with request data', async () => {
        const mockResponse = {
          Result: 200,
          Response: { Output: '0xresult', GasUsed: 21000 }
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        const result = await api.callContract({
          Blockchain: 'MainNet',
          From: '0xfrom',
          Address: '0xcontract',
          Request: '0xrequest',
          Timestamp: '2024-01-01:00:00:00',
          Version: API_VERSION
        })

        expect(result.Response).toBeDefined()
      })
    })
  })

  describe('Asset API Unit Tests', () => {
    describe('getAsset', () => {
      test('should fetch asset details', async () => {
        const mockResponse = {
          Result: 200,
          Response: {
            AssetName: 'CIRX',
            TotalSupply: 1000000000,
            Decimals: 8
          }
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        const result = await api.getAsset({
          Blockchain: 'MainNet',
          AssetName: 'CIRX',
          Version: API_VERSION
        })

        expect((result.Response as any).AssetName).toBe('CIRX')
      })
    })

    describe('getAssetSupply', () => {
      test('should return supply information', async () => {
        const mockResponse = {
          Result: 200,
          Response: {
            TotalSupply: 1000000000,
            CirculatingSupply: 750000000
          }
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        const result = await api.getAssetSupply({
          Blockchain: 'MainNet',
          AssetName: 'CIRX',
          Version: API_VERSION
        })

        expect(result.Response).toHaveProperty('TotalSupply')
        expect(result.Response).toHaveProperty('CirculatingSupply')
      })
    })
  })

  describe('Domain and Network API Unit Tests', () => {
    describe('getDomain', () => {
      test('should resolve domain to address', async () => {
        const mockResponse = {
          Result: 200,
          Response: { Domain: 'alice.cir', Address: '0xalice' }
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        const result = await api.getDomain({
          Blockchain: 'MainNet',
          Domain: 'alice.cir',
          Version: API_VERSION
        })

        expect((result.Response as any).Domain).toBe('alice.cir')
      })
    })

    describe('getBlockchains', () => {
      test('should return list of blockchains', async () => {
        const mockResponse = {
          Result: 200,
          Response: [
            { Name: 'MainNet', ChainID: '1', Active: true },
            { Name: 'TestNet', ChainID: '2', Active: true }
          ]
        }

        mockFetch.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        } as unknown as Response)

        const result = await api.getBlockchains({
          Version: API_VERSION
        })

        expect(Array.isArray(result.Response)).toBe(true)
      })
    })
  })

  describe('Error Handling Tests', () => {
    test('should handle JSON parse errors', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => {
          throw new Error('Invalid JSON')
        },
      } as unknown as Response)

      await expect(
        api.checkWallet({
          Blockchain: 'MainNet',
          Address: '0xtest',
          Version: API_VERSION
        })
      ).rejects.toThrow()
    })

    test('should handle fetch errors', async () => {
      mockFetch.mockRejectedValueOnce(new TypeError('Failed to fetch'))

      await expect(
        api.checkWallet({
          Blockchain: 'MainNet',
          Address: '0xtest',
          Version: API_VERSION
        })
      ).rejects.toThrow('API request failed')
    })
  })
})
",

  metadata = {
    version = config.version,
    framework = "Jest with mocked fetch",
    test_type = "unit",
    test_count = 24,
    description = "Generated TypeScript SDK unit tests with mocked HTTP",
  },
}
