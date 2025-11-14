# TypeScript Renovate Configuration Generator
# Outputs renovate.json for TypeScript SDK

let shared_config = import "../../shared/ci-cd/renovate-config.ncl" in

{
  renovate_json = shared_config.typescript_config,
}
