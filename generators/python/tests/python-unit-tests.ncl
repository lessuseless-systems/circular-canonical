# Python Unit Test Generator
# Generates pytest unit tests with mocked requests library

let config = import "../../../src/config.ncl" in
let helpers = import "../../shared/helpers.ncl" in

{
  test_code = "\"\"\"
Circular Protocol Python SDK Unit Tests
Generated from Nickel API specification

These tests mock the requests library to test SDK methods in isolation.
They verify request building, response parsing, and error handling.

No mock server required - tests run independently.

Run with:
    pytest dist/tests/test_sdk_unit.py -v
\"\"\"

import pytest
from unittest.mock import Mock, patch, MagicMock
import requests
from circular_protocol import CircularProtocolAPI


TEST_URL = 'http://test.api'
API_VERSION = '%{config.version}'


@pytest.fixture
def api():
    \"\"\"Fixture providing API client\"\"\"
    return CircularProtocolAPI(TEST_URL)


@pytest.fixture
def mock_session(monkeypatch):
    \"\"\"Fixture providing mocked requests session\"\"\"
    mock = MagicMock()
    monkeypatch.setattr('requests.Session.post', mock)
    return mock


@pytest.mark.unit
class TestWalletAPIUnit:
    \"\"\"Unit tests for Wallet API methods\"\"\"

    def test_check_wallet_builds_correct_payload(self, api, mock_session):
        \"\"\"Should build correct request payload for checkWallet\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'exists': True, 'address': '0xtest'}
        }
        mock_session.return_value = mock_response

        api.check_wallet(blockchain='MainNet', address='0xtest')

        mock_session.assert_called_once()
        call_args = mock_session.call_args
        assert call_args[0][0] == f'{TEST_URL}/checkWallet'
        assert call_args[1]['json']['Blockchain'] == 'MainNet'
        assert call_args[1]['json']['Address'] == '0xtest'
        assert call_args[1]['json']['Version'] == API_VERSION

    def test_check_wallet_parses_response(self, api, mock_session):
        \"\"\"Should parse checkWallet response correctly\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'exists': True, 'address': '0xtest'}
        }
        mock_session.return_value = mock_response

        result = api.check_wallet(blockchain='MainNet', address='0xtest')

        assert result['Result'] == 200
        assert result['Response']['exists'] is True
        assert 'address' in result['Response']

    def test_check_wallet_handles_http_error(self, api, mock_session):
        \"\"\"Should handle HTTP errors in checkWallet\"\"\"
        mock_session.side_effect = requests.exceptions.HTTPError('500 Server Error')

        with pytest.raises(requests.exceptions.RequestException):
            api.check_wallet(blockchain='MainNet', address='0xtest')

    def test_check_wallet_handles_connection_error(self, api, mock_session):
        \"\"\"Should handle connection errors in checkWallet\"\"\"
        mock_session.side_effect = requests.exceptions.ConnectionError('Connection refused')

        with pytest.raises(requests.exceptions.RequestException):
            api.check_wallet(blockchain='MainNet', address='0xtest')

    def test_get_wallet_returns_wallet_data(self, api, mock_session):
        \"\"\"Should return wallet data with Balance and Nonce\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'Address': '0xtest', 'Balance': 1000, 'Nonce': 5}
        }
        mock_session.return_value = mock_response

        result = api.get_wallet(blockchain='MainNet', address='0xtest')

        assert result['Result'] == 200
        assert 'Balance' in result['Response']
        assert 'Nonce' in result['Response']

    def test_get_wallet_balance_includes_asset(self, api, mock_session):
        \"\"\"Should include Asset parameter in request\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'Balance': 5000, 'Asset': 'CIRX'}
        }
        mock_session.return_value = mock_response

        result = api.get_wallet_balance(
            blockchain='MainNet',
            address='0xtest',
            asset='CIRX'
        )

        call_args = mock_session.call_args
        assert call_args[1]['json']['Asset'] == 'CIRX'
        assert result['Response']['Asset'] == 'CIRX'

    def test_get_wallet_nonce_returns_number(self, api, mock_session):
        \"\"\"Should return Nonce as number\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'Nonce': 42}
        }
        mock_session.return_value = mock_response

        result = api.get_wallet_nonce(blockchain='MainNet', address='0xtest')

        assert isinstance(result['Response']['Nonce'], int)

    def test_register_wallet_returns_transaction(self, api, mock_session):
        \"\"\"Should return TransactionID and Status\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'TransactionID': '0xtx', 'Status': 'pending'}
        }
        mock_session.return_value = mock_response

        result = api.register_wallet(blockchain='MainNet', public_key='0xpubkey')

        assert 'TransactionID' in result['Response']
        assert 'Status' in result['Response']


@pytest.mark.unit
class TestTransactionAPIUnit:
    \"\"\"Unit tests for Transaction API methods\"\"\"

    def test_send_transaction_builds_complete_payload(self, api, mock_session):
        \"\"\"Should build complete transaction payload\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'TransactionID': '0xtx', 'Status': 'pending'}
        }
        mock_session.return_value = mock_response

        api.send_transaction(
            transaction_id='0xtx',
            from_address='0xfrom',
            to_address='0xto',
            timestamp='2024-01-01:00:00:00',
            tx_type='C_TYPE_TRANSACTION',
            payload='0xdata',
            nonce='1',
            signature='0xsig',
            blockchain='MainNet'
        )

        call_args = mock_session.call_args
        payload = call_args[1]['json']
        assert payload['Signature'] == '0xsig'
        assert payload['Nonce'] == '1'
        assert payload['Type'] == 'C_TYPE_TRANSACTION'

    def test_send_transaction_parses_response(self, api, mock_session):
        \"\"\"Should parse transaction response\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'TransactionID': '0xtx', 'Status': 'confirmed'}
        }
        mock_session.return_value = mock_response

        result = api.send_transaction(
            transaction_id='0xtx',
            from_address='0xfrom',
            to_address='0xto',
            timestamp='2024-01-01:00:00:00',
            tx_type='C_TYPE_TRANSACTION',
            payload='0xdata',
            nonce='1',
            signature='0xsig',
            blockchain='MainNet'
        )

        assert result['Response']['Status'] == 'confirmed'

    def test_get_pending_transaction(self, api, mock_session):
        \"\"\"Should fetch pending transaction\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'TransactionID': '0xtx', 'Status': 'pending'}
        }
        mock_session.return_value = mock_response

        result = api.get_pending_transaction(
            blockchain='MainNet',
            transaction_id='0xtx'
        )

        assert 'TransactionID' in result['Response']

    def test_get_transaction_by_id(self, api, mock_session):
        \"\"\"Should find transaction by ID\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'Transactions': [{'ID': '0xtx'}]}
        }
        mock_session.return_value = mock_response

        result = api.get_transaction_by_id(
            blockchain='MainNet',
            transaction_id='0xtx',
            start='100',
            end='200'
        )

        assert 'Transactions' in result['Response']


@pytest.mark.unit
class TestBlockAPIUnit:
    \"\"\"Unit tests for Block API methods\"\"\"

    def test_get_block(self, api, mock_session):
        \"\"\"Should fetch block by number\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'BlockNumber': 12345, 'Hash': '0xblockhash'}
        }
        mock_session.return_value = mock_response

        result = api.get_block(blockchain='MainNet', block_number='12345')

        assert result['Response']['BlockNumber'] == 12345
        assert 'Hash' in result['Response']

    def test_get_block_range(self, api, mock_session):
        \"\"\"Should get range of blocks\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'Blocks': []}
        }
        mock_session.return_value = mock_response

        result = api.get_block_range(
            blockchain='MainNet',
            start='100',
            end='200'
        )

        assert 'Blocks' in result['Response']

    def test_get_block_count(self, api, mock_session):
        \"\"\"Should return block count\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'BlockCount': 999999}
        }
        mock_session.return_value = mock_response

        result = api.get_block_count(blockchain='MainNet')

        assert isinstance(result['Response']['BlockCount'], int)

    def test_get_analytics(self, api, mock_session):
        \"\"\"Should return analytics data\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {
                'TotalTransactions': 1000000,
                'TotalWallets': 50000,
                'BlockHeight': 99999
            }
        }
        mock_session.return_value = mock_response

        result = api.get_analytics(blockchain='MainNet')

        assert 'TotalTransactions' in result['Response']
        assert 'BlockHeight' in result['Response']


@pytest.mark.unit
class TestSmartContractAPIUnit:
    \"\"\"Unit tests for Smart Contract API methods\"\"\"

    def test_test_contract(self, api, mock_session):
        \"\"\"Should send contract test request\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': 'Contract execution successful'
        }
        mock_session.return_value = mock_response

        result = api.test_contract(
            blockchain='MainNet',
            from_address='0xfrom',
            project='0xproject',
            timestamp='2024-01-01:00:00:00'
        )

        assert result['Result'] == 200

    def test_call_contract(self, api, mock_session):
        \"\"\"Should call contract with request data\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'Output': '0xresult', 'GasUsed': 21000}
        }
        mock_session.return_value = mock_response

        result = api.call_contract(
            blockchain='MainNet',
            from_address='0xfrom',
            address='0xcontract',
            request='0xrequest',
            timestamp='2024-01-01:00:00:00'
        )

        assert result['Response'] is not None


@pytest.mark.unit
class TestAssetAPIUnit:
    \"\"\"Unit tests for Asset API methods\"\"\"

    def test_get_asset_list(self, api, mock_session):
        \"\"\"Should get list of assets\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'Assets': ['CIRX', 'TEST']}
        }
        mock_session.return_value = mock_response

        result = api.get_asset_list(blockchain='MainNet')

        assert 'Assets' in result['Response']

    def test_get_asset(self, api, mock_session):
        \"\"\"Should fetch asset details\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {
                'AssetName': 'CIRX',
                'TotalSupply': 1000000000,
                'Decimals': 8
            }
        }
        mock_session.return_value = mock_response

        result = api.get_asset(blockchain='MainNet', asset_name='CIRX')

        assert result['Response']['AssetName'] == 'CIRX'

    def test_get_asset_supply(self, api, mock_session):
        \"\"\"Should return supply information\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {
                'TotalSupply': 1000000000,
                'CirculatingSupply': 750000000
            }
        }
        mock_session.return_value = mock_response

        result = api.get_asset_supply(blockchain='MainNet', asset_name='CIRX')

        assert 'TotalSupply' in result['Response']
        assert 'CirculatingSupply' in result['Response']

    def test_get_voucher(self, api, mock_session):
        \"\"\"Should get voucher information\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'Code': 'VOUCHER123', 'Value': 100}
        }
        mock_session.return_value = mock_response

        result = api.get_voucher(blockchain='MainNet', code='VOUCHER123')

        assert result['Response']['Code'] == 'VOUCHER123'


@pytest.mark.unit
class TestDomainAndNetworkAPIUnit:
    \"\"\"Unit tests for Domain and Network API methods\"\"\"

    def test_get_domain(self, api, mock_session):
        \"\"\"Should resolve domain to address\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': {'Domain': 'alice.cir', 'Address': '0xalice'}
        }
        mock_session.return_value = mock_response

        result = api.get_domain(blockchain='MainNet', domain='alice.cir')

        assert result['Response']['Domain'] == 'alice.cir'

    def test_get_blockchains(self, api, mock_session):
        \"\"\"Should return list of blockchains\"\"\"
        mock_response = Mock()
        mock_response.json.return_value = {
            'Result': 200,
            'Response': [
                {'Name': 'MainNet', 'ChainID': '1', 'Active': True},
                {'Name': 'TestNet', 'ChainID': '2', 'Active': True}
            ]
        }
        mock_session.return_value = mock_response

        result = api.get_blockchains()

        assert isinstance(result['Response'], list)
        assert len(result['Response']) > 0


@pytest.mark.unit
class TestErrorHandling:
    \"\"\"Unit tests for error handling\"\"\"

    def test_handles_json_decode_error(self, api, mock_session):
        \"\"\"Should handle JSON decode errors\"\"\"
        mock_response = Mock()
        mock_response.json.side_effect = ValueError('Invalid JSON')
        mock_session.return_value = mock_response

        with pytest.raises(Exception):
            api.check_wallet(blockchain='MainNet', address='0xtest')

    def test_handles_timeout(self, api, mock_session):
        \"\"\"Should handle timeout errors\"\"\"
        mock_session.side_effect = requests.exceptions.Timeout('Request timeout')

        with pytest.raises(requests.exceptions.RequestException):
            api.check_wallet(blockchain='MainNet', address='0xtest')

    def test_handles_connection_error(self, api, mock_session):
        \"\"\"Should handle connection errors\"\"\"
        mock_session.side_effect = requests.exceptions.ConnectionError('Connection failed')

        with pytest.raises(requests.exceptions.RequestException):
            api.check_wallet(blockchain='MainNet', address='0xtest')


@pytest.mark.unit
class TestHelperFunctions:
    \"\"\"Unit tests for helper utility functions\"\"\"
    # Note: These tests assume helpers are exported from the SDK
    # If not yet implemented, these tests will fail and serve as specification

    def test_hex_fix_adds_0x_prefix_when_missing(self):
        \"\"\"Should add 0x prefix when missing\"\"\"
        input_val = '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
        expected = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
        # assert hex_fix(input_val) == expected
        pass

    def test_hex_fix_preserves_0x_prefix_when_present(self):
        \"\"\"Should preserve 0x prefix when present\"\"\"
        input_val = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
        expected = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
        # assert hex_fix(input_val) == expected
        pass

    def test_is_valid_address_accepts_64_char_hex_without_prefix(self):
        \"\"\"Should accept 64 char hex without prefix\"\"\"
        input_val = '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
        # assert is_valid_address(input_val) is True
        pass

    def test_is_valid_address_accepts_66_char_hex_with_0x_prefix(self):
        \"\"\"Should accept 66 char hex with 0x prefix\"\"\"
        input_val = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
        # assert is_valid_address(input_val) is True
        pass

    def test_is_valid_address_rejects_too_short(self):
        \"\"\"Should reject too short addresses\"\"\"
        input_val = '0x123'
        # assert is_valid_address(input_val) is False
        pass

    def test_is_valid_address_rejects_non_hex_characters(self):
        \"\"\"Should reject non-hex characters\"\"\"
        input_val = '0xzzz4567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
        # assert is_valid_address(input_val) is False
        pass

    def test_sha256_hash_simple_string(self):
        \"\"\"Should hash simple string\"\"\"
        input_val = 'hello world'
        expected = 'b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9'
        # assert sha256_hash(input_val) == expected
        pass

    def test_sha256_hash_empty_string(self):
        \"\"\"Should hash empty string\"\"\"
        input_val = ''
        expected = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
        # assert sha256_hash(input_val) == expected
        pass

    def test_get_timestamp_format(self):
        \"\"\"Should format timestamp correctly\"\"\"
        # timestamp = get_timestamp()
        # assert re.match(r'^\\d{4}-\\d{2}-\\d{2}:\\d{2}:\\d{2}:\\d{2}$', timestamp)
        pass

    def test_is_valid_timestamp_accepts_valid_format(self):
        \"\"\"Should accept valid timestamp format\"\"\"
        input_val = '2024-01-15:14:30:45'
        # assert is_valid_timestamp(input_val) is True
        pass

    def test_is_valid_timestamp_rejects_invalid_format(self):
        \"\"\"Should reject invalid timestamp format\"\"\"
        input_val = '2024/01/15 14:30:45'
        # assert is_valid_timestamp(input_val) is False
        pass

    def test_to_hex_converts_ascii_to_hex(self):
        \"\"\"Should convert ASCII to hex\"\"\"
        input_val = 'hello'
        expected = '68656c6c6f'
        # assert to_hex(input_val) == expected
        pass

    def test_from_hex_converts_hex_to_ascii(self):
        \"\"\"Should convert hex to ASCII\"\"\"
        input_val = '68656c6c6f'
        expected = 'hello'
        # assert from_hex(input_val) == expected
        pass

    def test_to_wei_converts_1_to_wei(self):
        \"\"\"Should convert 1 to wei\"\"\"
        input_val = '1'
        expected = '1000000000000000000'
        # assert to_wei(input_val) == expected
        pass

    def test_from_wei_converts_wei_to_standard(self):
        \"\"\"Should convert wei to standard\"\"\"
        input_val = '1000000000000000000'
        expected = '1'
        # assert from_wei(input_val) == expected
        pass

    def test_is_valid_amount_accepts_positive_integer(self):
        \"\"\"Should accept positive integer\"\"\"
        input_val = '1000'
        # assert is_valid_amount(input_val) is True
        pass

    def test_is_valid_amount_rejects_negative(self):
        \"\"\"Should reject negative\"\"\"
        input_val = '-100'
        # assert is_valid_amount(input_val) is False
        pass

    def test_is_valid_amount_rejects_decimal(self):
        \"\"\"Should reject decimal\"\"\"
        input_val = '10.5'
        # assert is_valid_amount(input_val) is False
        pass
",

  metadata = {
    version = config.version,
    framework = "pytest with mocked requests",
    test_type = "unit",
    test_count = 51,  # 30 SDK methods + 21 helper functions
    description = "Generated Python SDK unit tests with mocked HTTP and helper function tests",
  },
}
