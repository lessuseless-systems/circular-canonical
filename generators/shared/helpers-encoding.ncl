# Encoding Helper Functions for SDKs
# Based on circular-js reference implementation
# Provides hex encoding/decoding, timestamp formatting

{
  # TypeScript implementation of encoding helpers
  typescript = {

    # Remove or add 0x prefix to normalize hex strings
    hexFix = m%"
  /**
   * Normalize hex strings (remove 0x prefix if present)
   * @param hexString - Hex string with or without 0x prefix
   * @returns Normalized hex string without 0x prefix
   */
  hexFix(hexString: string): string {
    if (hexString.startsWith('0x') || hexString.startsWith('0X')) {
      return hexString.slice(2);
    }
    return hexString;
  }
"%,

    # Convert string to hex encoding
    stringToHex = m%"
  /**
   * Convert string to hex encoding
   * @param str - String to convert
   * @returns Hex-encoded string
   */
  stringToHex(str: string): string {
    let hex = '';
    for (let i = 0; i < str.length; i++) {
      const charCode = str.charCodeAt(i);
      hex += charCode.toString(16).padStart(2, '0');
    }
    return hex;
  }
"%,

    # Convert hex to string
    hexToString = m%"
  /**
   * Convert hex encoding to string
   * @param hex - Hex-encoded string
   * @returns Decoded string
   */
  hexToString(hex: string): string {
    const normalized = this.hexFix(hex);
    let str = '';
    for (let i = 0; i < normalized.length; i += 2) {
      const charCode = parseInt(normalized.substr(i, 2), 16);
      str += String.fromCharCode(charCode);
    }
    return str;
  }
"%,

    # Pad number with leading zero if single digit
    padNumber = m%"
  /**
   * Pad number with leading zero if single digit
   * @param num - Number to pad
   * @returns Padded string
   */
  private padNumber(num: number): string {
    return num < 10 ? '0' + num : num.toString();
  }
"%,

    # Get formatted timestamp for Circular Protocol
    getFormattedTimestamp = m%"
  /**
   * Get current timestamp in Circular Protocol format
   * Format: YYYY:MM:DD-hh:mm:ss (UTC)
   * @returns Formatted timestamp string
   */
  getFormattedTimestamp(): string {
    const now = new Date();
    const year = now.getUTCFullYear();
    const month = this.padNumber(now.getUTCMonth() + 1);
    const day = this.padNumber(now.getUTCDate());
    const hours = this.padNumber(now.getUTCHours());
    const minutes = this.padNumber(now.getUTCMinutes());
    const seconds = this.padNumber(now.getUTCSeconds());

    return `${year}:${month}:${day}-${hours}:${minutes}:${seconds}`;
  }
"%,

    # Sign message with DER-encoded signature
    signMessage = m%"
  /**
   * Sign a message using secp256k1 with DER encoding
   * @param message - Message to sign (will be SHA256 hashed)
   * @param privateKey - Private key in hex format (with or without 0x prefix)
   * @returns DER-encoded signature as hex string
   */
  signMessage(message: string, privateKey: string): string {
    const elliptic = require('elliptic');
    const crypto = require('crypto');

    const EC = elliptic.ec;
    const ec = new EC('secp256k1');
    const key = ec.keyFromPrivate(this.hexFix(privateKey), 'hex');

    // Hash the message
    const msgHash = crypto.createHash('sha256').update(message).digest('hex');

    // Sign and return DER-encoded signature
    const signature = key.sign(msgHash).toDER('hex');
    return signature;
  }
"%,

    # Calculate transaction ID
    calculateTransactionId = m%"
  /**
   * Calculate transaction ID from components
   * @param blockchain - Blockchain ID (hex)
   * @param from - From address (hex)
   * @param to - To address (hex)
   * @param payload - Transaction payload (hex)
   * @param nonce - Wallet nonce (string)
   * @param timestamp - Formatted timestamp
   * @returns Transaction ID as hex string
   */
  calculateTransactionId(
    blockchain: string,
    from: string,
    to: string,
    payload: string,
    nonce: string,
    timestamp: string
  ): string {
    const crypto = require('crypto');

    const input =
      this.hexFix(blockchain) +
      this.hexFix(from) +
      this.hexFix(to) +
      this.hexFix(payload) +
      nonce +
      timestamp;

    return crypto.createHash('sha256').update(input).digest('hex');
  }
"%,

  },

  # Python implementation of encoding helpers
  python = {

    # Remove or add 0x prefix to normalize hex strings
    hexFix = m%"
    def hex_fix(self, hex_string: str) -> str:
        """
        Normalize hex strings (remove 0x prefix if present)

        Args:
            hex_string: Hex string with or without 0x prefix

        Returns:
            Normalized hex string without 0x prefix
        """
        if hex_string.startswith('0x') or hex_string.startswith('0X'):
            return hex_string[2:]
        return hex_string
"%,

    # Convert string to hex encoding
    stringToHex = m%"
    def string_to_hex(self, string: str) -> str:
        """
        Convert string to hex encoding

        Args:
            string: String to convert

        Returns:
            Hex-encoded string
        """
        return string.encode('utf-8').hex()
"%,

    # Convert hex to string
    hexToString = m%"
    def hex_to_string(self, hex_string: str) -> str:
        """
        Convert hex encoding to string

        Args:
            hex_string: Hex-encoded string

        Returns:
            Decoded string
        """
        normalized = self.hex_fix(hex_string)
        return bytes.fromhex(normalized).decode('utf-8')
"%,

    # Pad number with leading zero if single digit
    padNumber = m%"
    def _pad_number(self, num: int) -> str:
        """
        Pad number with leading zero if single digit

        Args:
            num: Number to pad

        Returns:
            Padded string
        """
        return f'{num:02d}'
"%,

    # Get formatted timestamp for Circular Protocol
    getFormattedTimestamp = m%"
    def get_formatted_timestamp(self) -> str:
        """
        Get current timestamp in Circular Protocol format
        Format: YYYY:MM:DD-hh:mm:ss (UTC)

        Returns:
            Formatted timestamp string
        """
        from datetime import datetime

        now = datetime.utcnow()
        year = now.year
        month = self._pad_number(now.month)
        day = self._pad_number(now.day)
        hours = self._pad_number(now.hour)
        minutes = self._pad_number(now.minute)
        seconds = self._pad_number(now.second)

        return f'{year}:{month}:{day}-{hours}:{minutes}:{seconds}'
"%,

    # Sign message with DER-encoded signature
    signMessage = m%"
    def sign_message(self, message: str, private_key: str) -> str:
        """
        Sign a message using secp256k1 with DER encoding

        Args:
            message: Message to sign (will be SHA256 hashed)
            private_key: Private key in hex format (with or without 0x prefix)

        Returns:
            DER-encoded signature as hex string
        """
        import hashlib
        from ecdsa import SigningKey, SECP256k1
        from ecdsa.util import sigencode_der

        # Remove 0x prefix if present
        clean_key = self.hex_fix(private_key)

        # Create signing key
        private_key_bytes = bytes.fromhex(clean_key)
        sk = SigningKey.from_string(private_key_bytes, curve=SECP256k1)

        # Hash the message
        message_hash = hashlib.sha256(message.encode()).digest()

        # Sign with DER encoding
        signature_bytes = sk.sign_digest(message_hash, sigencode=sigencode_der)
        return signature_bytes.hex()
"%,

    # Calculate transaction ID
    calculateTransactionId = m%"
    def calculate_transaction_id(
        self,
        blockchain: str,
        from_address: str,
        to_address: str,
        payload: str,
        nonce: str,
        timestamp: str
    ) -> str:
        """
        Calculate transaction ID from components

        Args:
            blockchain: Blockchain ID (hex)
            from_address: From address (hex)
            to_address: To address (hex)
            payload: Transaction payload (hex)
            nonce: Wallet nonce (string)
            timestamp: Formatted timestamp

        Returns:
            Transaction ID as hex string
        """
        import hashlib

        input_str = (
            self.hex_fix(blockchain) +
            self.hex_fix(from_address) +
            self.hex_fix(to_address) +
            self.hex_fix(payload) +
            nonce +
            timestamp
        )

        return hashlib.sha256(input_str.encode()).hexdigest()
"%,

  },
}
