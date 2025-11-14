# Go GitHub Actions CI/CD Generator

let config = import "../../../src/config.ncl" in

{
  workflow_content = m%"name: Go SDK CI/CD

on:
  push:
    branches: [ main, development ]
  pull_request:
    branches: [ main, development ]

jobs:
  test:
    name: Test on Go ${{ matrix.go-version }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        go-version: ['1.19', '1.20', '1.21', '1.22']

    steps:
    - uses: actions/checkout@v4

    - name: Set up Go ${{ matrix.go-version }}
      uses: actions/setup-go@v5
      with:
        go-version: ${{ matrix.go-version }}

    - name: Download dependencies
      run: go mod download

    - name: Verify dependencies
      run: go mod verify

    - name: Build
      run: go build -v ./...

    - name: Run tests
      run: go test -v -race -coverprofile=coverage.out -covermode=atomic ./...

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v4
      with:
        files: ./coverage.out
        flags: unittests
        name: codecov-umbrella

  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Set up Go
      uses: actions/setup-go@v5
      with:
        go-version: '1.22'

    - name: golangci-lint
      uses: golangci/golangci-lint-action@v4
      with:
        version: latest

  e2e:
    name: E2E Tests
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/development' || github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v4

    - name: Set up Go
      uses: actions/setup-go@v5
      with:
        go-version: '1.22'

    - name: Run E2E tests
      env:
        CIRCULAR_TEST_ADDRESS: ${{ secrets.CIRCULAR_TEST_ADDRESS }}
        CIRCULAR_TEST_BLOCKCHAIN: ${{ secrets.CIRCULAR_TEST_BLOCKCHAIN }}
        CIRCULAR_NAG_URL: ${{ secrets.CIRCULAR_NAG_URL }}
        CIRCULAR_API_KEY: ${{ secrets.CIRCULAR_API_KEY }}
      run: |
        if [ -n "$CIRCULAR_TEST_ADDRESS" ]; then
          go test -v -tags=e2e ./...
        else
          echo "Skipping E2E tests - CIRCULAR_TEST_ADDRESS not set"
        fi
"%,
}
