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
    getTransactionOutcome = m%"
  /**
   * Poll for transaction confirmation
   * Recursively checks transaction status until confirmed or timeout
   * @param blockchain - Blockchain network (e.g., 'MainNet', 'testnet')
   * @param txID - Transaction ID to monitor
   * @param timeoutSec - Maximum time to wait in seconds (default: 120)
   * @param intervalSec - Polling interval in seconds (default: 5)
   * @returns Transaction response when confirmed
   * @throws Error if transaction fails or times out
   */
  async getTransactionOutcome(
    blockchain: string,
    txID: string,
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
          TxID: txID,
        });

        // Check if transaction is confirmed
        if (tx.BlockID && tx.BlockID !== '') {
          // Transaction confirmed
          return tx;
        }

        // Check if transaction failed
        if (tx.Status === 'failed' || tx.Status === 'rejected') {
          const error = `Transaction ${txID} failed: ${tx.Status}`;
          this.handleError(error);
          throw new Error(error);
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
    getTransactionOutcome = m%"
    def get_transaction_outcome(
        self,
        blockchain: str,
        tx_id: str,
        timeout_sec: int = 120,
        interval_sec: int = 5
    ) -> dict:
        """
        Poll for transaction confirmation
        Recursively checks transaction status until confirmed or timeout

        Args:
            blockchain: Blockchain network (e.g., 'MainNet', 'testnet')
            tx_id: Transaction ID to monitor
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
                    'TxID': tx_id,
                })

                # Check if transaction is confirmed
                if tx.get('BlockID') and tx['BlockID'] != '':
                    # Transaction confirmed
                    return tx

                # Check if transaction failed
                if tx.get('Status') in ['failed', 'rejected']:
                    error = f"Transaction {tx_id} failed: {tx.get('Status')}"
                    self._handle_error(error)
                    raise Exception(error)

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
