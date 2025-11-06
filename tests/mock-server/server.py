#!/usr/bin/env python3
"""
Mock HTTP Server for Circular Protocol API Testing
Simulates all 24 API endpoints with realistic mock responses
Used for testing generated TypeScript and Python SDKs
"""

import json
import re
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
from typing import Dict, Any, Optional

# Mock configuration
VERSION = "1.0.8"
PORT = 8080


class MockAPIHandler(BaseHTTPRequestHandler):
    """Handles mock API requests for all Circular Protocol endpoints"""

    def log_message(self, format: str, *args) -> None:
        """Override to provide cleaner logging"""
        print(f"[{self.log_date_time_string()}] {format % args}")

    def _send_response(self, status_code: int, data: Dict[str, Any]) -> None:
        """Send JSON response"""
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps(data, indent=2).encode())

    def _get_request_body(self) -> Optional[Dict[str, Any]]:
        """Parse JSON request body"""
        content_length = int(self.headers.get("Content-Length", 0))
        if content_length > 0:
            body = self.rfile.read(content_length)
            return json.loads(body.decode())
        return None

    def do_OPTIONS(self) -> None:
        """Handle CORS preflight"""
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_POST(self) -> None:
        """Handle POST requests to all API endpoints"""
        path = urlparse(self.path).path
        body = self._get_request_body()

        # Route to appropriate handler
        handlers = {
            # Wallet API
            "/checkWallet": self._handle_check_wallet,
            "/getWallet": self._handle_get_wallet,
            "/getLatestTransactions": self._handle_get_latest_transactions,
            "/getWalletBalance": self._handle_get_wallet_balance,
            "/getWalletNonce": self._handle_get_wallet_nonce,
            "/registerWallet": self._handle_register_wallet,

            # Transaction API
            "/sendTransaction": self._handle_send_transaction,
            "/getPendingTransaction": self._handle_get_pending_transaction,
            "/getTransactionbyID": self._handle_get_transaction_by_id,
            "/getTransactionbyNode": self._handle_get_transaction_by_node,
            "/getTransactionbyAddress": self._handle_get_transaction_by_address,
            "/getTransactionbyDate": self._handle_get_transaction_by_date,

            # Block API
            "/getBlock": self._handle_get_block,
            "/getBlockRange": self._handle_get_block_range,
            "/getBlockCount": self._handle_get_block_count,
            "/getAnalytics": self._handle_get_analytics,

            # Smart Contract API
            "/testContract": self._handle_test_contract,
            "/callContract": self._handle_call_contract,

            # Asset API
            "/getAssetList": self._handle_get_asset_list,
            "/getAsset": self._handle_get_asset,
            "/getAssetSupply": self._handle_get_asset_supply,
            "/getVoucher": self._handle_get_voucher,

            # Domain API
            "/getDomain": self._handle_get_domain,

            # Network API
            "/getBlockchains": self._handle_get_blockchains,
        }

        handler = handlers.get(path)
        if handler:
            handler(body or {})
        else:
            self._send_response(404, {
                "Result": 404,
                "Response": f"Endpoint not found: {path}"
            })

    # Wallet API Handlers
    def _handle_check_wallet(self, body: Dict[str, Any]) -> None:
        address = body.get("Address", "")
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "exists": True,
                "address": address
            }
        })

    def _handle_get_wallet(self, body: Dict[str, Any]) -> None:
        address = body.get("Address", "")
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "Address": address,
                "Balance": 1000000,
                "Nonce": 42,
                "Registered": True
            }
        })

    def _handle_get_latest_transactions(self, body: Dict[str, Any]) -> None:
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "Transactions": [
                    {
                        "ID": "0xabcd...1234",
                        "From": body.get("Address", ""),
                        "To": "0x9999...9999",
                        "Amount": 100,
                        "Timestamp": "2024-01-15:10:30:00"
                    }
                ],
                "Count": 1
            }
        })

    def _handle_get_wallet_balance(self, body: Dict[str, Any]) -> None:
        asset = body.get("Asset", "CIRX")
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "Balance": 500000,
                "Asset": asset
            }
        })

    def _handle_get_wallet_nonce(self, body: Dict[str, Any]) -> None:
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "Nonce": 42
            }
        })

    def _handle_register_wallet(self, body: Dict[str, Any]) -> None:
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "TransactionID": "0xcccc...cccc",
                "Status": "pending"
            }
        })

    # Transaction API Handlers
    def _handle_send_transaction(self, body: Dict[str, Any]) -> None:
        tx_id = body.get("ID", "0xabcd...efgh")
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "TransactionID": tx_id,
                "Status": "pending"
            }
        })

    def _handle_get_pending_transaction(self, body: Dict[str, Any]) -> None:
        tx_id = body.get("ID", "")
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "TransactionID": tx_id,
                "Status": "pending",
                "Timestamp": "2024-01-15:10:30:00"
            }
        })

    def _handle_get_transaction_by_id(self, body: Dict[str, Any]) -> None:
        tx_id = body.get("ID", "")
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "Transactions": [
                    {
                        "ID": tx_id,
                        "From": "0xaaaa...aaaa",
                        "To": "0xbbbb...bbbb",
                        "Amount": 100,
                        "Status": "confirmed"
                    }
                ]
            }
        })

    def _handle_get_transaction_by_node(self, body: Dict[str, Any]) -> None:
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "Transactions": [],
                "Count": 0
            }
        })

    def _handle_get_transaction_by_address(self, body: Dict[str, Any]) -> None:
        address = body.get("Address", "")
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "Transactions": [
                    {
                        "ID": "0xtx1",
                        "From": address,
                        "To": "0xdest",
                        "Amount": 50
                    }
                ],
                "Count": 1
            }
        })

    def _handle_get_transaction_by_date(self, body: Dict[str, Any]) -> None:
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "Transactions": [],
                "Count": 0
            }
        })

    # Block API Handlers
    def _handle_get_block(self, body: Dict[str, Any]) -> None:
        block_num = body.get("BlockNumber", "12345")
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "BlockNumber": int(block_num) if block_num.isdigit() else 12345,
                "Timestamp": "2024-01-15:10:30:00",
                "Transactions": [],
                "Hash": "0xblock123..."
            }
        })

    def _handle_get_block_range(self, body: Dict[str, Any]) -> None:
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "Blocks": [],
                "Count": 0
            }
        })

    def _handle_get_block_count(self, body: Dict[str, Any]) -> None:
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "BlockCount": 123456
            }
        })

    def _handle_get_analytics(self, body: Dict[str, Any]) -> None:
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "TotalTransactions": 1000000,
                "TotalWallets": 50000,
                "TotalAssets": 100,
                "BlockHeight": 123456
            }
        })

    # Smart Contract API Handlers
    def _handle_test_contract(self, body: Dict[str, Any]) -> None:
        self._send_response(200, {
            "Result": 200,
            "Response": "Contract execution successful"
        })

    def _handle_call_contract(self, body: Dict[str, Any]) -> None:
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "Output": "0x1234",
                "GasUsed": 21000
            }
        })

    # Asset API Handlers
    def _handle_get_asset_list(self, body: Dict[str, Any]) -> None:
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "Assets": ["CIRX", "TEST", "DEMO"],
                "Count": 3
            }
        })

    def _handle_get_asset(self, body: Dict[str, Any]) -> None:
        asset_name = body.get("AssetName", "CIRX")
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "AssetName": asset_name,
                "TotalSupply": 1000000000,
                "Decimals": 8,
                "Owner": "0xbbbb...bbbb"
            }
        })

    def _handle_get_asset_supply(self, body: Dict[str, Any]) -> None:
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "TotalSupply": 1000000000,
                "CirculatingSupply": 750000000,
                "ResidualSupply": 250000000
            }
        })

    def _handle_get_voucher(self, body: Dict[str, Any]) -> None:
        code = body.get("Code", "")
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "Code": code,
                "Value": 100,
                "Asset": "CIRX",
                "Redeemed": False
            }
        })

    # Domain API Handlers
    def _handle_get_domain(self, body: Dict[str, Any]) -> None:
        domain = body.get("Domain", "")
        self._send_response(200, {
            "Result": 200,
            "Response": {
                "Domain": domain,
                "Address": "0xbbbb...bbbb"
            }
        })

    # Network API Handlers
    def _handle_get_blockchains(self, body: Dict[str, Any]) -> None:
        self._send_response(200, {
            "Result": 200,
            "Response": [
                {"Name": "MainNet", "ChainID": "1", "Active": True},
                {"Name": "TestNet", "ChainID": "2", "Active": True},
                {"Name": "DevNet", "ChainID": "3", "Active": True}
            ]
        })


def run_server(port: int = PORT) -> None:
    """Start the mock server"""
    server_address = ("", port)
    httpd = HTTPServer(server_address, MockAPIHandler)

    print(f"🔵 Circular Protocol Mock API Server")
    print(f"   Version: {VERSION}")
    print(f"   Listening on: http://localhost:{port}")
    print(f"   Endpoints: 24 API endpoints")
    print(f"\nPress Ctrl+C to stop")
    print()

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n\n✅ Mock server stopped")
        httpd.shutdown()


if __name__ == "__main__":
    run_server()
