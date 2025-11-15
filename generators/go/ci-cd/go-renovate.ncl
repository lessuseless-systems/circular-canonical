# Go Renovate Configuration Generator
# Outputs renovate.json for Go SDK

let shared_config = import "../../shared/ci-cd/renovate-config.ncl" in

{
  renovate_json = shared_config.go_config,
}
