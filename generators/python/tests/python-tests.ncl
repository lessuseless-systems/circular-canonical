# Python pytest Test Generator
# Generates comprehensive SDK tests from Nickel endpoint test data

let config = import "../../../src/config.ncl" in
let helpers = import "../../shared/helpers.ncl" in

{
  test_code = "\"\"\"
Circular Protocol Python SDK Tests
Generated from Nickel API specification

These tests use the real generated SDK to make HTTP requests
to the mock server, validating full response structures.

Prerequisites:
- Mock server running on http://localhost:8080
- Start with: just mock-server

Run with:
    pytest dist/tests/test_sdk.py -v
\"\"\"

import pytest
from circular_protocol import CircularProtocolAPI


MOCK_SERVER_URL = 'http://localhost:8080'
API_VERSION = '%{config.version}'


@pytest.fixture(scope='module')
def api():
    \"\"\"Fixture providing API client connected to mock server\"\"\"
    return CircularProtocolAPI(MOCK_SERVER_URL)


class TestWalletAPI:
    \"\"\"Tests for Wallet API endpoints\"\"\"

    def test_check_wallet_mainnet(self, api):
        \"\"\"Should check if wallet exists on MainNet\"\"\"
        result = api.check_wallet(
            blockchain='MainNet',
            address='0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
        )

        assert result['Result'] == 200
        assert 'exists' in result['Response']
        assert 'address' in result['Response']
        assert isinstance(result['Response']['exists'], bool)

    def test_check_wallet_testnet(self, api):
        \"\"\"Should check if wallet exists on TestNet\"\"\"
        result = api.check_wallet(
            blockchain='TestNet',
            address='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
        )

        assert result['Result'] == 200
        assert 'exists' in result['Response']
        assert 'address' in result['Response']

    def test_get_wallet(self, api):
        \"\"\"Should get wallet information\"\"\"
        result = api.get_wallet(
            blockchain='MainNet',
            address='0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
        )

        assert result['Result'] == 200
        assert 'Address' in result['Response']
        assert 'Balance' in result['Response']
        assert 'Nonce' in result['Response']
        assert isinstance(result['Response']['Balance'], int)

    def test_get_wallet_balance(self, api):
        \"\"\"Should get wallet balance for specific asset\"\"\"
        result = api.get_wallet_balance(
            blockchain='MainNet',
            address='0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
            asset='CIRX'
        )

        assert result['Result'] == 200
        assert 'Balance' in result['Response']
        assert 'Asset' in result['Response']
        assert result['Response']['Asset'] == 'CIRX'

    def test_get_wallet_nonce(self, api):
        \"\"\"Should get wallet nonce\"\"\"
        result = api.get_wallet_nonce(
            blockchain='MainNet',
            address='0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
        )

        assert result['Result'] == 200
        assert 'Nonce' in result['Response']
        assert isinstance(result['Response']['Nonce'], int)

    def test_register_wallet(self, api):
        \"\"\"Should register a new wallet\"\"\"
        result = api.register_wallet(
            blockchain='MainNet',
            public_key='04abc123def456789abcdef0123456789abcdef0123456789abcdef012345678'
        )

        assert result['Result'] == 200
        assert 'TransactionID' in result['Response']
        assert 'Status' in result['Response']

    def test_get_latest_transactions(self, api):
        \"\"\"Should get latest transactions for wallet\"\"\"
        result = api.get_latest_transactions(
            blockchain='MainNet',
            address='0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
        )

        assert result['Result'] == 200
        assert 'Transactions' in result['Response']


class TestTransactionAPI:
    \"\"\"Tests for Transaction API endpoints\"\"\"

    def test_send_transaction(self, api):
        \"\"\"Should send a transaction\"\"\"
        result = api.send_transaction(
            transaction_id='0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd',
            from_address='0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
            to_address='0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
            timestamp='2024-01-15:10:30:00',
            tx_type='C_TYPE_TRANSACTION',
            payload='0x48656c6c6f',
            nonce='5',
            signature='0xsig123',
            blockchain='MainNet'
        )

        assert result['Result'] == 200
        assert 'TransactionID' in result['Response']
        assert 'Status' in result['Response']

    def test_get_pending_transaction(self, api):
        \"\"\"Should get pending transaction by ID\"\"\"
        result = api.get_pending_transaction(
            blockchain='MainNet',
            transaction_id='0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd'
        )

        assert result['Result'] == 200
        assert 'TransactionID' in result['Response']

    def test_get_transaction_by_id(self, api):
        \"\"\"Should find transaction by ID\"\"\"
        result = api.get_transaction_by_id(
            blockchain='MainNet',
            transaction_id='0xabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd',
            start='100',
            end='200'
        )

        assert result['Result'] == 200
        assert 'Transactions' in result['Response']

    def test_get_transaction_by_address(self, api):
        \"\"\"Should find transactions by address\"\"\"
        result = api.get_transaction_by_address(
            blockchain='MainNet',
            address='0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
            start='0',
            end='100'
        )

        assert result['Result'] == 200
        assert 'Transactions' in result['Response']

    def test_get_transaction_by_date(self, api):
        \"\"\"Should find transactions by date range\"\"\"
        result = api.get_transaction_by_date(
            blockchain='MainNet',
            address='0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
            initial_date='2024-01-01:00:00:00',
            final_date='2024-01-31:23:59:59'
        )

        assert result['Result'] == 200
        assert 'Transactions' in result['Response']


class TestBlockAPI:
    \"\"\"Tests for Block API endpoints\"\"\"

    def test_get_block(self, api):
        \"\"\"Should get specific block\"\"\"
        result = api.get_block(
            blockchain='MainNet',
            block_number='12345'
        )

        assert result['Result'] == 200
        assert 'BlockNumber' in result['Response']
        assert 'Hash' in result['Response']

    def test_get_block_range(self, api):
        \"\"\"Should get range of blocks\"\"\"
        result = api.get_block_range(
            blockchain='MainNet',
            start='100',
            end='200'
        )

        assert result['Result'] == 200
        assert 'Blocks' in result['Response']

    def test_get_block_count(self, api):
        \"\"\"Should get total block count\"\"\"
        result = api.get_block_count(
            blockchain='MainNet'
        )

        assert result['Result'] == 200
        assert 'BlockCount' in result['Response']
        assert isinstance(result['Response']['BlockCount'], int)

    def test_get_analytics(self, api):
        \"\"\"Should get blockchain analytics\"\"\"
        result = api.get_analytics(
            blockchain='MainNet'
        )

        assert result['Result'] == 200
        assert 'TotalTransactions' in result['Response']
        assert 'TotalWallets' in result['Response']
        assert 'BlockHeight' in result['Response']


class TestSmartContractAPI:
    \"\"\"Tests for Smart Contract API endpoints\"\"\"

    def test_test_contract(self, api):
        \"\"\"Should test contract execution\"\"\"
        result = api.test_contract(
            blockchain='MainNet',
            from_address='0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
            project='0x636f6e74726163745f636f6465...',
            timestamp='2024-01-15:10:30:00'
        )

        assert result['Result'] == 200
        assert result['Response'] is not None

    def test_call_contract(self, api):
        \"\"\"Should call deployed contract\"\"\"
        result = api.call_contract(
            blockchain='MainNet',
            from_address='0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
            contract_address='0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
            request='0x66756e6374696f6e4e616d65...',
            timestamp='2024-01-15:10:30:00'
        )

        assert result['Result'] == 200
        assert result['Response'] is not None


class TestAssetAPI:
    \"\"\"Tests for Asset API endpoints\"\"\"

    def test_get_asset_list(self, api):
        \"\"\"Should get list of all assets\"\"\"
        result = api.get_asset_list(
            blockchain='MainNet'
        )

        assert result['Result'] == 200
        assert 'Assets' in result['Response']

    def test_get_asset(self, api):
        \"\"\"Should get specific asset details\"\"\"
        result = api.get_asset(
            blockchain='MainNet',
            asset_name='CIRX'
        )

        assert result['Result'] == 200
        assert 'AssetName' in result['Response']
        assert 'TotalSupply' in result['Response']

    def test_get_asset_supply(self, api):
        \"\"\"Should get asset supply information\"\"\"
        result = api.get_asset_supply(
            blockchain='MainNet',
            asset_name='CIRX'
        )

        assert result['Result'] == 200
        assert 'TotalSupply' in result['Response']
        assert 'CirculatingSupply' in result['Response']

    def test_get_voucher(self, api):
        \"\"\"Should get voucher information\"\"\"
        result = api.get_voucher(
            blockchain='MainNet',
            code='VOUCHERCODE123'
        )

        assert result['Result'] == 200
        assert 'Code' in result['Response']
        assert 'Value' in result['Response']


class TestDomainAPI:
    \"\"\"Tests for Domain API endpoints\"\"\"

    def test_get_domain(self, api):
        \"\"\"Should resolve domain name to address\"\"\"
        result = api.get_domain(
            blockchain='MainNet',
            domain='alice.cir'
        )

        assert result['Result'] == 200
        assert 'Domain' in result['Response']
        assert 'Address' in result['Response']


class TestNetworkAPI:
    \"\"\"Tests for Network API endpoints\"\"\"

    def test_get_blockchains(self, api):
        \"\"\"Should list available blockchains\"\"\"
        result = api.get_blockchains()

        assert result['Result'] == 200
        assert isinstance(result['Response'], list)
        assert len(result['Response']) > 0
",

  metadata = {
    version = config.version,
    framework = "pytest",
    test_count = 24,
    description = "Generated Python SDK integration tests",
  },
}
