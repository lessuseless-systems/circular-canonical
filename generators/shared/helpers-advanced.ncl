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

    # Error tracking field (now in helpers-config.ncl)
    errorField = "",

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

  # Java implementation of advanced helpers
  java = {

    # Error tracking field
    errorField = m%"
  private String lastError = "";
"%,

    # Get last error
    GetError = m%"
    /**
     * Get last error message
     * @return Last error message
     */
    public String getError() {
        return this.lastError;
    }
"%,

    # Handle error (internal)
    handleError = m%"
    /**
     * Handle error and store error message
     * @param error Error object or string
     */
    private void handleError(Exception error) {
        if (error != null) {
            this.lastError = error.getMessage() != null ? error.getMessage() : "Unknown error";
        } else {
            this.lastError = "Unknown error";
        }
    }

    private void handleError(String error) {
        this.lastError = error != null ? error : "Unknown error";
    }
"%,

    # Poll for transaction confirmation
    getTransactionOutcome = m%"
    /**
     * Poll for transaction confirmation
     *
     * @param blockchain Blockchain network (e.g., 'MainNet', 'testnet')
     * @param txID Transaction ID to monitor
     * @param start Start block number for search
     * @param end End block number for search
     * @param timeoutSec Maximum time to wait in seconds (default: 120)
     * @param intervalSec Polling interval in seconds (default: 5)
     * @return CompletableFuture<Map<String, Object>> Transaction response when confirmed
     * @throws Exception if transaction fails or times out
     */
    public CompletableFuture<Map<String, Object>> getTransactionOutcome(
        String blockchain,
        String txID,
        String start,
        String end,
        int timeoutSec,
        int intervalSec
    ) {
        return CompletableFuture.supplyAsync(() -> {
            long startTime = System.currentTimeMillis();
            long timeoutMs = timeoutSec * 1000L;
            long intervalMs = intervalSec * 1000L;

            while (true) {
                // Check if timeout exceeded
                long elapsed = System.currentTimeMillis() - startTime;
                if (elapsed >= timeoutMs) {
                    String error = String.format("Transaction %s timed out after %d seconds", txID, timeoutSec);
                    handleError(error);
                    throw new RuntimeException(error);
                }

                try {
                    // Build request
                    Map<String, Object> request = new HashMap<>();
                    request.put("Blockchain", blockchain);
                    request.put("ID", txID);
                    request.put("Start", start);
                    request.put("End", end);
                    request.put("Version", "2.0.0-alpha.1");

                    // Check transaction status
                    Map<String, Object> tx = getTransactionbyID(request).get();

                    // Check if transaction is confirmed (has BlockNumber)
                    if (tx.containsKey("Response")) {
                        @SuppressWarnings("unchecked")
                        Map<String, Object> response = (Map<String, Object>) tx.get("Response");
                        if (response.containsKey("BlockNumber") &&
                            response.get("BlockNumber") != null &&
                            (Integer) response.get("BlockNumber") > 0) {
                            // Transaction confirmed
                            return tx;
                        }
                    }

                    // Still pending, wait before next check
                    Thread.sleep(intervalMs);

                } catch (Exception error) {
                    // If error is not just "pending", rethrow
                    if (error.getMessage() == null || !error.getMessage().toLowerCase().contains("pending")) {
                        handleError(error);
                        throw new RuntimeException(error);
                    }

                    // Otherwise, wait and retry
                    try {
                        Thread.sleep(intervalMs);
                    } catch (InterruptedException ie) {
                        throw new RuntimeException(ie);
                    }
                }
            }
        });
    }

    // Overload with default timeout and interval
    public CompletableFuture<Map<String, Object>> getTransactionOutcome(
        String blockchain,
        String txID,
        String start,
        String end
    ) {
        return getTransactionOutcome(blockchain, txID, start, end, 120, 5);
    }
"%,

  },

  # PHP implementation of advanced helpers
  php = {

    # Error tracking field
    errorField = m%"
    /** @var string Last error message */
    private string $lastError = '';
"%,

    # Get last error
    GetError = m%"
    /**
     * Get last error message
     *
     * @return string Last error message
     */
    public function getError(): string {
        return $this->lastError;
    }
"%,

    # Handle error (internal)
    handleError = m%"
    /**
     * Handle error and store error message
     *
     * @param \Throwable|string $error Error object or string
     * @return void
     */
    private function handleError(\Throwable|string $error): void {
        if ($error instanceof \Throwable) {
            $this->lastError = $error->getMessage();
        } elseif (is_string($error)) {
            $this->lastError = $error;
        } else {
            $this->lastError = 'Unknown error';
        }
    }
"%,

    # Poll for transaction confirmation
    getTransactionOutcome = m%"
    /**
     * Poll for transaction confirmation
     *
     * @param string $blockchain Blockchain network (e.g., 'MainNet', 'testnet')
     * @param string $txID Transaction ID to monitor
     * @param string $start Start block number for search
     * @param string $end End block number for search
     * @param int $timeoutSec Maximum time to wait in seconds (default: 120)
     * @param int $intervalSec Polling interval in seconds (default: 5)
     * @return array Transaction response when confirmed
     * @throws CircularProtocolException if transaction fails or times out
     */
    public function getTransactionOutcome(
        string $blockchain,
        string $txID,
        string $start,
        string $end,
        int $timeoutSec = 120,
        int $intervalSec = 5
    ): array {
        $startTime = time();

        while (true) {
            // Check if timeout exceeded
            $elapsed = time() - $startTime;
            if ($elapsed >= $timeoutSec) {
                $error = "Transaction {$txID} timed out after {$timeoutSec} seconds";
                $this->handleError($error);
                throw new CircularProtocolException($error, 0, 'getTransactionOutcome');
            }

            try {
                // Check transaction status
                $tx = $this->getTransactionbyID([
                    'Blockchain' => $blockchain,
                    'ID' => $txID,
                    'Start' => $start,
                    'End' => $end,
                    'Version' => '2.0.0-alpha.1',
                ]);

                // Check if transaction is confirmed (has BlockNumber)
                if (isset($tx['Response']['BlockNumber']) && $tx['Response']['BlockNumber'] > 0) {
                    // Transaction confirmed
                    return $tx;
                }

                // Still pending, wait before next check
                sleep($intervalSec);

            } catch (CircularProtocolException $error) {
                // If error is not just "pending", rethrow
                if (stripos($error->getMessage(), 'pending') === false) {
                    $this->handleError($error);
                    throw $error;
                }

                // Otherwise, wait and retry
                sleep($intervalSec);
            }
        }
    }
"%,

  },

  # Go implementation of advanced helpers
  go = {

    # Error tracking field
    errorField = m%"
	lastError string
"%,

    # Get last error
    GetError = m%"
// GetError returns the last error message
func (c *Client) GetError() string {
	return c.lastError
}
"%,

    # Handle error (internal)
    handleError = m%"
// handleError stores error message for later retrieval
func (c *Client) handleError(err error) {
	if err != nil {
		c.lastError = err.Error()
	} else {
		c.lastError = "Unknown error"
	}
}
"%,

    # Poll for transaction confirmation
    getTransactionOutcome = m%%"
// GetTransactionOutcome polls for transaction confirmation
// blockchain: Blockchain network (e.g., 'MainNet', 'testnet')
// txID: Transaction ID to monitor
// start: Start block number for search
// end: End block number for search
// timeoutSec: Maximum time to wait in seconds (default: 120)
// intervalSec: Polling interval in seconds (default: 5)
// Returns: Transaction response when confirmed
func (c *Client) GetTransactionOutcome(
	ctx context.Context,
	blockchain string,
	txID string,
	start string,
	end string,
	timeoutSec int,
	intervalSec int,
) (map[string]interface{}, error) {
	if timeoutSec <= 0 {
		timeoutSec = 120
	}
	if intervalSec <= 0 {
		intervalSec = 5
	}

	startTime := time.Now()
	timeout := time.Duration(timeoutSec) * time.Second
	interval := time.Duration(intervalSec) * time.Second

	for {
		// Check if timeout exceeded
		elapsed := time.Since(startTime)
		if elapsed >= timeout {
			err := fmt.Errorf("transaction %s timed out after %d seconds", txID, timeoutSec)
			c.handleError(err)
			return nil, err
		}

		// Check transaction status
		request := map[string]interface{}{
			"Blockchain": blockchain,
			"ID":         txID,
			"Start":      start,
			"End":        end,
			"Version":    "2.0.0-alpha.1",
		}

		tx, err := c.GetTransactionbyID(ctx, request)
		if err != nil {
			// If error is not just "pending", return error
			if !strings.Contains(strings.ToLower(err.Error()), "pending") {
				c.handleError(err)
				return nil, err
			}

			// Otherwise, wait and retry
			time.Sleep(interval)
			continue
		}

		// Check if transaction is confirmed (has BlockNumber)
		if response, ok := tx["Response"].(map[string]interface{}); ok {
			if blockNum, ok := response["BlockNumber"].(float64); ok && blockNum > 0 {
				// Transaction confirmed
				return tx, nil
			}
		}

		// Still pending, wait before next check
		time.Sleep(interval)
	}
}
"%%,

  },

  # Dart implementation of advanced helpers
  dart = {

    # Error tracking field
    errorField = m%"
  String _lastError = '';
"%,

    # Get last error
    GetError = m%"
  /// Get last error message
  String getError() {
    return _lastError;
  }
"%,

    # Handle error (internal)
    handleError = m%"
  /// Handle error and store error message
  void _handleError(dynamic error) {
    if (error is Exception) {
      _lastError = error.toString();
    } else if (error is String) {
      _lastError = error;
    } else {
      _lastError = 'Unknown error';
    }
  }
"%,

    # Poll for transaction confirmation
    getTransactionOutcome = m%"
  /// Poll for transaction confirmation
  ///
  /// [blockchain] Blockchain network (e.g., 'MainNet', 'testnet')
  /// [txID] Transaction ID to monitor
  /// [start] Start block number for search
  /// [end] End block number for search
  /// [timeoutSec] Maximum time to wait in seconds (default: 120)
  /// [intervalSec] Polling interval in seconds (default: 5)
  ///
  /// Returns: Transaction response when confirmed
  /// Throws: Exception if transaction fails or times out
  Future<Map<String, dynamic>> getTransactionOutcome(
    String blockchain,
    String txID,
    String start,
    String end, {
    int timeoutSec = 120,
    int intervalSec = 5,
  }) async {
    final startTime = DateTime.now();
    final timeout = Duration(seconds: timeoutSec);
    final interval = Duration(seconds: intervalSec);

    while (true) {
      // Check if timeout exceeded
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed >= timeout) {
        final error = 'Transaction $txID timed out after $timeoutSec seconds';
        _handleError(error);
        throw Exception(error);
      }

      try {
        // Check transaction status
        final tx = await getTransactionbyID({
          'Blockchain': blockchain,
          'ID': txID,
          'Start': start,
          'End': end,
          'Version': '2.0.0-alpha.1',
        });

        // Check if transaction is confirmed (has BlockNumber)
        if (tx['Response'] != null &&
            tx['Response']['BlockNumber'] != null &&
            tx['Response']['BlockNumber'] > 0) {
          // Transaction confirmed
          return tx;
        }

        // Still pending, wait before next check
        await Future.delayed(interval);

      } catch (error) {
        // If error is not just "pending", rethrow
        if (!error.toString().toLowerCase().contains('pending')) {
          _handleError(error);
          rethrow;
        }

        // Otherwise, wait and retry
        await Future.delayed(interval);
      }
    }
  }
"%,

  },
}
