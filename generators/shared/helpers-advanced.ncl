# Advanced Helper Functions for SDKs
# Based on circular-js reference implementation
# Provides transaction polling and error handling

{
  # TypeScript implementation of advanced helpers
  typescript = {

    # Error tracking field
    errorField = m%"
  private lastError: string = '';
"%,

    # Get last error
    GetError = m%"
  /**
   * Get last error message
   * @returns Last error message
   */
  GetError(): string {
    return this.lastError;
  }
"%,

    # Handle error (internal)
    handleError = m%"
  /**
   * Handle error and store error message
   * @param error - Error object or string
   */
  private handleError(error: any): void {
    if (error instanceof Error) {
      this.lastError = error.message;
    } else if (typeof error === 'string') {
      this.lastError = error;
    } else {
      this.lastError = 'Unknown error';
    }
  }
"%,

    # Poll for transaction confirmation
    # TODO: Fix to match actual transaction response schema (uses BlockNumber not BlockID)
    getTransactionOutcome = m%"
  /**
   * Poll for transaction confirmation
   * NOTE: Currently disabled - needs schema update to match actual API response
   * @param blockchain - Blockchain network (e.g., 'MainNet', 'testnet')
   * @param txID - Transaction ID to monitor
   * @param start - Start block number for search
   * @param end - End block number for search
   * @param timeoutSec - Maximum time to wait in seconds (default: 120)
   * @param intervalSec - Polling interval in seconds (default: 5)
   * @returns Transaction response when confirmed
   * @throws Error if transaction fails or times out
   */
  async getTransactionOutcome(
    blockchain: string,
    txID: string,
    start: string,
    end: string,
    timeoutSec: number = 120,
    intervalSec: number = 5
  ): Promise<any> {
    const startTime = Date.now();
    const timeoutMs = timeoutSec * 1000;
    const intervalMs = intervalSec * 1000;

    while (true) {
      // Check if timeout exceeded
      const elapsed = Date.now() - startTime;
      if (elapsed >= timeoutMs) {
        const error = `Transaction ${txID} timed out after ${timeoutSec} seconds`;
        this.handleError(error);
        throw new Error(error);
      }

      try {
        // Check transaction status
        const tx = await this.getTransactionbyID({
          Blockchain: blockchain,
          ID: txID,
          Start: start,
          End: end,
          Version: '2.0.0-alpha.1',
        });

        // Check if transaction is confirmed (has BlockNumber)
        if (tx.Response && tx.Response.BlockNumber && tx.Response.BlockNumber > 0) {
          // Transaction confirmed
          return tx;
        }

        // Still pending, wait before next check
        await new Promise(resolve => setTimeout(resolve, intervalMs));

      } catch (error) {
        // If error is not just "pending", rethrow
        if (error instanceof Error && !error.message.includes('pending')) {
          this.handleError(error);
          throw error;
        }

        // Otherwise, wait and retry
        await new Promise(resolve => setTimeout(resolve, intervalMs));
      }
    }
  }
"%,

  },

  # Python implementation of advanced helpers
  python = {

    # Error tracking field
    errorField = m%"
        self._last_error = ''
"%,

    # Get last error
    GetError = m%"
    def get_error(self) -> str:
        """
        Get last error message

        Returns:
            Last error message
        """
        return self._last_error
"%,

    # Handle error (internal)
    handleError = m%"
    def _handle_error(self, error: Exception | str) -> None:
        """
        Handle error and store error message

        Args:
            error: Error object or string
        """
        if isinstance(error, Exception):
            self._last_error = str(error)
        elif isinstance(error, str):
            self._last_error = error
        else:
            self._last_error = 'Unknown error'
"%,

    # Poll for transaction confirmation
    # TODO: Fix to match actual transaction response schema
    getTransactionOutcome = m%"
    def get_transaction_outcome(
        self,
        blockchain: str,
        tx_id: str,
        start: str,
        end: str,
        timeout_sec: int = 120,
        interval_sec: int = 5
    ) -> dict:
        """
        Poll for transaction confirmation
        NOTE: Currently uses correct schema with BlockNumber

        Args:
            blockchain: Blockchain network (e.g., 'MainNet', 'testnet')
            tx_id: Transaction ID to monitor
            start: Start block number for search
            end: End block number for search
            timeout_sec: Maximum time to wait in seconds (default: 120)
            interval_sec: Polling interval in seconds (default: 5)

        Returns:
            Transaction response when confirmed

        Raises:
            Exception: If transaction fails or times out
        """
        import time

        start_time = time.time()

        while True:
            # Check if timeout exceeded
            elapsed = time.time() - start_time
            if elapsed >= timeout_sec:
                error = f'Transaction {tx_id} timed out after {timeout_sec} seconds'
                self._handle_error(error)
                raise Exception(error)

            try:
                # Check transaction status
                tx = self.get_transaction_by_id({
                    'Blockchain': blockchain,
                    'ID': tx_id,
                    'Start': start,
                    'End': end,
                    'Version': '2.0.0-alpha.1',
                })

                # Check if transaction is confirmed (has BlockNumber)
                if tx.get('Response') and tx['Response'].get('BlockNumber') and tx['Response']['BlockNumber'] > 0:
                    # Transaction confirmed
                    return tx

                # Still pending, wait before next check
                time.sleep(interval_sec)

            except Exception as error:
                # If error is not just "pending", rethrow
                if 'pending' not in str(error).lower():
                    self._handle_error(error)
                    raise error

                # Otherwise, wait and retry
                time.sleep(interval_sec)
"%,

  },
}
