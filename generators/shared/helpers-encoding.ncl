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

  # Go implementation of encoding helpers
  go = {

    # Remove or add 0x prefix to normalize hex strings
    hexFix = m%"
// hexFix normalizes hex strings (removes 0x prefix if present)
// This is a package-level helper function
func hexFix(hexString string) string {
	if len(hexString) >= 2 && (hexString[:2] == "0x" || hexString[:2] == "0X") {
		return hexString[2:]
	}
	return hexString
}
"%,

    # Convert string to hex encoding
    stringToHex = m%"
// StringToHex converts string to hex encoding
func (c *Client) StringToHex(str string) string {
	return hex.EncodeToString([]byte(str))
}
"%,

    # Convert hex to string
    hexToString = m%"
// HexToString converts hex encoding to string
func (c *Client) HexToString(hexStr string) (string, error) {
	normalized := hexFix(hexStr)
	bytes, err := hex.DecodeString(normalized)
	if err != nil {
		return "", fmt.Errorf("invalid hex string: %w", err)
	}
	return string(bytes), nil
}
"%,

    # Pad number with leading zero if single digit
    padNumber = m%%"
// padNumber pads number with leading zero if single digit
// This is a package-level helper function
func padNumber(num int) string {
	if num < 10 {
		return fmt.Sprintf("0%d", num)
	}
	return fmt.Sprintf("%d", num)
}
"%%,

    # Get formatted timestamp for Circular Protocol
    getFormattedTimestamp = m%%"
// GetFormattedTimestamp returns current timestamp in Circular Protocol format
// Format: YYYY:MM:DD-hh:mm:ss (UTC)
func (c *Client) GetFormattedTimestamp() string {
	now := time.Now().UTC()
	return fmt.Sprintf("%d:%s:%s-%s:%s:%s",
		now.Year(),
		padNumber(int(now.Month())),
		padNumber(now.Day()),
		padNumber(now.Hour()),
		padNumber(now.Minute()),
		padNumber(now.Second()))
}
"%%,

  },

  # Java implementation of encoding helpers
  java = {

    # Remove or add 0x prefix to normalize hex strings
    hexFix = m%"
    /**
     * Normalize hex strings (remove 0x prefix if present)
     *
     * @param hexString Hex string with or without 0x prefix
     * @return Normalized hex string without 0x prefix
     */
    private String hexFix(String hexString) {
        if (hexString.startsWith("0x") || hexString.startsWith("0X")) {
            return hexString.substring(2);
        }
        return hexString;
    }
"%,

    # Convert string to hex encoding
    stringToHex = m%%"
    /**
     * Convert string to hex encoding
     *
     * @param str String to convert
     * @return Hex-encoded string
     * @throws UnsupportedEncodingException if UTF-8 encoding is not supported
     */
    public String stringToHex(String str) throws UnsupportedEncodingException {
        byte[] bytes = str.getBytes("UTF-8");
        StringBuilder hex = new StringBuilder();
        for (byte b : bytes) {
            hex.append(String.format("%02x", b));
        }
        return hex.toString();
    }
"%%,

    # Convert hex to string
    hexToString = m%"
    /**
     * Convert hex encoding to string
     *
     * @param hexString Hex-encoded string
     * @return Decoded string
     * @throws UnsupportedEncodingException if UTF-8 encoding is not supported
     */
    public String hexToString(String hexString) throws UnsupportedEncodingException {
        String normalized = hexFix(hexString);
        byte[] bytes = new byte[normalized.length() / 2];
        for (int i = 0; i < bytes.length; i++) {
            int index = i * 2;
            bytes[i] = (byte) Integer.parseInt(normalized.substring(index, index + 2), 16);
        }
        return new String(bytes, "UTF-8");
    }
"%,

    # Pad number with leading zero if single digit
    padNumber = m%"
    /**
     * Pad number with leading zero if single digit
     *
     * @param num Number to pad
     * @return Padded string
     */
    private String padNumber(int num) {
        return num < 10 ? "0" + num : String.valueOf(num);
    }
"%,

    # Get formatted timestamp for Circular Protocol
    getFormattedTimestamp = m%%"
    /**
     * Get current timestamp in Circular Protocol format
     * Format: YYYY:MM:DD-hh:mm:ss (UTC)
     *
     * @return Formatted timestamp string
     */
    public String getFormattedTimestamp() {
        java.time.ZonedDateTime now = java.time.ZonedDateTime.now(java.time.ZoneOffset.UTC);
        return String.format("%d:%s:%s-%s:%s:%s",
            now.getYear(),
            padNumber(now.getMonthValue()),
            padNumber(now.getDayOfMonth()),
            padNumber(now.getHour()),
            padNumber(now.getMinute()),
            padNumber(now.getSecond()));
    }
"%%,

  },

  # PHP implementation of encoding helpers
  php = {

    # Remove or add 0x prefix to normalize hex strings
    hexFix = m%"
    /**
     * Normalize hex strings (remove 0x prefix if present)
     *
     * @param string $hexString Hex string with or without 0x prefix
     * @return string Normalized hex string without 0x prefix
     */
    private function hexFix(string $hexString): string {
        if (str_starts_with($hexString, '0x') || str_starts_with($hexString, '0X')) {
            return substr($hexString, 2);
        }
        return $hexString;
    }
"%,

    # Convert string to hex encoding
    stringToHex = m%"
    /**
     * Convert string to hex encoding
     *
     * @param string $str String to convert
     * @return string Hex-encoded string
     */
    public function stringToHex(string $str): string {
        return bin2hex($str);
    }
"%,

    # Convert hex to string
    hexToString = m%"
    /**
     * Convert hex encoding to string
     *
     * @param string $hexString Hex-encoded string
     * @return string Decoded string
     */
    public function hexToString(string $hexString): string {
        $normalized = $this->hexFix($hexString);
        return hex2bin($normalized);
    }
"%,

    # Pad number with leading zero if single digit
    padNumber = m%"
    /**
     * Pad number with leading zero if single digit
     *
     * @param int $num Number to pad
     * @return string Padded string
     */
    private function padNumber(int $num): string {
        return str_pad((string)$num, 2, '0', STR_PAD_LEFT);
    }
"%,

    # Get formatted timestamp for Circular Protocol
    getFormattedTimestamp = m%%"
    /**
     * Get current timestamp in Circular Protocol format
     * Format: YYYY:MM:DD-hh:mm:ss (UTC)
     *
     * @return string Formatted timestamp string
     */
    public function getFormattedTimestamp(): string {
        $now = new \DateTime('now', new \DateTimeZone('UTC'));
        return sprintf('%d:%s:%s-%s:%s:%s',
            $now->format('Y'),
            $this->padNumber((int)$now->format('m')),
            $this->padNumber((int)$now->format('d')),
            $this->padNumber((int)$now->format('H')),
            $this->padNumber((int)$now->format('i')),
            $this->padNumber((int)$now->format('s')));
    }
"%%,

  },

  # Dart implementation of encoding helpers
  dart = {

    # Remove or add 0x prefix to normalize hex strings
    hexFix = m%"
  /// Normalize hex strings (remove 0x prefix if present)
  String _hexFix(String hexString) {
    if (hexString.startsWith('0x') || hexString.startsWith('0X')) {
      return hexString.substring(2);
    }
    return hexString;
  }
"%,

    # Convert string to hex encoding
    stringToHex = m%"
  /// Convert string to hex encoding
  String stringToHex(String str) {
    return str.codeUnits.map((c) => c.toRadixString(16).padLeft(2, '0')).join();
  }
"%,

    # Convert hex to string
    hexToString = m%"
  /// Convert hex encoding to string
  String hexToString(String hexString) {
    final normalized = _hexFix(hexString);
    final List<int> bytes = [];
    for (int i = 0; i < normalized.length; i += 2) {
      bytes.add(int.parse(normalized.substring(i, i + 2), radix: 16));
    }
    return String.fromCharCodes(bytes);
  }
"%,

    # Pad number with leading zero if single digit
    padNumber = m%"
  /// Pad number with leading zero if single digit
  String _padNumber(int num) {
    return num < 10 ? '0$num' : num.toString();
  }
"%,

    # Get formatted timestamp for Circular Protocol
    getFormattedTimestamp = m%"
  /// Get current timestamp in Circular Protocol format
  /// Format: YYYY:MM:DD-hh:mm:ss (UTC)
  String getFormattedTimestamp() {
    final now = DateTime.now().toUtc();
    return '${now.year}:${_padNumber(now.month)}:${_padNumber(now.day)}-${_padNumber(now.hour)}:${_padNumber(now.minute)}:${_padNumber(now.second)}';
  }
"%,

  },
}
