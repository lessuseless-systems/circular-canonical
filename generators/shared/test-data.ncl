# Test Data Aggregator
# Collects test data from all endpoint test files for test generation
# TODO: Import actual endpoint test files when they are created

let config = import "../../src/config.ncl" in

# Placeholder test data structure
# TODO: Replace with actual imports when tests/endpoints/*.test.ncl files exist
{
  version = config.version,

  # Placeholder for endpoint tests
  # TODO: Import from tests/endpoints/
  endpoints = {
    # Wallet API (6 endpoints)
    # checkWallet = checkWallet_test,
    # getWallet = getWallet_test,
    # etc...
  },

  # Metadata
  total_endpoints = 24,
  categories = {
    wallet = 6,
    transaction = 6,
    block = 4,
    contract = 2,
    asset = 4,
    domain = 1,
    network = 1,
  },
}
