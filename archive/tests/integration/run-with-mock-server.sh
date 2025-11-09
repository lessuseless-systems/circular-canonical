#!/usr/bin/env bash
# Run integration tests with mock API server
# Starts server, runs tests, then stops server

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔵 Starting Mock API Server..."
cd "$PROJECT_ROOT"

# Start mock server in background
python3 tests/mock-server/server.py &
SERVER_PID=$!

# Wait for server to be ready
echo "   Waiting for server to start..."
sleep 2

# Check if server is running
if ! curl -s http://localhost:8080/getBlockchains -X POST -H "Content-Type: application/json" -d '{"Version":"2.0.0"}' > /dev/null; then
    echo "❌ Mock server failed to start"
    kill $SERVER_PID 2>/dev/null ||true
    exit 1
fi

echo "✅ Mock server running on http://localhost:8080"
echo ""

# Run integration tests
echo "🧪 Running Integration Tests..."
cd "$SCRIPT_DIR"
CIRCULAR_API_URL=http://localhost:8080 npm test

# Save test exit code
TEST_EXIT=$?

# Stop mock server
echo ""
echo "🛑 Stopping mock server..."
kill $SERVER_PID 2>/dev/null || true
wait $SERVER_PID 2>/dev/null || true

# Exit with test exit code
if [ $TEST_EXIT -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Some tests failed"
fi

exit $TEST_EXIT
