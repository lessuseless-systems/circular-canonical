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

  },
}
