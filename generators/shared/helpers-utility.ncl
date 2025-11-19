# Utility Helper Functions for SDKs
# Provides SDK version info and node configuration

let config = import "../../src/config.ncl" in

{
  # TypeScript implementation
  typescript = {

    # Get SDK version
    getVersion = m%"
  /**
   * Get the SDK version
   * @returns SDK version string
   */
  getVersion(): string {
    return '%{config.version}';
  }
"%,

    # Set node URL
    setNode = m%"
  /**
   * Set the primary node address for querying blockchain
   * @param address - Node address or URL
   */
  setNode(address: string): void {
    this.nagUrl = address;
  }
"%,

  },

  # Python implementation
  python = {

    getVersion = m%"
    def get_version(self) -> str:
        """
        Get the API version.

        Returns:
            str: API version string (e.g., '%{config.version}')
        """
        return '%{config.version}'
"%,

    setNode = m%"
    def set_node(self, address: str) -> None:
        """
        Set the primary node address for querying blockchain.

        Args:
            address: Node address or URL
        """
        self.base_url = address
"%,

  },

  # Java implementation
  java = {

    getVersion = m%"
    /**
     * Get the SDK version
     * @return SDK version string
     */
    public static String getVersion() {
        return "%{config.version}";
    }
"%,

    setNode = m%"
    /**
     * Set the primary node address for querying blockchain
     * @param address Node address or URL
     */
    public void setNode(String address) {
        this.nagUrl = address;
    }
"%,

  },

  # PHP implementation
  php = {

    getVersion = m%"
    /**
     * Get the SDK version
     *
     * @return string SDK version
     */
    public function getVersion(): string
    {
        return '%{config.version}';
    }
"%,

    setNode = m%"
    /**
     * Set the primary node address for querying blockchain
     *
     * @param string $address Node address or URL
     * @return void
     */
    public function setNode(string $address): void
    {
        $this->nagUrl = $address;
    }
"%,

  },

  # Go implementation
  go = {

    getVersion = m%"
// GetVersion returns the SDK version
func GetVersion() string {
	return "%{config.version}"
}
"%,

    setNode = m%"
// SetNode sets the primary node address for querying blockchain
func (c *Client) SetNode(address string) {
	c.nagURL = address
}
"%,

  },

  # Dart implementation
  dart = {

    getVersion = m%"
  /// Get the SDK version
  String getVersion() {
    return '%{config.version}';
  }
"%,

    setNode = m%"
  /// Set the primary node address for querying blockchain
  void setNode(String address) {
    nagUrl = address;
  }
"%,

  },

  # Rust implementation
  rust = {

    getVersion = m%"
    /// Get the SDK version
    pub fn get_version(&self) -> &str {
        "%{config.version}"
    }
"%,

    setNode = m%"
    /// Set the primary node address for querying blockchain
    pub fn set_node(&mut self, address: String) {
        self.nag_url = address;
    }
"%,

  },
}
