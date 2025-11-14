# Go Module Manifest Generator (go.mod)
# Generates go.mod file for Circular Protocol Go SDK

let config = import "../../../src/config.ncl" in

{
  go_mod = m%"module github.com/circular-protocol/circular-go

go 1.19

require (
	// No external dependencies - uses standard library only
)
"%,

  go_sum = "",  # Empty go.sum initially
}
