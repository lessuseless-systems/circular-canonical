# Configuration Helper Functions for SDKs
# Based on circular-js reference implementation
# Provides NAG URL and API key configuration

{
  # TypeScript implementation of config helpers
  typescript = {

    # Private fields for configuration
    fields = m%"
  private nagURL: string = 'https://nag.circularlabs.io/NAG.php?cep=';
  private nagKey: string = '';
"%,

    # Set custom NAG URL
    setNAGURL = m%"
  /**
   * Set custom NAG endpoint URL
   * @param url - NAG endpoint URL
   */
  setNAGURL(url: string): void {
    this.nagURL = url;
  }
"%,

    # Get current NAG URL
    getNAGURL = m%"
  /**
   * Get current NAG endpoint URL
   * @returns Current NAG URL
   */
  getNAGURL(): string {
    return this.nagURL;
  }
"%,

    # Set NAG API key
    setNAGKey = m%"
  /**
   * Set NAG API key for authenticated requests
   * @param key - API key
   */
  setNAGKey(key: string): void {
    this.nagKey = key;
  }
"%,

    # Get current NAG API key
    getNAGKey = m%"
  /**
   * Get current NAG API key
   * @returns Current NAG key
   */
  getNAGKey(): string {
    return this.nagKey;
  }
"%,

    # Updated _makeRequest to use nagURL
    makeRequestUpdate = m%"
  /**
   * Make HTTP request to NAG endpoint
   * @param endpoint - Endpoint name (e.g., 'GetBlockchains')
   * @param data - Request payload
   * @returns Full API response with Result and Response fields
   */
  private async _makeRequest(endpoint: string, data: any = {}): Promise<{ Result: number; Response: any }> {
    const url = `${this.nagURL}Circular_${endpoint}_`;

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...this.headers,
    };

    // Add NAG key if set
    if (this.nagKey) {
      headers['X-NAG-Key'] = this.nagKey;
    }

    const response = await fetch(url, {
      method: 'POST',
      headers,
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.statusText}`);
    }

    const result = await response.json() as { Result: number; Response: any };

    // Return full response including non-200 Result codes
    // Let callers handle Result codes appropriately
    return result;
  }
"%,

  },

  # Python implementation of config helpers
  python = {

    # Private fields for configuration (in __init__)
    # NOTE: Indentation is added at insertion point in SDK generator
    fields = m%"
self._nag_url = 'https://nag.circularlabs.io/NAG.php?cep='
self._nag_key = ''
self._last_error = ''
"%,

    # Set custom NAG URL
    setNAGURL = m%"
    def set_nag_url(self, url: str) -> None:
        """
        Set custom NAG endpoint URL

        Args:
            url: NAG endpoint URL
        """
        self._nag_url = url
"%,

    # Get current NAG URL
    getNAGURL = m%"
    def get_nag_url(self) -> str:
        """
        Get current NAG endpoint URL

        Returns:
            Current NAG URL
        """
        return self._nag_url
"%,

    # Set NAG API key
    setNAGKey = m%"
    def set_nag_key(self, key: str) -> None:
        """
        Set NAG API key for authenticated requests

        Args:
            key: API key
        """
        self._nag_key = key
"%,

    # Get current NAG API key
    getNAGKey = m%"
    def get_nag_key(self) -> str:
        """
        Get current NAG API key

        Returns:
            Current NAG key
        """
        return self._nag_key
"%,

    # Updated _make_request to use nag_url
    makeRequestUpdate = m%"
    def _make_request(self, endpoint: str, data: dict = None) -> dict:
        """
        Make HTTP request to NAG endpoint

        Args:
            endpoint: Endpoint name (e.g., 'GetBlockchains')
            data: Request payload

        Returns:
            Full API response with Result and Response fields

        Raises:
            Exception: If API request fails
        """
        url = f'{self._nag_url}Circular_{endpoint}_'

        headers = {
            'Content-Type': 'application/json',
            **self.headers,
        }

        # Add NAG key if set
        if self._nag_key:
            headers['X-NAG-Key'] = self._nag_key

        response = requests.post(
            url,
            json=data or {},
            headers=headers
        )

        if not response.ok:
            raise Exception(f'API error: {response.status_code} {response.reason}')

        result = response.json()

        # Return full response including non-200 Result codes
        # Let callers handle Result codes appropriately
        return result
"%,

  },
}
